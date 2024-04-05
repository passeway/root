#!/bin/bash

# 函数：检查错误并退出
check_error() {
    if [ $? -ne 0 ]; then
        echo "发生错误。退出..."
        exit 1
    fi
}

# 生成随机密码并更改 root 密码
random_password=$(openssl rand -base64 12)
echo "正在更改 root 密码..."
echo "root:$random_password" | sudo chpasswd
check_error

# 在 sshd_config 中启用 PermitRootLogin
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
check_error

# 在 sshd_config 中启用 PasswordAuthentication
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
check_error

# 重启 SSH 服务
echo "正在重启 SSH 服务..."
sudo service sshd restart
check_error

echo "密码更改成功。生成的随机密码为：$random_password"
