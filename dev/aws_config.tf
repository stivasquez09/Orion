
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
        Effect = "Allow"
        Action = [
          "ssm:StartAutomationExecution",
          "ssm:GetAutomationExecution"
        ]
        Resource = "*"
      }
    ]
  })
}


# ─────────────────────────────────────────────
# S3 BUCKET
# ─────────────────────────────────────────────
resource "aws_s3_bucket" "config" {
  bucket        = "config-lab-snapshots-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "config" {
  bucket = aws_s3_bucket.config.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSConfigBucketPermissionsCheck"
        Effect    = "Allow"
        Principal = { Service = "config.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.config.arn
      },
      {
        Sid       = "AWSConfigBucketDelivery"
        Effect    = "Allow"
        Principal = { Service = "config.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.config.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      }
    ]
  })
}

# ─────────────────────────────────────────────
# IAM ROLE — Config Recorder
# ─────────────────────────────────────────────
resource "aws_iam_role" "config_recorder" {
  name = "config-recorder-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config_recorder" {
  role       = aws_iam_role.config_recorder.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# ─────────────────────────────────────────────
# RECORDER + DELIVERY CHANNEL
# ─────────────────────────────────────────────
resource "aws_config_configuration_recorder" "main" {
  name     = "config-lab-recorder"
  role_arn = aws_iam_role.config_recorder.arn

  recording_group {
    all_supported                 = false
    include_global_resource_types = false
    resource_types                = ["AWS::EC2::Volume"]
  }
}

resource "aws_config_delivery_channel" "main" {
  name           = "config-lab-channel"
  s3_bucket_name = aws_s3_bucket.config.bucket
  depends_on     = [aws_config_configuration_recorder.main]
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.main]
}



# ─────────────────────────────────────────────
# CONFORMANCE PACK
# ─────────────────────────────────────────────
resource "aws_config_conformance_pack" "ebs_unused" {
  name       = "ebs-unused-volumes-pack"
  depends_on = [aws_config_configuration_recorder_status.main]

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
          TargetId: AWSConfigRemediation-DeleteUnusedEBSVolume
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
