# Breakout Game - User Story Map

## Project Vision

**Core Elements**:

- Nostalgia-driven (Commodore 64 breakout inspiration)
- Modern visual aesthetic and sound design
- Mobile-first: iOS platform (Swift/SpriteKit)
- Single-player gameplay
- Success metric: App Store release + 1,000 downloads

**MVP Scope**:

- Single level
- No power-ups
- Touch controls for paddle
- Modern look and sound

**Launch Version (v1.0)**:

- Multiple levels with variety
- Reasonable difficulty curve
- Power-ups system
- Possibly accelerometer/tilt controls

---

## Story Map Structure

### Backbone (User Activities - Player Journey)

1. **Start Experience** → 2. **Play Level** → 3. **Progress** → 4. **Complete/Fail**

---

### Stories by Activity

Organized vertically: Top = Essential/MVP, Bottom = Nice-to-have/v1.0+

#### 1. START EXPERIENCE

- Launch app and see main menu
- Tap to start new game
- View instructions/how to play
- Resume previous game *(v1.0+)*
- Adjust settings (sound on/off)

#### 2. PLAY LEVEL

- Control paddle with touch (swipe/drag)
- Ball launches and bounces
- Ball breaks bricks on contact
- Ball bounces off paddle
- Ball bounces off walls
- Lose life when ball falls off bottom
- See current score
- See lives remaining
- Pause game
- Control paddle with tilt *(v1.0+)*

#### 3. PROGRESS

- Clear all bricks to complete level
- Advance to next level *(v1.0+)*
- Collect power-ups *(v1.0+)*
- Track high score *(v1.0+)*

#### 4. COMPLETE/FAIL

- See game over when lives run out
- See victory screen when level(s) complete
- Return to main menu
- Restart game

---

## MVP Release Slice

The MVP includes:

- ✅ Basic main menu
- ✅ Single level gameplay
- ✅ Touch paddle control
- ✅ Core brick-breaking mechanics (ball physics, collisions)
- ✅ Lives and score tracking
- ✅ Game over/victory states
- ✅ Pause functionality
- ✅ Basic settings (sound toggle)

## v1.0 Launch Additions

Beyond MVP:

- Multiple levels with progression
- Power-ups system
- Tilt/accelerometer controls
- High score tracking
- Resume game functionality

---

## Technical Notes

- **Platform**: iOS (requires paid Apple Developer Program - $99/year for App Store)
- **Technology**: Swift + SpriteKit
- **Controls**: Touch (MVP), Tilt (v1.0+)
- **Monetization**: None (free app)
