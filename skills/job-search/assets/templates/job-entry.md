# Job History Entry Template

Use this format when appending jobs to `job-history.md`:

```markdown
## [YYYY-MM-DD] - Search: "[search terms]"

| Job Title | Company | Location | Salary | Link | Fit | Lane | Source | Notes |
|-----------|---------|----------|--------|------|-----|------|--------|-------|
| [title] | [company] | [location] | [salary or N/A] | [url] | [High/Medium/Low/Skip] | [Top/Stretch/Speculative/Unverified/-] | [source name] | [brief note] |
```

Older sections may not have the `Lane` and `Source` columns. Read them as before.

## Fit Score Criteria

See `shared/references/fit-scoring.md` for canonical definitions.

## Lane

- `Top`: dated and fresh, found by an exact or synonym query (tier 1 or 2)
- `Stretch`: dated and fresh, found only by an adjacent-role or skills-only query (tier 3 or 4)
- `Speculative`: open/general application portal at a recently funded startup (tier 5)
- `Unverified`: date could not be found, see `shared/references/job-freshness.md`
- `-`: not presented (Low, Skip, stale, closed, or already shown)

## Source

The board, careers page, or search that first surfaced the job, for example `hiring.cafe`, `Remote OK`, `Greenhouse (web search)`, or `Company pool`. Use the same name as in the search log.

## Notes Format

Keep notes brief and actionable:
- "Strong match - [key reasons]"
- "Comp below target"
- "Agency - dealbreaker"
- "Crypto - dealbreaker"
- "Onsite only"
- "Requires [X] - dealbreaker"
- "Stale posting - older than 14 days"
- "Date unverified"
- "Closed posting"
- "No longer accepting applications"
- "Employer page could not be checked"
