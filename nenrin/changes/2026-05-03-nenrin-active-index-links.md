---
type: nenrin_change
id: nenrin-active-index-links
date: 2026-05-03
status: reviewed
impact: effective
related_files:
  - nenrin/index.md
  - nenrin/metrics.md
review_after:
  tasks: 3
  days: 7
---

# Change: nenrin-active-index-links

## Changed

- Added active change ids and record links to `nenrin/index.md`.
- Kept the summary counts, but made the index useful as a direct navigation artifact.

## Reason

The previous index said one change was observing, but did not name the change or point to the record. During self-use, that forced an extra repository search before the agent could decide whether the active change affected the task.

## Expected Behavior

- Agents open active Nenrin change records directly from `nenrin/index.md`.
- Agents avoid broad exploratory searches just to locate active change files.
- Follow-up observations can identify whether the active index changed the next command from search to direct file inspection.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- A later self-use task reads the active change from the index without using `rg` to discover it.
- The agent can decide whether to keep, remove, merge, narrow, or move a Nenrin change from the indexed record.
- `nenrin/metrics.md` remains aligned with the index summary.

## Failure Signals

- Agents still need repository-wide search to find active Nenrin records.
- The index grows into a duplicate of the full change records instead of a short navigation aid.
- Active changes are added without updating the index and metrics.

## Result

Kept. Later self-use runs used the active links directly and avoided repository-wide discovery searches just to find active Nenrin records.
