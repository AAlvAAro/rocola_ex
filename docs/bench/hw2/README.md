# HW2 benchmark: /ship workflow

Same ticket (ROC-001), same base commit, fresh session per run, one branch per run (keep all for week 3).

| Run | Branch | Setup | Prompt |
|---|---|---|---|
| 0 (optional) | hw2/run0-single | no subagents | `docs/bench/hw2/baseline-prompt.md` |
| 1 | hw2/run1-inherit | every agent `model: inherit` | `/ship ROC-001` |
| 2 | hw2/run2-model-per-agent | lever: product-reviewer + code-reviewer `haiku`, tech-lead + builder `sonnet` | `/ship ROC-001` |

After each run: `/usage` and `/tasks` screenshots, plus
`git log --oneline <base>..HEAD`, `mix precommit`, the review rounds and the C1-C5 line from docs/reviews/ROC-001.md.

| Metric | Run 0 | Run 1 | Run 2 |
|---|---|---|---|
| Total cost (/usage) | | | |
| Cache hit % | | | |
| Wall time | | | |
| Review rounds | | | |
| C1-C5 passed | | | |
| mix precommit | | | |
