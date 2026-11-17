---
description: Add a ticket to docs/roadmap.md. Usage: /roadmap-add <P1|P2|P3> <title> -- <user story>
argument-hint: <P1|P2|P3> <title> -- <user story>
---
Add one row to the table in `docs/roadmap.md` from: $ARGUMENTS

- ID = the next `ROC-NNN` after the highest one in the table.
- Priority = the P1/P2/P3 given (default P2). Status = `open`.
- User story in the form "As a <role>, I <action>". If it isn't clear, ask one question before writing.
- If the feature is commercial or public-venue use (payments, tips, multi-venue, ads), stop: see CLAUDE.md "Scope".
- Change nothing else. Reply with the new row only.
