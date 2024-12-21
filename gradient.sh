#!/bin/bash

REPO_DIR="/root/Gradient"
PROXIES_FILE="$REPO_DIR/proxies.txt"

function install_gradient () {
	# 克隆 GitHub 仓库
	echo "开始克隆仓库..."
	git clone https://github.com/sdohuajia/Gradient.git "$REPO_DIR"

	# 提示用户输入 代理資訊
	read -p "请输入您的 proxy: " PROXY_INFO

	# 将 proxy 保存到 proxies.txt 文件中
	echo "$PROXY_INFO" >> "$PROXIES_FILE"

	# 获取用户邮箱
	read -p "请输入您的邮箱地址: " user_email

	# 获取用户密码
	read -s -p "请输入您的密码: " user_password

	# 提示用户按任意鍵返回主選單
	read -n 1 -s -r -p "按任意鍵返回主選單..."
}

# 主選單
function main_menu () {
	while true; do
	    clear
		echo "請選擇要執行的操作:"
        echo "-----------------------安裝----------------------"
	    echo "1. 安裝gradient"
        echo "-----------------------其他----------------------"
	    echo "0. 退出脚本 exit"
	    read -p "请输入选项: " OPTION
	
	    case $OPTION in
	    1) install_gradient ;;
	    0) echo "退出腳本。"; exit 0 ;;
	    *) echo "無效選項，請重新輸入。"; sleep 3 ;;
	    esac
	    echo "按任意鍵返回主選單..."
        read -n 1
    done
}

main_menu