#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: print_habitat_artifact.sh /path/to/habitat-scan /path/to/project artifact [expected-version]

Prints one generated Habitat artifact to stdout after verifying:
- habitat-scan --version matches scan_result.json generatorVersion
- scan_result.json reports the expected schemaVersion for this helper
- the requested artifact is present in generated metadata with the expected role,
  path, format, read order, read trigger, and agent-use hint
- optional expected-version matches both values

Artifact may be one of:
- scan-result or scan_result.json
- agent-context or agent_context.md
- command-policy or command_policy.md
- environment-report or environment_report.md

Filename forms may also be passed as ./filename.

This script does not create or update a habitat-report directory. Diagnostics
and verification failures are written to stderr so stdout remains the requested
artifact.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if [[ "$#" -lt 3 || "$#" -gt 4 ]]; then
  usage
  exit 2
fi

habitat_scan="$1"
project_path="$2"
requested_artifact="$3"
expected_version="${4:-}"
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

artifact_metadata="$(printf '%s' "$scan_json" \
  | REQUESTED_ARTIFACT="$requested_artifact" \
    EXPECTED_SCHEMA_VERSION="$expected_schema_version" \
    BINARY_VERSION="$binary_version" \
    EXPECTED_VERSION="$expected_version" \
    /usr/bin/env python3 -c '
import json
import os
import sys

requested = os.environ["REQUESTED_ARTIFACT"]
if requested.startswith("./"):
    requested = requested[2:]
expected_schema_version = os.environ["EXPECTED_SCHEMA_VERSION"]
binary_version = os.environ["BINARY_VERSION"]
expected_version = os.environ["EXPECTED_VERSION"]

artifact_map = {
    "scan-result": ("scan_result.json", "scan_result", "scan-result", None),
    "scan_result.json": ("scan_result.json", "scan_result", "scan_result.json", None),
    "agent-context": ("agent_context.md", "agent_context", "agent-context", {
        "readOrder": 1,
        "readTrigger": "before_any_project_command",
        "agentUse": "read_first",
    }),
    "agent_context.md": ("agent_context.md", "agent_context", "agent_context.md", {
        "readOrder": 1,
        "readTrigger": "before_any_project_command",
        "agentUse": "read_first",
    }),
    "command-policy": ("command_policy.md", "command_policy", "command-policy", {
        "readOrder": 2,
        "readTrigger": "before_risky_remote_mutating_secret_or_environment_sensitive_commands",
        "agentUse": "consult_before_risky_commands",
    }),
    "command_policy.md": ("command_policy.md", "command_policy", "command_policy.md", {
        "readOrder": 2,
        "readTrigger": "before_risky_remote_mutating_secret_or_environment_sensitive_commands",
        "agentUse": "consult_before_risky_commands",
    }),
    "environment-report": ("environment_report.md", "environment_report", "environment-report", {
        "readOrder": 3,
        "readTrigger": "only_for_diagnostics_or_audit",
        "agentUse": "debug_audit_only",
    }),
    "environment_report.md": ("environment_report.md", "environment_report", "environment_report.md", {
        "readOrder": 3,
        "readTrigger": "only_for_diagnostics_or_audit",
        "agentUse": "debug_audit_only",
    }),
}

if requested not in artifact_map:
    print(f"error: unsupported artifact {requested!r}", file=sys.stderr)
    sys.exit(2)

expected_name, expected_role, stdout_value, artifact_reading_contract = artifact_map[requested]
data = json.load(sys.stdin)
schema_version = data.get("schemaVersion", "")
generator_version = data.get("generatorVersion", "")
artifacts = data.get("artifacts", [])

if schema_version != expected_schema_version:
    print(f"error: scan_result.json schemaVersion {schema_version!r} does not match expected {expected_schema_version!r}", file=sys.stderr)
    sys.exit(3)

if not generator_version:
    print("error: scan_result.json did not include generatorVersion", file=sys.stderr)
    sys.exit(1)

if binary_version != generator_version:
    print(f"error: binary version {binary_version} does not match generatorVersion {generator_version}", file=sys.stderr)
    sys.exit(1)

if expected_version and binary_version != expected_version:
    print(f"error: version {binary_version} does not match expected version {expected_version}", file=sys.stderr)
    sys.exit(1)

if expected_name == "scan_result.json":
    print(stdout_value)
    print(expected_name)
    print(expected_role)
    sys.exit(0)

artifact_by_name = {
    artifact.get("name"): artifact
    for artifact in artifacts
    if isinstance(artifact, dict)
}
artifact = artifact_by_name.get(expected_name)
if not isinstance(artifact, dict):
    print(f"error: scan_result.json missing requested artifact metadata: {expected_name}", file=sys.stderr)
    sys.exit(3)

required_fields = {
    "role": expected_role,
    "relativePath": expected_name,
    "format": "markdown",
}
if artifact_reading_contract:
    required_fields.update(artifact_reading_contract)
errors = []
for field, expected in required_fields.items():
    actual = artifact.get(field)
    if actual != expected:
        errors.append(f"{expected_name}.{field} expected {expected!r} but found {actual!r}")

if errors:
    print("error: scan_result.json invalid requested artifact metadata: " + "; ".join(errors), file=sys.stderr)
    sys.exit(3)

print(stdout_value)
print(expected_name)
print(expected_role)
')"

stdout_value="$(printf '%s\n' "$artifact_metadata" | sed -n '1p')"
artifact_name="$(printf '%s\n' "$artifact_metadata" | sed -n '2p')"
artifact_role="$(printf '%s\n' "$artifact_metadata" | sed -n '3p')"

if [[ "$artifact_name" == "scan_result.json" ]]; then
  if [[ "$stdout_value" == "scan-result" ]]; then
    printf '%s\n' "$scan_json"
    exit 0
  fi

  scan_json_by_name="$("$habitat_scan" scan --project "$project_path" --stdout "$stdout_value")"
  printf '%s' "$scan_json_by_name" \
    | EXPECTED_SCHEMA_VERSION="$expected_schema_version" \
      EXPECTED_GENERATOR_VERSION="$binary_version" \
      /usr/bin/env python3 -c '
import json
import os
import sys

data = json.load(sys.stdin)
schema_version = data.get("schemaVersion", "")
generator_version = data.get("generatorVersion", "")
expected_schema_version = os.environ["EXPECTED_SCHEMA_VERSION"]
expected_generator_version = os.environ["EXPECTED_GENERATOR_VERSION"]

if schema_version != expected_schema_version:
    print(f"error: --stdout scan_result.json schemaVersion {schema_version!r} does not match expected {expected_schema_version!r}", file=sys.stderr)
    sys.exit(3)

if generator_version != expected_generator_version:
    print(f"error: --stdout scan_result.json generatorVersion {generator_version!r} does not match scan-result generatorVersion {expected_generator_version!r}", file=sys.stderr)
    sys.exit(4)
'
  printf '%s\n' "$scan_json_by_name"
  exit 0
fi

artifact_text="$("$habitat_scan" scan --project "$project_path" --stdout "$stdout_value")"

case "$artifact_role" in
  agent_context)
    expected_header="# Agent Context"
    ;;
  command_policy)
    expected_header="# Command Policy"
    ;;
  environment_report)
    expected_header="# Environment Report"
    ;;
  *)
    printf 'error: unsupported artifact role after metadata validation: %s\n' "$artifact_role" >&2
    exit 3
    ;;
esac

if [[ "$artifact_text" != "$expected_header"* ]]; then
  printf 'error: --stdout %s did not return %s\n' "$stdout_value" "$artifact_name" >&2
  exit 4
fi

printf '%s\n' "$artifact_text"
