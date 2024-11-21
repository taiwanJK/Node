#!/bin/bash

function install_bless () {
    sudo npm install -g cacache node-gyp mkdirp nopt tar which
    echo "正在從 GitHub 克隆 Bless 倉庫..."
    git clone https://github.com/sdohuajia/Bless-node.git Bless || { echo "克隆失敗，請檢查網路連接或倉庫地址。"; exit 1; }

    cd Bless || { echo "無法進入 Bless 目錄"; exit 1; }

    # 創建 config.js 的開頭
    cat > config.js << EOF
module.exports = [
    {
EOF

    # 提示用户輸入 token
    read -p "請輸入 usertoken: " usertoken
    
    # 添加 usertoken 部分
    cat >> config.js << EOF
        usertoken: '${usertoken}',
        nodes: [
EOF

    # 循環添加節點訊息
    while true; do
        read -p "請輸入 nodeid (直接按回車结束添加): " nodeid
        if [ -z "$nodeid" ]; then
            break
        fi
        read -p "請輸入 hardwareid: " hardwareid
        read -p "請輸入 proxy (如果没有請直接按回車): " proxy

        # 设置 proxy 值
        if [ -z "$proxy" ]; then
            proxy_value="null"
        else
            proxy_value="'${proxy}'"
        fi

        # 添加節點信息
        cat >> config.js << EOF
            { nodeId: '${nodeid}', hardwareId: '${hardwareid}', proxy: ${proxy_value} },
EOF
    done

    # 完成配置文件
    cat >> config.js << EOF
        ]
    }
];
EOF

    echo "配置文件 config.js 已創建"

    # 修改index.js，將詢問是否啟動代理程式碼註解並將useProxy設為false
    sed -i 's/useProxy = await promptUseProxy();/useProxy = false;/g' index.js
    sed -i '/logTimestamped(`使用代理: ${useProxy ? '\''是'\'' : '\''否'\''}`, colors.info);/ s/^/\/\//g' index.js
    
    # 安裝專案所需套件
    npm install
    # 透過pm2啟動節點運行
    pm2 start index.js --name Bless

    # 提示用户按任意鍵返回主選單
    read -n 1 -s -r -p "按任意鍵返回主選單..."
}

# 主選單
function main_menu () {
	while true; do
	    clear
		echo "請選擇要執行的操作:"
        echo "-----------------------安裝----------------------"
	    echo "1. 安裝bless"
        echo "-----------------------其他----------------------"
	    echo "0. 退出脚本 exit"
	    read -p "请输入选项: " OPTION
	
	    case $OPTION in
	    1) install_bless ;;
	    0) echo "退出腳本。"; exit 0 ;;
	    *) echo "無效選項，請重新輸入。"; sleep 3 ;;
	    esac
	    echo "按任意鍵返回主選單..."
        read -n 1
    done
}

main_menu