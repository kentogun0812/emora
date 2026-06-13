---
name: agent-memory-systems
description: Covers the architecture of agent memory, including short-term context, long-term vector stores, and cognitive architectures. Use when designing or debugging agent memory systems, chunking strategies, or retrieval logic.
---

# Agent Memory Systems

## Overview
Memory is the cornerstone of intelligent agents. This skill focuses on retrieval-centric memory architectures where the challenge is not storing data, but surfacing the right information at the right time.

## When to Use
- Designing long-term memory systems (vector stores)
- Developing chunking and embedding strategies
- Debugging retrieval failures or context management issues
- Implementing cognitive architectures for persistent agent state

## Instructions
- **Design for Retrieval**: Always prioritize retrieval quality over storage volume. Memory failures are often retrieval failures.
- **Implement Tiered Memory**:
  - **Short-term**: Context window for immediate tasks.
  - **Long-term**: Vector stores for episodic and semantic memory.
  - **Working memory**: Active state and tool outputs.
- **Optimize Chunking**:
  - Use contextual chunking to preserve meaning.
  - Test multiple chunk sizes for different document types.
  - Track embedding model versions in metadata.
- **Metadata Filtering**: Always filter by metadata before performing vector searches to improve precision and reduce noise.

## Patterns & Best Practices
- **Temporal Scoring**: Weight recent memories higher for tasks where time context matters.
- **Conflict Detection**: Identify and resolve inconsistencies when storing new information that contradicts existing memory.
- **Token Budgeting**: Allocate specific token limits for different memory types within the context window.

## Anti-Patterns
- **Store Everything Forever**: Avoid indiscriminate storage without decay or relevance filtering.
- **Chunk Without Testing**: Never assume a chunking strategy works without verifying retrieval performance.
- **Single Memory Type**: Do not use a one-size-fits-all approach for heterogeneous data (e.g., mixing code and prose in the same bucket).

## Related Resources
- **Related Skills**: `planning-and-task-breakdown`, `using-agent-skills`
