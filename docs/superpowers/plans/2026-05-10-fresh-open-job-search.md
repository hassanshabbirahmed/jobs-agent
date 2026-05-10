# Fresh Open Job Search Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the `job-search` skill show only fresh jobs and filter out direct employer postings that visibly say they are closed, expired, inactive, removed, filled, or no longer accepting applications.

**Architecture:** Keep the current instruction-driven skill architecture. Update the evaluator prompt to make 14-day freshness a hard eligibility gate, update the main job-search workflow to resolve direct employer pages and scan relevant posting text for closed-state language before presentation, and update the history template so skipped stale/closed jobs are logged clearly.

**Tech Stack:** Markdown-based Codex/Claude skills, browser automation instructions, shell/`rg` verification commands.

---

## File Structure

- Modify `skills/job-search/scripts/evaluate-jobs.md`: define freshness as a gate and add `posted_date`, `freshness`, and `availability` fields to evaluator JSON output.
- Modify `skills/job-search/SKILL.md`: add explicit search extraction requirements, eligibility gates, closed-language detection, history notes, and presentation filtering.
- Modify `skills/job-search/assets/templates/job-entry.md`: add standard notes for stale, unknown-date, closed-language, and uncheckable employer-page skips.
- No changes to `skills/jobsearch-telegram/SKILL.md`: it delegates search requests to `skills/job-search/SKILL.md`, so the central search behavior covers Telegram.
- No browser scraper or ATS-specific form verification will be added.

---

### Task 1: Update Evaluator Freshness Contract

**Files:**
- Modify: `skills/job-search/scripts/evaluate-jobs.md`

- [ ] **Step 1: Run the evaluator contract check before editing**

Run:

```bash
missing=0
for pattern in \
  '"posted_date"' \
  '"freshness"' \
  '"availability"' \
  'Older than 14 days = Skip' \
  'Unknown posting date = Skip'; do
  if ! rg -q "$pattern" skills/job-search/scripts/evaluate-jobs.md; then
    printf 'missing: %s\n' "$pattern"
    missing=1
  fi
done
exit "$missing"
```

Expected: FAIL with one or more `missing:` lines.

- [ ] **Step 2: Replace the evaluation section and output schema**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: skills/job-search/scripts/evaluate-jobs.md
@@
-## Evaluation Process
-
-For each job listing:
-
-Follow the evaluation process and fit scoring criteria defined in `shared/references/fit-scoring.md`.
+## Evaluation Process
+
+For each job listing, apply eligibility gates before fit scoring:
+
+1. **Freshness gate**
+   - Posted or refreshed within the last 14 days = continue to fit scoring.
+   - Older than 14 days = Skip.
+   - Unknown posting date = Skip unless the listing explicitly says it is new, recent, posted today, or refreshed recently.
+2. **Fit gate**
+   - Follow the evaluation process and fit scoring criteria defined in `shared/references/fit-scoring.md`.
+   - Dealbreakers from the matching rules still override all positive signals.
@@
       "salary": "$250k-$300k",
       "link": "https://...",
+      "posted_date": "2026-05-03",
+      "freshness": "fresh",
+      "availability": "unchecked",
       "fit": "High",
       "notes": "Strong match - remote, SaaS, meets comp target"
@@
-- Prioritize recent postings (< 2 weeks) over older ones
+- Freshness is an eligibility gate, not a scoring preference
+- Older than 14 days = Skip
+- Unknown posting date = Skip unless the listing explicitly labels itself recent
+- Set `freshness` to `fresh`, `stale`, or `unknown`
+- Set `availability` to `unchecked`; the main job-search workflow updates it after checking the direct employer page
*** End Patch
```

- [ ] **Step 3: Run the evaluator contract check after editing**

Run:

```bash
missing=0
for pattern in \
  '"posted_date"' \
  '"freshness"' \
  '"availability"' \
  'Older than 14 days = Skip' \
  'Unknown posting date = Skip'; do
  if ! rg -q "$pattern" skills/job-search/scripts/evaluate-jobs.md; then
    printf 'missing: %s\n' "$pattern"
    missing=1
  fi
done
exit "$missing"
```

Expected: PASS with no output.

- [ ] **Step 4: Review the evaluator prompt**

Run:

```bash
sed -n '1,120p' skills/job-search/scripts/evaluate-jobs.md
```

Expected: The evaluator says freshness is an eligibility gate and the sample JSON includes `posted_date`, `freshness`, and `availability`.

- [ ] **Step 5: Commit Task 1**

Run:

```bash
git add skills/job-search/scripts/evaluate-jobs.md
git commit -m "Tighten job freshness evaluation"
```

Expected: Commit succeeds.

---

### Task 2: Update Main Job-Search Workflow Gates

**Files:**
- Modify: `skills/job-search/SKILL.md`

- [ ] **Step 1: Run the main workflow contract check before editing**

Run:

```bash
missing=0
for pattern in \
  '14 days' \
  'closed-state language' \
  'no longer accepting applications' \
  'no_closed_language_found' \
  'closed_language_found' \
  'Do not verify apply buttons or application forms'; do
  if ! rg -q "$pattern" skills/job-search/SKILL.md; then
    printf 'missing: %s\n' "$pattern"
    missing=1
  fi
done
exit "$missing"
```

Expected: FAIL with one or more `missing:` lines.

- [ ] **Step 2: Add eligibility rules after search term extraction**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: skills/job-search/SKILL.md
@@
 Extract search terms from:
 1. `$ARGUMENTS` if provided
 2. Target roles from preferences
+
+Eligibility gates for jobs shown to the user:
+1. The job must pass the user's dealbreakers and fit criteria.
+2. The listing must be fresh: posted or refreshed within the last 14 days.
+3. Unknown posting dates are `Skip` unless the source explicitly labels the listing as new, recent, posted today, or refreshed recently.
+4. The direct employer or ATS posting page must not visibly contain closed-state language.
+5. The job must not already appear in `DATA_DIR/job-history.md`.
*** End Patch
```

- [ ] **Step 3: Update browser search extraction requirements**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: skills/job-search/SKILL.md
@@
-Use Claude in Chrome MCP tools per `shared/references/browser-setup.md`, navigating to https://hiring.cafe. For each search term, enter the query and apply relevant filters (date posted, location, etc.).
+Use Claude in Chrome MCP tools per `shared/references/browser-setup.md`, navigating to https://hiring.cafe. For each search term, enter the query and apply relevant filters (date posted, location, etc.). Prefer filters that limit results to jobs posted or refreshed within the last 14 days.
@@
-If that selector doesn't match, take a screenshot to understand the page structure, then write a targeted JS selector for the specific site. The goal is to extract just the listing rows (title, company, location, salary) — never the full page.
+If that selector doesn't match, take a screenshot to understand the page structure, then write a targeted JS selector for the specific site. The goal is to extract just the listing rows (title, company, location, salary, link, and visible posted/refreshed date or freshness label) — never the full page.
*** End Patch
```

- [ ] **Step 4: Update Step 3 evaluation wording**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: skills/job-search/SKILL.md
@@
-Score each job against the candidate's resume and preferences using the criteria in `shared/references/fit-scoring.md`.
+Evaluate each job against the freshness gate first, then the candidate's resume and preferences using the criteria in `shared/references/fit-scoring.md`.
+
+Freshness rules:
+- Posted or refreshed within the last 14 days: continue to fit scoring.
+- Older than 14 days: mark `Skip` with note `Stale posting - older than 14 days`.
+- Unknown posting date with no explicit recent label: mark `Skip` with note `Unknown posting date`.
+
+Only High/Medium jobs that pass freshness should continue to employer URL resolution.
*** End Patch
```

- [ ] **Step 5: Update history table columns**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: skills/job-search/SKILL.md
@@
-| Job Title | Company | Location | Salary | Fit | Notes |
-|-----------|---------|----------|--------|-----|-------|
-| ... | ... | ... | ... | ... | ... |
+| Job Title | Company | Location | Salary | Link | Fit | Notes |
+|-----------|---------|----------|--------|------|-----|-------|
+| ... | ... | ... | ... | ... | ... | ... |
*** End Patch
```

- [ ] **Step 6: Replace Step 5 with closed-language verification**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: skills/job-search/SKILL.md
@@
-### Step 5: Resolve Employer URLs & Save Top Postings
-
-For each **High-fit** job:
-1. Click through the hiring.cafe listing to reach the actual employer careers page
-2. Capture the direct employer URL for the job posting
-3. Extract the job description using `javascript_tool` to pull the posting content (e.g. `document.querySelector('[class*="description"], [class*="content"], article, main')?.innerText`). Do NOT use `get_page_text` — employer pages often have huge footers, navs, and related listings that bloat the output and can blow out the context window.
-4. Save to `DATA_DIR/jobs/[company-slug]-[date]/posting.md` with the employer URL at the top
-
-For **Medium-fit** jobs, try to resolve the employer URL but don't save the full posting.
-
-If you can't resolve the direct link for a job, note the company name so the user can find it themselves. Never show hiring.cafe URLs to the user.
+### Step 5: Resolve Employer URLs, Check Closed Language, and Save Top Postings
+
+For each **High-fit** and **Medium-fit** job that passed freshness:
+1. Click through the hiring.cafe listing to reach the actual employer or ATS posting page.
+2. Capture the direct employer URL for the job posting. Never show hiring.cafe URLs to the user.
+3. Extract the relevant posting text using `javascript_tool` to pull the posting content (e.g. `document.querySelector('[class*="description"], [class*="content"], article, main')?.innerText`). Do NOT use `get_page_text` — employer pages often have huge footers, navs, and related listings that bloat the output and can blow out the context window.
+4. Scan the extracted posting text case-insensitively for closed-state language:
+   - `expired`
+   - `closed`
+   - `no longer accepting applications`
+   - `not accepting applications`
+   - `application period has ended`
+   - `position has been filled`
+   - `job is no longer available`
+   - `job has been removed`
+   - `posting has been taken down`
+   - `archived`
+   - `inactive`
+5. If closed-state language is found, set availability to `closed_language_found`, mark the job `Skip`, add a note such as `Closed posting` or `No longer accepting applications`, and do not present it.
+6. If no closed-state language is found, set availability to `no_closed_language_found`.
+7. If the employer page cannot be reached or parsed, mark the job `Skip` with note `Employer page could not be checked` and do not present it as a top match.
+8. Do not verify apply buttons or application forms. The availability check is only the closed-language scan.
+
+For **High-fit** jobs with `availability: no_closed_language_found`, save the full posting to `DATA_DIR/jobs/[company-slug]-[date]/posting.md` with the employer URL at the top.
+
+For **Medium-fit** jobs with `availability: no_closed_language_found`, keep the direct employer URL for presentation but don't save the full posting.
*** End Patch
```

- [ ] **Step 7: Update presentation filtering**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: skills/job-search/SKILL.md
@@
-Show only NEW High/Medium fits not in previous history.
+Show only NEW High/Medium fits that passed the 14-day freshness gate, have `availability: no_closed_language_found`, and are not in previous history.
*** End Patch
```

- [ ] **Step 8: Run the main workflow contract check after editing**

Run:

```bash
missing=0
for pattern in \
  '14 days' \
  'closed-state language' \
  'no longer accepting applications' \
  'no_closed_language_found' \
  'closed_language_found' \
  'Do not verify apply buttons or application forms'; do
  if ! rg -q "$pattern" skills/job-search/SKILL.md; then
    printf 'missing: %s\n' "$pattern"
    missing=1
  fi
done
exit "$missing"
```

Expected: PASS with no output.

- [ ] **Step 9: Review the modified main workflow**

Run:

```bash
sed -n '39,130p' skills/job-search/SKILL.md
```

Expected: The workflow contains eligibility gates, 14-day freshness, closed-state language detection, no CTA/form verification, and presentation filtering.

- [ ] **Step 10: Commit Task 2**

Run:

```bash
git add skills/job-search/SKILL.md
git commit -m "Filter closed and stale job search results"
```

Expected: Commit succeeds.

---

### Task 3: Update Job History Notes Template

**Files:**
- Modify: `skills/job-search/assets/templates/job-entry.md`

- [ ] **Step 1: Run the history template contract check before editing**

Run:

```bash
missing=0
for pattern in \
  'Stale posting - older than 14 days' \
  'Unknown posting date' \
  'Closed posting' \
  'No longer accepting applications' \
  'Employer page could not be checked'; do
  if ! rg -q "$pattern" skills/job-search/assets/templates/job-entry.md; then
    printf 'missing: %s\n' "$pattern"
    missing=1
  fi
done
exit "$missing"
```

Expected: FAIL with one or more `missing:` lines.

- [ ] **Step 2: Add freshness and availability notes**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: skills/job-search/assets/templates/job-entry.md
@@
 - "Onsite only"
 - "Requires [X] - dealbreaker"
+- "Stale posting - older than 14 days"
+- "Unknown posting date"
+- "Closed posting"
+- "No longer accepting applications"
+- "Employer page could not be checked"
*** End Patch
```

- [ ] **Step 3: Run the history template contract check after editing**

Run:

```bash
missing=0
for pattern in \
  'Stale posting - older than 14 days' \
  'Unknown posting date' \
  'Closed posting' \
  'No longer accepting applications' \
  'Employer page could not be checked'; do
  if ! rg -q "$pattern" skills/job-search/assets/templates/job-entry.md; then
    printf 'missing: %s\n' "$pattern"
    missing=1
  fi
done
exit "$missing"
```

Expected: PASS with no output.

- [ ] **Step 4: Commit Task 3**

Run:

```bash
git add skills/job-search/assets/templates/job-entry.md
git commit -m "Document job search skip reasons"
```

Expected: Commit succeeds.

---

### Task 4: Final Verification

**Files:**
- Verify: `skills/job-search/SKILL.md`
- Verify: `skills/job-search/scripts/evaluate-jobs.md`
- Verify: `skills/job-search/assets/templates/job-entry.md`

- [ ] **Step 1: Verify there are no unresolved placeholder markers in changed files**

Run:

```bash
rg -n 'PLACEHOLDER|unresolved marker' \
  skills/job-search/SKILL.md \
  skills/job-search/scripts/evaluate-jobs.md \
  skills/job-search/assets/templates/job-entry.md
```

Expected: Exit code 1 with no output.

- [ ] **Step 2: Verify closed-language phrases are present in the main skill**

Run:

```bash
for pattern in \
  'expired' \
  'closed' \
  'no longer accepting applications' \
  'not accepting applications' \
  'application period has ended' \
  'position has been filled' \
  'job is no longer available' \
  'job has been removed' \
  'posting has been taken down' \
  'archived' \
  'inactive'; do
  rg -q "$pattern" skills/job-search/SKILL.md || exit 1
done
```

Expected: PASS with no output.

- [ ] **Step 3: Verify the implementation matches the approved non-goal**

Run:

```bash
rg -n 'Do not verify apply buttons or application forms|closed-language scan' skills/job-search/SKILL.md
```

Expected: Output includes the Step 5 instruction saying not to verify apply buttons or application forms.

- [ ] **Step 4: Inspect the final diff**

Run:

```bash
git show --stat --oneline HEAD~3..HEAD
git diff HEAD~3..HEAD -- skills/job-search/SKILL.md skills/job-search/scripts/evaluate-jobs.md skills/job-search/assets/templates/job-entry.md
```

Expected: Diff only touches the three job-search skill files and reflects the approved freshness/closed-language behavior.

- [ ] **Step 5: Confirm clean working tree**

Run:

```bash
git status --short
```

Expected: No output.
