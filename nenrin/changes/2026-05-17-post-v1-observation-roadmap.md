---
type: nenrin_change
id: post-v1-observation-roadmap
date: 2026-05-17
status: reviewed
impact: effective
related_files:
  - docs/roadmap.md
  - docs/current_status.md
  - docs/self_use.md
  - CHANGELOG.md
review_after:
  tasks: 3
  days: 7
---

# Change: post-v1-observation-roadmap

## Changed

- Reframed post-`v1.0` roadmap work as observation-led judgment gates instead
  of a feature expansion table.
- Set the post-v1 priority order to core bounded evidence, then thin agent
  integration, then platform expansion parking lot.
- Captured early post-v1 judgment gates for the observation ledger,
  representative examples, no-scan validity, Linux feasibility notes, and MCP
  gating without fixing Nenrin's public role too early.

## Reason

External planning discussion agreed that the current `v1.0` direction is sound,
but post-v1 work needs a stronger guard against drifting into broad platform,
integration, or ecosystem expansion. Habitat's advantage is not knowing more
things; it is reducing false confidence with short command-relevant evidence.

## Expected Behavior

- Future post-v1 planning starts from "more bounded evidence, less false
  confidence."
- Agents treat no-scan success and verified no-op as valid evidence when no
  command mistake follows.
- Nenrin, or any successor ledger, stays focused on judgment changes unless
  review cadence and observed value justify a larger role.

## Review After

- 3 related task(s)
- 7 day(s)

## Success Signals

- `v1.1` / `v1.2` work deepens observed command-decision patterns before adding
  new surfaces.
- MCP, Linux, GUI, command enforcement, and broad scanner expansion stay parked
  until measured blockers justify them.

## Failure Signals

- Post-v1 planning turns into a list of attractive integrations without
  command-decision evidence.
- Nenrin starts recording routine work again instead of judgment changes.

## Result

Reviewed on 2026-05-19: keep, but narrow to the thin observation spine. The
first post-v1 runs repeatedly ended as verified no-op or bounded stale-report
intake without creating product churn, which is the intended behavior. Keep
Nenrin visible enough to record command-decision judgments, but do not record
routine automation history or use backlog pressure as a Habitat work selector.

Follow-up on 2026-05-20: an external Habitat review again suggested promoting a
read-only MCP prototype and making observation-to-action criteria more explicit.
Keep MCP parked until repeated file/stdout consumption failures make it
command-changing, but clarify the roadmap gate for when observations become
docs-only corrections, policy/output changes, pruning, or broader integration
work.

Follow-up on 2026-05-20: an external Astro asset-cleanup walkthrough reported
that Habitat's Node runtime mismatch warning and `npm run build` hint changed
verification behavior in a real cleanup task. Keep that as positive `v1.1`
use-observation evidence. The same walkthrough suggested dead asset detection;
park it as cleanup intelligence until repeated traces show it changes command
safety, validation choice, or mutation boundaries.

Follow-up on 2026-05-21: a second external web cleanup walkthrough again
reported useful mutation guards, Node mismatch visibility, and `npm run build`
validation guidance during CSS pruning. Treat this as enough evidence to keep
the post-v1 automation loop active at low frequency. The walkthrough also asked
for automatic re-scan hooks and CSS/asset dead-code detection; keep both parked
unless repeated stale-report over-trust or cleanup-command mistakes show they
change Habitat's command-decision boundary.

Follow-up on 2026-05-24: development-loop and ledger README wording now match
the thin-spine decision. Create or update Nenrin records only when a slice
changes a later command decision, report-freshness judgment, generated guidance,
fixture/helper behavior, automation wording, or pruning judgment; routine docs
edits, verified no-ops, and already-covered observations can end without adding
ledger pressure.

Follow-up on 2026-05-26: self-use guidance now carries the same post-v1
thin-spine condition, so future Habitat docs or automation edits do not create
Nenrin records unless they change a command decision, freshness judgment,
generated guidance, fixture/helper behavior, automation wording, or pruning
review.

Follow-up on 2026-05-26: the cross-project observation example now names the
old `hazakura-ai-mobile` no-primary-package-manager report as historical and
treats the current `./scripts/assemble-debug.sh` wrapper guidance as
confirmation of the existing wrapper-script contract, not as a reason to expand
Gradle or Android coverage.

Follow-up on 2026-05-27: the `v1.0.x` observation-ledger roadmap now names the
current shape directly: keep Nenrin visible but sparse, narrowed to the thin
observation spine for post-v1 command-decision, freshness, generated-guidance,
fixture/helper, automation-wording, or pruning-review judgments. This removes
the remaining three-way wording that made the ledger role look unresolved after
the thin-spine review.
