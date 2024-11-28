#!/bin/bash

function install_grass () {
    echo "正在从 GitHub 克隆 grass 仓库..."
    git clone https://github.com/sdohuajia/grass-2.0.git grass

    cd "grass" || { echo "无法进入 grass 目录"; exit 1; }

    # 安装 npm 依赖
    echo "正在安装 npm 依赖..."
    npm install

    # 安裝 npm 其他依賴
    npm install cacache gyp mkdirp nopt tar which

    # 配置代理信息
    read -p "请输入您的代理信息，格式为 socks5://user:pass@ip:port: " proxy_info
    proxy_file="/root/grass/proxy.txt"

    # 将代理信息写入文件
    echo "$proxy_info" > "$proxy_file"
    echo "代理信息已添加到 $proxy_file."

    # 获取用户ID并写入 uid.txt
    read -p "请输入您的 userId: " user_id
    uid_file="/root/grass/uid.txt"  # uid 文件路径

    # 将 userId 写入文件
    echo "$user_id" > "$uid_file"
    echo "userId 已添加到 $uid_file."

    # 建立screen會話
    screen -S Grass -dm

    # 啟動節點
    echo "啟動節點..."
    screen -S Grass -p 0 -X stuff 'node index.js\n'

     # 手動操作
    echo "請進入screen會話, 完成剩餘操作"

    # 提示用户按任意鍵返回主選單
    read -n 1 -s -r -p "按任意鍵返回主選單..."
}

# 主選單
function main_menu () {
	while true; do
	    clear
		echo "請選擇要執行的操作:"
        echo "-----------------------安裝----------------------"
	    echo "1. 安裝Grass"
        echo "-----------------------其他----------------------"
	    echo "0. 退出脚本 exit"
	    read -p "请输入选项: " OPTION
	
	    case $OPTION in
	    1) install_grass ;;
	    0) echo "退出腳本。"; exit 0 ;;
	    *) echo "無效選項，請重新輸入。"; sleep 3 ;;
	    esac
	    echo "按任意鍵返回主選單..."
        read -n 1
    done
}

main_menu