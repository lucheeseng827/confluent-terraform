provider "confluentcloud" {}

resource "confluentcloud_environment" "environment" {
  name = "default"
}

resource "confluentcloud_kafka_cluster" "test" {
  name             = "provider-test"
  service_provider = "aws"
  region           = "ap-southeast-1"
  availability     = "LOW"
  environment_id   = confluentcloud_environment.environment.id
}

resource "confluentcloud_schema_registry" "test" {
  environment_id   = confluentcloud_environment.environment.id
  service_provider = "aws"
  region           = "EU"

  # Requires at least one kafka cluster to enable 
  # schema registry in the environment.
  depends_on       = [confluentcloud_kafka_cluster.test]
}

resource "confluentcloud_api_key" "provider_test" {
  cluster_id     = confluentcloud_kafka_cluster.test.id
  environment_id = confluentcloud_environment.environment.id
}

resource "confluentcloud_service_account" "test" {
  name           = "test"
  description    = "service account test"
}

locals {
  bootstrap_servers = [replace(confluentcloud_kafka_cluster.test.bootstrap_servers, "SASL_SSL://", "")]
}

provider "kafka" {
  bootstrap_servers = local.bootstrap_servers

  tls_enabled    = true
  sasl_username  = confluentcloud_api_key.provider_test.key
  sasl_password  = confluentcloud_api_key.provider_test.secret
  sasl_mechanism = "plain"
}

resource "kafka_topic" "syslog" {
  name               = "syslog2"
  replication_factor = 3
  partitions         = 1
}

