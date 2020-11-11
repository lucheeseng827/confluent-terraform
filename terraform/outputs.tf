output "kafka_url" {
  value = local.bootstrap_servers
}

output "key" {
  value     = confluentcloud_api_key.provider_test.key
  sensitive = true
}

output "secret" {
  value     = confluentcloud_api_key.provider_test.secret
  sensitive = true
}