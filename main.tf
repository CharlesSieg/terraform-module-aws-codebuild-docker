provider "aws" {
  alias = "tools"
}

data "aws_iam_role" "tools_codebuild_role" {
  name     = "codebuild-role"
  provider = aws.tools
}

resource "aws_codebuild_project" "main" {
  build_timeout = 5
  description   = "Builds a Docker image, uploads to ECR, and then deploys to service on ECS cluster."
  name          = "${var.environment}-${var.app_name}-docker-build"
  provider      = aws.tools
  service_role  = data.aws_iam_role.tools_codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0-1.13.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "CLUSTER_NAME"
      value = var.cluster_name
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.image_repo_name
    }

    environment_variable {
      name  = "SERVICE_NAME"
      value = var.service_name
    }

    environment_variable {
      name  = "TARGET_ACCOUNT_ID"
      value = var.target_account_id
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "codebuild"
      stream_name = "${var.environment}-${var.app_name}-docker-build"
    }

    /*s3_logs {
      location = "${var.logs_bucket_id}/codebuild/${var.app_name}-worker"
      status   = "ENABLED"
    }*/
  }

  source {
    git_clone_depth = 1
    location        = var.github_repo_url
    type            = "GITHUB"
  }

  tags = {
    Application = "${var.app_name}"
    Billing     = "${var.environment}-${var.app_name}"
    Environment = "${var.environment}"
    Name        = "${var.environment}-${var.app_name}-docker-build"
    Terraform   = "true"
  }
}

#
# Github to CodeBuild webhook for worker
#
resource "aws_codebuild_webhook" "ascloud" {
  project_name = aws_codebuild_project.main.name
  provider     = aws.tools

  filter_group {
    filter {
      pattern = "PUSH"
      type    = "EVENT"
    }

    filter {
      pattern = var.environment
      type    = "HEAD_REF"
    }
  }
}
