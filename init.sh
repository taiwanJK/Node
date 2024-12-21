#!/bin/bash

function init () {
    # 更新套件列表並安裝一些必要的套件
	sudo apt update && sudo apt upgrade -y
    sudo apt install ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev curl git wget make jq build-essential pkg-config lsb-release libssl-dev libreadline-dev libffi-dev gcc screen unzip lz4 vim nano -y
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
    wget https://go.dev/dl/go1.23.2.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.23.2.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    source ~/.bashrc
    rm go1.23.2.linux-amd64.tar.gz
    echo "Go 安装完成，版本: $(go version) / Go installation completed, version: $(go version)"
}

function install_python () {
    sudo apt install python3
	python3 --version
	sudo apt install python3-pip
	pip3 --version
}

function install_node () {
    echo "检测 Node.js 和 npm 是否已安装..."
    if command -v node &>/dev/null && command -v npm &>/dev/null; then
        echo "Node.js 和 npm 已安装，跳过安装步骤。"
        echo "Node.js 版本: $(node -v)"
        echo "npm 版本: $(npm -v)"
    else
        echo "Node.js 和 npm 未安装，正在安装..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        
        if sudo apt install -y nodejs; then
            echo "Node.js 和 npm 安装成功！"
        else
            echo "Node.js 或 npm 安装失败，请检查网络或权限问题。"
            exit 1
        fi
    fi

    echo "验证 Node.js 和 npm 版本..."
    node -v || { echo "Node.js 未正确安装，请检查。"; exit 1; }
    npm -v || { echo "npm 未正确安装，请检查。"; exit 1; }

    echo "检测 PM2 是否已安装..."
    if command -v pm2 &>/dev/null; then
        echo "PM2 已安装，版本: $(pm2 -v)"
    else
        echo "正在安装 PM2..."
        if npm install -g pm2; then
            echo "PM2 安装成功，版本: $(pm2 -v)"
        else
            echo "PM2 安装失败，请检查网络或权限问题。"
            exit 1
        fi
    fi

    echo "所有组件已安装完毕。"
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
        echo "5. 安裝Node & PM2"
        echo "--------------------節點類項目--------------------"
        echo "101. Allora 一鍵部署"
        echo "--------------------挖礦類項目--------------------"
        echo "201. Bless 一鍵部署"
        echo "202. Pipe Network 一鍵部署"
        echo "203. NodePay 一鍵部署"
        echo "204. Grass 一鍵部署"
        echo "205. Gradient 一鍵部署"
        echo "---------------------已停項目---------------------"
        echo "-----------------------其他----------------------"
        echo "0. 退出腳本exit"
        read -p "請輸入選項: " OPTION

        case $OPTION in
        1) init ;;
        2) install_docker ;;
        3) install_go ;;
        4) install_python ;;
        5) install_node ;;
        101) wget -O allora.sh https://raw.githubusercontent.com/taiwanJK/Node/main/allora.sh && chmod +x allora.sh && ./allora.sh ;;
        201) wget -O bless.sh https://raw.githubusercontent.com/taiwanJK/Node/main/bless.sh && chmod +x bless.sh && ./bless.sh ;;
        202) wget -O pipe.sh https://raw.githubusercontent.com/taiwanJK/Node/main/pipe.sh && chmod +x pipe.sh && ./pipe.sh ;;
        203) wget -O nodepay.sh https://raw.githubusercontent.com/taiwanJK/Node/main/nodepay.sh && chmod +x nodepay.sh && ./nodepay.sh ;;
        204) wget -O grass.sh https://raw.githubusercontent.com/taiwanJK/Node/main/grass.sh && chmod +x grass.sh && ./grass.sh ;;
        205) wget -O gradient.sh https://raw.githubusercontent.com/taiwanJK/Node/main/gradient.sh && chmod +x gradient.sh && ./gradient.sh ;;
        0) echo "退出腳本。"; exit 0 ;;
	    *) echo "無效選項，請重新輸入。"; sleep 3 ;;
	    esac
	    echo "按任意鍵返回主選單..."
        read -n 1
    done
}

# 顯示主選單
main_menu