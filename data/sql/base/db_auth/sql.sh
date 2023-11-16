#!/usr/bin/env bash

#
# loop over the result of 'ls -1 *.sql'
#     'ls -1' sorts the file names based on the current locale 
#     and presents them in a single column
for i in `ls -1 *.sql`; do 
    cat "$i" | docker exec -i "34d6fe2395d7" usr/bin/mysql -u root --password="WelcomeToTheCraftCraftM8" acore_auth
done