#!/bin/bash

read -r username
read -r password

urlencode() {
  local string="$1"
  local encoded=""
  for (( i = 0; i < ${#string}; i++ )); do
    local c="${string:i:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) encoded+="$c" ;;
      ' ') encoded+="%20" ;;
      *) encoded+=$(printf '%%%02X' "'$c") ;;
    esac
  done
  echo "$encoded"
}

username=$(urlencode $username)
password=$(urlencode $password)
dst="status.html"
popup="false"
params=$(printf "dst=%s&popup=%s&username=%s&password=%s" $dst $popup $username $password)

preparation=$(curl 'https://login.iust.ac.ir/login.php' -X POST -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br, zstd' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: https://login.iust.ac.ir' -H 'DNT: 1' -H 'Sec-GPC: 1' -H 'Connection: keep-alive' -H 'Referer: https://login.iust.ac.ir/login.php' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'Priority: u=0, i' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' --data-raw $params -s)


if [[ -z $preparation ]]; then
        echo "cannot request preparation"
        exit 1
else
        echo "successfully requested preparation"
fi

# echo $preparation > offline.html

server_username=$(echo $preparation | grep -oP "login\.username\.value = '\K[^']+")
server_password=$(echo $preparation | grep -oP "login\.password\.value = '\K[^']+")
server_destination=$(echo $preparation | grep -oP 'action="\K[^"]+')

if [[ -z $server_username || -z $server_password || -z $server_destination ]]; then

        echo "cannot find credentials. you maybe logged in or entered wrong credentials!"
        exit 1
else
        echo "successfully parsed credentials"
fi

popup="true"
dst=$(echo $server_destination | sed 's/login/status/')
dst=$(urlencode $dst)
params=$(printf "username=%s&password=%s&dst=%s&popup=%s" $server_username $server_password $dst $popup)

result=$(curl $server_destination -X POST -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: null' -H 'DNT: 1' -H 'Sec-GPC: 1' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Priority: u=0, i' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' --data-raw $params -s)

if [[ -z $result ]]; then
        echo "cannot request login"
        exit 1
else
        echo "successfully requested login"
fi