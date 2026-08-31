# MovieTycoon — Project Rules

These are non-negotiable rules for this codebase. They exist so the project
stays debuggable by someone without a coding background, and so anyone —
including a future AI session with no memory of prior conversations — can
pick up work correctly on first read. Read this file before writing any code.

## Architecture Rules (from GDD Section 13)
1. **UI never touches game logic directly.** UI scenes only listen to
   Autoload signals and call Autoload functions to *request* actions. Game
   rules (currency changes, skill growth, box office math) live only in
   `/autoloads/`. If you find game math inside a `.tscn`-attached script
   under `/ui/` or `/scenes/`, that's a rule violation — move it.
2. **One Game Clock.** All weekly-tick logic (salaries, screening runs, news
   rotation) subscribes to `GameClock.week_passed`. Never create a second
   independent timer for weekly logic.
3. **Data lives in Resources, not code.** New staff, contracts, distributors,
   or movies are added as `.tres` files under `/data/`, using the Resource
   classes in `/resources/`. Don't hardcode content values inside manager
   scripts.
4. **Debug scene before real UI.** Every new Autoload manager gets a
   throwaway debug scene with buttons + print statements, verified to work,
   *before* any real UI is built on top of it. Don't skip this step even
   when a change feels small.
5. **Two-layer FSM only — no Behavior Trees.** Macro state
   (`HUB/PRODUCTION/RELEASE/AWARDS`) and nested micro-states
   (`ProductionStage`, `ReleaseStage`) are plain `enum` + `match`. Don't
   introduce a different state-management pattern without updating this file
   and explaining why in Deviations (see PROGRESS.md).

## Process Rules
6. **One step, one commit.** Follow the 8-step Phase 1 build order in the
   GDD (Section 11 / step list). Don't start step N+1 until step N's debug
   scene has been manually verified and PROGRESS.md is updated.
7. **Commit message format:**
   `[Phase<N>-Step<M>] <short description> — <WIP|verified>`
   e.g. `[Phase1-Step2] GameClock + Economy foundation — verified`
8. **Update PROGRESS.md every commit** — check the step box, add the commit
   hash, and add one line to "Verified Debug Checks" describing what was
   actually confirmed to work (numbers, not vibes).
9. **Log any GDD deviation.** If a build session implements something
   differently than the GDD or this appendix specifies (a different formula
   constant, a renamed signal, a skipped feature), write one line in
   PROGRESS.md's "Deviations from the GDD" section immediately. The GDD is
   the source of truth for *design intent*; PROGRESS.md is the source of
   truth for *what was actually built*.
10. **No real-world names or currency.** Per GDD Section 9 — no real actor/
    movie/studio names anywhere in code, comments, or placeholder data, and
    currency stays generic (not ₹/$/€ specific), even in test/debug content.

## Formula Reference (don't redefine these ad hoc — pull from GDD 13.2)
- Staff skill growth: `skill += base_gain * (1 - skill/100) * trait_modifier`
- Freelance payout: `base_rate * difficulty * (1 + reputation_tier_index * 0.05)`
- Box office opening: see GDD 13.2 for full formula
- Reputation gain: `award_points + (revenue/budget - 1) * 8 - flop_penalty`

If a formula constant needs tuning during playtesting, update it in the GDD
appendix directly and note the change in PROGRESS.md — don't let the code and
the GDD drift apart silently.
