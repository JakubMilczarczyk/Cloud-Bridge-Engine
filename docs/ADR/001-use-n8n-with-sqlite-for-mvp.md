# ADR 001: [Short decision title]

**Date:** [YYYY-MM-DD]
**Status:** Accepted

## Context
Need to quickly impement ETL piepine MVP for notification logic.

## Decision
Using n8n with a buit-in SQLite database.

## Consequences
**Positive:**
* Lightning-fast start
* no additional container (PostgreSQL)
* minimal memory consumption (FinOps)

**Negative** 
* More difficult to scale if moving to a multi-node model in the future.
