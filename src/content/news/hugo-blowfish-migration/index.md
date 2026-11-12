---
title: "The site moves to Hugo and Blowfish"
date: 2026-11-12
categories: ["Site"]
tags: ["Hugo", "Blowfish", "maintenance"]
summary: "sat-wiki.github.io went from a handful of hand-written pages to a Hugo build, with source and output kept apart and old URLs left in place."
---

Before this change sat-wiki.github.io held a few loose pages: an interactive script under `/chunqiu/`, a TLE analyzer under `/tools/`, and no home page at all, so the bare domain returned 404. The whole site now builds with Hugo on the Blowfish theme, which gives news and technical posts a shared list view, taxonomy and RSS feed.

What changed:

1. **Source and output are separate.** The Hugo project lives in `src/`; the built files are published to the repository root, which is where GitHub Pages has always read from, so no repository setting had to move.
2. **Old URLs survive.** `/chunqiu/`, `/tools/tle_data_analyzer.html` and the font files moved into `src/static/`, and the build writes them back to the same paths. Existing external links keep working.
3. **Two kinds of content.** `/news/` holds dated posts in reverse order; `/space-systems/` holds long-form technical pieces with tables of contents, formulas, code and series grouping. Both appear in the feed.
4. **The toolchain is pinned.** Blowfish v3 requires Hugo Extended 0.162 or newer; this build used 0.169. The theme is a git submodule, so upgrading means moving the submodule pointer.

Day-to-day maintenance: edit the Markdown under `src/content/`, then run `./deploy.ps1` to build and push.
