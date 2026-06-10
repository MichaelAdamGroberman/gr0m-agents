<!-- Keep PRs small and reviewable — that's the whole point of the model. -->

## What & why
<!-- One paragraph. Link the spec or issue. -->

## Spec / issue
<!-- specs/<file>.md or #issue -->

## How to verify
<!-- Exact command(s) a reviewer can run. -->

## Checklist
- [ ] Small, single-purpose change
- [ ] `bash -n` + `shellcheck` pass on any changed scripts
- [ ] Configs still source cleanly (`team.conf`, `tiers.conf`, project confs)
- [ ] Docs updated if behavior changed
- [ ] No secrets committed
