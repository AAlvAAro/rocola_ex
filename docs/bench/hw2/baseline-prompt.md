Run 0 (no subagents). Paste this into a fresh session as one message:

Do ROC-001 from docs/roadmap.md yourself, in this conversation, without subagents:
1. Read the code it touches and write a TDD to docs/tdd/ROC-001.md (Summary, Current code, Design, Tests first, Files to touch, Out of scope, Risks).
2. Review it as a product owner (user value, scope, personal-use only) and append "## Product review" with a Decision.
3. Implement it test-first, make `mix precommit` pass, commit on this branch.
4. Review your own diff against CLAUDE.md checks C1-C5 and write docs/reviews/ROC-001.md; fix any comments (max 2 rounds) and commit.
5. Set the ticket to done in docs/roadmap.md and commit. Then give me a one-line summary per step.
