# jobs-agent

A agent skill / claude plugin for AI-powered job searching, resume tailoring, and cover letter writing. 

| Skill | Command | Description |
|-------|---------|-------------|
| [Setup](./skills/setup/) | `/jobs-agent:setup` | One-time onboarding: resume, preferences, LinkedIn contacts, and work history interview |
| [Job Search](./skills/job-search/) | `/jobs-agent:job-search` | Automated job search with smart filtering and network matching |
| [Tailor Resume](./skills/tailor-resume/) | `/jobs-agent:tailor-resume` | Create tailored resumes for specific job postings |
| [Cover Letter](./skills/cover-letter/) | `/jobs-agent:cover-letter` | Write natural, persuasive cover letters |
| [Network Scan](./skills/network-scan/) | `/jobs-agent:network-scan` | Scan your contacts' companies for matching job openings |
| [Apply](./skills/apply/) | `/jobs-agent:apply` | Fill out job applications on Greenhouse, Lever, and Workday |
| [Telegram Loop](./skills/jobsearch-telegram/) | `/jobs-agent:jobsearch-telegram` | Headless job search assistant via Telegram — apply, search, and check status by chat |

## How They Work Together

1. **`/jobs-agent:setup`** uploads your resume, configures preferences, imports LinkedIn contacts, and conducts a work history interview (one-time)
2. **`/jobs-agent:job-search`** finds jobs that match your preferences and resume, flags companies where you have connections
3. **`/jobs-agent:tailor-resume`** rewrites your resume for a specific job posting, saves the job posting and tailored resume together
4. **`/jobs-agent:cover-letter last`** writes a cover letter using the most recent job's posting and tailored resume
5. **`/jobs-agent:apply last`** fills out the application form on Greenhouse, Lever, or Workday using your tailored resume and cover letter
6. **`/jobs-agent:network-scan`** scans your LinkedIn contacts' companies for matching openings (leverages your network for warm intros)
7. **`/loop 1m /jobs-agent:jobsearch-telegram`** runs the Telegram bot in the background — send a job URL or "search [keywords]" from your phone to trigger any of the above automatically

All skills share a `~/.jobs-agent/` directory for personal files. Each job application gets its own folder containing the posting, tailored resume, and cover letter.

## Installation

### Option A: Claude Cowork (desktop app)

1. Download [Claude Cowork](https://claude.com/product/cowork) if you haven't already
2. Download the plugin as a zip from GitHub: [Download ZIP](https://github.com/hassanshabbirahmed/jobs-agent/archive/refs/heads/main.zip)
3. In Cowork, go to **Plugins** (left sidebar) and click the **+** button
4. Select **Upload plugin**
5. Drag and drop the downloaded zip file, then click **Upload**
6. Run `/jobs-agent:setup` to get started

### Option B: Claude Code CLI

First, add the repository as a marketplace:

```bash
claude plugin marketplace add https://github.com/hassanshabbirahmed/jobs-agent.git
```

Then install the plugin:

```bash
claude plugin install jobs-agent@jobs-agent
```

Then run setup:

```
/jobs-agent:setup
```

### Option C: Codex

Codex uses [Agent Skills](https://developers.openai.com/codex/skills): folders with a `SKILL.md` file plus optional scripts, references, and assets. Codex discovers repo-scoped skills from `.agents/skills` in the current working directory and parent folders up to the repository root, so you can enable jobs-agent only for this checkout without installing it globally.

From this repository:

```bash
mkdir -p .agents
ln -s ../skills .agents/skills
```

If you prefer copying instead of symlinking:

```bash
mkdir -p .agents/skills
cp -R skills/* .agents/skills/
```

To install jobs-agent for a different folder, create that folder's `.agents/skills` directory and copy these skill folders there. Also keep this repo's `shared/` directory at that folder's root, because the skills reference the shared templates and reference docs.

Restart Codex or start a new Codex session from this folder:

```bash
codex
```

Codex uses the `name` field in each `SKILL.md`, so explicit skill invocations are `$setup`, `$job-search`, `$tailor-resume`, `$cover-letter`, `$network-scan`, `$apply`, and `$jobsearch-telegram`. The `/jobs-agent:...` commands above are for Claude plugin usage.

### After installing

Setup will create `~/.jobs-agent/`, prompt you for your resume, configure your job preferences, optionally import your LinkedIn contacts, and conduct a work history interview.

You can also add your resume manually first:

```bash
mkdir -p ~/.jobs-agent/resume
cp /path/to/your/resume.pdf ~/.jobs-agent/resume/
```

## Prerequisites

- [Claude Cowork](https://claude.com/product/cowork) desktop app **or** [Claude Code CLI](https://claude.ai/code)
- [Claude in Chrome](https://chromewebstore.google.com/detail/claude-in-chrome) extension (for browser automation)
- Chrome browser running with the extension active

## File Structure

**Plugin (installed via marketplace):**
```
jobs-agent/
├── .claude-plugin/
│   └── plugin.json                     # Plugin manifest
├── shared/
│   ├── templates/
│   │   └── profile.md                  # Work history profile template
│   └── references/
│       ├── fit-scoring.md              # Canonical fit scoring criteria
│       ├── data-directory.md           # Data directory resolution algorithm
│       ├── prerequisites.md            # Prerequisites checking by skill
│       ├── browser-setup.md            # Browser automation setup sequence
│       ├── ats-patterns.md            # ATS navigation patterns (Greenhouse, Lever, Workday)
│       └── priority-hierarchy.md       # Instruction priority hierarchy
├── skills/
│   ├── setup/
│   │   ├── SKILL.md
│   │   └── scripts/
│   ├── job-search/
│   │   ├── SKILL.md
│   │   ├── assets/templates/
│   │   └── scripts/
│   ├── tailor-resume/
│   │   ├── SKILL.md
│   │   └── scripts/
│   ├── cover-letter/
│   │   ├── SKILL.md
│   │   └── scripts/
│   ├── network-scan/
│   │   ├── SKILL.md
│   │   └── scripts/
│   ├── apply/
│   │   ├── SKILL.md
│   │   └── scripts/
│   └── jobsearch-telegram/
│       └── SKILL.md
└── README.md
```

**User data (created by `/jobs-agent:setup`, persists across plugin updates):**
```
~/.jobs-agent/
├── resume/                             # Your resume PDF/DOCX
├── profile.md                          # Work history from interview
├── preferences.md                      # Job matching rules
├── linkedin-contacts.csv               # LinkedIn connections (optional)
├── job-history.md                      # Running log from job-search
├── company-careers.json                # Cached careers page URLs
├── network-scan-history.md             # Running log from network-scan
├── application-data.md                # Reusable form field answers
└── jobs/                               # One folder per application
    ├── google-lead-gpm-2026-02-11/
    │   ├── posting.md                  # Saved job description
    │   ├── resume.md                   # Tailored resume
    │   ├── cover-letter.md             # Cover letter
    │   └── applied.md                  # Application log (date, ATS, status)
    └── ...
```

## Built by jobs-agent

This plugin is free and open source. If you'd rather have someone handle the whole process for you — finding jobs, tailoring resumes, writing cover letters, submitting applications, and connecting you with hiring managers — visit [github.com/hassanshabbirahmed/jobs-agent](https://github.com/hassanshabbirahmed/jobs-agent).

## License

MIT
