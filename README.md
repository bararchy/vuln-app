# DVRA - Damn Vulnerable Ruby Application

A deliberately vulnerable Rails application designed for testing SAST (Static Application Security Testing) tools.

## 🚀 Quick Start

### Running with Docker Compose (Recommended)

1. **Build and start the application:**
   ```bash
   docker-compose up --build
   ```

2. **Access the application:**
   
   Open your browser to [http://localhost:3000](http://localhost:3000)

3. **Stop the application:**
   ```bash
   docker-compose down
   ```

### Running with Docker

1. **Build the Docker image:**
   ```bash
   docker build -t vuln-rails-app .
   ```

2. **Run the container:**
   ```bash
   docker run -p 3000:3000 -v $(pwd):/app vuln-rails-app
   ```

### Running Commands Inside the Container

```bash
# Run migrations
docker-compose exec web bundle exec rails db:migrate

# Open Rails console
docker-compose exec web bundle exec rails console

# Run tests
docker-compose exec web bundle exec rails test

# Run security scanners
docker-compose exec web ./run_scanners.sh

# Access bash shell
docker-compose exec web bash
```

## 🐛 Vulnerabilities

This application contains the following intentional security vulnerabilities:

| Location | Vulnerability |
|----------|---------------|
| `config/initializers/secret_token.rb:1` | **Vuln 1:** Hardcoded secret (Google API Key) |
| `app/controllers/users_controller.rb:20` | **Vuln 2:** Unscoped Find/Read IDOR |
| `app/controllers/users_controller.rb:29` | **Vuln 3:** Mass Assignment |
| `app/controllers/sessions_controller.rb:4` | **Vuln 4:** SQLi via parent class method with hash reassignment |
| `app/controllers/posts_controller.rb:21` | **Vuln 5:** *Maybe* Unscoped find IDOR? |
| `app/controllers/posts_controller.rb:69` | **Vuln 6:** sanitize_sql_array SQLi false positive (MEU-1468) |
| `app/controllers/posts_controller.rb:65` | **Vuln 7:** UnscopedFind Delete IDOR with parent class accessor and hash reassignment |
| `app/controllers/application_controller.rb:15` | **Vuln 8:** Cookie tampering ATO |
| `app/views/posts/show.html.erb:6` | **Vuln 9:** XSS via html_safe |
| `app/controllers/posts_controller.rb:81` | **Vuln 10:** SQLi via callee interpolation |
| `config/initializers/secret_token.rb:2` | **Vuln 11:** Plaintext password storage |
| `app/controllers/application_controller.rb:11` | **Vuln 12:** Information disclosure - `/config` endpoint exposes secrets |

## 🔍 Running Security Scans

Execute all security scanners:

```bash
./run_scanners.sh
```

## 🧪 Running Tests

Run the API endpoint tests:

```bash
./test_api_endpoints.sh
```

This will test all API endpoints including authentication, CRUD operations, and verify that the intentional vulnerabilities are present.

## 📊 SAST Tool Comparison

| Vuln ID | Vuln Example | Semgrep | Semgrep Pro | Corgea Blast | Brakeman 7.1.0 |
|---------|--------------|---------|-------------|--------------|----------------|
| 1 | Secret  | Detected | Detected | **Not** Detected (incorrectly marked as FP) | Detected |
| 2 | Read IDOR  | **Not** Detected* | **Not** Detected* | Partially Detected** | **Not** Detected |
| 3 | Mass Assignment  | **Not** Detected |  **Not** Detected | **Not** Detected | Detected |
| 4 | Complex SQLi  | **Not** Detected | **Not** Detected | Detected | Detected*** |
| 5 | UnscopedFind IDOR  | Detected | Detected | Detected | **Not** Detected |
| 6 | SQLi sanitize_sql_array FP (MEU-1468) | **Not** Detected | **Not** Detected | Detected | **Not** Detected |
| 7 | Delete IDOR  | **Not** Detected | **Not** Detected | Detected | **Not** Detected |
| 8 | Cookie Tampering  | Detected | Detected | Detected | **Not** Detected |
| 9 | XSS  | Detected | Detected | **Not** Detected | **Not** Detected |
| 10 | Callee Interpolated SQLi | **Not** Detected | **Not** Detected | Detected | **Not** Detected |
| 11 | Plaintext PW Storage | **Not** Detected | **Not** Detected | Detected | Detected |
| | **Total Findings**  | 11 | 11 | 17 | 4 |
| | **Detection Rate**  | 36% | 36% | 73% | 27% |
| | **FP Rate**  | TODO | TODO | TODO | TODO |

### Notes

\* Meraki Semgrep rule will detect this finding

\*\* Reflects non-deterministic behavior. Noted examples were suppressed as false positives during some executions.

\*\*\* String interpolation detected, user input is not a factor (this will lead to high number of false positives)

### Honorable Mention

- [dawnscanner](https://github.com/thesp0nge/dawnscanner) failed to find *any* vulnerabilities in this application.

## ⚠️ Warning

**This application is intentionally vulnerable. Do NOT deploy this in a production environment or expose it to the internet.**



