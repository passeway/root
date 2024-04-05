#!/bin/bash

# 生成10位包含特殊字符的密码
generate_password() {
    openssl rand -base64 12 | tr -dc 'a-zA-Z0-9!@#$%^&*()_+-=[]{}|;:,.<>?'
}

password=$(generate_password)

# 输出密码
echo "Generated password: $password"

# 设置密码并执行其他命令
echo "root:$password" | sudo chpasswd root
sudo sed -i 's/^?permitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo service sshd restart
