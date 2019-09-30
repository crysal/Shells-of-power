#!/bin/bash
#Print help
if [ $# -eq 0 ] ;then
echo "Usage: $0 <Poll ID> <Awnser Number> <Proxy List> <User-Agent List> <Geo List>"
echo "<Poll ID> - is the number https://www.strawpoll.me/<Poll ID>"
echo "<Awnser number> - is the number of the awnser 1..64 where 1 is the first awnser"
echo "<Proxy List> - the location of your proxy list"
echo "<User-Agent List> - a list with User-Agents"
echo "<Geo List> - a list with conties Alpha 2 codes"
exit 1
fi
#Create variabels to use in curls
URL="https://www.strawpoll.me/$1"
AWNSERID=$2
PROXYLIST=$3
AGENTLIST=$4
GEOLIST=$5

#starts the while loop to read from proxy list and use a new one every loop
while read PROXY; do

#Get security token and choice id and puts into array
KeyAndID=( $(curl --url $URL |
grep 'value=' | head -n -5 | sed 's/ //g' |
sed 's/<inputid="field-security-token"name="security-token"type="hidden"value="//g' |
sed 's/"\/><inputid="field-authenticity-token"name="/\&/g' |
sed 's/"type="hidden"//g' |
sed 's/value="//g' |
sed 's/""\/>//g' |
sed 's/"//g' |
sed 's/\/>//g') )
#{0} = SecurityToken&SecurityKey
#{>0} = Awnsers ID
#Creating the --data string to send
KEY="security-token=$(echo ${KeyAndID[0]} | sed 's/\r//')" #sed 's/\r//' to remove /r at the end of array string
ID="=&options=$(echo ${KeyAndID[$AWNSERID]} | sed 's/\r//')"
DATA="$KEY$ID"
echo "Your DATA string for curl is"
echo $DATA
echo "Using IP: " $PROXY
AGENT=$(shuf -n 1 $AGENTLIST)
echo "Using Agent: "$AGENT
GEO=$(shuf -n 1 $GEOLIST)
echo "Using Geo: "$GEO
curl --proxy $PROXY --url $URL --data $DATA\
 -H "User-Agent: $AGENT"\
 -H "Accept: */*"\
 -H "Accept-Language: en-GB,en;q=0.5"\
 --compressed\
 -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8"\
 -H "X-Requested-With: XMLHttpRequest"\
 -H "Connection: keep-alive"\
 -H "Referer: $URL"\
 -H "Cookie: ResponsiveSwitch.DesktopMode=1; hibext_instdsigdipv2=1; StrawPoll.PollLoginUpsell=true; cdmgeo=$GEO; tracking-opt-in-status=accepted; tracking-opt-in-version=2"\
 -H "Pragma: no-cache"\
 -H "Cache-Control: no-cache"\
 -H "TE: Trailers"\
 --max-time 60 &
done < <(grep "" $PROXYLIST)
exit 0

#TODO
#make faster (done, but can be faster)
#make choice for how many votes
#test to see if return is success or connection refused
#make bypass for cloudflare challenge / captcha
#make a random selection of User-Agents (done)
#make random selection of GEO data for cdmgeo cookie (done)
