#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: check_habitat_metadata.sh /path/to/habitat-scan /path/to/project [expected-version]

Checks that:
- habitat-scan --version reports the same version as scan_result.json generatorVersion
- scan_result.json reports the expected schemaVersion for this helper
- scan_result.json includes the core generated Markdown artifact names, roles, paths, formats, read order, read triggers, agent-use hints, entry sections, and agent_context.md line budget
- --stdout agent-context, command-policy, and environment-report return the core Markdown artifacts
- --stdout filename aliases return the matching core Markdown artifacts and scan-result metadata
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
expected_schema_version="0.1"

if [[ ! -f "$habitat_scan" || ! -x "$habitat_scan" || -L "$habitat_scan" ]]; then
  printf 'error: habitat-scan binary is not a regular non-symlink executable file: %s\n' "$habitat_scan" >&2
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

metadata_values="$(printf '%s' "$scan_json" | EXPECTED_SCHEMA_VERSION="$expected_schema_version" /usr/bin/env python3 -c '
import json
import os
import sys

data = json.load(sys.stdin)
schema_version = data.get("schemaVersion", "")
generator_version = data.get("generatorVersion", "")
artifacts = data.get("artifacts", [])
expected_schema_version = os.environ["EXPECTED_SCHEMA_VERSION"]

if schema_version != expected_schema_version:
    print(f"error: scan_result.json schemaVersion {schema_version!r} does not match expected {expected_schema_version!r}", file=sys.stderr)
    sys.exit(3)

required_artifacts = {
    "agent_context.md": {
        "role": "agent_context",
        "relativePath": "agent_context.md",
        "format": "markdown",
        "readOrder": 1,
        "readTrigger": "before_any_project_command",
        "agentUse": "read_first",
        "entrySection": "Use",
        "lineLimit": 120,
        "withinLineLimit": True,
    },
    "command_policy.md": {
        "role": "command_policy",
        "relativePath": "command_policy.md",
        "format": "markdown",
        "readOrder": 2,
        "readTrigger": "before_risky_remote_mutating_secret_or_environment_sensitive_commands",
        "agentUse": "consult_before_risky_commands",
        "entrySection": "Review First",
    },
    "environment_report.md": {
        "role": "environment_report",
        "relativePath": "environment_report.md",
        "format": "markdown",
        "readOrder": 3,
        "readTrigger": "only_for_diagnostics_or_audit",
        "agentUse": "debug_audit_only",
        "entrySection": "Diagnostics",
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

print(schema_version)
print(generator_version)
')"

schema_version="$(printf '%s\n' "$metadata_values" | sed -n '1p')"
generator_version="$(printf '%s\n' "$metadata_values" | sed -n '2p')"

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

scan_json_by_name="$("$habitat_scan" scan --project "$project_path" --stdout scan_result.json)"
agent_context_by_name="$("$habitat_scan" scan --project "$project_path" --stdout agent_context.md)"
command_policy_by_name="$("$habitat_scan" scan --project "$project_path" --stdout command_policy.md)"
environment_report_by_name="$("$habitat_scan" scan --project "$project_path" --stdout environment_report.md)"

generator_version_by_name="$(SCAN_JSON="$scan_json" SCAN_JSON_BY_NAME="$scan_json_by_name" EXPECTED_SCHEMA_VERSION="$expected_schema_version" /usr/bin/env python3 -c '
import json
import os
import sys

data = json.loads(os.environ["SCAN_JSON_BY_NAME"])
schema_version = data.get("schemaVersion", "")
generator_version = data.get("generatorVersion", "")
expected_schema_version = os.environ["EXPECTED_SCHEMA_VERSION"]
if schema_version != expected_schema_version:
    print(f"error: --stdout scan_result.json schemaVersion {schema_version!r} does not match expected {expected_schema_version!r}", file=sys.stderr)
    sys.exit(3)

canonical = json.loads(os.environ["SCAN_JSON"])

fields = [
    "name",
    "role",
    "relativePath",
    "format",
    "readOrder",
    "readTrigger",
    "agentUse",
    "entrySection",
    "lineLimit",
    "withinLineLimit",
]

def core_artifact_metadata(scan):
    artifacts = scan.get("artifacts", [])
    return [
        {field: artifact.get(field) for field in fields if field in artifact}
        for artifact in artifacts
    ]

if core_artifact_metadata(data) != core_artifact_metadata(canonical):
    print("error: --stdout scan_result.json core artifact metadata did not match --stdout scan-result output", file=sys.stderr)
    sys.exit(4)

print(generator_version)
')"

if [[ "$generator_version_by_name" != "$generator_version" ]]; then
  printf 'error: --stdout scan_result.json generatorVersion %s does not match scan-result generatorVersion %s\n' "$generator_version_by_name" "$generator_version" >&2
  exit 4
fi

if [[ "$agent_context_by_name" != \#\ Agent\ Context* ]]; then
  printf 'error: --stdout agent_context.md did not return agent_context.md\n' >&2
  exit 4
fi

if [[ "$agent_context_by_name" != *$'\n## Use'* ]]; then
  printf 'error: --stdout agent_context.md did not include entry section Use\n' >&2
  exit 4
fi

if [[ "$command_policy_by_name" != \#\ Command\ Policy* ]]; then
  printf 'error: --stdout command_policy.md did not return command_policy.md\n' >&2
  exit 4
fi

if [[ "$command_policy_by_name" != *$'\n## Review First'* ]]; then
  printf 'error: --stdout command_policy.md did not include entry section Review First\n' >&2
  exit 4
fi

if [[ "$environment_report_by_name" != \#\ Environment\ Report* ]]; then
  printf 'error: --stdout environment_report.md did not return environment_report.md\n' >&2
  exit 4
fi

if [[ "$environment_report_by_name" != *$'\n## Diagnostics'* ]]; then
  printf 'error: --stdout environment_report.md did not include entry section Diagnostics\n' >&2
  exit 4
fi

printf 'binaryVersion=%s\n' "$binary_version"
printf 'schemaVersion=%s\n' "$schema_version"
printf 'generatorVersion=%s\n' "$generator_version"
printf 'agentContext=ok\n'
printf 'commandPolicy=ok\n'
printf 'environmentReport=ok\n'
