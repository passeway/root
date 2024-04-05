#!/bin/bash

# 函数：检测并安装依赖
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

# 函数：检查SSH私钥文件是否存在，如果不存在则生成新的SSH密钥对
generate_ssh_keypair() {
    local ssh_key_file=~/.ssh/id_rsa
    if [ ! -f "$ssh_key_file" ]; then
        echo "Generating new SSH key pair..."
        ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f "$ssh_key_file" -q -N ""
    fi
}

# 函数：设置SSH私钥文件权限
set_key_permissions() {
    echo "Setting SSH key file permissions..."
    local ssh_key_file=$(find ~/.ssh -type f -name "*.pem" | head -n 1)
    if [ -n "$ssh_key_file" ]; then
        chmod 400 "$ssh_key_file"
    else
        echo "No SSH private key file found."
        exit 1
    fi
}

# 函数：启用VPS的SSH连接
enable_ssh_connection() {
    echo "Enabling SSH connection on VPS..."
    local local_ip=$(hostname -I | awk '{print $1}')
    local vps_ip="$local_ip"
    local ssh_user=$(whoami)
    local ssh_key_file=$(find ~/.ssh -type f -name "*.pem" | head -n 1)
    
    cat "$ssh_key_file" | ssh -i "$ssh_key_file" "$ssh_user@$vps_ip" 'cat >> ~/.ssh/authorized_keys'
    ssh -i "$ssh_key_file" "$ssh_user@$vps_ip" 'sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config'
    ssh -i "$ssh_key_file" "$ssh_user@$vps_ip" 'sudo systemctl restart sshd'
}

# 主函数
main() {
    install_dependencies
    generate_ssh_keypair
    set_key_permissions
    enable_ssh_connection

    # 生成随机密码并设置给root账户
    local random_password=$(openssl rand -base64 12)
    echo "Randomly generated password for root account: $random_password"
    local ssh_key_file=$(find ~/.ssh -type f -name "*.pem" | head -n 1)
    local local_ip=$(hostname -I | awk '{print $1}')
    sshpass -p "$random_password" ssh -i "$ssh_key_file" root@"$local_ip" << EOF
echo "Setting root password..."
echo "$random_password" | sudo passwd --stdin root
EOF
}

# 执行主函数
main
