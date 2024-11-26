#!/bin/bash

function install_nodepay () {
    git clone https://github.com/ziqing888/nodepay.git
    cd nodepay || { echo "进入目录失败"; exit 1; }
    npm install
    # 安裝 SOCKS5 代理
    npm install socks-proxy-agent

    # 替換bot.js
    rm $HOME/nodepay/src/bot.js 
    cd $HOME/nodepay/src
    wget -O bot.js https://raw.githubusercontent.com/taiwanJK/Node/main/nodepay/bot.js
    cd ..

    # 提示用户输入 token
    read -p "请输入您的 token: " USER_TOKEN
    
    # 将 token 保存到 token.txt 文件中
    echo "$USER_TOKEN" > token.txt

    # 提示用户输入 代理資訊
    read -p "请输入您的 proxy: " PROXY_INFO

    # 将 proxy 保存到 proxy.txt 文件中
    echo "$PROXY_INFO" > proxy.txt

    # 建立screen會話
    screen -S Nodepay -dm

    # 啟動節點
    echo "啟動節點..."
    screen -S Nodepay -p 0 -X stuff 'node index.js\n'

    # 提示用户按任意鍵返回主選單
    read -n 1 -s -r -p "按任意鍵返回主選單..."
}

# 主選單
function main_menu () {
	while true; do
	    clear
		echo "請選擇要執行的操作:"
        echo "-----------------------安裝----------------------"
	    echo "1. 安裝NodePay"
        echo "-----------------------其他----------------------"
	    echo "0. 退出脚本 exit"
	    read -p "请输入选项: " OPTION
	
	    case $OPTION in
	    1) install_nodepay ;;
	    0) echo "退出腳本。"; exit 0 ;;
	    *) echo "無效選項，請重新輸入。"; sleep 3 ;;
	    esac
	    echo "按任意鍵返回主選單..."
        read -n 1
    done
}

main_menu