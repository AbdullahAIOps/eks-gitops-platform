# 1. Record architecture decisions

Date: 2026-01-15

## Status
Accepted

## Context
We want the *reasoning* behind significant choices to be reviewable, not just
the resulting code. New team members (and interviewers) should be able to
understand why the platform looks the way it does.

## Decision
We use Architecture Decision Records (Michael Nygard format). Each significant,
architecturally-relevant decision gets a short, immutable, numbered record here.

## Consequences
- Decisions have a durable rationale; superseding a decision means adding a new
  ADR that references the old one, not editing history.
- Slight overhead per decision; offset by faster onboarding and clearer reviews.
