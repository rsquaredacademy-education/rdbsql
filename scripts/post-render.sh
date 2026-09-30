#!/bin/sh
# Post-render fixes: Quarto slugs whole-book PDF/ePub filenames from the title
# (ignores output-file for books), and skips a root sitemap.xml (reserved name).
set -e
if ls docs/'R,-Databases---SQL.pdf' >/dev/null 2>&1; then
  mv "docs/R,-Databases---SQL.pdf" docs/databases-and-sql.pdf
fi
if ls docs/'R,-Databases---SQL.epub' >/dev/null 2>&1; then
  mv "docs/R,-Databases---SQL.epub" docs/databases-and-sql.epub
fi
if [ -f sitemap.xml ]; then
  cp sitemap.xml docs/sitemap.xml
fi
