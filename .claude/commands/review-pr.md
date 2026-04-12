Review pull request $ARGUMENTS.

Steps:
1. Fetch the PR details: `env -u GITHUB_TOKEN gh pr view $ARGUMENTS --json title,body,headRefName`
2. Fetch the diff: `env -u GITHUB_TOKEN gh pr diff $ARGUMENTS`
3. Fetch any existing review comments: `env -u GITHUB_TOKEN gh pr view $ARGUMENTS --json reviews,comments`

Review the changes against these focus areas:
- **Correctness** — matches the PR description and linked issue; no silent scope creep
- **Design quality** — cohesion, coupling, separation of concerns, appropriate abstractions, modularisation; suggest refactorings and label each as "must fix before merge" or "follow-up PR"
- **Swift & SpriteKit conventions** — no per-frame allocations, physics bodies correct, action vs. physics tradeoffs considered
- **Test coverage** — new logic has tests using Swift Testing (`@Test`, `#expect`), not XCTest
- **Simplicity** — flag anything that could be materially simpler without losing clarity
- **Performance** — no object creation in `update()`, texture atlases used where appropriate
- **Naming** — types, methods, variables reveal intent
- **Dead code** — no unused methods, variables, or imports
- **Comment quality** — only where logic isn't self-evident; no commented-out code
- **SwiftLint** — flag anything stylistically off even if it passes the linter
- **Safety** — flag force-unwraps that could crash in real gameplay

Post your review as inline comments where possible:
`env -u GITHUB_TOKEN gh pr review $ARGUMENTS --comment --body "..."`

End with a summary: overall verdict (approve / request changes), the most important issues, and any suggested follow-up PRs.
