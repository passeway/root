#!/bin/bash

# 检测并安装sshpass和openssl工具
install_dependencies() {
    echo "Checking and installing dependencies..."
    if ! command -v sshpass &> /dev/null; then
        echo "Installing sshpass..."
        sudo apt update
        sudo apt install -y sshpass
    fi
    if ! command -v openssl &> /dev/null; then
        echo "Installing openssl..."
        sudo apt update
        sudo apt install -y openssl
    fi
}

# 获取本机IP地址
local_ip=$(hostname -I | awk '{print $1}')

# 获取密钥路径
key_path=$(find ~/.ssh -type f -name "*.pem" | head -n 1)

# 检测并安装依赖
install_dependencies

# 生成随机密码
random_password=$(openssl rand -base64 12)

# 输出本机IP地址和密钥路径
echo "Local IP address: $local_ip"
echo "SSH key path: $key_path"

# 修改VPS的SSH配置文件，允许密码登录，并重启SSH服务
ssh -i "$key_path" root@"$local_ip" << EOF
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
EOF

# 设置root账户的随机密码
sshpass -p "$random_password" ssh -i "$key_path" root@"$local_ip" << EOF
echo "Setting root password..."
echo "$random_password" | sudo passwd --stdin root
EOF

echo "Randomly generated password for root account: $random_password"
