#!/bin/bash
#This gets 3 top images from arg1 search....... after some tests, looks more like it's random

#get the urls for each image
URLS=$(curl "https://www.bing.com/images/search?q=$1" | sed 's/></>\n</g' | grep "<a class=\"thumb\" target=\"_blank\" href=\"" | sed 's/.*http/http/g' | sed 's/" h=.*//g' | head -n3)
wget $(echo $URLS | awk '{print $1}') -O $1.1
wget $(echo $URLS | awk '{print $2}') -O $1.2
wget $(echo $URLS | awk '{print $3}') -O $1.3
