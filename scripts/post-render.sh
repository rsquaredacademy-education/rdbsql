#!/bin/sh
# Post-render fixes: skip a root sitemap.xml (reserved name), and normalise the
# PDF/ePub filenames that `book.downloads` links to.
#
# Quarto's whole-book output filename has changed across versions: older ones
# emitted the raw title ("R,-Databases---SQL.pdf"), while Quarto 1.10 slugifies
# it to "databases-and-sql.pdf". The download button on the landing page is
# generated from whichever name this render produced, so both must be handled —
# otherwise the advertised link 404s.
set -e
for f in 'R,-Databases---SQL.pdf' 'databases-and-sql.pdf'; do
  if [ -f "docs/$f" ] && [ "$f" != 'databases-and-sql.pdf' ]; then
    mv "docs/$f" docs/databases-and-sql.pdf
  fi
done
for f in 'R,-Databases---SQL.epub' 'databases-and-sql.epub'; do
  if [ -f "docs/$f" ] && [ "$f" != 'databases-and-sql.epub' ]; then
    mv "docs/$f" docs/databases-and-sql.epub
  fi
done
if [ -f sitemap.xml ]; then
  cp sitemap.xml docs/sitemap.xml
fi
