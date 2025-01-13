#!/bin/bash

function install_humanity () {
    # 建立目錄
    mkdir Humanity_Bot
    cd Humanity_Bot

    # 腳本下載路徑
    read -p "請輸入腳本資源下載路徑: " PROJECT_PATH
    read -p "請輸入腳本資源檔名: " PROJECT_NAME

    wget $PROJECT_PATH
    unzip $PROJECT_NAME
    
    cd Humanity_Linux || { echo "进入目录失败"; exit 1; }
    chmod +x Humanity_Linux

    # 下載生成錢包腳本
    wget https://raw.githubusercontent.com/taiwanJK/Node/main/humanity/generate_wallet.py
    pip3 install eth-account

    # 建立screen會話
    screen -S Humanity -dm

    echo "繼續完成剩下的操作！"

    # 提示用户按任意鍵返回主選單
    read -n 1 -s -r -p "按任意鍵返回主選單..."
}

# 主選單
function main_menu () {
	while true; do
	    clear
		echo "請選擇要執行的操作:"
        echo "-----------------------安裝----------------------"
	    echo "1. 安裝humanity"
        echo "-----------------------其他----------------------"
	    echo "0. 退出脚本 exit"
	    read -p "请输入选项: " OPTION
	
	    case $OPTION in
	    1) install_humanity ;;
	    0) echo "退出腳本。"; exit 0 ;;
	    *) echo "無效選項，請重新輸入。"; sleep 3 ;;
	    esac
	    echo "按任意鍵返回主選單..."
        read -n 1
    done
}

main_menu