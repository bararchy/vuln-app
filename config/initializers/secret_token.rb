### APPSEC Vuln 1: Hardcoded secret
### APPSEC Vuln 11: Plaintext password storage (see User model - has_secure_password disabled)
VulnerableApp::Application.config.secret_token = '41befdfb8c234e77d2278668e03fd1de83c7bf4ca62c441b2a60192f7b2121df7c46b9370a83053c1db00416acdcf5bfc90da7b41eb03b2b6b8a7a3ec8465fa2'
