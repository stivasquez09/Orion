
# ─────────────────────────────────────────────
# IAM ROLE — Remediación SSM
# ─────────────────────────────────────────────
resource "aws_iam_role" "remediation" {
  name = "config-remediation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = [
          "ssm.amazonaws.com",
          "config.amazonaws.com"
        ]
      }
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy" "remediation" {
  role = aws_iam_role.remediation.name
  name = "ebs-delete-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:DeleteVolume", "ec2:DescribeVolumes"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "ssm:StartAutomationExecution",
          "ssm:GetAutomationExecution"
        ]
        Resource = "*"
      }
    ]
  })
}

# ─────────────────────────────────────────────
# CONFORMANCE PACK
# ─────────────────────────────────────────────
resource "aws_config_conformance_pack" "ebs_unused" {
  name = "ebs-unused-volumes-pack"

  template_body = <<-EOT
    Resources:
      EbsVolumeUnusedRule:
        Type: AWS::Config::ConfigRule
        Properties:
          ConfigRuleName: ebs-volume-unused
          Description: Detecta volúmenes EBS en estado available (sin adjuntar)
          Source:
            Owner: AWS
            SourceIdentifier: EC2_VOLUME_INUSE_CHECK
          Scope:
            ComplianceResourceTypes:
              - AWS::EC2::Volume
      EbsVolumeRemediation:
        Type: AWS::Config::RemediationConfiguration
        DependsOn: EbsVolumeUnusedRule
        Properties:
          ConfigRuleName: ebs-volume-unused
          TargetType: SSM_DOCUMENT
          TargetId: AWS-DeleteEbsVolume
          TargetVersion: "1"
          Automatic: true
          MaximumAutomaticAttempts: 3
          RetryAttemptSeconds: 60
          ResourceType: AWS::EC2::Volume
          Parameters:
            VolumeId:
              ResourceValue:
                Value: RESOURCE_ID
            AutomationAssumeRole:
              StaticValue:
                Values:
                  - ${aws_iam_role.remediation.arn}
          ExecutionControls:
            SsmControls:
              ConcurrentExecutionRatePercentage: 25
              ErrorPercentage: 20
  EOT
}