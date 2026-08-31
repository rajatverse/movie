# MovieTycoon — Build Progress

**Last updated:** 2026-08-31
**Current phase:** Phase 1 (MVP)
**Current step:** Step 4 of 8 — First playable slice: freelance loop UI

> How to use this file: after every verified step, check its box, fill in the
> commit hash, and add one line under "Verified Debug Checks" describing what
> you actually confirmed (not just "done"). Anyone opening this file — including
> a future AI session with no memory of this conversation — should be able to
> tell exactly what exists, what's verified, and what's next.

## Phase 1 — MVP Steps
- [x] **Step 1** — Project shell & folder structure — `commit: a4d39c0`
- [x] **Step 2** — Foundation autoloads: GameClock + Economy — `commit: a4d39c0`
- [x] **Step 3** — StaffData/ContractData resources + StaffManager/ContractManager — `commit: ee69ae6`
- [ ] **Step 4** — First playable slice: freelance loop UI — `commit: ______`
- [ ] **Step 5** — Studio Tower visual progression — `commit: ______`
- [ ] **Step 6** — Movie production wizard + Movie DNA — `commit: ______`
- [ ] **Step 7** — Release flow: distributors, Buzz, box office sim — `commit: ______`
- [ ] **Step 8** — Reputation, weekly news, loan/failure system — `commit: ______`

## Verified Debug Checks
(one line per step, added when you confirm the debug scene behaves as expected)

- Step 1 & 2: GameClock ticks and Economy balance updates verified via live debug scene buttons.
- Step 3: Staff hiring, contract assignment, skill growth curve calculation, and on-time/late contract payouts verified in debug_staff_contracts.tscn.

## Open Blockers / Questions
(anything currently stuck — pull from GDD Section 12 open questions as they come up)

- None

## Deviations from the GDD
(if you ever build something differently than the GDD/appendix specifies, log
it here with a one-line reason — keeps the GDD from silently going stale)

- Contract late delivery uses placeholder 90% payout (`payout * 0.9`) pending final GDD late-penalty curve implementation.
