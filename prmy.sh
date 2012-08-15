#!/bin/bash

echo =======================================================================================
echo 'https://github.com/Anoncheg1/proxies-scripts'
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

sleep 1
trap quit INT

varagent="Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.23) Gecko/20110920 Firefox/3.6.23 SearchToolbar/1.2"
cookie_header="Cookie: s_i=1; statSuSid=0.9385053525684567;"
TIMEOUT=10
OUTPUT_DIR="output"

function quit {

killall -9 curl
[ -f "$OUTPUT_DIR"/cookie ] && rm "$OUTPUT_DIR"/cookie
[ -f "$OUTPUT_DIR"/objs ] && rm "$OUTPUT_DIR"/objs
[ -f "$OUTPUT_DIR"/result ] && rm "$OUTPUT_DIR"/result
echo
exit

}

function get_freeproxylists {

echo Ripping ELITE freeproxylists.com
echo They do not provide anyone with your IP address and effectively hide any information about you and your reading interests

#ugly
for img in `curl -A "$varagent"  -s http://www.freeproxylists.com/elite.php | grep "elite " | grep "elite/" | sed 's/.*elite\///g' | sed 's/\.html.*//g' | sed 's/^/http:\/\/www.freeproxylists.com\/load_elite_/g' | sed 's/$/\.html/g'`
do
echo $img
curl -A "$varagent"  -s $img | awk '{gsub("&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;&lt;td&gt;","\n"); print}' | awk '{gsub("&lt;/td&gt;&lt;td&gt;",":"); print}' | sed 's/&lt.*//g' | grep -v "<" | sed '/Try our\|You/d' | sed '/^[ \t]/d' | tr -d '\r' >> "$OUTPUT_DIR"/http/freeproxylist
done

	TOTAL_CONNECT=`cat $OUTPUT_DIR"/http/freeproxylist" | wc -l`
	echo /"Got "$TOTAL_CONNECT" socks proxies   \\r"
}

function ping_http {

# <p>fuck</p>/nArray
#    [Accept] => text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
#    [Accept-Charset] => ISO-8859-1,utf-8;q=0.7,*;q=0.7
#    [Accept-Encoding] => gzip,deflate
#    [Accept-Language] => en-us,en;q=0.5
#    [Connection] => close
#    [Host] => .ru
#    [User-Agent] => Mozilla/5.0 (X11; U; Linux i68
#    [Via] => 1.1 89.28.122.140 (Mikrotik HttpProxy)
#    [X-Forwarded-For] => 
#    [X-Proxy-Id] => 1773250874
#    [X-Real-Ip] => 

	echo -ne "\t\t\t\t\t\t checking process $count \\r"

	local proxyip=$1


	#DEBUG 	echo second check PASS ! with elite!
	#sed 's/:.*//  sed 's/.*REMOTE_ADDR == \([0-9]\+.[0-9]\+.[0-9]\+.[0-9]*\).*/\1/'
#	local http_check_var1=`echo $http_check_var | sed 's/.*REMOTE_ADDR == \([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/'`
#	local http_check_var2=`echo $http_check_var | sed 's/.*HTTP_X_FORWARDED_FOR[^=]*== \([0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}\).*/\1/'` #proxy
#	local proxyip_noport=`echo $proxyip | sed 's/:.*//'`
	local http_check_var=`curl -s -A "$varagent" -x "$proxyip" --header "$cookie_header" --connect-timeout $TIMEOUT \
	--header "Host: .ru" --url "http://.../ххх/" -L -m 5`
	local http_check_var1=`echo $http_check_var | grep -o "fuck"`
	local http_check_var2=`echo $http_check_var | grep -o "X-Forwarded-For"`
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
		if [[ -z "$http_check_var2" ]]; then  #  -z - if null
			echo "$proxyip" >> "$OUTPUT_DIR"/http/elite
			echo -ne "Found `cat "$OUTPUT_DIR"/http/elite | wc -l` elite proxies        \\r"
			if [[ -z "$http_check_var3" && -z "$http_check_var4" ]]; then  #  -z - if null
				echo "$proxyip" >> "$OUTPUT_DIR"/http/superelite
				echo -ne "Found `cat "$OUTPUT_DIR"/http/superelite | wc -l` super elite proxies   \\r"
			fi
		fi
		local http_check_var=`curl -s -A "$varagent" -p -x "$proxyip" --connect-timeout $TIMEOUT -m 5 \
		--header "Host: .ru" --url "http://...//" -L | \
		grep -o "fuck"`
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
	local socks_check_var=`curl -s -A "$varagent" --socks4 "$proxyip" --header "Host: .ru" \
	--url "http://.../" -L --connect-timeout $TIMEOUT -m 10 | grep "fuck"`
	if [[ -n "$socks_check_var" ]];	then
		local ipold=$(echo $proxyip | sed 's/:.*//')
		local ip=$(dig +short $ipold)
		if [[ $ip != "" ]]; then
			local proxyip=$ip:$(echo $proxyip | sed 's/.*://')
		fi
		# DEBUG echo socks_check_var is GOOD ! checking one more time ....... must pass two checks !
		local socks_check_var=`curl -s -A "$varagent" --socks4 "$proxyip" --header "Host: .ru" --url "http:///" -L --connect-timeout $TIMEOUT -m 10 | grep "fuck"`
		if [[ "$socks_check_var" == "" ]]; then
			echo second check faild skipping > /dev/null # DEBUG
		else
			# DEBUG echo second check PASS !
			echo "$proxyip" >> "$OUTPUT_DIR"/socks/good
			echo -ne "Found `cat "$OUTPUT_DIR"/socks/good | wc -l` working proxies      \\r"
		fi
	else
		local socks_check_var1=`curl -s -A "$varagent" --socks5 "$proxyip" --header "Host: .ru" --url "http:///" -L --connect-timeout $TIMEOUT -m 10 | grep "fuck"`
		if [ -n "$socks_check_var1" ]; then
			echo "$proxyip" >> "$OUTPUT_DIR"/socks/goodothers
		else
			local socks_check_var2=`curl -s -A "$varagent" --socks4a "$proxyip" --header "Host: .ru" --url "http:///" -L --connect-timeout $TIMEOUT -m 10 | grep "fuck"`
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

	get_freeproxylists
	

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

	[ -f $l1"_rus" ] && rm $l1"_rus"
	[ -f $l2"_rus" ] && rm $l2"_rus"
	[ -f $l3"_rus" ] && rm $l3"_rus"
#	[ -f $l3"_rus" ] && rm $OUTPUT_DIR"/http/superelite" i dont remember wtf is this

	if [ -f $l1 -o -f $l2 -o $l3 ] ; then
		cat $l1 | sed 's/^/http\t/' | sed "s/:/\t/" >> $OUTPUT_DIR"/CONNECT_proxychains"
		cat $l2 | sed 's/^/socks4\t/' | sed "s/:/\t/" >> $OUTPUT_DIR"/CONNECT_proxychains"
		cat $l3 | sed 's/^/socks5\t/' | sed "s/:/\t/" >> $OUTPUT_DIR"/CONNECT_proxychains"
		parse_country $l1
		parse_country $l2
		parse_country $l3
		[ -f $l1"_rus" ] && cat $l1"_rus" | sed 's/^/http\t/' | sed "s/:/\t/" >> $OUTPUT_DIR"/CONNECT_proxychains_rus"
		[ -f $l2"_rus" ] && cat $l2"_rus" | sed 's/^/socks4\t/' | sed "s/:/\t/" >> $OUTPUT_DIR"/CONNECT_proxychains_rus"
		[ -f $l3"_rus" ] && cat $l3"_rus" | sed 's/^/socks5\t/' | sed "s/:/\t/" >> $OUTPUT_DIR"/CONNECT_proxychains_rus"
	else
	    echo "IP's not checked, please run $0 -c "
	fi

	parse_country $OUTPUT_DIR"/http/elite"

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

echo "Currently supporting freeproxylists, sakura, multiproxy, nntime, myproxy, proxylistsnet, shroomery, samair.ru , rosinstrument"
echo
echo "`basename $0` -r rip proxy websites to \"$OUTPUT_DIR\" driectory"
echo "`basename $0` -c read IPs from \"$OUTPUT_DIR\" driectory and check if alive"
echo "`basename $0` -p copy good connect http proxies IPs to "$OUTPUT_DIR"/CONNECT_proxychains"
echo "`basename $0` -b recover backup of /etc/proxychains.conf"
echo "`basename $0` -l show etc/proxychains.conf"
echo "`basename $0` -s silent"
echo "`basename $0` -o don't check all proxies, only already checked"

}

###################### main #####################################

#defaults
getproxies=0
checkalive=0
feedchains=0
recoverchains=0
silent=0
notallcheck=0

if (($# == 0)); then
 echo "Script requires an argument" ...
 _usage
 exit
fi

while getopts "rcpbhslo" flag
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

[ "$checkalive" -eq 1 ] &&
	{ check_alive_http; } &&
		{ check_alive_socks; }

[ "$feedchains" -eq 1 ] &&
	{ parse; } #&&
#		{ feed_proxychains; }

[ "$recoverchains" -eq 1 ] && { recover_proxychains ; }

echo "Done."

exit

