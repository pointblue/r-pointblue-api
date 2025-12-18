---
title: Setting `PB_API_KEY` for R Clients
search: true
headingLevel: 2
---

**⚠️ SECURITY ADVISORY ⚠️**

**Your API key is like a password - keep it secure!**  

  - ❌ Never commit API keys to version control (git, GitHub, etc.)
  - ❌ Never share API keys in emails, Slack, or other messaging
  - ❌ Never hardcode API keys in scripts you share with others
  - ✅ Pass API keys as command-line arguments (as shown in examples)
  - ✅ Store API keys in secure password managers
  - ✅ Generate new keys if you suspect one has been compromised

# R Environment Setup

The Warehouse API snippets assume your R process can read the `PB_API_KEY`
environment variable. Use whichever option matches how you run code:

## 1. One-off interactive session

```r
Sys.setenv(PB_API_KEY = "paste-your-api-key-here")
```

Call this once per R session (before any `GET()` calls). The value lives only in
memory and disappears when you close R.

## 2. `.Renviron` for repeat use

Create or edit `~/.Renviron` and add:

```
PB_API_KEY=paste-your-api-key-here
```

Restart R so it reloads `.Renviron`. The variable is then available to every R
session on that machine.

## 3. Project-specific `.Renviron`

If you prefer to scope the key to a single project, add the same line to a
`.Renviron` file inside that project directory (e.g., the folder with your
R scripts). Call `readRenviron(".Renviron")` at the start of your script or let
RStudio load it automatically when the project opens.

## 4. Shell export before launching R

When running R from a terminal:

```bash
export PB_API_KEY="paste-your-api-key-here"
Rscript your_script.R
```

The variable stays defined until you close the shell (or `unset PB_API_KEY`).

---

Whichever method you choose, confirm it works with:

```r
Sys.getenv("PB_API_KEY")
```

It should return the key (or an empty string if not set). Remember to rotate
keys regularly and never commit them to version control.***
