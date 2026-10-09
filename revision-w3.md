# Revision Notes — Wave 3 (CI convergence)

**Date:** 2026-10-05
**Scope:** One workflow shape per book; gates that cannot drift
**Author:** automated review pass

Part of a workspace-wide standard for all six books, documented at
[`viz-base/AUTHOR-STANDARDS.md`](https://github.com/rsquaredacademy-publications/viz-base/blob/master/AUTHOR-STANDARDS.md).
This file records only what changed in **this** repository.

---

## Summary

- Rename `deploy.yml` to `render.yml`.
- Add `scripts/verify-slugs.sh` — this book had **no slug gate at all**.
- Add a cross-reference gate — also absent, despite 5 `@sec-` references.
- Generate the sitemap at build time; it was missing three live pages.
- Add `scripts/verify-sitemap.sh` and `scripts/make-sitemap.sh`.
- Add a weekly `linkcheck.yml`.

---

## 1. No slug gate, and no cross-reference gate

This book was the least protected of the six. It had five `@sec-` references in
`index.qmd` (`@sec-dbi`, `@sec-dbplyr`, `@sec-sqlbasics`, `@sec-sql2`,
`@sec-joins`) and nothing that would notice one breaking.

Both gates added. The slug gate derives its list from `_quarto.yml`:

```sh
slugs=$(yq eval -r '.book.chapters[]?, .book.appendices[]?' "$YAML" \
        | grep '\.qmd$' \
        | sed 's/\.qmd$//')
```

---

## 2. The sitemap was missing three live pages

The hand-maintained root `sitemap.xml` listed 7 URLs for 10 built pages, omitting
`cheatsheet.html`, `production.html` and `duckdb.html`. All three are live and
linked from the book.

`scripts/make-sitemap.sh` now generates the file from the rendered pages after
the HTML render; the root file is deleted. All ten pages are listed.

---

## 3. `post-render.sh` no longer copies the sitemap

It previously did `cp sitemap.xml docs/sitemap.xml`. With generation in place
there is nothing to copy, so the script is now an explicit no-op — retained so
future post-render fixes have an obvious home and so the workflow still calls it.

Its other job, deliberately *not* doing, is renaming the PDF/ePub. That is
documented in the file: Quarto bakes the output filename into the landing page's
download link, so a post-render rename breaks the link. The filename is set via
`book.output-file` in `_quarto.yml` instead.

---

## Verification

- Slug gate: all 10 chapters pass against committed `docs/`.
- Sitemap gate: all 10 pages covered, including the three that were missing.
- Negative controls: removing a declared page makes the slug gate exit non-zero;
  removing a page while the sitemap still lists it makes the sitemap gate exit
  non-zero.
- Workflow parses as valid YAML; 18 steps.
- CI green (2m46s, deployed to GitHub Pages).

Confirmed live: `https://rdbsql.rsquaredacademy.com/sitemap.xml` now lists 12
URLs and includes `cheatsheet.html` and `duckdb.html`.

---

## Commits

| SHA | Message |
|:--|:--|
| `7b5db11` | ci: derive gates from _quarto.yml and regenerate the sitemap |

---

## Not done here

- **Deploys to GitHub Pages but ships `_redirects`**, which is Netlify-specific
  and ignored by Pages. Those two redirect rules are dead config. Wave 4 resolves
  this properly.
- **No `renv.lock` or `.Rprofile`** — package versions unpinned locally; CI
  installs a hard-coded list against a Posit Package Manager snapshot. Wave 9.
- **`sitemap.xml` is not in `_quarto.yml` `resources`**, which is now correct
  since there is no root copy, but worth knowing if you add one back.
- `dbi.qmd` is the largest chapter in the book (322 lines) and has no exercises;
  only 3 of 7 chapters do. Wave 7.
- `AGENTS.md` is still the shared 300-byte boilerplate.
- **Chapter structure already conforms.** `code/ch1`–`ch7` are numbered to match
  render order with every one linked from its chapter, and `solutions/` is
  referenced from all three chapters that have exercises. This is the pattern the
  other books should copy.