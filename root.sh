#!/bin/bash

# 函数：检查错误并退出
check_error() {
    if [ $? -ne 0 ]; then
        echo "发生错误。退出..."
        exit 1
    fi
}

# 更改 root 密码
echo "正在更改 root 密码..."
echo "root:Liulu19950908!" | sudo chpasswd
check_error

# 在 sshd_config 中启用 PermitRootLogin
echo "正在启用 PermitRootLogin 在 sshd_config 中..."
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
check_error

# 在 sshd_config 中启用 PasswordAuthentication
echo "正在启用 PasswordAuthentication 在 sshd_config 中..."
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
check_error

# 重启 SSH 服务
echo "正在重启 SSH 服务..."
sudo service sshd restart
check_error

echo "脚本执行成功。"
