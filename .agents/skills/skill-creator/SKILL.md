---
name: skill-creator
description: Create new skills, modify and improve existing skills, and measure skill performance. Use when building a skill from scratch, editing existing ones, running benchmarks, or optimizing triggering descriptions.
---

# Skill Creator

## Overview
A skill for creating, evaluating, and iteratively improving agent skills. This skill helps move from a fuzzy behavioral intent to high-quality, verifiable agent instructions that generalize across tasks.

## When to Use
- Translating a manual workflow into a reusable agent skill
- Improving the accuracy or performance of an existing skill
- Running benchmarks to compare skill versions or large-scale evaluation
- Optimizing a skill's triggering description for better discovery

## The Skill Creation Workflow
1. **Capture Intent**: Define what the skill enables Claude to do and when it should trigger.
2. **Draft SKILL.md**: Write the initial instructions using imperative form, following the normalized structure.
3. **Test Case Generation**: Create 2-3 realistic test prompts in `evals/evals.json`.
4. **Run and Evaluate**:
   - Spawn subagents (With-Skill vs. Baseline) using `claude-with-access-to-the-skill`.
   - Collect outputs and timing data (`timing.json`).
5. **Human Review**: Use `generate_review.py` to launch the eval viewer for qualitative and quantitative analysis.
6. **Improve**: Refactor the skill based on feedback, focusing on generalization and lean prompts.
7. **Optimize Triggering**: Generate eval queries to refine the frontmatter description.

## Instructions
- **Iterate Rapidly**: Don't wait for perfection. Run eval-0 and eval-1 to see if the skill actually helps before polishing.
- **Explain the "Why"**: Always provide reasoning for instructions so the agent can generalize beyond specific examples.
- **Standardized Benchmarking**:
  - Store results in `<skill-name>-workspace/iteration-N/`.
  - Use `python -m scripts.aggregate_benchmark` for pass rates and token usage.
- **Viewer-First Review**: Always generate the eval viewer (`generate_review.py`) before assessing results yourself.

## Best Practices
- **Avoid Static Instructions**: Use dynamic parameters or metaphors that allow the agent to adapt to context.
- **Reference Bundled Resources**: If all test cases result in similar helper scripts, bundle them into `scripts/`.
- **Blind Comparison**: Use `agents/comparator.md` for rigorous A/B testing of skill versions.

## Anti-Patterns
- **Overfitting**: Writing instructions that only work for the test cases but fail on slightly different prompts.
- **Heavy-Handed MUSTs**: Using excessive capitalization or rigid rules that stifle the agent's problem-solving capability.
- **Implicit Knowledge**: Assuming the agent knows project context that isn't in the skill or current context window.

## Related Resources
- **Grader Agent**: `agents/grader.md`
- **Benchmark Schema**: `references/schemas.md`
