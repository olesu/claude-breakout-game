# Breakout Game - User Story Map

## Project Vision

**Core Elements**:

- Nostalgia-driven (Commodore 64 breakout inspiration)
- Modern visual aesthetic and sound design
- Mobile-first: iOS platform (Swift/SpriteKit)
- Single-player gameplay
- Success metric: App Store release + 1,000 downloads

**MVP Scope**:

- Single level defined in data
- Touch controls for paddle
- Ball attached to paddle, launches on tap
- Modern look and sound (sound always on)

**Launch Version (v1.0)**:

- Multiple levels with variety
- Reasonable difficulty curve
- Power-ups system
- Possibly accelerometer/tilt controls
- Sound toggle setting

---

## Story Map Structure

### Backbone (User Activities - Player Journey)

1. **Start Experience** → 2. **Play Level** → 3. **Progress** → 4. **Complete/Fail**

---

### Stories by Activity

Organized vertically: Top = Essential/MVP, Bottom = Nice-to-have/v1.0+

#### 1. START EXPERIENCE

- Show splash screen with "Tap to Play"
- View instructions/how to play *(v1.0+)*
- Resume previous game *(v1.0+)*
- Adjust settings (sound on/off) *(v1.0+)*

#### 2. PLAY LEVEL

- Ball sits on paddle at game start and after losing a life
- Tap to launch ball from paddle
- Ball bounces off top and side walls
- Ball bounces off paddle
- Level layout defined in data (level config)
- Render brick grid from level data
- Ball-brick collision destroys brick and awards points
- Lose life when ball falls off bottom
- See current score (HUD)
- See lives remaining (HUD)
- Pause game
- Control paddle with tilt *(v1.0+)*

#### 3. PROGRESS

- Detect when all bricks are cleared (trigger level complete)
- Advance to next level *(v1.0+)*
- Collect power-ups *(v1.0+)*
- Track high score *(v1.0+)*

#### 4. COMPLETE/FAIL

- Show game over screen when all lives lost
- Show victory screen when level complete
- Tap to restart game
- Return to main menu *(v1.0+)*

---

## Walking Skeleton

The thinnest deployable slice that exercises the full scene flow end-to-end.
No game logic — just scene transitions and state wiring.

**Scene flow**: `SplashScene` → `GameScene` → `GameSummaryScene` → `SplashScene`

**Game screen state machine** (skeleton only):

`WaitingToLaunch` → `Playing` → `BallLost` → (lives = 0) → `GameOver`

Stories:

- 🦴 `SplashScene`: app launches, shows splash, tap to continue
- 🦴 `GameScene`: ball drops immediately (no paddle, no bricks), loses all lives
- 🦴 `GameSummaryScene`: shows "Game Over", tap to return to splash

---

## MVP Release Slice

The MVP includes:

- ✅ Splash screen (tap to play)
- ✅ Ball attached to paddle, tap to launch
- ✅ Ball physics: wall and paddle bouncing
- ✅ Level layout defined in data
- ✅ Brick grid rendered from level data
- ✅ Ball-brick collision: destroy brick, award points
- ✅ Lose life when ball falls off bottom
- ✅ Lives and score tracking (HUD)
- ✅ Game over / victory screens with restart
- ✅ Pause functionality

## v1.0 Launch Additions

Beyond MVP, in priority order:

1. Multiple levels with progression
2. High score tracking
3. Resume game functionality
4. Power-ups system
5. Tilt/accelerometer controls *(skip if time-constrained)*

Deferred (no longer in v1.0 scope):

- Sound toggle setting — cut until sound is implemented
- Main menu with named buttons — cut until there are multiple destinations to
  navigate to

---

## Technical Notes

- **Platform**: iOS (requires paid Apple Developer Program - $99/year for App Store)
- **Technology**: Swift + SpriteKit
- **Controls**: Touch (MVP), Tilt (v1.0+)
- **Monetization**: None (free app)
