#!/bin/bash

# 函数：检查错误并退出
# 参数 $1: 错误消息
check_error() {
    if [ $? -ne 0 ]; then
        echo "发生错误： $1"
        exit 1
    fi
}

# 函数：检查是否具有 root 权限
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "需要 root 权限来运行此脚本。请使用 sudo 或以 root 用户身份运行。"
        exit 1
    fi
}

# 函数：生成随机密码
generate_random_password() {
    random_password=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9!@#$%^&*()_-')
    echo "root:$random_password" | sudo chpasswd
    check_error "生成随机密码时出错"
    echo "$random_password" # 输出密码
}

# 函数：修改 sshd_config 文件
modify_sshd_config() {
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    check_error "备份 sshd_config 文件时出错"

    # 注释掉 Include /etc/ssh/sshd_config.d/*.conf 行
    sudo sed -i 's/^Include \/etc\/ssh\/sshd_config.d\/\*\.conf/# &/' /etc/ssh/sshd_config
    check_error "注释掉 Include 行时出错"

    # 检查文件中是否存在以'PermitRootLogin'开头的行
    if grep -q '^PermitRootLogin' /etc/ssh/sshd_config; then
        # 存在匹配行，用'PermitRootLogin yes'替换
        sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
        check_error "修改 PermitRootLogin 时出错"
    else
        # 不存在匹配行，追加'PermitRootLogin yes'到文件末尾
        echo 'PermitRootLogin yes' | sudo tee -a /etc/ssh/sshd_config > /dev/null
        check_error "追加 PermitRootLogin 时出错"
    fi

    # 检查文件中是否存在以'PasswordAuthentication'开头的行
    if grep -q '^PasswordAuthentication' /etc/ssh/sshd_config; then
        # 存在匹配行，用'PasswordAuthentication yes'替换
        sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        check_error "修改 PasswordAuthentication 时出错"
    else
        # 不存在匹配行，追加'PasswordAuthentication yes'到文件末尾
        echo 'PasswordAuthentication yes' | sudo tee -a /etc/ssh/sshd_config > /dev/null
        check_error "追加 PasswordAuthentication 时出错"
    fi
}

# 函数：重启 SSHD 服务
restart_sshd_service() {
    sudo service sshd restart
    check_error "重启 SSHD 服务时出错"
}

# 主函数
main() {
    # 提示用户选择密码选项
    echo "请选择密码选项："
    echo "1. 生成密码"
    echo "2. 输入密码"
    read -p "请输入选项编号：" option

    case $option in
        1)
            check_root
            password=$(generate_random_password) # 保存生成的密码
            ;;
        2)
            read -p "请输入更改密码：" custom_password
            echo "root:$custom_password" | sudo chpasswd
            check_error "修改密码时出错"
            password=$custom_password # 保存输入的密码
            ;;
        *)
            echo "无效选项 退出..."
            exit 1
            ;;
    esac

    modify_sshd_config
    restart_sshd_service

    echo "密码已成功更改：$password" # 输出密码

    # 删除下载的脚本
    rm -f "$0"
}

# 执行主函数
main
