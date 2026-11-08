---
name: initialize-project-task
description: Initialize and execute a software-project task by reading the project's authoritative reference file such as CODEHUB_REFERENCE.md, inspecting the relevant repository implementation, defining the main task and hard rules, and writing a direct phased implementation plan with checkboxes and validation gates under docs/. After the user approves the plan, create a suitable dedicated branch and implement every approved phase there. Use for requests to analyze a project before coding, start a substantial feature or redesign, convert requirements into an implementation-ready plan, or establish a living task plan that will be updated during implementation.
---

# Initialize Project Task

Create an evidence-based, implementation-ready task plan before changing product code. Keep the plan direct, scoped, and easy to maintain.

## Operating Rules

- Treat the repository and its authoritative reference document as the source of truth.
- Prefer `CODEHUB_REFERENCE.md`. If absent, locate the nearest equivalent architecture/reference document plus `README`, manifests, and applicable `AGENTS.md`.
- Read selected instruction and reference files completely. Inspect actual code for every area affected by the task.
- Separate verified facts, requirements, assumptions, and unresolved blockers. Do not present guesses as project facts.
- Avoid generic advice, speculative features, broad refactors, database changes, or new dependencies unless the task requires them.
- Preserve existing behavior outside the declared scope.
- Do not begin product implementation when the user requested analysis or planning only.
- Treat approval to start implementation as authorization to create and switch to a dedicated task branch.
- Keep all implementation phases on that task branch. Do not merge or push it unless the user separately requests those actions.
- Never expose secrets or copy credentials into the plan.

## Workflow

### 1. Establish the repository baseline

1. Find the repository root.
2. Inspect git status, current branch, remotes, and recent relevant history without modifying them.
3. Locate `CODEHUB_REFERENCE.md`, `AGENTS.md`, the main README, package manifests, routes, configuration, and test/build commands.
4. Read `CODEHUB_REFERENCE.md` completely.
5. Inspect the files and runtime paths directly related to the requested task. Use search to trace components, data flow, navigation, styles, APIs, and tests.
6. Note conflicts between documentation and code; treat current code as runtime truth and record documentation drift.

### 2. Normalize the request

Write one concise main-task statement. Then derive:

- required outcomes;
- in-scope behavior;
- explicit non-goals;
- technical and product rules;
- existing functionality that must remain unchanged;
- measurable acceptance criteria;
- genuine blockers or decisions that materially change the solution.

Make a reasonable, reversible assumption when possible. Ask the user only when an unresolved decision would significantly change the result.

### 3. Design the smallest complete change

Map each requirement to the exact existing area it affects:

- route or entry point;
- component or service;
- state/data source;
- styles and responsive behavior;
- configuration or external integration;
- tests and validation.

Prefer adapting current patterns over introducing parallel systems. Include pagination, schema work, new packages, abstractions, or infrastructure only when evidence shows they are necessary.

### 4. Build phased execution

Divide the work into ordered phases with independently verifiable outcomes. Use as few phases as necessary, normally:

1. baseline and safeguards;
2. core implementation;
3. integration and edge cases;
4. responsive, accessibility, or performance polish when applicable;
5. documentation and final verification.

For every phase include:

- objective;
- exact files or project areas;
- ordered implementation steps;
- expected behavior after the phase;
- a dedicated review and validation checklist;
- dependencies on earlier phases.

Each step must be specific enough that another engineer can implement it without reopening the initial discovery. Do not pad the plan with obvious ceremony.

### 5. Write the plan in `docs/`

Use `assets/task-plan-template.md` as the structure and adapt it to the project. Save the result as:

`docs/<clear-task-slug>-implementation-plan.md`

Create `docs/` if it does not exist. Use repository-relative paths inside the document. Mark completed discovery work with `[x]` and future work with `[ ]`.

The plan must contain:

- task status, source request, date, and a suitable intended branch;
- main task;
- verified project baseline;
- requirements, rules, non-goals, and assumptions;
- change map with exact files/areas and reasons;
- phased checklists;
- review/validation gate for every phase;
- risks and rollback notes;
- final definition of done;
- progress table and update log.

### 6. Validate the plan

Before handoff, verify:

- every user requirement maps to at least one phase and one acceptance criterion;
- every phase has a review/validation gate;
- no planned change violates an explicit rule or non-goal;
- file and route names match the repository;
- the plan distinguishes confirmed facts from assumptions;
- checkboxes accurately reflect current progress;
- the document exists under `docs/` and is readable Markdown;
- no implementation changes were made if the user requested planning only.

### 7. Create the approved implementation branch

When the user authorizes implementation:

1. Recheck the current branch and worktree before modifying files. Preserve unrelated user changes and stop if switching branches would put them at risk.
2. Use the user's exact branch name when provided. Otherwise follow the repository's documented branch convention; when none exists, use `codex/<clear-task-slug>`.
3. Create the new branch from the approved base branch and switch to it before editing product code.
4. If the intended branch already exists, verify it belongs to this task and switch to it instead of creating a conflicting duplicate.
5. Record the actual branch in the plan, mark branch setup complete, and keep all phases on it.
6. Do not merge into the base branch or push to a remote unless the user explicitly asks.

### 8. Implement every approved phase

After branch setup:

1. Work only from the approved plan and dedicated task branch.
2. Update checkboxes immediately after each completed step.
3. Record material deviations and their reasons in the update log.
4. After each implementation step, report a compact table with completed steps, remaining steps, and the completed result.
5. Run the phase's review gate before marking the phase complete.
6. Continue through every approved phase and final verification unless blocked by a material decision, missing authority, or unsafe external action.
7. Do not silently expand scope. Amend the plan when requirements change.

## Handoff

Lead with the result and link the plan using its absolute local path. Summarize the main task, phase count, important constraints, and any blocker. If planning-only was requested, ask for review and confirmation before implementation.

