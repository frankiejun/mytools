#**
# @file load_config.sh
# @Brief 取配置文件通用脚本
# @author fkj8965@outlook.com
# @version 1.0
# @date 2024-08-07
# MIT License
#/
#!/bin/bash

handle_err() {
  rm -rf online_config.yaml
}

configfile='config.yaml'
if [ ! -f $configfile ]; then
  echo "$configfile is not exists !!!"
  exit 1
fi

trap handle_err HUP INT TERM EXIT

online_url=$(yq eval '.online.url' $configfile)
#echo "online_url:$online_url"

if [[ -z "$online_url"  || "$online_url" == "null" ]]; then
  echo "no online.url"
else
  pwsd=$(echo $online_url | sed -n "s/.*pwd=\([^&]*\).*/\1/p")
  realpwd=$(./getpass -d $pwsd)

  url=$(echo $online_url | sed  "s/pwd=[^&]*/pwd=$realpwd/")

  curl -s -o online_config.yaml "$url"

  if [ $? -ne 0 ]; then
    echo "Failed to download the config file."
    exit 1
  fi

  if [ ! -f "online_config.yaml" ]; then
    echo "has no online_config.yaml !!!"
    exit 1
  fi

  configfile="online_config.yaml"
fi

