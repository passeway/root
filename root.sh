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
    random_password=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9!@#$%^&*()_-')
    echo "root:$random_password" | sudo chpasswd
    check_error
    echo "$random_password" # 输出密码
}

# 修改 sshd_config 文件
modify_sshd_config() {
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    check_error

    # 在 sshd_config 中启用 PermitRootLogin
    sudo sed -i 's/^#?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
    check_error

    # 在 sshd_config 中启用 PasswordAuthentication
    sudo sed -i 's/^#?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    check_error
}

# 修改 PAM 配置文件
modify_pam_config() {
    sudo cp /etc/pam.d/sshd /etc/pam.d/sshd.bak
    check_error

    # 取消注释与密码验证相关的行
    sudo sed -i '/password.*required.*pam_unix.so/s/^#//g' /etc/pam.d/sshd
    check_error
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
read -p "请输入选项编号： " option

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
modify_pam_config
restart_sshd_service

echo "密码更改成功：$password" # 输出密码



# 删除下载的脚本
rm -f "$0"
