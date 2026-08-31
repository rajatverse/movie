# MovieTycoon — Build Progress

**Last updated:** 2026-08-31
**Current phase:** Phase 1 (MVP)
**Current step:** Step 6 of 8 — Movie production wizard + Movie DNA (Verified)

> How to use this file: after every verified step, check its box, fill in the
> commit hash, and add one line under "Verified Debug Checks" describing what
> you actually confirmed (not just "done"). Anyone opening this file — including
> a future AI session with no memory of this conversation — should be able to
> tell exactly what exists, what's verified, and what's next.

## Phase 1 — MVP Steps
- [x] **Step 1** — Project shell & folder structure — `commit: a4d39c0`
- [x] **Step 2** — Foundation autoloads: GameClock + Economy — `commit: a4d39c0`
- [x] **Step 3** — StaffData/ContractData resources + StaffManager/ContractManager — `commit: ee69ae6`
- [x] **Step 4** — First playable slice: freelance loop UI — `commit: 237d0dc`
- [x] **Step 5** — Studio Tower visual progression — `commit: af1c641`
- [x] **Step 6** — Movie production wizard + Movie DNA — `commit: 9406ed5`
- [ ] **Step 7** — Release flow: distributors, Buzz, box office sim — `commit: ______`
- [ ] **Step 8** — Reputation, weekly news, loan/failure system — `commit: ______`

## Verified Debug Checks
(one line per step, added when automated test suite assertions pass headlessly)

- Step 1 & 2: game_clock_test.gd & economy_test.gd headlessly verified week increment, signal payload, currency addition, and insufficient-funds spend rejection (12 PASS).
- Step 3 & 4: staff_manager_test.gd & contract_manager_test.gd headlessly verified staff hiring, diminishing-returns skill growth formula, staff availability lock (is_busy), and on-time/late contract payouts (15 PASS). Total suite: 27 PASS, 0 FAIL.
- Step 5: office_manager_test.gd headlessly verified can_upgrade currency gating, upgrade_office floor/capacity increments, office_upgraded signal payload, and capacity refusal/resolution for hire_staff & assign_to_contract (23 PASS). Total suite: 50 PASS, 0 FAIL.
- Step 6: movie_manager_test.gd headlessly verified greenlight budget deduction, affordable/unaffordable/double-production gating (3 tests), all 9 DNA attrs in [0,100] for small+large inputs (18 PASS), and blockbuster-vs-darling mass/crit divergence >= 10 pts in both directions (4 PASS). Total suite: 84 PASS, 0 FAIL.

## Open Blockers / Questions
(anything currently stuck — pull from GDD Section 12 open questions as they come up)

- None

## Deviations from the GDD
(if you ever build something differently than the GDD/appendix specifies, log
it here with a one-line reason — keeps the GDD from silently going stale)

- Contract late delivery uses placeholder 90% payout (`payout * 0.9`) pending final GDD late-penalty curve implementation.
- Added staff availability lock (is_busy property) to prevent assigning one staff member to multiple contracts simultaneously.
- Office tier progression seeded in data/office/ (5 tiers, floor 1..5, staff cap 3..25, project cap 1..6, costs 2k..25k).
- **[STEP 6] Movie DNA formula is a Phase 1 placeholder (per GDD Section 12 open question):** acting=cast.size*15 (no real actor-quality system), direction=director_quality param (default 50, no real director system), story/music/visuals/pacing/originality all derived from budget/100 clamped [20,90]. No randomness applied yet. Requires a refinement pass before Phase 1 is GDD-complete: introduce actor/director quality objects, genre-based DNA weightings, and controlled randomness (±10% per GDD).
