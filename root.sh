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

# 设置SSH私钥文件权限
set_key_permissions() {
    echo "Setting SSH key file permissions..."
    # 获取SSH私钥文件路径
    key_file=$(find ~/.ssh -type f -name "*.pem" | head -n 1)
    if [ -n "$key_file" ]; then
        # 设置私钥文件权限
        chmod 400 "$key_file"
    else
        echo "SSH private key file not found."
        exit 1
    fi
}

# 启用VPS的SSH连接
enable_ssh_connection() {
    echo "Enabling SSH connection on VPS..."
    # 获取本机IP地址
    local_ip=$(hostname -I | awk '{print $1}')
    # 获取VPS IP地址
    vps_ip="$local_ip"
    # 获取VPS用户名
    ssh_user=$(whoami)
    # 获取SSH私钥文件路径
    key_file=$(find ~/.ssh -type f -name "*.pem" | head -n 1)
    
    # 将SSH公钥添加到VPS的authorized_keys文件中
    cat "$key_file" | ssh -i "$key_file" "$ssh_user@$vps_ip" 'cat >> ~/.ssh/authorized_keys'

    # 修改VPS的SSH配置文件以允许密码登录
    ssh -i "$key_file" "$ssh_user@$vps_ip" 'sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config'
    # 重启SSH服务以应用更改
    ssh -i "$key_file" "$ssh_user@$vps_ip" 'sudo systemctl restart sshd'
}

# 检测并安装依赖
install_dependencies

# 设置SSH私钥文件权限
set_key_permissions

# 启用VPS的SSH连接
enable_ssh_connection

# 生成随机密码
random_password=$(openssl rand -base64 12)

# 输出本机IP地址和密钥路径
echo "Local IP address: $local_ip"
echo "SSH key path: $key_file"

# 设置root账户的随机密码
sshpass -p "$random_password" ssh -i "$key_file" root@"$vps_ip" << EOF
echo "Setting root password..."
echo "$random_password" | sudo passwd --stdin root
EOF

echo "Randomly generated password for root account: $random_password"
