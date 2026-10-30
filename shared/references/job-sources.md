# Job Sources Registry

Default sources for the `job-search` skill, beyond hiring.cafe. These are starting points chosen by role domain. Pick the ones that match the candidate's target roles and nice-to-haves; do not run all of them every time.

User changes live in `DATA_DIR/sources.md` (added and retired sources). The skill's search log retires sources that stop producing results, so a stale or broken entry here costs little.

## Rules

- These sites change. Treat every entry as a starting point and verify it loads before relying on it. Mark sources that fail twice as retired in `DATA_DIR/sources.md`.
- Skip any source that needs a login, shows a CAPTCHA, or blocks automation. Do not try to get around it.
- Respect each site's terms and robots rules. Browse listing pages the way a person would; do not crawl or hammer a site.
- Never show an aggregator URL to the user. Resolve the direct employer or ATS posting URL for every result you present.
- Use the same context-safe extraction as the rest of the skill: `javascript_tool` or `read_page`, never `get_page_text` on listing pages. See `shared/references/browser-setup.md`.

## General and Remote

| Source | URL | Best for |
|--------|-----|----------|
| Remote OK | https://remoteok.com | Remote roles, tech-leaning |
| We Work Remotely | https://weworkremotely.com | Remote roles across functions |
| Remotive | https://remotive.com | Remote roles |
| EuroTechJobs | https://www.eurotechjobs.com | Pan-European tech & engineering roles (often visa-sponsoring) |
| Built In | https://builtin.com/jobs | US tech companies by city |
| Welcome to the Jungle | https://www.welcometothejungle.com | Culture-forward companies in Europe (France, UK, Germany) & US |

## Regional Startup & Tech Hubs (Europe & GCC / MENA)

Use the rows matching the candidate's target regions (US, Europe/UK, GCC/MENA, or remote across timezones):

### Europe & UK
| Source | URL / Search Pattern | Best for |
|--------|----------------------|----------|
| Welcome to the Jungle | https://www.welcometothejungle.com | European & UK tech startups and scaleups |
| Otta (Welcome to the Jungle UK) | https://app.otta.com (skip if login required) | Curated UK & European tech startups |
| Relocate.me | https://relocate.me | European tech companies offering relocation/visa support |
| GermanTechJobs / SwissDevJobs | https://germantechjobs.de, https://swissdevjobs.ch | DACH region tech roles with transparent salaries |
| Station F Job Board | https://jobs.stationf.co | Early-stage French & European startups at Station F |
| Silicon Milkroundabout / Cord | https://cord.co (skip if login required) | UK & European startup engineering/product roles |

### GCC & MENA (UAE, Saudi Arabia, Qatar, Bahrain, Kuwait, Oman)
| Source | URL / Search Pattern | Best for |
|--------|----------------------|----------|
| Hub71 Jobs (Abu Dhabi) | `site:jobs.hub71.com "[title]"` or browse https://jobs.hub71.com | Abu Dhabi tech ecosystem & funded Hub71 startups |
| Dubai Future District Fund (DFDF) | `site:jobs.dfdf.vc "[title]"` | Dubai venture-backed startups |
| Wamda / Magnitt Ecosystem | `site:wamda.com` / `site:magnitt.com` (via `WebSearch` for hiring/funding) | MENA startup ecosystem & newly funded GCC companies |
| GulfTalent | https://www.gulftalent.com | Senior tech, Sovereign Wealth / Giga-project, and enterprise roles across UAE, KSA, Qatar |
| Naukrigulf | https://www.naukrigulf.com | Tech and product roles across Dubai, Abu Dhabi, Riyadh, Doha |
| Bayt | https://www.bayt.com | Broad MENA & GCC tech/corporate roles (filter by UAE/KSA/Qatar) |

## Startup (Global)

| Source | URL | Best for |
|--------|-----|----------|
| Work at a Startup | https://www.workatastartup.com | YC-backed companies worldwide (some views need a login: skip those) |
| Wellfound | https://wellfound.com/jobs | Early-stage startups globally (often blocks automation: skip if it does) |
| Hacker News "Who is hiring?" | https://news.ycombinator.com (search for the latest monthly thread) | Global small companies and founder-posted roles (US, EU, UK, remote, MENA) |

For the HN thread, open only the most recent thread. Comments usually open with a line separated by `|` (company, role, location, remote). Extract those first lines with `javascript_tool`, filtering for the query keywords, instead of reading the whole page.

## VC Talent Networks (Getro & Consider Boards — US, Europe & GCC)

Major VC firms across the US, Europe, and GCC maintain live portfolio job boards powered by Getro or Consider that index stealth and recently funded portfolio startups before they rank on Google or aggregators. Search these via `WebSearch` (or browse if needed):

| VC Network | Region | URL / Search Pattern | Best for |
|------------|--------|----------------------|----------|
| Sequoia Capital | US / Global | `site:jobs.sequoiacap.com "[title]"` | Seed to growth portfolio companies |
| Andreessen Horowitz (a16z) | US / Global | `site:jobs.a16z.com "[title]"` | AI, infra, bio, fintech, and consumer startups |
| Bessemer Venture Partners | US / Global | `site:jobs.bvp.com "[title]"` | Cloud, B2B SaaS, and deep tech startups |
| Khosla Ventures | US | `site:jobs.khoslaventures.com "[title]"` | AI, climate, health, and frontier tech startups |
| Greylock | US | `site:jobs.greylock.com "[title]"` | Early-stage enterprise and AI startups |
| General Catalyst | US / Europe | `site:jobs.generalcatalyst.com "[title]"` | Seed to Series B startups in US, UK, and EU |
| Index Ventures | Europe / US | `site:indexventures.com/startup-jobs "[title]"` | European & US venture-backed startups |
| Balderton Capital | Europe / UK | `site:jobs.balderton.com "[title]"` | Leading European Seed to Series B startups |
| Northzone | Europe / Nordics / UK | `site:jobs.northzone.com "[title]"` | European & Nordic tech startups |
| Creandum | Europe / Nordics | `site:jobs.creandum.com "[title]"` | Early-stage European tech companies |
| Earlybird Venture Capital | Europe / DACH | `site:jobs.earlybird.com "[title]"` | German, DACH, and pan-European startups |
| Atomico | Europe | `site:jobs.atomico.com "[title]"` | European growth-stage scaleups |
| Seedcamp | Europe / UK | `site:jobs.seedcamp.com "[title]"` | Pre-seed and Seed European startups |
| Point Nine | Europe | `site:jobs.pointnine.com "[title]"` | European B2B SaaS and marketplace startups |
| LocalGlobe / Latitude | UK / Europe | `site:jobs.localglobe.vc "[title]"` | UK & European Seed/Series A startups |
| Hub71 (Mubadala) | GCC (Abu Dhabi) | `site:jobs.hub71.com "[title]"` | Abu Dhabi & MENA funded startups |
| Dubai Future District Fund | GCC (Dubai) | `site:jobs.dfdf.vc "[title]"` | UAE & MENA venture-backed startups |
| Shorooq Partners /BECO / STV / Wa'ed | GCC (KSA / UAE) | Search `"Shorooq Partners" OR "STV" OR "Wa'ed Ventures" OR "Sanabil" portfolio careers "[title]"` | Saudi Arabia (Riyadh) & UAE (Dubai/Abu Dhabi) funded startups |

When `discover-companies.md` surfaces a newly funded startup's **lead investor**, also check if that investor runs a `jobs.[vc-domain].com` board and add productive ones to `DATA_DIR/sources.md`.

## By Domain

Use only the rows that match the candidate's domain.

| Domain | Sources |
|--------|---------|
| AI / ML | https://aijobs.net |
| Climate / energy | https://climatebase.org/jobs |
| Impact / policy / nonprofit | https://80000hours.org/jobs, https://www.idealist.org |
| Crypto / web3 | https://web3.career, https://cryptocurrencyjobs.co (check dealbreakers first) |
| Higher education | https://www.higheredjobs.com |
| Government | https://www.usajobs.gov |
| Design | https://dribbble.com/jobs |

If the candidate's domain is not listed, find two or three niche boards with `WebSearch` (for example `"[domain] job board"`), note them in `DATA_DIR/sources.md` under Added sources, and let the search log decide whether they stay.

## ATS and Lightweight Startup Workspace Search Patterns

Small companies and newly funded startups often post only on their own ATS board or a public Notion page and never reach aggregators. Find those postings with `WebSearch`, no browser needed. Run one query per pattern per search term:

**Standard, European, GCC & Startup-Native ATS:**
```
site:boards.greenhouse.io "[title]"
site:job-boards.greenhouse.io "[title]"
site:boards.eu.greenhouse.io "[title]"
site:jobs.lever.co "[title]"
site:jobs.eu.lever.co "[title]"
site:jobs.ashbyhq.com "[title]"
site:app.dover.com "[title]"
site:jobs.gem.com "[title]"
site:ats.rippling.com "[title]"
site:apply.workable.com "[title]"
site:jobs.smartrecruiters.com "[title]"
site:pinpointhq.com "[title]"
site:breezy.hr "[title]"
site:jobs.personio.de "[title]"
site:jobs.personio.com "[title]"
site:jobs.teamtailor.com "[title]"
site:career.softgarden.de "[title]"
site:recruitee.com "[title]"
site:careers.zenhr.com "[title]"
```

**No-ATS Public Workspaces (common at Seed and freshly funded Series A):**
```
site:notion.site ("we're hiring" OR "open roles" OR "join us") "[title]"
```

## Social & Founder Hiring Signals (Pre-ATS)

Founders and early talent leads across the US, Europe, and GCC frequently announce roles on LinkedIn or X right after closing a seed or Series A round—days or weeks before setting up an ATS. Run these `WebSearch` queries using Tier 1 and Tier 2 titles or core skills:

```
site:linkedin.com/posts ("just raised" OR "seed" OR "series A" OR "out of stealth") ("hiring" OR "looking for") "[title]"
site:x.com ("we raised" OR "announcing our" OR "hiring our first" OR "join us as") "[title]"
```

Add regional/city hubs or `remote` to the query when the preferences require it (for example `"London" OR "Berlin" OR "Amsterdam" OR "Paris"` for Europe, or `"Dubai" OR "Abu Dhabi" OR "Riyadh" OR "UAE" OR "Saudi"` for GCC). Use the result snippet for title, company, and any date; the posting page (or linked Notion/ATS doc) supplies the rest in Step 5.
