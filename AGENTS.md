# MovieTycoon — Agent Instructions

These instructions apply automatically to every task in this project.
Read RULES.md and PROGRESS.md before starting any task if you haven't
already done so this session.

## Standing Rules

1. After completing any coding task, update PROGRESS.md automatically:
   - If the task corresponds to a Phase 1 step, note it as
     "implemented, pending manual verification" — do NOT check the step's
     box or mark it "verified" until the user explicitly confirms they
     manually tested it. Writing code is not verification.
   - Once the user confirms manual verification in a later message, THEN
     check the box, add the commit hash, and add one line under
     "Verified Debug Checks" describing what was confirmed.

2. Use the commit message format from RULES.md:
   [Phase<N>-Step<M>] <description> — <WIP|verified>

3. If any implementation deviates from the GDD or RULES.md, log it under
   "Deviations from the GDD" in PROGRESS.md immediately, with a one-line
   reason — don't let it go unrecorded even if it seems minor.

4. Whenever reporting file contents, search results, or tool-call output,
   always state the full absolute path alongside it, and confirm that
   path belongs to THIS project (/home/rajatpatel/Documents/Projects/Movie
   Tycoon), not a sibling project. Never report file content without
   confirming its source path first.

5. Follow all architecture rules in RULES.md (UI never touches game logic
   directly, one Game Clock, data in Resources not code, debug scene
   before real UI, two-layer FSM only) without needing to be reminded
   each time.
