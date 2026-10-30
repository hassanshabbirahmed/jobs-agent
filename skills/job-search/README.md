# Job Search Skill for Claude Code

An automated job search skill that uses browser automation to find and evaluate job listings from [hiring.cafe](https://hiring.cafe), niche and startup boards, ATS-hosted postings, and a rotating pool of company careers pages.

## Features

- **Global coverage across US, Europe/UK, and GCC/MENA**: searches hiring.cafe, European & GCC regional tech boards (Welcome to the Jungle, Otta, EuroTechJobs, Relocate.me, Station F, Hub71, DFDF, GulfTalent), VC portfolio boards (Sequoia, a16z, Index, Balderton, Northzone, Creandum, Earlybird, Seedcamp, Hub71, STV, Shorooq), global & regional ATS platforms (Greenhouse, Lever, Ashby, Dover, Gem, Personio, Teamtailor, Recruitee, Softgarden, ZenHR, Notion workspaces), founder social hiring signals, and company careers pages
- **Query expansion** into exact titles, synonyms, adjacent roles, and skills-only searches, with adjacent finds shown in a separate Stretch section
- **Funding-to-hiring company discovery (US, Europe & GCC)** from funding wires (TechCrunch, Sifted, EU-Startups, Tech.eu, Wamda, Magnitt, Zawya), PR announcements, and US/European/GCC investor portfolios, giving newly funded startups a fast-track 48-hour check cadence and capturing open/speculative application portals before specific roles are posted
- **Undated postings kept honestly**: dates are read from structured data and posting text, and jobs that still have no date go in a Date unverified section instead of being dropped
- **Learns what works** through a search log that promotes productive queries and retires dead ones
- **Automated daily search** via cron job
- **Smart filtering** based on your preferences (salary, location, dealbreakers)
- **Job history tracking** to avoid showing duplicates
- **Learning from feedback** - refine preferences over time
- **Browser automation** via Claude in Chrome MCP

## Prerequisites

1. [Claude Code CLI](https://claude.ai/code) installed
2. [Claude in Chrome](https://chromewebstore.google.com/detail/claude-in-chrome) extension installed
3. Chrome browser running with the extension active

## Installation

### 1. Clone to your skills directory

```bash
git clone https://github.com/YOUR_USERNAME/job-search-skill.git ~/.claude/skills/job-search
```

### 2. Run setup

```bash
claude "/jobs-agent:setup"
```

This will configure your resume, preferences, and work history profile.

## Usage

### Daily search (manual)
```bash
claude "/job-search"
```

### Search with specific keywords
```bash
claude "/job-search AI infrastructure"
claude "/job-search remote startup"
```

### Narrow, faster search
```bash
claude "/job-search AI infrastructure --exact"
```

`--exact` searches hiring.cafe only, with your exact keywords. The default is wide: expanded queries, niche boards, ATS postings, and the company pool.

### Run headless (for cron)
```bash
claude -p "/job-search"
```

## File Structure

**Plugin files:**
```
job-search/
├── SKILL.md                      # Main skill definition
├── README.md                     # This file
├── assets/
│   └── templates/                # Format templates (committed)
│       ├── job-entry.md          # Format for history entries
│       ├── search-log-init.md    # Starting point for the search log
│       └── sources-init.md       # Starting point for added/retired sources
└── scripts/
    ├── evaluate-jobs.md          # Job evaluation subagent
    ├── scan-sources.md           # Niche boards and ATS web search subagent
    ├── scan-careers.md           # Company careers page subagent
    └── discover-companies.md     # Finds new target companies
```

Shared references: `shared/references/job-freshness.md` and `shared/references/job-sources.md`.

**User data (at `~/.jobs-agent/`):**
```
~/.jobs-agent/
├── resume/                       # Your resume PDF/DOCX
├── preferences.md                # Job matching rules
├── job-history.md                # Log of all jobs found
├── sources.md                    # Job sources you added or retired
├── search-log.md                 # Which queries and sources have worked
├── discovered-companies.json     # Company pool scanned directly
└── jobs/                         # Per-job application folders
```

## Configuration

### Matching Rules (`~/.jobs-agent/preferences.md`)

Customize your job preferences:

```markdown
## Target Roles
- VP Growth
- Head of Growth
- Director of Marketing

## Must-Have Criteria
- Remote or hybrid OK
- Minimum $250k+ total comp

## Dealbreakers
- Marketing agencies
- Crypto/blockchain
- >25% travel required

## Nice-to-Have
- Series B+ startup
- AI/ML focus
- B2B SaaS
```

### Updating Preferences

Just tell Claude what you want:
- *"Add fintech to my nice-to-haves"*
- *"I don't want any roles requiring relocation"*
- *"Bump my minimum salary to $300k"*

The skill will update `~/.jobs-agent/preferences.md` automatically.

## Job History

All jobs found are logged to `~/.jobs-agent/job-history.md` with:
- Date and search terms
- Job details (title, company, location, salary)
- Fit score (High/Medium/Low/Skip)
- Notes explaining the rating

This prevents showing you the same jobs twice and creates a searchable archive. Each row also records the lane (Top, Stretch, or Unverified) and the source that found it.

## Customizing Sources

Default sources live in `shared/references/job-sources.md`. Your changes go in `~/.jobs-agent/sources.md`:
- *"Add source climatebase.org"* adds a board
- *"Drop Wellfound"* retires one
- Sources that fail twice or produce nothing useful for three runs in a row are retired automatically, and the skill tells you.

Some sites block automation or need a login. The skill skips those instead of working around them.

## Cron Setup

To run daily at 9am:

```bash
# Add to crontab
(crontab -l 2>/dev/null; echo "0 9 * * * cd ~ && claude -p '/job-search' >> ~/.claude/skills/job-search/logs/cron.log 2>&1") | crontab -
```

**Note**: Requires Chrome to be running with Claude in Chrome extension active.

## Troubleshooting

### Permission prompts interrupting cron
Ensure all permissions are in `~/.claude/settings.json` (see Installation step 3).

### Browser not responding
Make sure Chrome is running and Claude in Chrome extension is active.

### No jobs found
- Check that hiring.cafe is accessible
- Try different search terms
- Verify your matching rules aren't too restrictive
- Check `~/.jobs-agent/search-log.md` to see which sources and queries were retired, and add sources with "add source [name]"


## Roadmap

### v0.1 - Current
- [x] Automated job search on hiring.cafe
- [x] Smart filtering (salary, location, dealbreakers)
- [x] Job history tracking
- [x] Daily cron automation
- [x] Self-configuring setup flow

### v0.2 - Work History Interview
- [ ] Interactive interview to capture detailed work history
- [ ] Deep-dive on accomplishments, metrics, and impact
- [ ] Store structured work history in `assets/work-history.md`
- [ ] Use as foundation for all application materials

### v0.3 - Tailored Applications
- [ ] Generate customized resume for each target job
- [ ] Generate tailored cover letters highlighting relevant experience
- [ ] Match work history accomplishments to job requirements
- [ ] Store generated materials in `assets/applications/`

### v0.4 - Proactive Company Research
- [x] Research companies beyond job boards
- [x] Identify target companies based on preferences (industry, stage, culture)
- [ ] Track companies not currently hiring but worth monitoring
- [ ] Alert when target companies post new roles

### Future Ideas
- Support for login-only boards (LinkedIn, Indeed, etc.)
- Email digest of daily results
- Integration with ATS/application tracking
- Interview prep based on job description + work history

## Contributing

PRs welcome! Check the roadmap above for planned features, or open an issue to discuss new ideas.

## License

MIT
