#!/bin/bash

function install_pipe () {
    git clone https://github.com/sdohuajia/pipe.git
    cd pipe || { echo "进入目录失败"; exit 1; }
    pip install -r requirements.txt

    # 提示用户输入 token
    read -p "请输入您的 token: " USER_TOKEN
    
    # 将 token 保存到 token.txt 文件中
    echo "$USER_TOKEN" > token.txt

    # 建立screen會話
    screen -S Pipe -dm

    # 启动节点
    echo "启动节点..."
    screen -S Pipe -p 0 -X stuff 'sudo python3 $HOME/pipe/main.py\n'

    # 輸入選項1，開始運行節點
    screen -S Pipe -p 0 -X stuff '1\n'

    # 提示用户按任意鍵返回主選單
    read -n 1 -s -r -p "按任意鍵返回主選單..."
}

# 主選單
function main_menu () {
	while true; do
	    clear
		echo "請選擇要執行的操作:"
        echo "-----------------------安裝----------------------"
	    echo "1. 安裝pipe network"
        echo "-----------------------其他----------------------"
	    echo "0. 退出脚本 exit"
	    read -p "请输入选项: " OPTION
	
	    case $OPTION in
	    1) install_pipe ;;
	    0) echo "退出腳本。"; exit 0 ;;
	    *) echo "無效選項，請重新輸入。"; sleep 3 ;;
	    esac
	    echo "按任意鍵返回主選單..."
        read -n 1
    done
}

main_menu