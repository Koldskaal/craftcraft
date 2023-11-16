#!/bin/sh

#
# loop over the result of 'ls -1 *.sql'
#     'ls -1' sorts the file names based on the current locale 
#     and presents them in a single column
for i in `/root/azerothcore-wotlk/data/sql/base/db_auth -1 *.sql`; do 
    echo i
done