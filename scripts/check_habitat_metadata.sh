#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: check_habitat_metadata.sh /path/to/habitat-scan /path/to/project [expected-version]

Checks that:
- habitat-scan --version reports the same version as scan_result.json generatorVersion
- scan_result.json includes the core generated Markdown artifact names, roles, paths, formats, read order, and agent-use hints
- --stdout agent-context, command-policy, and environment-report return the core Markdown artifacts
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
environment_report="$("$habitat_scan" scan --project "$project_path" --stdout environment-report)"

if [[ "$agent_context" != \#\ Agent\ Context* ]]; then
  printf 'error: --stdout agent-context did not return agent_context.md\n' >&2
  exit 4
fi

if [[ "$command_policy" != \#\ Command\ Policy* ]]; then
  printf 'error: --stdout command-policy did not return command_policy.md\n' >&2
  exit 4
fi

if [[ "$environment_report" != \#\ Environment\ Report* ]]; then
  printf 'error: --stdout environment-report did not return environment_report.md\n' >&2
  exit 4
fi

generator_version="$(printf '%s' "$scan_json" | /usr/bin/env python3 -c '
import json
import sys

data = json.load(sys.stdin)
generator_version = data.get("generatorVersion", "")
artifacts = data.get("artifacts", [])

required_artifacts = {
    "agent_context.md": {
        "role": "agent_context",
        "relativePath": "agent_context.md",
        "format": "markdown",
        "readOrder": 1,
        "agentUse": "read_first",
    },
    "command_policy.md": {
        "role": "command_policy",
        "relativePath": "command_policy.md",
        "format": "markdown",
        "readOrder": 2,
        "agentUse": "consult_before_risky_commands",
    },
    "environment_report.md": {
        "role": "environment_report",
        "relativePath": "environment_report.md",
        "format": "markdown",
        "readOrder": 3,
        "agentUse": "debug_audit_only",
    },
}

artifact_by_name = {
    artifact.get("name"): artifact
    for artifact in artifacts
    if isinstance(artifact, dict)
}

missing_artifacts = sorted(name for name in required_artifacts if name not in artifact_by_name)
metadata_errors = []
for name, required_fields in required_artifacts.items():
    artifact = artifact_by_name.get(name)
    if not isinstance(artifact, dict):
        continue
    for field, expected in required_fields.items():
        actual = artifact.get(field)
        if actual != expected:
            metadata_errors.append(f"{name}.{field} expected {expected!r} but found {actual!r}")

if missing_artifacts or metadata_errors:
    details = []
    if missing_artifacts:
        details.append("missing " + ", ".join(missing_artifacts))
    details.extend(metadata_errors)
    print("error: scan_result.json missing or invalid core artifact metadata: " + "; ".join(details), file=sys.stderr)
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
printf 'environmentReport=ok\n'
