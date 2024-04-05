#!/bin/bash

# 修改 SSH 配置文件以允许密码登录
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 重新启动 SSH 服务以应用新的配置
sudo systemctl restart sshd

# 生成一个包含数字、字母和特殊字符的随机密码
password=$(head /dev/urandom | tr -dc A-Za-z0-9\!\@\#\$\%\^\&\*\(\)-\+= | head -c 16 ; echo '')

# 输出自动生成的密码
echo "自动生成的密码为: $password"

# 修改 root 账户的密码
echo "正在修改 root 账户的密码..."
echo "root:$password" | sudo chpasswd

# 输出修改密码的结果
echo "root 账户的密码已成功修改为自动生成的密码。请妥善保管密码，并不要分享给任何人。"
