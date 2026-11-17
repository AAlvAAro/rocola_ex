# Shared scaffold helpers for the code-reviewer cases. Not a case (no prompt.md).
# Source it from a case's fixture.sh:  source "$case_dir/../_lib/roc002.sh"
set -euo pipefail

# Clone Rocola at tag hw3-roc002-ref (ROC-002 shipped, review round 2 APPROVED)
# into the current (empty) run workspace.
roc002_setup() {
  local repo
  repo="$(git -C "$case_dir" rev-parse --show-toplevel)"
  git -C "$repo" rev-parse -q --verify "refs/tags/hw3-roc002-ref" >/dev/null || {
    echo "tag hw3-roc002-ref not found in $repo" >&2
    exit 1
  }
  git clone -q --no-checkout "$repo" .
  git checkout -q -B roc-002 hw3-roc002-ref
  git remote remove origin
  git config user.name "Rocola Eval"
  git config user.email "eval@example.invalid"
}

# replace_once FILE OLD NEW: replace the single exact occurrence of OLD with NEW.
# Fails if OLD occurs zero or several times, so a drifted fixture breaks loudly.
replace_once() {
  python3 -I - "$1" "$2" "$3" <<'PY'
import sys
path, old, new = sys.argv[1:4]
src = open(path).read()
n = src.count(old)
if n != 1:
    sys.exit(f"replace_once: expected 1 match in {path}, found {n}:\n{old}")
open(path, "w").write(src.replace(old, new))
PY
}

# commit MSG: stage everything and commit it as the one new change to review.
commit() {
  git add -A
  git commit -q -m "$1"
}

# Design-review workspace: Rocola before ROC-002 was built (tag hw3-eval-base),
# plus docs/tdd/ROC-002.md from hw3-roc002-ref with its "## Product review"
# section removed, so the reviewer can't copy the old verdict.
roc002_design_setup() {
  local repo
  repo="$(git -C "$case_dir" rev-parse --show-toplevel)"
  for t in hw3-eval-base hw3-roc002-ref; do
    git -C "$repo" rev-parse -q --verify "refs/tags/$t" >/dev/null || {
      echo "tag $t not found in $repo" >&2
      exit 1
    }
  done
  git clone -q --no-checkout "$repo" .
  git checkout -q -B roc-002-design hw3-eval-base
  git remote remove origin
  git config user.name "Rocola Eval"
  git config user.email "eval@example.invalid"
  mkdir -p docs/tdd
  git show "hw3-roc002-ref:docs/tdd/ROC-002.md" > docs/tdd/ROC-002.md
  python3 -I - docs/tdd/ROC-002.md <<'PY'
import sys
path = sys.argv[1]
src = open(path).read()
head, sep, _ = src.partition("\n## Product review")
if not sep:
    sys.exit("roc002_design_setup: no '## Product review' section to strip")
open(path, "w").write(head.rstrip("\n") + "\n")
PY
}

# /ship workspace: Rocola at tag hw3-eval-base on branch BRANCH (e.g. main).
ship_setup() {
  local branch="$1" repo
  repo="$(git -C "$case_dir" rev-parse --show-toplevel)"
  git -C "$repo" rev-parse -q --verify "refs/tags/hw3-eval-base" >/dev/null || {
    echo "tag hw3-eval-base not found in $repo" >&2
    exit 1
  }
  git clone -q --no-checkout "$repo" .
  git checkout -q -B "$branch" hw3-eval-base
  # Drop every other local branch so `main` exists only when the case wants it.
  git for-each-ref --format='%(refname:short)' refs/heads | grep -vxF "$branch" | xargs -r git branch -q -D
  git remote remove origin
  git config user.name "Rocola Eval"
  git config user.email "eval@example.invalid"
}

# git can't run inside the eval sandbox on macOS (Apple's /usr/bin/git shim
# can't write its xcrun cache), so the reviewer can't run `git diff`. Save what
# it would have seen into .review/ (untracked, git-excluded) before the run.
write_review_inputs() {
  local base=5825a7b62d0546374be80a3d355cbe4320ed6637
  mkdir -p .review
  echo ".review/" >> .git/info/exclude
  git log --oneline "$base"..HEAD > .review/log.txt
  git diff "$base"..HEAD > .review/diff-base-to-head.patch
  git show --format='commit %H%nAuthor: %an%nDate: %ad%n%n    %s%n' HEAD > .review/new-commit.patch
}
