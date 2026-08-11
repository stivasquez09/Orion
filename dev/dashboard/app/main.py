import os
import json
import time
import threading

import boto3
from flask import Flask, render_template, jsonify, redirect, url_for

app = Flask(__name__)

# ---- Configuración vía variables de entorno (definidas en la Task Definition) ----
AGGREGATOR_NAME = os.environ.get("CONFIG_AGGREGATOR_NAME", "org-aggregator")
REGION = os.environ.get("AWS_REGION", "us-east-1")
REFRESH_SECONDS = int(os.environ.get("REFRESH_SECONDS", "600"))  # cada 10 min por defecto
WARNING_THRESHOLD = int(os.environ.get("WARNING_THRESHOLD_PCT", "70"))
CRITICAL_THRESHOLD = int(os.environ.get("CRITICAL_THRESHOLD_PCT", "85"))

config_client = boto3.client("config", region_name=REGION)

# Cache en memoria compartido entre requests (thread-safe con lock)
_cache = {"data": [], "last_updated": None, "error": None}
_lock = threading.Lock()
_refresh_lock = threading.Lock()  # evita refrescos manuales simultaneos

QUERY = """
SELECT
  accountId,
  awsRegion,
  configuration.vpcId,
  resourceId,
  configuration.cidrBlock,
  configuration.availableIpAddressCount
WHERE
  resourceType = 'AWS::EC2::Subnet'
ORDER BY
  configuration.vpcId ASC,
  configuration.availableIpAddressCount DESC
"""


def calculate_total_ips(cidr):
    """AWS reserva 5 IPs por subnet (network, VPC router, DNS, futuro uso, broadcast)."""
    try:
        mask = int(cidr.split("/")[1])
        return max((2 ** (32 - mask)) - 5, 0)
    except (IndexError, ValueError):
        return 0


def fetch_subnet_data():
    results = []
    next_token = None
    while True:
        kwargs = {"ConfigurationAggregatorName": AGGREGATOR_NAME, "Expression": QUERY}
        if next_token:
            kwargs["NextToken"] = next_token

        response = config_client.select_aggregate_resource_config(**kwargs)

        for item_str in response.get("Results", []):
            item = json.loads(item_str)
            configuration = item.get("configuration", {})
            cidr = configuration.get("cidrBlock", "")
            available = configuration.get("availableIpAddressCount", 0)
            total = calculate_total_ips(cidr)
            used_pct = round((1 - (available / total)) * 100, 1) if total else 0

            if used_pct >= CRITICAL_THRESHOLD:
                status = "critical"
            elif used_pct >= WARNING_THRESHOLD:
                status = "warning"
            else:
                status = "ok"

            results.append({
                "account_id": item.get("accountId"),
                "region": item.get("awsRegion"),
                "vpc_id": configuration.get("vpcId"),
                "subnet_id": item.get("resourceId"),
                "cidr": cidr,
                "available_ips": available,
                "total_ips": total,
                "used_pct": used_pct,
                "status": status,
            })

        next_token = response.get("NextToken")
        if not next_token:
            break

    # El orden ya viene de la query (agrupado por VPC, IPs disponibles
    # descendente dentro de cada VPC). Si prefieres ver primero las subnets
    # más críticas sin importar la VPC, descomenta la siguiente línea:
    # results.sort(key=lambda r: r["used_pct"], reverse=True)
    return results


def refresh_now():
    """Ejecuta un refresco inmediato del cache. La usa tanto el loop automatico
    como el boton de 'Actualizar ahora' en el dashboard."""
    try:
        data = fetch_subnet_data()
        with _lock:
            _cache["data"] = data
            _cache["last_updated"] = time.strftime("%Y-%m-%d %H:%M:%S UTC", time.gmtime())
            _cache["error"] = None
        return True
    except Exception as exc:  # noqa: BLE001
        with _lock:
            _cache["error"] = str(exc)
        print(f"[refresh_now] error consultando el aggregator: {exc}")
        return False


def refresh_loop():
    """Corre en background: refresca el cache cada REFRESH_SECONDS sin
    bloquear las requests entrantes."""
    while True:
        refresh_now()
        time.sleep(REFRESH_SECONDS)


threading.Thread(target=refresh_loop, daemon=True).start()


@app.route("/")
def dashboard():
    with _lock:
        data = list(_cache["data"])
        last_updated = _cache["last_updated"]
        error = _cache["error"]

    summary = {
        "total_subnets": len(data),
        "total_accounts": len({r["account_id"] for r in data}),
        "critical": sum(1 for r in data if r["status"] == "critical"),
        "warning": sum(1 for r in data if r["status"] == "warning"),
        "ok": sum(1 for r in data if r["status"] == "ok"),
    }

    # Vista por defecto: solo las subnets mas urgentes de toda la cuenta,
    # no las 1000+ filas completas. El detalle por cuenta se filtra en el
    # navegador contra /api/data (sin volver a golpear a AWS Config).
    top_risk = sorted(data, key=lambda r: r["used_pct"], reverse=True)[:8]

    accounts = sorted({(r["account_id"]) for r in data})

    return render_template(
        "dashboard.html",
        top_risk=top_risk,
        accounts=accounts,
        last_updated=last_updated,
        error=error,
        summary=summary,
    )


@app.route("/refresh", methods=["POST"])
def refresh():
    # Refresco manual bajo demanda, sin esperar al ciclo automatico de
    # REFRESH_SECONDS. Usa el mismo Task Role, solo que disparado por el
    # usuario en vez del hilo en background.
    with _refresh_lock:
        refresh_now()
    return redirect(url_for("dashboard"))


@app.route("/api/data")
def api_data():
    with _lock:
        return jsonify({
            "last_updated": _cache["last_updated"],
            "error": _cache["error"],
            "subnets": _cache["data"],
        })


@app.route("/health")
def health():
    # Usado por el health check del ALB / target group
    return {"status": "ok"}, 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)