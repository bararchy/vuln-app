### APPSEC Vuln 1: Hardcoded secret (Google API Key)
### APPSEC Vuln 11: Plaintext password storage (see User model - has_secure_password disabled)
VulnerableApp::Application.config.secret_token = 'AIzaSyD2wIxpYCuNI0Zjt8kChs2hLTS5abVQfRQ'
