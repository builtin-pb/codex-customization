---
name: test-driven-development
description: Use when implementing features, bug fixes, refactors, or behavior changes, before writing implementation code.
---

# Test-Driven Development

## Overview

Use TDD to drive behavior through tests, not to validate code after the fact.

**Core principle:** tests should verify observable behavior through public interfaces. Code can change completely; tests should still pass if behavior stays correct.

Good TDD usually produces integration-style tests over real code paths. Prefer tests that read like specifications, use public APIs, and survive internal refactors. Avoid tests that mainly prove mocks, private methods, or internal wiring.

Load [testing-anti-patterns.md](testing-anti-patterns.md) when you are adding mocks, changing test structure, or feeling pressure to expose internals just to make tests easier.

## When to Use

Use for:
- New features
- Bug fixes and regression tests
- Refactoring with behavior protection
- Any behavior change that should be driven by failing tests first

Usually do not use for:
- Throwaway prototypes
- Pure configuration changes with no meaningful behavior to specify
- Generated code you do not intend to maintain directly

If the work is still exploratory, spike quickly if needed, then throw the spike away and restart from a failing test once the behavior is clear enough to implement for real.

## Core Rules

1. No production code before a failing test for the current behavior.
2. Write one behavior-focused test at a time.
3. Make the test fail for the right reason before implementing.
4. Write the minimum code that makes the current test pass.
5. Refactor only while green.

## Recovery Path

If code already exists before `RED`, do not keep building forward and call it TDD later.

Use one of these paths:
- If the code was exploratory and disposable, throw it away and restart from a failing test.
- If the code must be preserved, stop changing production code, identify the next externally visible behavior that still is not protected, write the smallest test that fails honestly for that behavior, then continue from that `RED`.
- If this is a pure refactor and the relevant behavior is already covered by passing characterization tests, stay `GREEN`: strengthen coverage first if needed, then refactor under those passing tests. Do not invent a fake failing test just to simulate compliance.

The rule is simple: either recover an honest failing test for the next behavior, or admit you are doing a green-only refactor under existing coverage.

## Anti-Pattern: Horizontal Slices

Do not treat RED as "write all the tests" and GREEN as "write all the code."

That creates brittle tests for imagined designs instead of real behavior:
- Tests lock onto shapes and signatures too early
- The suite becomes insensitive to real regressions
- You commit to structure before learning from the first slice

Use vertical slices instead:

```text
WRONG (horizontal):
  RED:   test1, test2, test3, test4
  GREEN: impl1, impl2, impl3, impl4

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
```

Each cycle should teach you something about the next one.

## Workflow

### 1. Orient On Behavior

Before writing the next test:
- Identify the public interface or user-visible behavior being added or fixed
- Decide which behavior is most important to prove first
- Prefer small interfaces and simple boundaries
- Introduce seams at real external boundaries, not just to make tests easier
- If requirements are unclear, clarify only what is necessary to write the next correct test

Ask:
- What should the caller or user observe?
- What is the smallest useful path I can prove end-to-end?
- Can the interface be smaller or simpler?
- Can this module stay deep: small interface, substantial logic hidden inside?

### 2. RED

Write one test for one behavior.

Requirements:
- Clear name
- Public interface or observable effect
- Real code path unless isolation is genuinely needed
- Narrow scope: one behavior, one reason to fail

Good:

```typescript
test('retries failed operations 3 times before succeeding', async () => {
  let attempts = 0;

  const operation = async () => {
    attempts++;
    if (attempts < 3) throw new Error('fail');
    return 'success';
  };

  const result = await retryOperation(operation);

  expect(result).toBe('success');
  expect(attempts).toBe(3);
});
```

Bad:

```typescript
test('retry works', async () => {
  const mock = jest.fn()
    .mockRejectedValueOnce(new Error())
    .mockRejectedValueOnce(new Error())
    .mockResolvedValueOnce('success');

  await retryOperation(mock);

  expect(mock).toHaveBeenCalledTimes(3);
});
```

Why this is weak:
- Name is vague
- It mostly checks one interaction detail
- It does not clearly specify the externally useful behavior

### 3. Verify RED

Run the test and confirm it fails for the expected reason.

```bash
npm test path/to/test.test.ts
```

Check:
- The test fails, not errors unexpectedly
- The failure matches the missing behavior
- It is not already green because the behavior exists or the assertion is too weak

If the test passes immediately, you have not proved the new behavior yet. Strengthen or replace the test before writing production code.

### 4. GREEN

Write the smallest production change that makes the current test pass.

Do not:
- Add behavior for future tests
- Refactor unrelated code
- Generalize prematurely
- Add extra options "while you are here"

If the implementation feels awkward, that is often design feedback. Finish the slice, get green, then refactor.

### 5. Verify GREEN

Run the focused test again, then the relevant surrounding tests.

Check:
- The current test passes
- Related tests still pass
- Output is clean enough to trust

If other tests fail, fix the breakage before moving on.

### 6. REFACTOR

Only after green:
- Remove duplication
- Improve names
- Extract helpers or values
- Deepen modules by hiding complexity behind smaller interfaces
- Fix shallow APIs exposed by the previous slice
- Return results or other observable effects in ways callers can verify without peeking into internals

Run tests after each refactor step. Stay behavior-preserving.

### 7. Repeat

Choose the next most valuable behavior and start another vertical slice.

## What Good Tests Look Like

Good tests:
- Describe behavior, not implementation
- Use public interfaces
- Survive internal refactors
- Prefer real collaborators over deep mocking
- Make the intended API clearer

Weak tests:
- Assert on mock behavior instead of system behavior
- Reach into private helpers or hidden state
- Depend on exact internal call structure
- Verify database rows, logs, or internals when a public result is available
- Cover several behaviors under one vague name

Design cues from good TDD:
- Prefer small public surfaces over many tiny test-only seams
- Accept dependencies at genuine system boundaries, not by default
- Return values or other observable outcomes when that makes behavior easier to specify
- Let tests push modules deeper, not wider

## Rationalizations To Reject

| Thought | Correction |
|---------|------------|
| "I'll write tests after." | Passing afterward proves much less than watching the test fail first. |
| "I'll add all the tests now." | Horizontal slicing weakens feedback; do one slice at a time. |
| "This is too simple to test." | The simplest behavior is usually the cheapest test to write. |
| "I already tried it manually." | Manual checks are not a repeatable regression suite. |
| "I'll just add the future option now." | That is speculative code; wait for the next failing test. |
| "Mocking this is easier." | Easier setup is not enough; prefer real behavior unless the boundary is truly external or slow. |
| "I already wrote the code, I'll add tests now." | Stop. Either discard the spike and restart from `RED`, or freeze code changes until you recover an honest failing test for the next behavior. |

## Debugging Integration

When fixing a bug:
1. Reproduce it with a failing test.
2. Watch that test fail for the right reason.
3. Fix the bug with the smallest change.
4. Keep the test as regression protection.

Do not rely on a fix without a reproducible regression test unless the situation makes automated coverage impossible.

## Checklist Per Cycle

```text
[ ] Test describes behavior, not implementation
[ ] Test uses a public interface or observable effect
[ ] Test failed for the expected reason before implementation
[ ] Code added was minimal for this behavior
[ ] No speculative features were added
[ ] Relevant tests are green before moving on
[ ] The relevant surrounding test set is green before claiming completion
[ ] Tests use real code unless a boundary genuinely requires isolation
[ ] Important error paths and edge cases for this behavior are covered
```
