#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: check_habitat_metadata.sh /path/to/habitat-scan /path/to/project [expected-version]

Checks that:
- habitat-scan --version reports the same version as scan_result.json generatorVersion
- scan_result.json includes the core generated Markdown artifact metadata
- --stdout agent-context and --stdout command-policy return the core Markdown artifacts
- optional expected-version matches both values

This script reads scan_result.json through --stdout scan-result and does not
create or update a habitat-report directory.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if [[ "$#" -lt 2 || "$#" -gt 3 ]]; then
  usage
  exit 2
fi

habitat_scan="$1"
project_path="$2"
expected_version="${3:-}"

if [[ ! -x "$habitat_scan" ]]; then
  printf 'error: habitat-scan binary is not executable: %s\n' "$habitat_scan" >&2
  exit 1
fi

version_output="$("$habitat_scan" --version)"
binary_version="${version_output##* }"

if [[ -z "$binary_version" || "$binary_version" == "$version_output" ]]; then
  printf 'error: could not parse habitat-scan --version output: %s\n' "$version_output" >&2
  exit 1
fi

scan_json="$("$habitat_scan" scan --project "$project_path" --stdout scan-result)"
agent_context="$("$habitat_scan" scan --project "$project_path" --stdout agent-context)"
command_policy="$("$habitat_scan" scan --project "$project_path" --stdout command-policy)"

if [[ "$agent_context" != \#\ Agent\ Context* ]]; then
  printf 'error: --stdout agent-context did not return agent_context.md\n' >&2
  exit 4
fi

if [[ "$command_policy" != \#\ Command\ Policy* ]]; then
  printf 'error: --stdout command-policy did not return command_policy.md\n' >&2
  exit 4
fi

generator_version="$(printf '%s' "$scan_json" | /usr/bin/env python3 -c '
import json
import sys

data = json.load(sys.stdin)
generator_version = data.get("generatorVersion", "")
artifacts = data.get("artifacts", [])
artifact_names = {artifact.get("name") for artifact in artifacts if isinstance(artifact, dict)}
required_artifacts = {"agent_context.md", "command_policy.md"}
missing_artifacts = sorted(required_artifacts - artifact_names)

if missing_artifacts:
    print("error: scan_result.json missing artifact metadata for " + ", ".join(missing_artifacts), file=sys.stderr)
    sys.exit(3)

print(generator_version)
')"

if [[ -z "$generator_version" ]]; then
  printf 'error: scan_result.json did not include generatorVersion\n' >&2
  exit 1
fi

if [[ "$binary_version" != "$generator_version" ]]; then
  printf 'error: binary version %s does not match generatorVersion %s\n' "$binary_version" "$generator_version" >&2
  exit 1
fi

if [[ -n "$expected_version" && "$binary_version" != "$expected_version" ]]; then
  printf 'error: version %s does not match expected version %s\n' "$binary_version" "$expected_version" >&2
  exit 1
fi

printf 'binaryVersion=%s\n' "$binary_version"
printf 'generatorVersion=%s\n' "$generator_version"
printf 'agentContext=ok\n'
printf 'commandPolicy=ok\n'
