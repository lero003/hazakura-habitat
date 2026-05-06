# Change: package-manager-review-routing

Status: observing

## Intent

Keep selected package-manager Review First routing owned by `PolicyReasonCatalog` instead of leaving the scanner-facing map in the main catalog file.

## Expected Behavior Impact

When future package-manager command families change, agents and maintainers should update one catalog-owned routing boundary and preserve the same generated `reviewFirstCommandReasons`, `command_policy.md`, and `scan_result.json` behavior.

## Evidence To Watch

- Future package-manager additions update `PolicyReasonCatalog+PackageManagerReview.swift` instead of duplicating scanner or report-writer logic.
- Tests catch routing drift between selected package-manager review commands and family-specific command arrays.

## Review Trigger

Review after the next package-manager command-family addition or if a self-use run shows Review First entries diverging from the catalog-owned command families.
