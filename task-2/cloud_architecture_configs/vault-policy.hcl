# Production HashiCorp Vault Access Policy for SaaS App
# This policy is mapped to the Kubernetes ServiceAccount token via Vault's K8s auth method.

# 1. Read static application secrets (API keys, 3rd-party tokens)
path "secret/data/production/saas-api/*" {
  capabilities = ["read"]
}

# 2. Request dynamic database credentials
# Generates temporary PostgreSQL credentials that expire and rotate automatically.
path "database/creds/saas-app-role" {
  capabilities = ["read"]
}

# 3. Allow renewing database credential lease times
path "sys/leases/renew" {
  capabilities = ["update"]
}

path "sys/leases/renew/database/creds/saas-app-role/*" {
  capabilities = ["update"]
}

# 4. Allow revoking own database credentials on shutdown
path "sys/leases/revoke/database/creds/saas-app-role/*" {
  capabilities = ["update"]
}

# 5. Transit engine access for application-layer encryption (PII encryption at rest)
# Microservices encrypt customer emails and phone numbers before writing to PostgreSQL.
path "transit/encrypt/saas-data-key" {
  capabilities = ["update"]
}

path "transit/decrypt/saas-data-key" {
  capabilities = ["update"]
}

# 6. Read-only health check endpoint for monitoring vault agent status
path "sys/health" {
  capabilities = ["read"]
}
