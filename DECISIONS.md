# MovieTycoon — Decisions Log

A running record of decisions and the reasoning behind them, so nobody
re-litigates a settled question or accidentally reverses it without knowing
why it was made. Add a new entry whenever a real decision is made — not
every discussion, just the ones that actually change scope, architecture, or
design.

---

**Engine: Godot 4.x**
Chosen over Unity because the developer has no coding background and the
game is built entirely via AI-assisted prompting. GDScript is simpler for AI
tools to generate correctly, and Godot's text-based `.tscn` scenes are
AI-editable, unlike Unity's editor-heavy workflow.

**Build method: solo, no-code, AI-assisted (Antigravity / Claude / ChatGPT)**
Drives most other decisions below — favor simple, debuggable architecture
over clever architecture; debug-scene-first verification before UI.

**Monetization: IAP-first**
Casting/hiring stays deterministic — no randomized/gacha purchase mechanics,
to avoid loot-box regulation issues in the EU and other regions.

**Currency: generic/fictional in-game currency**
Not tied to any real-world currency (not ₹, $, or €-branded), to keep the
game reading as globally neutral rather than regional, given the
global-audience goal.

**Core simulation formula: "Movie DNA" + "Buzz" + tiered Reputation**
Adopted from external design review over a vaguer "genre fit + cast quality"
blend. Movie DNA (Mass Appeal vs. Critical Appeal split) allows divergent
outcomes — a movie can be a box-office hit with weak reviews, or a critical
darling with soft box office — which was judged more interesting than a
single quality score.

**Freelance work stays permanently relevant**
Not phased out after the player unlocks their own studio — it's the
fallback income source if a movie underperforms, and payout scales with
reputation tier so it never goes stale.

**Failure state: bank loan or staff layoffs, not a hard game-over**
Loan = principal + weekly interest + installment schedule.

**Cut from scope (see GDD Section 7 for full reasoning)**
Full staff relationship/chemistry system, deep staff promotion trees,
simulated competitor release-date-clash system, investor/co-production
financing. All judged too heavy to build and debug solo without a coding
background. Revisit only if the game is live and doing well.

**Game Presentation & Art Style (Added 2026-09-01)**
Portrait Android layout with a stylized low-poly 3D art direction.

**World Structure (Added 2026-09-01)**
The primary screen is a persistent 2.5D isometric studio world. Menus and management panels are layered on top of or load from this 3D environment to avoid a pure text-based dashboard feel.

**Player Flow (Added 2026-09-01)**
Strict linear flow established: Launch -> Main Menu -> Studio Setup (Name, Founder, City) -> New Game Init -> Studio Intro -> Game World. The Game World serves as the main hub going forward.

**Architecture: two-layer FSM (enum + match), not Behavior Trees**
Behavior Trees suit autonomous NPC decision-making; nothing in this game
needs that, since the player drives every state transition. Plain FSMs are
simpler for AI tools to generate correctly and for a non-coder to debug.

**Portrait orientation + vertical isometric "studio tower"**
Chosen specifically to resolve the tension between isometric art (which
wants horizontal space) and portrait mode — the office grows vertically,
floor by floor, as it's upgraded (Tiny Tower-style), which both fits
portrait and gives a strong visual progress signal.
