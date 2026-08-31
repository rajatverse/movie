# MovieTycoon — Agent Instructions

These instructions apply automatically to every task in this project.
Read RULES.md and PROGRESS.md before starting any task if you haven't
already done so this session.

## Standing Rules

1. After completing any coding task, update PROGRESS.md automatically:
   - Write and run automated headless tests for the step in `/scripts/tests/`.
     Mark the step verified in `PROGRESS.md` once all tests pass, without waiting
     for user confirmation.
   - Check the box, add the commit hash, and add one line under "Verified Debug
     Checks" describing what automated test assertions passed.
   - Only flag for the user's manual playtest when a Phase Boundary is reached
     (e.g., end of Phase 1's full MVP loop).

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
