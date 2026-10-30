# Search Log

Written by the `/job-search` skill. It records which sources and queries produced results so later runs can keep what works and drop what doesn't.

## Query Status

**Proven** (produced at least one High-fit job):
- (none yet)

**Retired** (no fresh High/Medium results in 3 consecutive runs):
- (none yet)

## Runs

Append one section per run, then one row per source and query combination:

```markdown
## [YYYY-MM-DD] - Run: "[arguments or default]"

| Source | Query | Tier | Rows seen | Fresh | High | Medium | Notes |
|--------|-------|------|-----------|-------|------|--------|-------|
| hiring.cafe | VP Growth | 1 | 120 | 34 | 2 | 3 | |
| Greenhouse (web search) | "head of growth" | 2 | 15 | 6 | 0 | 1 | |
| Company pool | - | - | 30 companies | 4 | 1 | 0 | 2 pages failed to load |
```

Tier: 1 exact title, 2 synonym, 3 adjacent role, 4 skills-only, 5 speculative/open application. Use `-` for company-pool rows.

---

