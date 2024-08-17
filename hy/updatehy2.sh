#!/bin/bash

# 定义变量
BINARY_PATH="/usr/local/bin/hysteria"
BACKUP_PATH="/usr/local/bin"
DATE=$(date +%Y%m%d)

# 检查更新
UPDATE_INFO=$(hysteria check-update 2>&1)
echo "UPDATE_INFO:$UPDATE_INFO"

# 解析更新信息
UPDATE_AVAILABLE=$(echo "$UPDATE_INFO" | grep "no update available")
echo "UPDATE_AVAILABLE:$UPDATE_AVAILABLE"
if [ -n "$UPDATE_AVAILABLE" ]; then
  echo "没有更新可用"
  exit
fi

UPDATE_AVAILABLE=$(echo "$UPDATE_INFO" | grep "update available")
if [ -n "$UPDATE_AVAILABLE" ]; then
  VERSION=$(echo "$UPDATE_AVAILABLE" | grep -oP '(?<=version": ")[^"]+')
  URL="https://github.com/apernet/hysteria/releases/download/app%2F${VERSION}/hysteria-linux-amd64"

  # 下载最新版本
  wget -O hysteria-new "$URL"

  # 检查是否存在旧版本，备份旧版本
  if [ -f "$BINARY_PATH" ]; then
    systemctl stop hysteria-server.service
    mv "$BINARY_PATH" "${BACKUP_PATH}/hysteria.${DATE}"
  fi

  # 替换为最新版本并重启服务
  mv hysteria-new "$BINARY_PATH"
  chmod +x "$BINARY_PATH"
  systemctl start hysteria-server.service

  echo "Hysteria has been updated to version $VERSION."
else
  echo "No updates available."
fi
