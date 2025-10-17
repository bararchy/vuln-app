Vulnerabilities:

```
config/initializers/secret_token.rb:1:          ### APPSEC Vuln 1: Hardcoded secret
app/controllers/users_controller.rb:20:         ### APPSEC Vuln 2: Unscoped Find/Read IDOR
app/controllers/users_controller.rb:29:         ### APPSEC Vuln 3: Mass Assignment
app/controllers/sessions_controller.rb:4:       ### APPSEC Vuln 4: SQLi via parent class method with hash reassignment
app/controllers/posts_controller.rb:21:         ### APPSEC Vuln 5: *Maybe* Unscoped find IDOR?
app/controllers/posts_controller.rb:69:         ### APPSEC Vuln 6: sanitize_sql_array SQLi false positive (MEU-1468)
app/controllers/posts_controller.rb:65:         ### APPSEC Vuln 7: UnscopedFind Delete IDOR with parent class accessor and hash reassignment
app/controllers/application_controller.rb:15:   ### APPSEC Vuln 8: Cookie tampering ATO
app/views/posts/show.html.erb:6:                ### APPSEC Vuln 9: XSS via html_safe
app/controllers/posts_controller.rb:81:         ### APPSEC Vuln 10: SQLi via callee interpolation
config/initializers/secret_token.rb:2:          ### APPSEC Vuln 11: Plaintext password storage
```


Execution:
```
./run_scanners.sh
```

| Vuln ID | Vuln Example | Semgrep | Semgrep Pro | Corgea Blast | Brakeman 7.1.0 |
| -------- | -------- | ------- | ------- | ------- | ------- |
|1| Secret  | Detected | Detected | **Not** Detected (incorrectly marked as FP) | Detected |
|2| Read IDOR  | **Not** Detected* | **Not** Detected* | Partially Detected** | **Not** Detected |
|3| Mass Assignment  | **Not** Detected |  **Not** Detected | **Not** Detected | Detected |
|4| Complex SQLi  | **Not** Detected | **Not** Detected | Detected | Detected*** |
|5| UnscopedFind IDOR  | Detected | Detected | Detected | **Not** Detected |
|6| SQLi sanitize_sql_array FP (MEU-1468) | **Not** Detected | **Not** Detected | Detected | **Not** Detected |
|7| Delete IDOR  | **Not** Detected | **Not** Detected | Detected | **Not** Detected | <--
|8| Cookie Tampering  | Detected | Detected | Detected | **Not** Detected |
|9| XSS  | Detected | Detected | **Not** Detected | **Not** Detected |
|10| Callee Interpolated SQLi | **Not** Detected | **Not** Detected | Detected | **Not** Detected |
|11| Plaintext PW Storage | **Not** Detected | **Not** Detected | Detected | Detected |
|| Total Findings  | 11 | 11 | 17 | 4 |
|| Detection Rate  | 36% | 36% | 73% | 27% |
|| FP Rate  | TODO | TODO | TODO | TODO |

*Meraki Semgrep rule will detect this finding

**Reflects non-deterministic behavior. Noted examples were suppressed as false positives during some executions.

***String interpolation detected, user input is not a factor (this will lead to high number of false positives)

Honorable Mention:
- https://github.com/thesp0nge/dawnscanner failed to find _any_ vulnerabilities in this application.



