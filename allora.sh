#!/bin/bash

function install_allorad () {
    git clone https://github.com/allora-network/allora-chain.git
    cd allora-chain
    # 切換版本到v0.2.14
    git fetch --tags
    git checkout v0.2.14
    # go
    export PATH=$PATH:/usr/local/go/bin
    source ~/.profile
    # 安裝 allorad
    make all
    $HOME/go/bin/allorad version
}

function fix_worker_dockerfile_b7s () {
    # it doesn't exist cos of the recent update in the original repo.  
    # So you'd need to create a new Dockerfile_b7s nano Dockerfile_b7s then paste this in
    cd $HOME/basic-coin-prediction-node
    cat > Dockerfile_b7s <<EOF
FROM alloranetwork/allora-inference-base:latest

USER root
RUN pip install requests

USER appuser
COPY . /app/
EOF
    docker compose build && docker compose up -d
}

# 主選單
function main_menu () {
	while true; do
	    clear
		echo "請選擇要執行的操作:"
        echo "-----------------------安裝----------------------"
	    echo "1. 安裝allorad"
        echo "-----------------------修復----------------------"
        echo "101. 修復安裝worker節點 Dockerfile_b7s不存在問題"
        echo "-----------------------其他----------------------"
	    echo "0. 退出脚本 exit"
	    read -p "请输入选项: " OPTION
	
	    case $OPTION in
	    1) install_allorad ;;
        101) fix_worker_dockerfile_b7s ;;
	    0) echo "退出腳本。"; exit 0 ;;
	    *) echo "無效選項，請重新輸入。"; sleep 3 ;;
	    esac
	    echo "按任意鍵返回主選單..."
        read -n 1
    done
}

main_menu