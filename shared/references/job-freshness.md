# Job Freshness Rules

Canonical freshness definitions for the `job-search` skill and its subagents. A listing is always classified into exactly one state before fit scoring decides how it is shown.

## States

| State | Meaning | What happens |
|-------|---------|--------------|
| `fresh` | Posted or refreshed within the last 14 days, or the source explicitly labels it new, recent, posted today, or refreshed recently | Continues to fit scoring and the normal lanes |
| `stale` | Posted or refreshed more than 14 days ago, or `validThrough` is in the past | `Skip` with note `Stale posting - older than 14 days` |
| `unknown` | No posting date could be found after the inference steps below | Eligible only for the **Date unverified** lane, never for Top Matches or Stretch |

Freshness is an eligibility gate, not a scoring preference. Dealbreakers still override everything.

## Date Sources

Record where the date came from in `date_source`. Use the first source that yields a date:

| `date_source` | Where it comes from |
|---------------|---------------------|
| `listed` | A posted/refreshed date or "N days ago" shown on the listing row of the board or careers page |
| `label` | An explicit label such as "New", "Posted today", "Recently updated" |
| `structured_data` | `datePosted` (or `dateModified`) in the posting's JSON-LD |
| `visible_text` | "Posted N days ago", "Updated ...", or a similar date in the posting body |
| `ats_metadata` | A date the ATS page itself exposes (listing metadata, feed, or sitemap `lastmod`) |
| `none` | No date found |

`dateModified` and "updated" dates count as refreshed. A `validThrough` date in the past means the posting has expired: classify as `stale`.

## Inference for Undated Listings

Many small and niche employers publish postings with no visible date. Before leaving a listing `unknown`, try these in order when you have the employer or ATS posting page open (job-search Step 5):

1. Read structured data. This is small and safe to run:

```javascript
Array.from(document.querySelectorAll('script[type="application/ld+json"]'))
  .map(s => s.textContent)
  .filter(t => /datePosted|dateModified|validThrough/i.test(t))
  .map(t => t.slice(0, 1500))
  .join('\n---\n')
```

2. Scan the extracted posting text for "posted", "updated", "days ago", or "ago" near a date.
3. If the ATS exposes a feed or sitemap with `lastmod`, use it only if it is one cheap fetch. Do not crawl.

If a date is found, reclassify the listing as `fresh` or `stale` and set `date_source` accordingly. If none is found, keep `unknown` and `date_source: none`.

## Date Unverified Lane

Listings that remain `unknown` are not discarded, but they are held to a stricter bar than dated listings:

- They must pass dealbreakers and score High or Medium.
- They must pass the closed-state language check on the direct employer or ATS page. If the employer page cannot be reached, they are `Skip`.
- They are shown in a separate **Date unverified** section, capped at 5 per run, ordered by fit.
- They are labeled so the user knows the age is unconfirmed.

They never appear under Top Matches or Stretch.
