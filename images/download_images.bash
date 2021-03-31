#!/bin/bash
CURL_USR_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"

for page in 1 10 100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000
do
   echo "page = $page"

   for img in $(cat "page$page.json" | json_pp | grep href | grep "_sa.jpg" | cut -d':' -f2,3 | cut -d',' -f1 | cut -d'"' -f2)
   do
      img_name=`basename $img`
      curl -s --user-agent "$CURL_USR_AGENT" $img > $img_name
      sips -g pixelWidth -g pixelHeight -1 $img_name
   done
done