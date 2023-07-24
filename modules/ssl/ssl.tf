resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

#resource "acme_registration" "reg" {
#  account_key_pem = tls_private_key.private_key.private_key_pem
#  email_address   = "wolfgang.huse@nutanix.com"
#}

resource "acme_certificate" "certificate" {
  #account_key_pem           = acme_registration.reg.account_key_pem
  account_key_pem = "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA3KcuXZvWhlYXiiVIppnP27iwZuuw17CapTO6yXilqAMfD+Xe\naNfwN3wkvGrynyH7xWuCoV5ah/7cSO91r1p1B2+VOzsp3TufWJQTUF6eHTWV920k\nvjuFlpd0aZfn1htQ64GOxPgonz3pbtWFcQTvKamajp9iop+IbazmGzL5IGI88fva\nJxnaMiAqhInr2Y42Gl6R8j8y6TsdSJDVQc5fewe3E1UfaP4J9V5cWIBUdMFE1GvH\nSL58CyQf5/XzYVVZIS22oRbI/yy9XCW4SzWOAp/u0GeY7emb+rYpSQr3INmMd7pO\nThmofRL8verLnuODHbJVNvNbKMCxGcJ+r/v2XwIDAQABAoIBAHgozpYJbFyBe5Yu\nUY7wSgJEZEPX69i5gq2eKwTWH5gMAxlcO67qkRUWFMdKkk9YaUwMDPolcLWIc5uA\nU50nbH2dJS45PMYOVusc0Bu/Oul7Keyw0gaKUWg9mBZ8s7Kj84AccIwQ+8YkJ//E\nZUOzxS3x/4nVgBhBOkFHm5OKQaKA+gENCkSnHOmGHPODwpyNCJNrmNreTt5wiN/q\nearNZWcNsMaKJVBJZOSiI29iuoWr62yUCCsuvKsOPangTjsBTtQNNwQiFy5avIYL\nLCy4lshmu9r4hMdqGrOdRvlklcVkMOnFOIjS2IEJc89byJwtu2Z1UACb+LVykNty\nbSu0SakCgYEA6sFaDxNSFZAP5FxjBPqqpHf6kjyc7eNxjeFBrFL+OpZduVFMJbyQ\n68aKddeh9d4J6TuA/39mDhtLm3rHlBFmSvYccdfqvS7/FfHMA+o4YQeu45r0ujQy\n8SMu1KMLhgv+cUyIKa4VFJf7fCHhQb8Dotnpy+LkG7We89ciXlrw6DUCgYEA8J8e\nXad20NvMq+qzx7rndoRQCphLeFcy6oUaiorIthoPTEBU/yLmHojBoyMjB+YyrTsG\ngZUBD/ptPR46L4QK2FTqNfa4aBz5Ue94d+dFTCILpZqv1fe0QaET9GNZRrP9q8c8\n8YuWEveBYqJz8boDNrEcPFyeAufsAOqo9YeNfsMCgYEA0PQ1k0GhSKwoWR2aza3J\nAggBMvVcwao3QxCDgj2FKOT6m58vZk+HtzXLvMSo1s5CiCV81u6xClFlZQlOaA9s\nu8CA5RxJRwdz6jaFX961PDi4hMNCnhMkXNryLjbKZRB79KEoeeEHxoLZSE5n0DuT\novrQTbixTbDFwUl2wAG2eRkCgYEAlHkqrJFj4FZwQXiOPGUY4+ma1h7JGtV7hnhh\nOzGNzcfgvqVHjTMEmby69yX8PKiPhpLQXe8Ke8iD1V2se5tXcctbxbaabSvLsAI6\n7ImZGfQ8CZCchUPWR1TUUk1nThhMI83JziXakZOFk844CuVDjGDW0mw32AUxfBNP\n9EkTRy8CgYBeYgkjLz3H/+unzPXAwOQ/wAeiI//Is43rKEyFcsbWIs5QX/TFVzAs\nrSgN+7P/EVHkd8B5H5CpOrp0JtlyaQoXfROb94hm1Rlcp1GJa1fyRKLEPC6ZkmLa\nnvHyT5prFwgg8knbNKrl47yW3c8ByrAn0bgCNW0y+f2eo17ZOxhrnw==\n-----END RSA PRIVATE KEY-----\n"
  common_name               = var.common_name
  subject_alternative_names = var.subject_alternative_names

  dns_challenge {
    provider = "cloudflare"
    config = {
      CF_DNS_API_TOKEN     = var.cloudflare_api_token
    }
  }
}





