#!/bin/sh
# Post-render fixes: Quarto slugs whole-book PDF from title and skips root sitemap.xml (reserved name).
set -e
if ls docs/'R,-Databases---SQL.pdf' >/dev/null 2>&1; then
  mv "docs/R,-Databases---SQL.pdf" docs/databases-and-sql.pdf
fi
if [ -f sitemap.xml ]; then
  cp sitemap.xml docs/sitemap.xml
fi
