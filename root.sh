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
    # 使用更强的随机密码生成方式
    random_password=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9!@#$%^&*()_+')
    # 确保 root 用户已启用
    sudo passwd -u root >/dev/null 2>&1
    echo "root:$random_password" | sudo chpasswd
    check_error "生成随机密码时出错"
    echo "$random_password" # 输出密码
}

# 函数：修改 sshd_config 文件
modify_sshd_config() {
    # 备份原始配置文件
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F-%H%M%S)
    check_error "备份 sshd_config 文件时出错"
    
    # 处理 Ubuntu 24.04 的 Include 配置
    # 1. 首先检查并处理主配置文件
    if grep -q "^Include /etc/ssh/sshd_config.d/\*\.conf" /etc/ssh/sshd_config; then
        # 创建我们自己的配置，将会被主配置包含
        echo "# 由脚本添加的 root 登录配置" | sudo tee /etc/ssh/sshd_config.d/root-login.conf > /dev/null
        echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config.d/root-login.conf > /dev/null
        echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config.d/root-login.conf > /dev/null
        check_error "创建自定义配置文件时出错"
    else
        # 如果没有 Include 指令，则直接修改主配置文件
        # 处理 PermitRootLogin
        if grep -q "^PermitRootLogin" /etc/ssh/sshd_config; then
            sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
            check_error "修改 PermitRootLogin 时出错"
        else
            echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config > /dev/null
            check_error "追加 PermitRootLogin 时出错"
        fi
        
        # 处理 PasswordAuthentication
        if grep -q "^PasswordAuthentication" /etc/ssh/sshd_config; then
            sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
            check_error "修改 PasswordAuthentication 时出错"
        else
            echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config > /dev/null
            check_error "追加 PasswordAuthentication 时出错"
        fi
    fi
    
    # 检查是否有可能覆盖我们设置的其他配置
    if [ -d "/etc/ssh/sshd_config.d" ]; then
        for conf_file in /etc/ssh/sshd_config.d/*.conf; do
            if [ -f "$conf_file" ] && [ "$conf_file" != "/etc/ssh/sshd_config.d/root-login.conf" ]; then
                # 检查并注释掉其他文件中可能覆盖我们设置的行
                if grep -q "^PermitRootLogin" "$conf_file"; then
                    sudo sed -i 's/^PermitRootLogin/# PermitRootLogin/' "$conf_file"
                    check_error "处理其他配置文件中的 PermitRootLogin 时出错"
                fi
                if grep -q "^PasswordAuthentication" "$conf_file"; then
                    sudo sed -i 's/^PasswordAuthentication/# PasswordAuthentication/' "$conf_file"
                    check_error "处理其他配置文件中的 PasswordAuthentication 时出错"
                fi
            fi
        done
    fi
}

# 函数：检查 SSH 服务状态
check_ssh_service() {
    # Ubuntu 24.04 可能使用 systemd
    if command -v systemctl &> /dev/null; then
        if ! systemctl is-active --quiet ssh.service && ! systemctl is-active --quiet sshd.service; then
            echo "SSH 服务未运行，正在启动"
            if systemctl list-unit-files | grep -q ssh.service; then
                sudo systemctl start ssh.service
            elif systemctl list-unit-files | grep -q sshd.service; then
                sudo systemctl start sshd.service
            else
                echo "未找到 SSH 服务，请确保已安装 openssh-server"
                sudo apt update && sudo apt install -y openssh-server
                check_error "安装 openssh-server 时出错"
            fi
        fi
    else
        # 使用传统方式
        if ! service ssh status &> /dev/null && ! service sshd status &> /dev/null; then
            echo "SSH 服务未运行，正在启动..."
            if service --status-all 2>&1 | grep -q " ssh"; then
                sudo service ssh start
            elif service --status-all 2>&1 | grep -q " sshd"; then
                sudo service sshd start
            else
                echo "未找到 SSH 服务，请确保已安装 openssh-server"
                sudo apt update && sudo apt install -y openssh-server
                check_error "安装 openssh-server 时出错"
            fi
        fi
    fi
}

# 函数：重启 SSH 服务
restart_ssh_service() {
    # 首先检查服务是否安装
    check_ssh_service
    
    # 使用 systemd（Ubuntu 24.04 默认使用）
    if command -v systemctl &> /dev/null; then
        if systemctl list-unit-files | grep -q ssh.service; then
            sudo systemctl restart ssh.service
        elif systemctl list-unit-files | grep -q sshd.service; then
            sudo systemctl restart sshd.service
        fi
    else
        # 使用传统的 service 命令
        if service --status-all 2>&1 | grep -q " ssh"; then
            sudo service ssh restart
        elif service --status-all 2>&1 | grep -q " sshd"; then
            sudo service sshd restart
        fi
    fi
    check_error "重启 SSH 服务时出错"
    
    # 确认服务已启动
    if command -v systemctl &> /dev/null; then
        if systemctl is-active --quiet ssh.service || systemctl is-active --quiet sshd.service; then
            echo "服务已成功重启："
        else
            echo "警告: SSH 服务可能未正确启动，请手动检查"
        fi
    else
        if service ssh status &> /dev/null || service sshd status &> /dev/null; then
            echo "服务已成功重启："
        else
            echo "警告: SSH 服务可能未正确启动，请手动检查"
        fi
    fi
}

# 主函数
main() {
    # 检查是否为 root 权限
    check_root
    
    # 确保 SSH 服务已安装
    if ! command -v sshd &> /dev/null; then
        echo "安装 SSH 服务器"
        apt update && apt install -y openssh-server
        check_error "安装 SSH 服务器时出错"
    fi
    
    # 提示用户选择密码选项
    echo "请选择密码选项："
    echo "1. 生成密码"
    echo "2. 输入密码"   
    read -p "请输入选项编号：" option
    
    case $option in
        1)
            password=$(generate_random_password) # 保存生成的密码
            ;;
        2)
            read -s -p "请输入 root 密码：" custom_password
            echo
            read -s -p "请再次输入密码确认：" confirm_password
            echo
            
            if [ "$custom_password" != "$confirm_password" ]; then
                echo "两次输入的密码不匹配，退出"
                exit 1
            fi
            
            # 确保 root 用户已启用
            sudo passwd -u root >/dev/null 2>&1
            echo "root:$custom_password" | sudo chpasswd
            check_error "修改密码时出错"
            password=$custom_password # 保存输入的密码
            ;;
        *)
            echo "无效选项，退出"
            exit 1
            ;;
    esac
    
    # 修改 SSH 配置
    modify_sshd_config
    
    # 重启 SSH 服务
    restart_ssh_service
    

    echo "密码成功设置为: $password"
    

}

# 执行主函数
main
