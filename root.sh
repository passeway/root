# 生成10位包含特殊字符的密码
import random
import string

def generate_password(length=10):
    special_characters = '!@#$%^&*()_+-=[]{}|;:,.<>?'
    characters = string.ascii_letters + string.digits + special_characters
    password = ''.join(random.choice(characters) for i in range(length))
    return password

password = generate_password()

# 输出密码
echo "Generated password: $password"

# 设置密码并执行其他命令
echo "root:$password" | sudo chpasswd root
sudo sed -i 's/^?permitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo service sshd restart
