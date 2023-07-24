output "private_key_pem" {
  description = "private_key_pem"
  value       = acme_certificate.certificate.private_key_pem
}

output "certificate_pem" {
  description = "certificate_pem"
  value       = acme_certificate.certificate.certificate_pem
}

output "issuer_pem" {
  description = "issuer_pem"
  value       = acme_certificate.certificate.issuer_pem
}