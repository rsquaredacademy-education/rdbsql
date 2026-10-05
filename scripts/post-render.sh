#!/bin/sh
# Post-render fix: skip a root sitemap.xml (reserved name).
#
# Deliberately does NOT rename the PDF/ePub. Quarto bakes the whole-book output
# filename into the landing page's download link, so renaming the file after the
# render breaks the link. An earlier version of this script renamed
# "R,-Databases---SQL.pdf" to "databases-and-sql.pdf", which left the advertised
# button 404ing while the renamed file sat unused in docs/.
#
# If you want a prettier filename, set it in _quarto.yml instead — for example
#   book:
#     output-file: databases-and-sql
# so the render emits that name and the link matches it.
set -e
if [ -f sitemap.xml ]; then
  cp sitemap.xml docs/sitemap.xml
fi
