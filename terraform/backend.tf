# Partial backend — the bucket/key/region/lock-table are supplied at init time
# (see the Makefile `init` target / scripts/bootstrap.sh). Keeping them out of
# code lets the same root module serve dev/staging/prod with isolated state.
terraform {
  backend "s3" {}
}
