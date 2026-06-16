# ADR 002: pivot to cloud bridge engine

**Date:** 2026-06-14
**Status:** Accepted

## Context
The main data provider (Upwork) has blocked the free information stream (no RSS and free email notifications).

## Decision
Changing the business objective to "Cloud Bridge Engine" (universal Micro-ETL for SMEs), while maintaining the original infrastructure architecture (OCI, Docker, n8n).

## Consequences
**Positive:**
* becoming independent from a single API
* expanding the service's target group
* maintaining FinOps assumptions (cost $0)

**Negative / Risks:**
