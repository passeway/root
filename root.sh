#!/bin/bash

# 函数：检查错误并退出
check_error() {
    if [ $? -ne 0 ]; then
        echo "发生错误。退出..."
        exit 1
    fi
}

# 生成随机密码
generate_random_password() {
    # 检查是否有root权限
    if [ "$(id -u)" -ne 0 ]; then
        echo "需要root权限来设置密码。退出..."
        exit 1
    fi

    random_password=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9!@#$%^&*()-_=+{}[]|\;:,.<>?')
    echo "root:$random_password" | sudo chpasswd
    check_error
    echo "$random_password" # 输出密码
}

# 修改 sshd_config 文件
modify_sshd_config() {
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    check_error

    # 检查文件中是否存在以'PermitRootLogin'开头的行
    if ! grep -q '^PermitRootLogin' /etc/ssh/sshd_config; then
        # 不存在匹配行，追加'PermitRootLogin yes'到文件末尾
        echo 'PermitRootLogin yes' | sudo tee -a /etc/ssh/sshd_config > /dev/null
        check_error
    fi

    # 检查文件中是否存在以'PasswordAuthentication'开头的行
    if ! grep -q '^PasswordAuthentication' /etc/ssh/sshd_config; then
        # 不存在匹配行，追加'PasswordAuthentication yes'到文件末尾
        echo 'PasswordAuthentication yes' | sudo tee -a /etc/ssh/sshd_config > /dev/null
        check_error
    fi
}

# 重启 SSHD 服务
restart_sshd_service() {
    sudo service sshd restart
    check_error
}

# 提示用户选择密码选项
echo "请选择密码选项："
echo "1. 生成密码"
echo "2. 输入密码"
read -p "请输入选项： " option

case $option in
    1)
        password=$(generate_random_password) # 保存生成的密码
        ;;
    2)
        read -p "请输入密码： " custom_password
        echo "root:$custom_password" | sudo chpasswd
        check_error
        password=$custom_password # 保存输入的密码
        ;;
    *)
        echo "无效选项。退出..."
        exit 1
        ;;
esac

modify_sshd_config
restart_sshd_service

echo "操作成功完成。" # 输出成功消息
echo "密码更改成功：$password" >&2 # 输出密码到标准错误流


# 删除下载的脚本
rm -f "$0"
