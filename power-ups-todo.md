# Power-Ups Todo

## Prerequisites

- [x] Refactor power-up system to support multiple types
  - Introduce a `PowerUpType` enum and refactor `PowerUpNode` and
    `PowerUpCoordinator` to be type-aware. Each type should have its own
    label, color, duration, and effect.

## Simple (no new game objects)

- [x] Wide Paddle (`WP`) — paddle grows 1.5x for 8s, smooth width animation
- [ ] Slow Ball (`SB`) — ball speed reduced 40% for 8s
- [ ] Extra Life (`+1`) — instant extra life, no duration

## Complex (new game objects / logic)

- [ ] Multi Ball (`MB`) — spawns 2 extra balls at current ball position;
  ends when only one ball remains
- [ ] Laser (`LZ`) — tap to fire lasers upward for 8s; lasers destroy bricks
  on contact; requires `LaserNode` and new physics category
- [ ] Sticky Paddle (`ST`) — ball sticks on paddle contact, tap to release;
  up to 3 catches; ends on ball loss
