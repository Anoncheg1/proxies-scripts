#!/bin/bash

echo ================================ me =======================================================
echo https://github.com/Anoncheg1/proxies-scripts

echo =============================== original ========================================================
echo admin@krisweston.com added and cleaned up some of my code but hes dropped off the face of the planet so i have to pickup where he left off
echo rmccurdy.com if you have any issues with any of the script not working ...

# http://forums.hak5.org/index.php?showtopic=25314
echo =======================================================================================
echo 'NOTES:'

echo '* Build with Ubuntu 10.04.3 LTS'
echo '* GNU sed version 4.2.1'
echo '* curl 7.19.7 (i486-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15 '

echo 'TODO:'
echo '* error checking max pages zero then bail report error ..'
echo '* setup vars for config max timeout and test urls ..'
echo '* add more checks from freeproxylists.com proxies ssl etc'
echo '* add support to check TEST urls before we start or auto detect and set net TEST url if blocked etc ..'
echo '* check output files for IP:PORT and wc to determining if site ripp worked ...'
echo '* add file uploader site check'
# curl -s -A "$varagent" -x "$proxyip" --url http://www.filesonic.com/file/537557874/T-64AOCP.rar --connect-timeout $TIMEOUT -m 10 | grep -ci 'suspicious'
# IP http://proxy.parser.by/check_proxy.php

echo =======================================================================================

sleep 0.1
trap quit INT

servdns=ypursite.com #dns of server with php site
servip=1.1.1.1 #ip address of server with php site

varagent="Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.23) Gecko/20110920 Firefox/3.6.23 SearchToolbar/1.2"
cookie_header="Cookie: s_i=1; statSuSid=0.9385053525684567;"
TIMEOUT=10
OUTPUT_DIR="output"

function quit {

kill 0
[ -f "$OUTPUT_DIR"/cookie ] && rm "$OUTPUT_DIR"/cookie
[ -f "$OUTPUT_DIR"/objs ] && rm "$OUTPUT_DIR"/objs
[ -f "$OUTPUT_DIR"/result ] && rm "$OUTPUT_DIR"/result
echo
exit

}

function get_freeproxylists {

#echo Ripping ELITE freeproxylists.com
#echo They do not provide anyone with your IP address and effectively hide any information about you and your reading interests

#ugly
for img in `curl -A "$varagent"  -s http://www.freeproxylists.com/elite.php | grep "elite " | grep "elite/" | sed 's/.*elite\///g' | sed 's/\.html.*//g' | sed 's/^/http:\/\/www.freeproxylists.com\/load_elite_/g' | sed 's/$/\.html/g'`
do
echo $img
curl -A "$varagent"  -s $img | awk '{gsub("&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;&lt;td&gt;","\n"); print}' | awk '{gsub("&lt;/td&gt;&lt;td&gt;",":"); print}' | sed 's/&lt.*//g' | grep -v "<" | sed '/Try our\|You/d' | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/http/freeproxylist
done

	TOTAL_CONNECT=`cat $OUTPUT_DIR"/http/freeproxylist" | wc -l`
	echo /"freeproxylists.com Got "$TOTAL_CONNECT" socks proxies   \\r"
}

function get_sakura {

[ -f "$OUTPUT_DIR"/tmp ] && rm "$OUTPUT_DIR"/tmp
local MAX_PAGE=$( curl -s "http://proxylist.sakura.ne.jp/"| grep -o "Page .[0-9]" | sed 's/Page //' | sort -n | tail -1 )

echo "Ripping proxylist.sakura.ne.jp ("$MAX_PAGE" Pages)"
sleep 0.1
for i in $(seq 1 $MAX_PAGE)
do
curl -s -A "$varagent"  "http://proxylist.sakura.ne.jp/index.htm?pages="$i"" | grep 'proxy([1-4]' >> "$OUTPUT_DIR"/tmp
# parse output
cat "$OUTPUT_DIR"/tmp | cut -d "'" -f 2,4,6,8,9 | sed "s/'/./g" | sed "s/.,/:/" | sed 's/);//' | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/http/sakura.ne.jp
rm "$OUTPUT_DIR"/tmp
done
}

# total crap 1 http and one socks .. function get_multiproxy {

# total crap 1 http and one socks .. echo "Ripping multiproxy.org"
# total crap 1 http and one socks .. lynx -connect_timeout=3 -width=999 -dump -nolist "http://www.multiproxy.org/cgi-bin/search-proxy.pl" | sed 's/ //'g | grep ':' | sed '/Disclaimer\|Total\|USEMAP\|All\|Non-anon/d' | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/socks/multiproxy

# total crap 1 http and one socks .. }

function get_nntime {

[ -f "$OUTPUT_DIR"/tmp ] && rm "$OUTPUT_DIR"/tmp
#echo "Ripping nntime.com"
# pages is wrong try division of total proxy on main page

for i in seq {01..17}
do
curl -s "http://nntime.com/proxy-list-$i.htm"  -A 'SAMSUNG-SGH-E250/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 UP.Browser/6.2.3.3.c.1.101 (GUI) MMP/2.0 (compatible; Googlebot-Mobile/2.1; +http://www.google.com/bot.html)' | egrep '(document.write| = )|;<\/script>' |sed -e 's/.*<td>/print("/g' -e 's/<script type="text\/javascript">document.write(//g' -e 's/":/:/g' -e 's/<\/script>.*/;/g' | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/tmp
done
js "$OUTPUT_DIR"/tmp >> "$OUTPUT_DIR"/http/nntime
rm "$OUTPUT_DIR"/tmp

	TOTAL_CONNECT=`cat "$OUTPUT_DIR"/http/nntime | wc -l`
	echo /"nntime.com Got "$TOTAL_CONNECT" http proxies   \\r"

}

function get_myproxy {
# fix "$OUTPUT_DIR"/cookie

#echo "Ripping www.my-proxy.com"

[ -f "$OUTPUT_DIR"/tmp ] && rm "$OUTPUT_DIR"/tmp
[ -f "$OUTPUT_DIR"/cookie ] && rm "$OUTPUT_DIR"/cookie

# no "$OUTPUT_DIR"/cookie needed anymore ??
curl -L -A "$varagent" -s  -c "$OUTPUT_DIR"/cookie -b "$OUTPUT_DIR"/cookie http://www.my-proxy.com/list/proxy.php > /dev/null
cat "$OUTPUT_DIR"/cookie  | sed 's/0$/2/' > "$OUTPUT_DIR"/tmp
mv "$OUTPUT_DIR"/tmp "$OUTPUT_DIR"/cookie

echo ripping Anonymous Proxy 3 pages 
curl -A "$varagent"  -s  -c "$OUTPUT_DIR"/cookie -b "$OUTPUT_DIR"/cookie "http://proxies.my-proxy.com/proxy-list-s1.html" -e 'http://www.m.com/list/verify.php'http://www.my-proxy.com/list/verify.php  |grep br | awk '{gsub("<br>","\n"); print}' | grep "[0-9]\.[0-9]" | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/http/my-proxy-s
curl -A "$varagent"  -s  -c "$OUTPUT_DIR"/cookie -b "$OUTPUT_DIR"/cookie "http://proxies.my-proxy.com/proxy-list-s2.html" -e 'http://www.m.com/list/verify.php'http://www.my-proxy.com/list/verify.php  |grep br | awk '{gsub("<br>","\n"); print}' | grep "[0-9]\.[0-9]" | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/http/my-proxy-s
curl -A "$varagent"  -s  -c "$OUTPUT_DIR"/cookie -b "$OUTPUT_DIR"/cookie "http://proxies.my-proxy.com/proxy-list-s3.html" -e 'http://www.m.com/list/verify.php'http://www.my-proxy.com/list/verify.php  |grep br | awk '{gsub("<br>","\n"); print}' | grep "[0-9]\.[0-9]" | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/http/my-proxy-s

echo ripping Socks 4 and 5 Proxy  2 pages
curl -A "$varagent"  -s  -c "$OUTPUT_DIR"/cookie -b "$OUTPUT_DIR"/cookie "http://proxies.my-proxy.com/proxy-list-socks4.html" -e 'http://www.m.com/list/verify.php'http://www.my-proxy.com/list/verify.php  |grep br | awk '{gsub("<br>","\n"); print}' | grep "[0-9]\.[0-9]" | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/socks/socks4
curl -A "$varagent"  -s  -c "$OUTPUT_DIR"/cookie -b "$OUTPUT_DIR"/cookie "http://proxies.my-proxy.com/proxy-list-socks5.html" -e 'http://www.m.com/list/verify.php'http://www.my-proxy.com/list/verify.php  |grep br | awk '{gsub("<br>","\n"); print}' | grep "[0-9]\.[0-9]" | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/socks/socks4



echo ripping http 10 pages
for i in seq {1..10}
do
curl -A "$varagent"  -s  -c "$OUTPUT_DIR"/cookie -b "$OUTPUT_DIR"/cookie "http://proxies.my-proxy.com/proxy-list-"$i".html" -e 'http://www.m.com/list/verify.php'http://www.my-proxy.com/list/verify.php  |grep br | awk '{gsub("<br>","\n"); print}' | grep "[0-9]\.[0-9]" | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/http/my-proxy



	TOTAL_CONNECT=`cat "$OUTPUT_DIR"/http/my-proxy | wc -l`
	echo /"www.my-proxy.com Got "$TOTAL_CONNECT" http proxies   \\r"


sleep 0.1
done
}


function get_proxylistsnet {

countries=$(curl -A "$varagent" -s http://www.proxylists.net/countries.html | grep -io "a href='/.*_0.html'" | sed "s/.*'\(.*\)'.*/\1/" | sed 's/\./_ext./')
rm "$OUTPUT_DIR"/proxy_list_socks5_objs 2> /dev/null
rm "$OUTPUT_DIR"/proxy_list_socks4_objs 2> /dev/null
rm "$OUTPUT_DIR"/proxy_list_http_objs 2> /dev/null
for entry in $countries; do
#echo $entry
  local MAX_PAGE=$(( $(curl -A "$varagent" -s http://www.proxylists.net$entry | grep "${entry:1}" | grep -o "a href" | wc -l) -1 ))
  echo "Ripping proxylists.net - "$entry pages:$(($MAX_PAGE + 1))
    for i in $(seq 0 "$MAX_PAGE");do
      local page=$(echo $entry | sed 's/_.*_/_'$i'_/')
      local proxies=$(curl -A "$varagent" -s http://www.proxylists.net$page)
      local ipies= #$(echo "$proxies" | grep -o "unescape('.*')")
      local ports=$(echo "$proxies" | grep -o "td>[0-9]*</td" | grep -o "[0-9]*")
      local types=$(echo "$proxies" | grep -o "td>[0-9]*</td.*" | sed 's/[^/]*\/\([^/]*\).*/\1/' | sed 's/.*<td>\(.*\)./\1/')
      local MAX_PRXIES=$(echo "$ipies" | wc -l)
      for i in $(seq 1 "$MAX_PRXIES");do
        if [[ $(echo "$types" | sed -n $i'p') == Socks5 ]];then
          echo "print("$(echo "$ipies" | sed -n $i'p')"+':'+"$(echo "$ports" | sed -n $i'p')");" >> "$OUTPUT_DIR"/proxy_list_socks5_objs
        elif [[ $(echo "$types" | sed -n $i'p') == Socks4 ]];then
          echo "print("$(echo "$ipies" | sed -n $i'p')"+':'+"$(echo "$ports" | sed -n $i'p')");" >> "$OUTPUT_DIR"/proxy_list_socks4_objs
        else
          echo "print("$(echo "$ipies" | sed -n $i'p')"+':'+"$(echo "$ports" | sed -n $i'p')");" >> "$OUTPUT_DIR"/proxy_list_http_objs
	fi        
      done
    done
done

	js "$OUTPUT_DIR"/proxy_list_http_objs | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.*' | sed 's/\");//' > "$OUTPUT_DIR"/http/plnhttp
	js "$OUTPUT_DIR"/proxy_list_socks5_objs | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.*' | sed 's/\");//' > "$OUTPUT_DIR"/socks/plnsocks5
	js "$OUTPUT_DIR"/proxy_list_socks4_objs | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.*' | sed 's/\");//' > "$OUTPUT_DIR"/socks/plnsocks4

	TOTAL_CONNECT1=`cat "$OUTPUT_DIR"/socks/plnsocks4 | wc -l`
	TOTAL_CONNECT2=`cat "$OUTPUT_DIR"/socks/plnsocks5 | wc -l`
	TOTAL_CONNECT3=`cat "$OUTPUT_DIR"/http/plnhttp | wc -l`
	echo /"proxylists.net Got "$TOTAL_CONNECT1" socks4, "$TOTAL_CONNECT2" socks5, "$TOTAL_CONNECT3" http proxies   \\r"

rm "$OUTPUT_DIR"/proxy_list_socks5_objs 2> /dev/null
rm "$OUTPUT_DIR"/proxy_list_socks4_objs 2> /dev/null
rm "$OUTPUT_DIR"/proxy_list_http_objs 2> /dev/null

}

function get_shroomery {

#echo "Ripping www.shroomery.org"
# OLD lynx -connect_timeout=3 -width=999 -dump -nolist 'http://www.shroomery.org/ythan/proxylist.php' | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/shroomery
lynx -connect_timeout=3 -width=999 -dump -nolist 'http://www.shroomery.org/ythan/proxylist' | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/http/shroomery

	TOTAL_CONNECT=`cat "$OUTPUT_DIR"/http/shroomery | wc -l`
	echo /"www.shroomery.org Got "$TOTAL_CONNECT" http proxies   \\r"


}

function get_samair_http {
	[ -f "$OUTPUT_DIR"/tmp ] && rm "$OUTPUT_DIR"/tmp

	local MAX_PAGE=$( curl -A "$varagent" -s http://www.samair.ru/proxy/proxy-01.htm | grep -io "=\"proxy-[0-9][0-9].htm\"" | wc -l )

	echo "Ripping www.samair.ru ("$MAX_PAGE" Pages)"

	for i in $(seq 1 "$MAX_PAGE");do
		a=$(printf "%02d" "$i") # leading zero
#		wget -q http://www.samair.ru/proxy/proxy-"$a".htm
		curl -A "$varagent" -s http://www.samair.ru/proxy/proxy-"$a".htm | grep -Eo '[0-9]+.[0-9]+.[0-9]+.[0-9]+.[0-9]+' | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/http/samair
		# throttle
		sleep 0.1
		# parse
#		cat ./proxy-$a.htm | grep -Eo '[0-9]+.[0-9]+.[0-9]+.[0-9]+.[0-9]+' | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/tmp
#		rm ./proxy-$a.htm
	done

	TOTAL_CONNECT=`cat "$OUTPUT_DIR"/http/samair | wc -l`
	echo /"www.samair.ru Got "$TOTAL_CONNECT" http proxies   \\r"

}
function get_samair_socks {
#	mv "$OUTPUT_DIR"/tmp "$OUTPUT_DIR"/http/samair

	# samair socks proxies - todo - arrange socks proxies into seperate files according to SOCKS 4 or 5 support

	local MAX_PAGE=$( curl -A "$varagent" -s http://www.samair.ru/proxy/socks01.htm | grep -io "=\"socks[0-9][0-9].htm\"" | wc -l )
	echo "Ripping www.samair.ru SOCKS proxies("$MAX_PAGE" Pages)"

	for i in $(seq 1 "$MAX_PAGE");do
		curl -A "$varagent" -s http://www.samair.ru/proxy/socks"$i".htm | grep -Eo '[0-9]+*\.[0-9]+.[0-9]+.[0-9]+.[0-9]+' | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/socks/samairsocks
		# throttle
		sleep 0.1
	done
}

function check_conn {

ping -s1 -c1 www.google.com >/dev/null
if [ $? -ne 0 ] ; then
echo problem with connection....
exit
fi

}
########################################## rosinstrument  ################################################
function rosiget {

local maxloops=5
local failing=1
local pagenum=$1

for i in $(seq 1 "$maxloops")
do

echo "Ripping page  "$1"  of rosinstrument of type "$2
sleep 0.1
#curl -s -b "$OUTPUT_DIR"/cookie -c "$OUTPUT_DIR"/cookie -A "$varagent" -e "http://www.proxies.by/raw_free_db.htm?t=0&i=rule2" "http://www.proxies.by/raw_free_db.htm?"$pagenum"&t=2"
#www.proxies.by
    curl -s -b "$OUTPUT_DIR"/cookie -c "$OUTPUT_DIR"/cookie -A "$varagent" -e "http://www.proxies.by/raw_free_db.htm?t="$2 "http://www.proxies.by/raw_free_db.htm?"$pagenum"&t=2" | grep '<script language="javascript" type="text/javascript">' -A 90 | sed '/-->/,/blkjsldkhqweh348239/ s/.*//' | sed 's/document.write/print/' | sed '1,2d' | grep -v 'function print' > "$OUTPUT_DIR"/objs
    if [ $? -ne 0 ] ; then
    echo "Problem with connection.."
               if [ $i -le "$maxloops" ] ; then
            echo "Trying again"
            else
                    echo "attempts exceeded "$maxloops": failed..."
                    echo "try changing ip"
                    failing=0
                    exit
            fi
    else
    break
    fi
echo $i
sleep 0.1
done
}

function get_rosinstrument_http { # HTTP
	touch "$OUTPUT_DIR"/http/rosinstrument_http
	type_of_proxy=1 #type t=0 - ALL; t=1 - http; t=2 - CONNECT; t=3 - SOCKS

	# connect proxies (t=2)
	# get first page to determine max page nums
	rosiget 0 $type_of_proxy
	js "$OUTPUT_DIR"/objs > "$OUTPUT_DIR"/result
	cat "$OUTPUT_DIR"/result | grep -o 'stat">[a-z,0-9.:-]*' | sed 's/stat">//' > "$OUTPUT_DIR"/http/rosinstrument_http

	# MAX_PAGE  var was not getting set or something because the cookie was stale or something .. so after touch cookie I got new cookie

	local MAX_PAGE=$( cat "$OUTPUT_DIR"/result | tr -d "'" | grep -o '?*[0-9,=tamp;& ]*title=to last page' | sed 's/&amp;t=. title=to last page//' | sed 's/?//' )
[ -z $MAX_PAGE ] && { echo "connection problem, exiting... http://www.proxies.by/raw_free_db.htm?t=2 to unblock etc .." ; exit ; }
	echo "Ripping www.www.proxies.by HTTP proxies("$MAX_PAGE" Pages)"

	for i in $(seq 1 "$MAX_PAGE")
	do
		rosiget "$i" $type_of_proxy
		js "$OUTPUT_DIR"/objs > "$OUTPUT_DIR"/result
		#cat "$OUTPUT_DIR"/result | html2text -utf8 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]*' >> "$OUTPUT_DIR"/http/rosinstrument_http
		TOTAL_CONNECT=`cat "$OUTPUT_DIR"/http/rosinstrument_http | wc -l`
		echo -ne "Got "$TOTAL_CONNECT" http proxies   \\r"
	done
	echo
}

function get_rosinstrument_connect { # CONNECT
	touch "$OUTPUT_DIR"/http/rosinstrument_connect
	type_of_proxy=2 #type t=0 - ALL; t=1 - http; t=2 - CONNECT; t=3 - SOCKS

	# connect proxies (t=2)
	# get first page to determine max page nums
	rosiget 0 $type_of_proxy
	js "$OUTPUT_DIR"/objs > "$OUTPUT_DIR"/result
	cat "$OUTPUT_DIR"/result | grep -o 'stat">[a-z,0-9.:-]*' | sed 's/stat">//' > "$OUTPUT_DIR"/http/rosinstrument_connect

	# MAX_PAGE  var was not getting set or something because the cookie was stale or something .. so after touch cookie I got new cookie

	local MAX_PAGE=$( cat "$OUTPUT_DIR"/result | tr -d "'" | grep -o '?*[0-9,=tamp;& ]*title=to last page' | sed 's/&amp;t=. title=to last page//' | sed 's/?//' )
[ -z $MAX_PAGE ] && { echo "connection problem, exiting... http://www.proxies.by/raw_free_db.htm?t=2 to unblock etc .." ; exit ; }
	echo "Ripping www.www.proxies.by CONNECT proxies("$MAX_PAGE" Pages)"

	for i in $(seq 1 "$MAX_PAGE")
	do
		rosiget "$i" $type_of_proxy
		js "$OUTPUT_DIR"/objs > "$OUTPUT_DIR"/result
		#cat "$OUTPUT_DIR"/result | html2text -utf8 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]*' >> "$OUTPUT_DIR"/http/rosinstrument_connect
		TOTAL_CONNECT=`cat "$OUTPUT_DIR"/http/rosinstrument_connect | wc -l`
		echo -ne "Got "$TOTAL_CONNECT" connect proxies   \\r"
	done
	echo
}

function get_rosinstrument_socks { # SOCKS
	touch "$OUTPUT_DIR"/socks/rosinstrument
	type_of_proxy=3 #type t=0 - ALL; t=1 - http; t=2 - CONNECT; t=3 - SOCKS

	# connect proxies (t=2)
	# get first page to determine max page nums
	rosiget 0 $type_of_proxy
	js "$OUTPUT_DIR"/objs > "$OUTPUT_DIR"/result
	cat "$OUTPUT_DIR"/result | grep -o 'stat">[a-z,0-9.:-]*' | sed 's/stat">//' > "$OUTPUT_DIR"/socks/rosinstrument

	# MAX_PAGE  var was not getting set or something because the cookie was stale or something .. so after touch cookie I got new cookie

	local MAX_PAGE=$( cat "$OUTPUT_DIR"/result | tr -d "'" | grep -o '?*[0-9,=tamp;& ]*title=to last page' | sed 's/&amp;t=. title=to last page//' | sed 's/?//' )
[ -z $MAX_PAGE ] && { echo "connection problem, exiting... http://www.proxies.by/raw_free_db.htm?t=2 to unblock etc .." ; exit ; }
	echo "Ripping www.www.proxies.by CONNECT proxies("$MAX_PAGE" Pages)"

	for i in $(seq 1 "$MAX_PAGE")
	do
		rosiget "$i" $type_of_proxy
		js "$OUTPUT_DIR"/objs > "$OUTPUT_DIR"/result
		cat "$OUTPUT_DIR"/result | grep -o 'stat">[a-z,0-9.:-]*' | sed 's/stat">//' >> "$OUTPUT_DIR"/socks/rosinstrument
		TOTAL_CONNECT=`cat "$OUTPUT_DIR"/socks/rosinstrument | wc -l`
		echo -ne "Got "$TOTAL_CONNECT" socks proxies   \\r"
	done
	echo
}

function get_rosinstrument {
	#http://www.proxies.by/raw_free_db.htm?t=2
	# how bloody annoying...

	#echo "Ripping http://www.proxies.by"
	touch "$OUTPUT_DIR"/cookie
	echo setting "$OUTPUT_DIR"/cookie
	curl -s -c "$OUTPUT_DIR"/cookie -A "$varagent" "http://www.proxies.by/raw_free_db.htm" > /dev/null
	cat "$OUTPUT_DIR"/cookie | tail -n 1 | cat "$OUTPUT_DIR"/cookie | tail -n 1 | sed 's/\([^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t\).*/\1ROBOTTEST\tOK/' >> "$OUTPUT_DIR"/cookie
	sleep 0.1
	curl -s -b "$OUTPUT_DIR"/cookie -c "$OUTPUT_DIR"/cookie -A "$varagent" -e "http://www.proxies.by/raw_free_db.htm" "http://www.proxies.by/raw_free_db.htm?t=0&i=rule2" > /dev/null
	sleep 0.2
	touch "$OUTPUT_DIR"/objs
	touch "$OUTPUT_DIR"/result
	get_rosinstrument_http
	if [ "$enablesocks" -eq 1 ];then
		get_rosinstrument_connect
		get_rosinstrument_socks
	fi
	rm -r "$OUTPUT_DIR"/cookie "$OUTPUT_DIR"/objs "$OUTPUT_DIR"/result
} #///////////////////////////////////// rosinstrument  ///////////////////////////////////////////////////

######################################## get_blogspot  ###################################################

function get_blogspot {
	touch $OUTPUT_DIR"/http/blogspot_http"
	#echo "Ripping http://elite-proxies.blogspot.com"
	curl -s -A "$varagent" "http://elite-proxies.blogspot.ru/" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]*' >> $OUTPUT_DIR"/http/blogspot_http"
	TOTAL_CONNECT=`cat $OUTPUT_DIR"/http/blogspot_http" | wc -l`
	echo "elite-proxies.blogspot Got "$TOTAL_CONNECT" http proxies   \\r"
} #///////////////////////////////////// get_blogspot  ///////////////////////////////////////////////////

######################################## get_socks5list  ###################################################

function get_socks5list {
	touch $OUTPUT_DIR"/socks/socks5list"
#	echo "Ripping http://www.socks5list.com/"
	curl -s -A "$varagent" "http://www.socks5list.com/" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]*' >> $OUTPUT_DIR"/socks/socks5list"
	TOTAL_CONNECT=`cat $OUTPUT_DIR"/socks/socks5list" | wc -l`
	echo /"socks5list Got "$TOTAL_CONNECT" socks proxies   \\r"
} #///////////////////////////////////// get_socks5list  ///////////////////////////////////////////////////


######################################## get_proxyhunter  ###################################################

function get_proxyhunter { #http://proxy-hunter.blogspot.com/
	touch $OUTPUT_DIR"/http/proxyhunter"
	#echo "Ripping http://proxy-hunter.blogspot.ru/"
	for line in $(curl -s -A "$varagent" "http://proxy-hunter.blogspot.ru/" | grep rmlink | grep -o "http.*\.html")  ; do
		curl -s -A "$varagent" $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]*' >> $OUTPUT_DIR"/http/proxyhunter"
	done
	TOTAL_CONNECT=`cat $OUTPUT_DIR"/http/proxyhunter" | wc -l`
	echo /"proxy-hunter Got "$TOTAL_CONNECT" http proxies   \\r"
} #///////////////////////////////////// get_proxyhunter  ///////////////////////////////////////////////////

function ping_http {

# <p>Ja em svoje govno kagdij den i zapivaju spermoj</p>/nArray
#    [Accept] => text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
#    [Accept-Charset] => ISO-8859-1,utf-8;q=0.7,*;q=0.7
#    [Accept-Encoding] => gzip,deflate
#    [Accept-Language] => en-us,en;q=0.5
#    [Connection] => close
#    [Host] => $servdns
#    [User-Agent] => Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.16) Gecko/20120421 Iceweasel/3.5.16 (like Firefox/3.5.16)
#    [Via] => 1.1 89.28.122.140 (Mikrotik HttpProxy)
#    [X-Forwarded-For] => 1.1.1.1
#    [X-Proxy-Id] => 1773250874
#    [X-Real-Ip] => 89.28.122.140

	echo -ne "\t\t\t\t\t\t checking process $count \\r"

	local proxyip=$1

	#DEBUG 	echo second check PASS ! with elite!
	#sed 's/:.*//  sed 's/.*REMOTE_ADDR == \([0-9]\+.[0-9]\+.[0-9]\+.[0-9]*\).*/\1/'
#	local http_check_var1=`echo $http_check_var | sed 's/.*REMOTE_ADDR == \([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/'`
#	local http_check_var2=`echo $http_check_var | sed 's/.*HTTP_X_FORWARDED_FOR[^=]*== \([0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}\).*/\1/'` #proxy
#	local proxyip_noport=`echo $proxyip | sed 's/:.*//'`
	local http_check_var=`curl -s -A "$varagent" -x "$proxyip" --connect-timeout $TIMEOUT \
	--header "Host: $servdns" --url "http://$servip/tmp/" -L -m 5`
	local http_check_var1=`echo $http_check_var | grep -o "Ja em svoje govno kagdij den i zapivaju spermoj"`
	local http_check_var2=`echo $http_check_var | grep -o "X-Forwarded-For"`
	local http_check_var22=`echo $http_check_var | grep -o "Client-Ip"`
	local http_check_var3=`echo $http_check_var | grep -o "X-Proxy-Id"`
	local http_check_var4=`echo $http_check_var | grep -o "Via"`
	if [[ -n "$http_check_var1" ]]; then	#-n not zero
		local ipold=$(echo $proxyip | sed 's/:.*//')
		local ip=$(dig +short $ipold)
		if [[ $ip != "" ]]; then
			local proxyip=$ip:$(echo $proxyip | sed 's/.*://')
		fi
		echo "$proxyip" >> "$OUTPUT_DIR"/http/good
		echo -ne "Found `cat "$OUTPUT_DIR"/http/good | wc -l` working proxies       \\r"
		if [[ -z "$http_check_var2" && -z "$http_check_var22" ]]; then  #  -z - if null
			local http_check_var_cookie=`curl -s -A "$varagent" -x "$proxyip" \
			--header "$cookie_header" --header "Cache-Control: no-cache" --connect-timeout $TIMEOUT \
			--header "Host: $servdns" --url "http://$servip/tmp/" -L -m 5`
			local http_check_var2=`echo $http_check_var | grep -o "X-Forwarded-For"`
			local http_check_var22=`echo $http_check_var | grep -o "Client-Ip"`
			local http_check_var_c3=`echo $http_check_var | grep -o "X-Proxy-Id"`
			local http_check_var_c4=`echo $http_check_var | grep -o "Via"`
			if [[ -n "$http_check_var_cookie" && -z "$http_check_var2" && -z "$http_check_var22" ]]; then  #  -z - if null
				echo "$proxyip" >> "$OUTPUT_DIR"/http/elite
				echo -ne "Found `cat "$OUTPUT_DIR"/http/elite | wc -l` elite proxies        \\r"
				if [[ -z "$http_check_var3" && -z "$http_check_var4" && -z "$http_check_var_c3" && -z "$http_check_var_c4" ]]; then  #  -z - if null
					echo "$proxyip" >> "$OUTPUT_DIR"/http/superelite
					echo -ne "Found `cat "$OUTPUT_DIR"/http/superelite | wc -l` super elite proxies   \\r"
				fi
			fi
		fi
		local http_check_var=`curl -s -A "$varagent" -p -x "$proxyip" --connect-timeout $TIMEOUT -m 5 \
		--header "Host: $servdns" --url "http://$servip/tmp/" -L | \
		grep -o "Ja em svoje govno kagdij den i zapivaju spermoj"`
		if [[ -n "$http_check_var" ]]; then	#-n not zero
			echo "$proxyip" >> "$OUTPUT_DIR"/http/goodconnect
		fi
	else
		echo second check faild skipping > /dev/null # DEBUG
	fi
	echo -ne "\t\t\t\t fin $count     \\r"
}

function ping_socks {
# change code not to put too many requests at high speed
	echo -ne "\t\t\t\t\t\t checking process $count \\r"
	local proxyip=$1
	local socks_check_var=`curl -s -A "$varagent" --socks4 "$proxyip" --header "Host: $servdns" \
	--url "http://$servip/tmp/" -L --connect-timeout $TIMEOUT -m 10 | grep "Ja em svoje govno kagdij den i zapivaju spermoj"`
	if [[ -n "$socks_check_var" ]];	then
		local ipold=$(echo $proxyip | sed 's/:.*//')
		local ip=$(dig +short $ipold)
		if [[ $ip != "" ]]; then
			local proxyip=$ip:$(echo $proxyip | sed 's/.*://')
		fi
		# DEBUG echo socks_check_var is GOOD ! checking one more time ....... must pass two checks !
		local socks_check_var=`curl -s -A "$varagent" --socks4 "$proxyip" --header "Host: $servdns" --url "http://$servip/tmp/" -L --connect-timeout $TIMEOUT -m 10 | grep "Ja em svoje govno kagdij den i zapivaju spermoj"`
		if [[ "$socks_check_var" == "" ]]; then
			echo second check faild skipping > /dev/null # DEBUG
		else
			# DEBUG echo second check PASS !
			echo "$proxyip" >> "$OUTPUT_DIR"/socks/good
			echo -ne "Found `cat "$OUTPUT_DIR"/socks/good | wc -l` working proxies      \\r"
		fi
	else
		local socks_check_var1=`curl -s -A "$varagent" --socks5 "$proxyip" --header "Host: $servdns" --url "http://$servip/tmp/" -L --connect-timeout $TIMEOUT -m 10 | grep "Ja em svoje govno kagdij den i zapivaju spermoj"`
		if [ -n "$socks_check_var1" ]; then
			echo "$proxyip" >> "$OUTPUT_DIR"/socks/goodothers
		else
			local socks_check_var2=`curl -s -A "$varagent" --socks4a "$proxyip" --header "Host: $servdns" --url "http://$servip/tmp/" -L --connect-timeout $TIMEOUT -m 10 | grep "Ja em svoje govno kagdij den i zapivaju spermoj"`
			if [ -n "$socks_check_var2" ]; then
				echo "$proxyip" >> "$OUTPUT_DIR"/socks/goodothers
			fi

		fi

	fi
echo -ne "\t\t\t\t fin $count \\r"
}


function check_alive_http {
	#################### HTTP check ##################################

	echo Removing dupes ...
	mv "$OUTPUT_DIR"/http/ALL "$OUTPUT_DIR"/http_tmp_all
	cat "$OUTPUT_DIR"/http/*|sort|uniq > "$OUTPUT_DIR"/http_tmp
	rm  "$OUTPUT_DIR"/http/*
	mv "$OUTPUT_DIR"/http_tmp_all "$OUTPUT_DIR"/http/ALL

	if [ $notallcheck == 1 ] ; then
		FILE="$OUTPUT_DIR"/http_tmp
	else
		FILE="$OUTPUT_DIR"/http/ALL
	fi
	TOTAL_HTTP=`cat $FILE | wc -l`
	echo "Checking "$TOTAL_HTTP" HTTP proxies"
	local count=1
	for line in $( cat $FILE )
	do
		ping_http "$line" &
		sleep 0.1
#		local p=$(( $count % 400)) # if process > 50 wait a bit
#		if [ "$p" -eq 0 ] ; then
#			wait
#		fi

	let count++
	done
	wait
	echo
	[ -f "$OUTPUT_DIR"/http_tmp ] && rm "$OUTPUT_DIR"/http_tmp
}

function check_alive_socks {
	#################################### SOCKS #########################

	echo Removing dupes ...
	mv "$OUTPUT_DIR"/socks/ALL "$OUTPUT_DIR"/socks_tmp_all
	cat "$OUTPUT_DIR"/socks/*|sort|uniq > "$OUTPUT_DIR"/socks_tmp
	rm  "$OUTPUT_DIR"/socks/*
	mv "$OUTPUT_DIR"/socks_tmp_all "$OUTPUT_DIR"/socks/ALL

	if [ $notallcheck == 1 ] ; then
		FILE="$OUTPUT_DIR"/socks_tmp
	else
		FILE="$OUTPUT_DIR"/socks/ALL
	fi
	TOTAL_SOCKS=`cat $FILE | wc -l`
	echo "Checking "$TOTAL_SOCKS" SOCKS proxies"
	local count=1
	for line in $( cat $FILE )
	do
		ping_socks "$line" &
		sleep 0.1
#		local p=$(( $count % 400)) # if process > 50 wait a bit
#        	if [ "$p" -eq 0 ] ; then
#			wait
#        	fi

	let count++
	done
	wait
	echo
	[ -f "$OUTPUT_DIR"/socks_tmp ] && rm "$OUTPUT_DIR"/socks_tmp
}

function nocodeen {

# wtf is this ?
# no CoDeeN
for i in `cat "$OUTPUT_DIR"/good|sed -e 's/:/ -sV -P0 -n -p /g' -e 's/^/nmap /g'` ;do echo "$i";done > nmap

bash nmap > "$OUTPUT_DIR"/tmp

#egrep -B 2 open "$OUTPUT_DIR"/tmp | egrep -v "(PORT|CoDeeN|--)" | sed 's/Interesting ports on /IP /g' | grep open -B 1 | sed 's/\/.*//g'|sed 's/--//g' | tr -d '\n' | awk '{gsub("IP ","\n"); print}' > "$OUTPUT_DIR"/nocodeen

rm "$OUTPUT_DIR"/tmp nmap
}

function get_proxies {
	if [ $silent == 1 ] ; then
		[ -d "$OUTPUT_DIR" ] && rm -r "$OUTPUT_DIR"
	else
		[ -d "$OUTPUT_DIR" ] && { echo "Do u wanna remove old \""$OUTPUT_DIR"\" directory?" ; rm -rI "$OUTPUT_DIR"; }
	fi

	[ ! -d "$OUTPUT_DIR" ] && mkdir "$OUTPUT_DIR"
	[ ! -d "$OUTPUT_DIR"/socks ] && mkdir "$OUTPUT_DIR"/socks/
	[ ! -d "$OUTPUT_DIR"/http ] && mkdir "$OUTPUT_DIR"/http/

# START
		#get_sakura   #doesnt working
		# lame removed get_multiproxy
	#small:
#	get_freeproxylists 
#	get_myproxy &
	get_nntime &
	get_proxylistsnet &
	get_shroomery &
	get_samair_http &
	get_proxyhunter &
	get_blogspot &		#http://elite-proxies.blogspot.com/

if [ "$enablesocks" -eq 1 ];then
	get_samair_socks &
	get_socks5list &
fi

	#large:
	get_rosinstrument & #many
wait
	echo "creating ALL file"
	cat "$OUTPUT_DIR"/http/*|sort|uniq > http_tmp
#	rm  "$OUTPUT_DIR"/http/*
	mv http_tmp "$OUTPUT_DIR"/http/ALL

	cat "$OUTPUT_DIR"/socks/*|sort|uniq > socks_tmp
#	rm  "$OUTPUT_DIR"/socks/*
	mv socks_tmp "$OUTPUT_DIR"/socks/ALL
}

function parse_country_sub { #1 - proxyip+port   2 - path
	prip=$(echo "$1" | sed 's/:.*//')
	countryvar=$(whois $prip | grep country | sed 's/country: \{1,\}//' | head -n 1)
	case $countryvar in
		"RU" | "UA" | "BY" | "KZ" | "KG" | "NL")
			echo "$1" >> "$2""_rus"
			echo -ne "\t\t\t\tFound `cat "$2""_rus" | wc -l` russian proxies   \\r"
			;;
	esac
}

function parse_country { # $1 - path to file with ip:port
	TOTAL_PROXIES=`cat $1 | wc -l`
	echo "Getting country "$TOTAL_PROXIES" proxies of "$1" "
	count=0
	for line in $( cat $1 )
	do
		echo -ne "Count "$count"     \\r"
		((count++))
		parse_country_sub $line $1 &
		sleep 0.08
#		echo $prip
	done
	wait
	echo
}

function parse {
	echo "Parsing..."

	local l1=$OUTPUT_DIR"/http/goodconnect"
	local l2=$OUTPUT_DIR"/socks/good"
	local l3=$OUTPUT_DIR"/socks/goodothers"
	# remove files if there already
	[ -f $OUTPUT_DIR"/CONNECT_proxychains" ] && rm $OUTPUT_DIR"/CONNECT_proxychains"
	[ -f $OUTPUT_DIR"/CONNECT_proxychains_rus" ] && rm $OUTPUT_DIR"/CONNECT_proxychains_rus"
#
#	[ -f $l1"_rus" ] && rm $l1"_rus"
#	[ -f $l2"_rus" ] && rm $l2"_rus"
#	[ -f $l3"_rus" ] && rm $l3"_rus"

	if [ -f $l1 -o -f $l2 -o $l3 ] ; then
		[ -f $l1 ] && cat $l1 | sed 's/^/http\t/' | sed "s/:/\t/" >> $OUTPUT_DIR"/CONNECT_proxychains"
		[ -f $l2 ] && cat $l2 | sed 's/^/socks4\t/' | sed "s/:/\t/" >> $OUTPUT_DIR"/CONNECT_proxychains"
		[ -f $l3 ] && cat $l3 | sed 's/^/socks5\t/' | sed "s/:/\t/" >> $OUTPUT_DIR"/CONNECT_proxychains"
#		parse_country $l1
#		parse_country $l2
#		parse_country $l3
#		[ -f $l1"_rus" ] && cat $l1"_rus" | sed 's/^/http\t/' | sed "s/:/\t/" >> $OUTPUT_DIR"/CONNECT_proxychains_rus"
#		[ -f $l2"_rus" ] && cat $l2"_rus" | sed 's/^/socks4\t/' | sed "s/:/\t/" >> $OUTPUT_DIR"/CONNECT_proxychains_rus"
#		[ -f $l3"_rus" ] && cat $l3"_rus" | sed 's/^/socks5\t/' | sed "s/:/\t/" >> $OUTPUT_DIR"/CONNECT_proxychains_rus"
	else
	    echo "IP's not checked, please run $0 -c "
	fi

#	[ -f $OUTPUT_DIR"/http/elite_rus" ] && rm $l3"_rus"
#	parse_country $OUTPUT_DIR"/http/elite"


#			prip=$(echo $line | sed 's/:.*//')
#			countryvar=$(whois $prip | grep country | sed 's/country: \{1,\}//' | head -n 1)
			#if [[ $countryvar == "RU" -o $countryvar == "UA" -o $countryvar == "BY"  -o $countryvar == "KZ"  -o $countryvar == "KG"]]; then 
#			case $countryvar in
#				"RU")
#					echo "$proxyip" >> "$OUTPUT_DIR"/http/elite_ru
#					;;
#				"UA")
#					echo "$proxyip" >> "$OUTPUT_DIR"/http/elite_ua
#					;;
#				"BY")
#					echo "$proxyip" >> "$OUTPUT_DIR"/http/elite_by
#					;;
#				"KZ")
#					echo "$proxyip" >> "$OUTPUT_DIR"/http/elite_kz
#					;;
#				"KG")
#					echo "$proxyip" >> "$OUTPUT_DIR"/http/elite_kg
#					;;
#			esac

}

function feed_proxychains {

	if [ ! -f $OUTPUT_DIR"/CONNECT_proxychains" ] ; then
	    echo "IP's not checked, please run $0 -c "
	    exit
	fi
#[ ! -f /etc/proxychains.bak ] && cp /etc/proxychains.conf /etc/proxychains.bak
#cat "$OUTPUT_DIR"/CONNECT_proxychains >> /etc/proxychains.conf
[ ! -f /home/user/.proxychains/proxychains.bak ] && cp /home/user/.proxychains/proxychains.conf /home/user/.proxychains/proxychains.bak
cat "$OUTPUT_DIR"/CONNECT_proxychains >> /home/user/.proxychains/proxychains.conf

echo "Good proxies copied to /etc/proxychains.conf"

}

function recover_proxychains {

cp /home/user/.proxychains/proxychains.bak /home/user/.proxychains/proxychains.conf
echo "/etc/proxychains.conf recovered..."

}

function _usage {

echo "Currently supporting freeproxylists, sakura, multiproxy, nntime, myproxy, proxylistsnet, shroomery, samair.ru, proxies.by"
echo
echo "`basename $0` -r rip proxy websites to \"$OUTPUT_DIR\" driectory"
echo "`basename $0` -c read IPs from \"$OUTPUT_DIR\" driectory and check if alive"
echo "`basename $0` -p copy good connect http proxies IPs to "$OUTPUT_DIR"/CONNECT_proxychains"
echo "`basename $0` -b recover backup of /etc/proxychains.conf"
echo "`basename $0` -l show etc/proxychains.conf"
echo "`basename $0` -s silent"
echo "`basename $0` -o don't check all proxies, only already checked"
echo "`basename $0` -S enable Socks"

}

###################### main #####################################

#defaults
getproxies=0
checkalive=0
feedchains=0
recoverchains=0
silent=0
notallcheck=0
enablesocks=0

if (($# == 0)); then
 echo "Script requires an argument" ...
 _usage
 exit
fi

while getopts "rcpbhsloS" flag
do
     case "$flag" in
         r)
             getproxies=1
             ;;
         c)
             checkalive=1
             ;;
         p)
             feedchains=1
             ;;
         b)
             recoverchains=1
             ;;
         l)
             cat /etc/proxychains.conf
             ;;
         s)
             silent=1
             ;;
         o)
             notallcheck=1
             ;;
         S)
             enablesocks=1
             ;;

         h)
             _usage
         exit
             ;;
         ?)
             _usage
             exit
             ;;
     esac
done

# removed .. dont need to check connectoin ..  check_conn

if [ "$recoverchains" -eq 1 ] && [ "$feedchains" -eq 1 ] ;then
echo "copy to proxychains selected with recover proxychains, ignoring recover"
recoverchains=0
fi
if [ "$getproxies" -eq 1 ] && [ "$notallcheck" -eq 1 ] ;then
echo "there is no checked proxies yet, ignoring -o notallcheck"
notallcheck=0
fi

[ "$getproxies" -eq 1 ] && { get_proxies ; echo "Completed ripping..."; }

if [ "$checkalive" -eq 1 ];then
	check_alive_http
	[ "$enablesocks" -eq 1 ] && check_alive_socks;
fi

[ "$feedchains" -eq 1 ] &&
	{ parse; } #&&
#		{ feed_proxychains; }

[ "$recoverchains" -eq 1 ] && { recover_proxychains ; }

echo "Done."

exit
