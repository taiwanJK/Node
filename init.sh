#!/bin/bash

function init () {
    # 更新套件列表並安裝一些必要的套件
	sudo apt update && sudo apt upgrade -y
    sudo apt install ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev curl git wget make jq build-essential pkg-config lsb-release libssl-dev libreadline-dev libffi-dev gcc screen unzip lz4 vim -y
}

function install_docker () {
    # 更新套件列表並安裝一些必要的套件
    sudo apt update
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    # 使用curl命令將Docker的公開GPG鑰匙下載到適當的目錄
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
    # 添加Docker的套件庫到系統的APT源列表
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    # 更新套件列表並安裝Docker
    sudo apt update
    sudo apt install docker-ce
}

function install_go () {
    wget https://golang.org/dl/go1.22.6.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.22.6.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    source ~/.profile
    go version
}

function install_python () {
    sudo apt install python3
	python3 --version
	sudo apt install python3-pip
	pip3 --version
}

# 主選單
function main_menu () {
    while true; do
        clear
        echo "★參與區塊鏈技術的發展並獲得空投機會"
        echo "請選擇要執行的操作:"
        echo "----------------------初始化---------------------"
        echo "1. 更新套件列表並安裝必要套件"
        echo "2. 安裝Docker & Docker Compose"
        echo "3. 安裝GO"
        echo "4. 安裝Python"
        echo "--------------------節點類項目--------------------"
        echo "101. Allora 一鍵部署"
        echo "--------------------挖礦類項目--------------------"
        echo "---------------------已停項目---------------------"
        echo "-----------------------其他----------------------"
        echo "0. 退出腳本exit"
        read -p "請輸入選項: " OPTION

        case $OPTION in
        1) init ;;
        2) install_docker ;;
        3) install_go ;;
        4) install_python ;;
        101) wget -O allora.sh https://raw.githubusercontent.com/taiwanJK/Node/main/allora.sh && chmod +x allora.sh && ./allora.sh ;;
        0) echo "退出腳本。"; exit 0 ;;
	    *) echo "無效選項，請重新輸入。"; sleep 3 ;;
	    esac
	    echo "按任意鍵返回主選單..."
        read -n 1
    done
}

# 顯示主選單
main_menu