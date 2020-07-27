Note: This repo is largely a snapshop record of bring Wikidata
information in line with Wikipedia, rather than code specifically
deisgned to be reused.

The code and queries etc here are unlikely to be updated as my process
evolves. Later repos will likely have progressively different approaches
and more elaborate tooling, as my habit is to try to improve at least
one part of the process each time around.

---------

Step 1: Check the Position Item
===============================

The Wikidata item: https://www.wikidata.org/wiki/Q2367542
contains all the data expected already.

Step 2: Tracking page
=====================

PositionHolderHistory already exists; current version is
https://www.wikidata.org/w/index.php?title=Talk:Q2367542&oldid=1240091975
with 24 dated memberships and 46 undated; and 67 warnigs.

Step 3: Set up the metadata
===========================

The first step in the repo is always to edit [add_P39.js script](add_P39.js)
to configure the Item ID and source URL.

Step 4: Get local copy of Wikidata information
==============================================

    wd ee --dry add_P39.js | jq -r '.claims.P39.value' |
      xargs wd sparql office-holders.js | tee wikidata.json

Step 5: Scrape
==============

Comparison/source = [Luettelo ministereistä Suomen valtiovarainministeriössä](https://fi.wikipedia.org/wiki/Luettelo_ministereist%C3%A4_Suomen_valtiovarainministeri%C3%B6ss%C3%A4)

    wb ee --dry add_P39.js  | jq -r '.claims.P39.references.P4656' |
      xargs bundle exec ruby scraper.rb | tee wikipedia.csv

This also includes a row for which Cabinet each was part of, so I
updated all the code to allow us to also import that.

Step 6: Create missing P39s
===========================

    bundle exec ruby new-P39s.rb wikipedia.csv wikidata.json |
      wd ee --batch --summary "Add missing P39s, from $(wb ee --dry add_P39.js | jq -r '.claims.P39.references.P4656')"

39 new additions as officeholders -> https://tools.wmflabs.org/editgroups/b/wikibase-cli/d539828f288bb/

Step 7: Add missing qualifiers
==============================

    bundle exec ruby new-qualifiers.rb wikipedia.csv wikidata.json |
      wd aq --batch --summary "Add missing qualifiers, from $(wb ee --dry add_P39.js | jq -r '.claims.P39.references.P4656')"

105 additions made as https://tools.wmflabs.org/editgroups/b/wikibase-cli/dfaeea5d1ad5d/
and a further 12 as https://tools.wmflabs.org/editgroups/b/wikibase-cli/274fe8bcf272b/ after 
the first run tripped up on Ahti Pekkala having three terms in one.

Step 8: Clean up bare P39s
==========================

    wd ee --dry add_P39.js | jq -r '.claims.P39.value' | xargs wd sparql bare-and-not-bare-P39.js |
      jq -r '.[] | "\(.bare_ps)"' | sort | uniq |
      wd rc --batch --summary "Remove bare P39s where qualified one exists"

-> https://tools.wmflabs.org/editgroups/b/wikibase-cli/efa978a8aa471/

Step 9: Move remaining undated positions to 2nd Minister
========================================================

The remaining undated people were actually the 2nd Minister, not the
actual Minister, so we want to migrate them all:

```sparql
  SELECT ?statement ?item ?itemLabel WHERE {
    ?item wdt:P31 wd:Q5; p:P39 ?statement.
    ?statement ps:P39 wd:Q2367542.
    MINUS { ?statement wikibase:rank wikibase:DeprecatedRank. }
    MINUS { ?statement pq:P580 [] }
    MINUS { ?statement pq:P582 [] }
    SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
  }
```

Using:

    wd sparql migrate-to-second-minister.rq | jq -r '.[] | "\(.statement) Q5482321"' | 
      wd uc --batch --summary "Move from Minister of Finance to 2nd Minister"

-> https://tools.wmflabs.org/editgroups/b/wikibase-cli/d9115afd348f5/

Step 10: Refresh the Tracking Page
==================================

New version at https://www.wikidata.org/w/index.php?title=Talk:Q1335939&oldid=1239413814
