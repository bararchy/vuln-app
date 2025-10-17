#! /bin/bash


touch results/$(git rev-parse HEAD)

semgrep scan --exclude=results/ -o tmp.json --json
jq -r . tmp.json > results/semgrep/findings.json && rm tmp.json

semgrep scan --exclude=results/ -o tmp.json  --json --pro
jq -r . tmp.json > results/semgrep_pro/findings.json && rm tmp.json

corgea scan --out-file tmp.json --out-format json
jq -r . tmp.json > results/corgea/findings.json && rm tmp.json

brakeman -A -o tmp.json -f json
jq -r . tmp.json > results/brakeman/findings.json && rm tmp.json
