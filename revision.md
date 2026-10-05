# Revision Notes

**Date:** 2026-10-05
**Scope:** Structural and build-consistency review (wave 1 — correctness)
**Author:** automated review pass

Part of a workspace-wide standard for all six books, documented at
`../BOOK-STRUCTURE-CHECKLIST.md`. This file records only what changed in
**this** repository.

---

## Summary

One change: a root `LICENSE` file was added.

No content, structure, configuration or CI changes were made to this repository
in this pass. It was reviewed and found to need no wave-1 corrections.

---

## 1. LICENSE added

`LICENSE` — verbatim CC BY-NC-SA 4.0 International legal code (438 lines),
fetched from `creativecommons.org`. License text is never reconstructed from
memory.

This is the substantive finding for this book: CC BY-NC-SA 4.0 was declared on
a licence line in the Preface, but **no `LICENSE` file existed** in any of the
six books. The declaration was prose-only and unenforceable by tooling or by
anyone cloning the repository.

---

## Verification

- `LICENSE` is byte-identical (SHA256) across all six books.
- LF line endings.
- Confirmed visible to git as a new file and matched by no ignore rule.
- No render was necessary — nothing else in this book changed.

---

## Before committing

- Suggested message: `chore: add LICENSE`

---

## Not done here (tracked in the workspace checklist)

This book needed no wave-1 corrections, so the open items are all later-wave
work:

- **No `renv.lock` or `.Rprofile`** — package versions are unpinned locally.
  CI installs from a hard-coded list against a `packagemanager.posit.co`
  snapshot. Wave 9.
- **Deploys to GitHub Pages but ships a `_redirects` file.** `_redirects` is
  Netlify-specific and is ignored by GitHub Pages, so those two rules
  (`/sqlbasics.html` → `/sql-basics.html`, `/sql2.html` → `/sql-advanced.html`)
  are dead config. Migrating to Netlify resolves this properly — wave 4.
- **No `netlify.toml`** and **no slug gate in CI.** Every other book asserts
  that each `_quarto.yml` slug rendered; this one does not, which is how
  `viz-base` lost its `references.html` page silently in the first place.
  Wave 3.
- **`sitemap.xml` is absent from `project.resources`**, so it never reaches
  `docs/`. It is also incomplete: it omits both appendix pages
  (`production.html`, `duckdb.html`) and lists `cheatsheet/dbi-cheatsheet.pdf`
  but not the `cheatsheet.html` chapter. Wave 3.
- CI makes PDF and ePub non-fatal (`|| echo "PDF_FAILED=1"`). Wave 2.
- **PDF engine is Typst, consistent with house standard** — but Quarto is
  pinned to `1.10.18` while house standard is `1.6.40`. Bump or pin
  deliberately, and pair any change with the Typst version. Wave 2.
- `dbi.qmd` is the largest chapter in the book (322 lines) and has no
  exercises; only 3 of 7 chapters do. Wave 7.
- Chapter H1 discipline, `{.unnumbered}` usage, and solutions pointers already
  conform — the `solutions/` folder is referenced correctly from all three
  chapters that have exercises. **This is the pattern the other books should
  copy**: `code/ch1`–`ch7` are numbered to match render order and every one is
  linked from its chapter.
- `AGENTS.md` is still the shared 300-byte boilerplate, carrying no
  book-specific state.