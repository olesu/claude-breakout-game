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
- **Swift concurrency** — `@MainActor` isolation correct on all UI/SpriteKit code; no data races, no unstructured `Task {}` that escapes actor context without explicit isolation, no missing `await` on actor-isolated calls
- **Safety** — flag force-unwraps that could crash in real gameplay

Post your review as inline comments where possible:
`env -u GITHUB_TOKEN gh pr review $ARGUMENTS --comment --body "..."`

**Labelling:** Apply appropriate labels based on what the diff touches. Fetch available labels first:
`env -u GITHUB_TOKEN gh label list`
Apply all that fit. If no existing label captures something significant, create one first:
`env -u GITHUB_TOKEN gh label create "name" --description "..." --color "RRGGBB"`
Then apply:
`env -u GITHUB_TOKEN gh pr edit $ARGUMENTS --add-label "label1,label2"`

**Merge policy:** This is a solo private repo — PRs cannot be self-approved. Instead:
- If changes are needed: end with "Request changes" and list them. Do NOT attempt `gh pr review --approve`.
- If the PR is ready: end with "Approved — ready to merge" and run:
  `env -u GITHUB_TOKEN gh pr merge $ARGUMENTS --squash --delete-branch`

End with a summary: overall verdict (ready to merge / request changes), the most important issues, and any suggested follow-up PRs.
