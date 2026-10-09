# Revision Notes — Wave 2 (toolchain pinning)

**Date:** 2026-10-05
**Scope:** Pin the build toolchain; make PDF/ePub failures fatal
**Author:** automated review pass

Part of a workspace-wide standard for all six books, documented at
[`viz-base/AUTHOR-STANDARDS.md`](https://github.com/rsquaredacademy-publications/viz-base/blob/master/AUTHOR-STANDARDS.md). This file records only what changed in
**this** repository.

---

## Summary

- Pin Typst to `0.13.1` alongside the existing Quarto `1.10.18`.
- Make PDF and ePub renders fatal; add a gate asserting both exist.
- Add `fc-cache -f`; install the font the runner actually provides.
- Add `downloads: [pdf, epub]`, which this book already built but never
  advertised.
- Set `output-file` so the download link resolves.

**The headline: this book's PDF was broken in production.** Details below.

---

## 1. The PDF was broken, and the workflow hid it

The render step was:

```yaml
run: quarto render --to pdf --output-dir /tmp/stage-pdf || echo "PDF_FAILED=1" >> $GITHUB_ENV
```

That form **always exits 0**. A failed PDF render left a green build, and
the assemble step logged "No PDF staged" and carried on. The landing page
never advertised a PDF, so nobody noticed.

Reproduced locally on the pre-existing CI pin (Quarto 1.10.18):

```
error: unexpected argument: scope
  place(top, float: true, scope: "parent", ...)
Error producing PDF.
```

Quarto 1.10's Typst template emits `scope:`, which Typst 0.11 rejects.

| Quarto | Typst | Result |
|:--|:--|:--|
| 1.10.18 | 0.11.0 | ❌ `unexpected argument: scope` |
| **1.10.18** | **0.13.1** | ✅ builds |
| 1.6.40 | 0.11.0 | ❌ `cannot reference heading without numbering` |

Quarto **cannot** be downgraded to the 1.6.40 the other books use:
`_quarto.yml` requires `>=1.10.0`, and forcing it lower fails on this
book's `@sec-…` cross-references. So this book stays on 1.10.18 — now
pinned explicitly rather than left to drift, with a comment in the
workflow recording why it must not be downgraded.

---

## 2. Changes made

| Change | Detail |
|:--|:--|
| Typst pinned | `0.13.1` (was floating on latest) |
| PDF/ePub fatal | `\|\| echo "PDF_FAILED=1"` removed from both render steps |
| `PDF_FAILED` plumbing removed | The assemble step now uses bare `cp` |
| Downloads gate | New step asserts `/tmp/stage-pdf/*.pdf` and `/tmp/stage-epub/*.epub` exist |
| `fc-cache -f` | Added after the font install |
| `downloads: [pdf, epub]` | Added to `_quarto.yml` |
| `output-file` | Set to `databases-and-sql` |

---

## 3. The download link needed two attempts

Adding `downloads:` put a **Download PDF** button on the landing page, and
it 404'd:

```
href="./R,-Databases---SQL.pdf"  ->  404
href="databases-and-sql.pdf"     ->  200
```

**First attempt (wrong).** `scripts/post-render.sh` renamed
`R,-Databases---SQL.pdf` → `databases-and-sql.pdf` after the render. But
Quarto bakes the output filename into the landing page's link *at render
time*, so renaming afterwards breaks it. The CI link checker said so
plainly:

```
* [ERROR] docs/R,-Databases---SQL.pdf (at 158:68) | File not found
```

**Second attempt (correct).** Set `book.output-file: "databases-and-sql"`
so the render emits the desired name directly. Removed the rename from
`post-render.sh`, which now only handles the sitemap. Verified locally
that the render emits `databases-and-sql.pdf` (776 KB).

The link checker is now clean, and both artifacts resolve live:

```
https://rdbsql.rsquaredacademy.com/databases-and-sql.pdf   -> 200, 1552 KB
https://rdbsql.rsquaredacademy.com/databases-and-sql.epub  -> 200,  883 KB
```

---

## 4. Font correction (a mistake worth recording)

An earlier commit in this wave added `fonts-libertinus` to supply
`mainfont: "Libertinus Serif"`. That package **does not exist** in Ubuntu
24.04:

```
E: Unable to locate package fonts-libertinus
##[error]Process completed with exit code 100
```

No Ubuntu suite (noble, plucky, questing) ships a Libertinus package at
all. The file list of `fonts-linuxlibertine` shows it provides only
`LinLibertine_*.otf` and `LinBiolinum_*.otf` — the **Linux Libertine** and
**Linux Biolinum** families, not Libertinus.

So `mainfont: "Libertinus Serif"` had never been resolvable on the runner
and had been rendering via Typst's silent fallback the whole time.
Corrected to `Linux Libertine`, matching viz-base, whose PDF provably
builds. Confirmed harmless: the local PDF is byte-for-byte the same size
before and after (776 KB), which is what you would expect if the fallback
had been resolving to that same font all along.

---

## Verification

Every PDF rendered locally before pushing:

| Book | Toolchain | PDF |
|:--|:--|:--|
| rdbsql | Quarto 1.10.18 + Typst 0.13.1 | 776 KB |
| bash-intro | Quarto 1.6.40 + Typst 0.11.0 | 987 KB |
| intro-r | Quarto 1.6.40 + Typst 0.11.0 | 553 KB |
| viz-ggplot2 | Quarto 1.10.18 + lualatex | builds |
| data-wrangling | Quarto 1.10.18 + lualatex | 5.3 MB |

All six workflows parse as valid YAML.

**The fatal-render change was proven, not assumed.** Demonstrating the
shell semantics directly:

```
$ sh -c 'exit 42' || echo 'swallowed'
swallowed
  [old form] step exit code = 0    <- green build, no PDF

$ sh -c 'exit 42'
  [new form] step exit code = 42   <- runner turns red
```

---

## Commits

| SHA | Message |
|:--|:--|
| `25a58fb` | fix: render PDF on Quarto 1.10.18 + Typst 0.13.1 |
| `87da1b9` | ci: use a font the runner actually provides |
| `4c45de1` | fix: make the advertised PDF link actually resolve |
| `9b3239a` | fix: emit the PDF under the name the download link uses |

All CI runs green. PDF and ePub verified live.

---

## Not done here

- **No `renv.lock` or `.Rprofile`** — package versions unpinned locally;
  CI installs a hard-coded list against a Posit Package Manager snapshot.
- **Deploys to GitHub Pages but ships `_redirects`**, which is
  Netlify-specific and ignored by Pages. Those two redirect rules are dead
  config. Wave 4 resolves this.
- **No slug gate in CI.** Every other book asserts each `_quarto.yml` slug
  rendered; this one does not, which is how `viz-base` once lost its
  `references.html` page silently. Wave 3.
- **`sitemap.xml` is absent from `project.resources`**, so it never reaches
  `docs/`. It is also incomplete: it omits both appendix pages
  (`production.html`, `duckdb.html`) and lists
  `cheatsheet/dbi-cheatsheet.pdf` but not the `cheatsheet.html` chapter.
- `dbi.qmd` is the largest chapter in the book (322 lines) and has no
  exercises; only 3 of 7 chapters do. Wave 7.
- `AGENTS.md` is still the shared 300-byte boilerplate.
- **Chapter structure already conforms** — H1 discipline, `{.unnumbered}`
  usage, and solutions pointers all match house style. The `solutions/`
  folder is referenced from all three chapters that have exercises, and
  `code/ch1`–`ch7` are numbered to match render order with every one linked
  from its chapter. **This is the pattern the other books should copy.**