# Wider, More Niche Job Search Design

## Context

After the fresh-open-job-search work, `job-search` searched one aggregator (hiring.cafe) with literal target-role keywords, read the first 50 rows per query, and skipped every listing with an unknown posting date. That combination favored well-known employers with dated postings and dropped the small, niche employers whose postings often carry no date and never reach aggregators.

## Goals

- Reach roles that don't use the obvious title.
- Reach employers that aggregators don't index.
- Stop discarding good niche listings only because they have no posting date.
- Keep the freshness and closed-posting protections for everything the user is told is verified.
- Improve over time from what works.

## Non-Goals

- No programmatic scraper or shared JavaScript library. The skill stays instruction-driven Markdown plus subagent prompts.
- No login-only sources, CAPTCHA handling, or workarounds for sites that block automation.
- No change to `apply`, `tailor-resume`, `cover-letter`, `setup`, or `network-scan`. `job-search` reads network-scan's careers URL cache but never writes to it.

## Changes

1. **Undated listings** (`shared/references/job-freshness.md`). Freshness has three states: `fresh`, `stale`, `unknown`. Unknown listings get a date inference pass on the employer page (JSON-LD `datePosted`, visible text, ATS metadata). Those still undated can appear only in a separate **Date unverified** section, capped at 5, and only after passing the closed-language check and reaching High or Medium fit. They never appear in Top Matches. This **supersedes** the earlier rule that unknown posting dates are always `Skip`.
2. **Company pool**. A new `DATA_DIR/discovered-companies.json` holds companies found through investor portfolios, recent funding, lists, and lookalikes of companies of interest. Each run scans up to 30 companies whose careers pages are due (older than 7 days), and runs discovery when fewer than 30 are due. Careers URLs are resolved with network-scan's resolver script, with its cache read first.
3. **More sources** (`shared/references/job-sources.md`, `DATA_DIR/sources.md`). Niche, startup, and domain boards, plus `site:` web searches against ATS domains. Sources that block automation are skipped.
4. **Query tiers**. Queries expand into exact, synonym, adjacent, and skills-only tiers. Jobs found only by tier 3 or 4 queries go in a **Stretch** section. The evaluator judges adjacent roles on responsibilities and skills overlap, not title. hiring.cafe is read to 3 pages for tier 1 and 2 queries.
5. **Search log** (`DATA_DIR/search-log.md`). Each run logs rows seen, fresh count, and High/Medium counts per source and query. Queries that produce High fits are Proven. Queries and sources with no fresh High or Medium results in 3 consecutive runs are retired. Feedback such as "more like #2" feeds new queries and lookalike companies.

`--exact` keeps the previous narrow behavior: hiring.cafe only, tier 1 queries only.

## Decisions

- **First-seen tracking was not added.** The original idea was a `first_seen` date used to age undated listings. Because the history file already prevents any job from being shown twice, a first-seen date would never be consulted. Date inference on the employer page does the real work instead.
- **Jobs left unchecked are not logged.** Step 5 checks at most 25 employer pages per run. Jobs over the limit are left out of `job-history.md` so they can surface on the next run instead of being deduplicated away.
- **History table gained `Lane` and `Source` columns.** Older sections keep the original columns and are read as before.

## Cost and Limits

A wide run does far more work than before. Browser subagents run at most 5 at a time. Defaults: up to 23 queries across four tiers, about 6 browse sources, 30 companies, 25 employer-page checks. These live in `SKILL.md` and can be tuned. `--exact` is the fast path.

## Verification

This repository has no automated tests for skills. Verify by reading the files for consistency and by running `/jobs-agent:job-search` once with and without `--exact`, checking that the search log, sources, and company pool files are created and that a stale or closed posting is still skipped.
