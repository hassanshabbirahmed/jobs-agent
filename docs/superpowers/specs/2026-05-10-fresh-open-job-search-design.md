# Fresh Open Job Search Design

## Context

The `job-search` skill currently searches hiring.cafe, scores listings against the user's resume and preferences, resolves employer URLs for top matches, and presents High/Medium fits. Its current freshness guidance is advisory: it says to apply date filters and prioritize recent postings, but it does not define freshness or visible closed-state language as hard eligibility rules. This allows expired, closed, or no-longer-accepting listings to reach the user.

The Telegram loop delegates search requests to `skills/job-search/SKILL.md`, so improving the main job-search skill also improves Telegram search behavior without adding separate Telegram-specific logic.

## Goals

- Show only jobs that are recent enough to be worth the user's attention.
- Filter out jobs whose direct employer or ATS posting visibly says the role is closed, expired, removed, archived, inactive, filled, or no longer accepting applications.
- Keep the availability check lightweight: scan visible posting text for closed-state language, but do not require apply button or form verification.
- Preserve the existing skill architecture, which is instruction-driven Markdown with a small evaluator prompt.
- Log skipped stale or closed jobs in history so they are less likely to resurface as new matches later.

## Non-Goals

- Do not add a programmatic browser scraper or shared JavaScript library.
- Do not require ATS-specific apply-flow verification for Greenhouse, Lever, Workday, Ashby, or other platforms.
- Do not block a job only because an apply button cannot be found.
- Do not change resume tailoring, cover letter, apply, setup, or network-scan behavior.

## Eligibility Rules

A job is eligible to show to the user only when all of these are true:

1. The job passes the user's dealbreakers and fit criteria.
2. The listing is fresh: posted or refreshed within the last 14 days.
3. The direct employer or ATS posting page does not visibly contain closed-state language.
4. The job has not already been shown in `DATA_DIR/job-history.md`.

If a posting date is unknown, the job should be skipped unless the source explicitly labels it as new, recent, posted today, or refreshed recently. If a direct employer page cannot be reached or checked, the job should not be presented as a verified top match.

## Closed-State Language

When checking the direct employer or ATS posting page, the skill should scan the extracted visible posting text for phrases such as:

- expired
- closed
- no longer accepting applications
- not accepting applications
- application period has ended
- position has been filled
- job is no longer available
- job has been removed
- posting has been taken down
- archived
- inactive

The check should be case-insensitive and should look for close variants of these phrases. If closed-state language appears in the posting text, mark the job as `Skip` with a short note such as `Closed posting` or `No longer accepting applications`.

## Workflow Changes

### Step 2: Browser Search

When extracting hiring.cafe listing rows, include the posting date, refreshed date, or visible freshness label when available. Continue to avoid `get_page_text` on large listing pages. The extracted listing data should include enough information for the evaluator to decide whether the posting is fresh.

### Step 3: Evaluate Jobs

Treat freshness as an eligibility gate before fit scoring:

- Fresh within 14 days: continue to fit scoring.
- Older than 14 days: `Skip`.
- Unknown date with no explicit recent label: `Skip`.

The evaluator output should include freshness-related fields so the main workflow can explain and log decisions:

```json
{
  "title": "VP of Growth",
  "company": "Acme Corp",
  "location": "Remote, US",
  "salary": "$250k-$300k",
  "link": "https://...",
  "posted_date": "2026-05-03",
  "freshness": "fresh",
  "availability": "unchecked",
  "fit": "High",
  "notes": "Strong match - remote, SaaS, meets comp target"
}
```

### Step 5: Resolve Employer URLs and Check Closed Language

For each High/Medium candidate, resolve the direct employer URL before presenting it. Extract only the relevant posting text from the direct employer or ATS page. Scan that text for closed-state language.

- No closed-state language found: set `availability` to `no_closed_language_found`.
- Closed-state language found: set `availability` to `closed_language_found`, mark the job `Skip`, and do not present it.
- Employer page cannot be reached or parsed: do not present it as a top match; log the issue in history.

This step does not need to verify whether an apply CTA exists or whether an application form can load.

### Step 6: Present Results

Show only new High/Medium jobs that passed freshness and closed-language gates. The Apply URL should be the direct employer URL, not a hiring.cafe URL.

## History Format

The history table can keep its existing columns, but notes should record why a job was skipped when it failed the new gates. Examples:

- `Stale posting - older than 14 days`
- `Unknown posting date`
- `Closed posting`
- `No longer accepting applications`
- `Employer page could not be checked`

This keeps the change small while making the filtering decisions auditable.

## Error Handling

- If hiring.cafe does not expose a posting date in visible listing data, skip that job unless there is an explicit recent label.
- If a listing appears fresh but the employer page contains closed-state language, closed-state language wins.
- If the page text is noisy, scan the most relevant posting container first. Avoid broad full-page extraction on large pages unless no targeted posting container is available.
- If a job cannot be checked reliably, do not show it as a top match.

## Testing

Testing should use prompt-level/manual fixtures rather than a new automated browser scraper:

- Fresh posting with no closed language should remain eligible.
- Fresh posting with `no longer accepting applications` should be skipped.
- Posting older than 14 days should be skipped even if it is a strong fit.
- Unknown-date posting should be skipped unless explicitly labeled recent.
- Closed-language matches should be case-insensitive.
- Final user-facing output should include only fresh jobs with no visible closed-state language.

## Acceptance Criteria

- `skills/job-search/SKILL.md` describes freshness and closed-language checks as hard gates.
- `skills/job-search/scripts/evaluate-jobs.md` treats freshness as an eligibility rule, not just a scoring preference.
- Job history notes clearly distinguish stale, unknown-date, and closed-language skips.
- Search results shown to the user contain only new High/Medium jobs that passed the 14-day freshness gate and direct-posting closed-language check.
