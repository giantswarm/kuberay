#!/usr/bin/env bash
# Fix the empty application.giantswarm.io/team label (regression in 1.2.0) and
# prepare the 1.2.1 release. Verified against the published chart's annotations.
#
#   bash fix-kuberay-1.2.1.sh
#
set -euo pipefail

REPO=/Users/fernando/Code/giantswarm/kuberay
cd "$REPO"

git checkout main && git pull --ff-only
git checkout -b fix-team-label

# 1. The regression. architect 10.x rewrites Chart.yaml annotations and keeps
#    only io.giantswarm.* and artifacthub.io/*, so the published 1.2.0 chart no
#    longer carries "application.giantswarm.io/team" and every rendered object
#    got team="". Index the annotation that survives instead; Chart.yaml keeps
#    both keys, so a local render is unaffected.
python3 - helm/kuberay/templates/_helpers.tpl <<'PY'
import sys
p = sys.argv[1]; s = open(p).read()
old = 'application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}'
new = 'application.giantswarm.io/team: {{ index .Chart.Annotations "io.giantswarm.application.team" | quote }}'
assert s.count(old) == 1
open(p, 'w').write(s.replace(old, new))
PY

# 2. CHANGELOG.
python3 - CHANGELOG.md <<'PY'
import sys
p = sys.argv[1]; s = open(p).read()
old = "## [Unreleased]\n\n## [1.2.0] - 2026-10-02\n"
new = """## [Unreleased]

### Fixed

- The `application.giantswarm.io/team` label rendered empty on every object in 1.2.0. The `architect` orb bump to 10.x rewrites `Chart.yaml` annotations and keeps only the `io.giantswarm.*` and `artifacthub.io/*` keys, so the annotation the label template read was no longer in the published chart. It now reads `io.giantswarm.application.team`.
- Regenerated the devctl workflows. `zz_generated.create_release.yaml` still matched the legacy `Release vX.Y.Z` commit subject, while release PRs are titled `chore(release): vX.Y.Z`, so merging a release PR created no tag and no release.

## [1.2.0] - 2026-10-02
"""
assert s.count(old) == 1
open(p, 'w').write(s.replace(old, new))
PY

# 3. Verify the chart before staging.
helm lint helm/kuberay
helm template kuberay-operator helm/kuberay --kube-version 1.35.0 >/dev/null
n=$(helm template kuberay-operator helm/kuberay | grep -c 'application.giantswarm.io/team: "planeteers"')
echo "objects carrying the team label: $n   (expected 13)"

git add -A
git status --short
echo
echo "Next: run 'devctl gen workflows' (step 4 in the notes), then commit:"
echo "  git commit -s -m 'fix: render the GS team label from the annotation architect preserves'"
