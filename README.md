
## 预览

![preview](https://tc.943465722.xyz/i/2024/04/06/095838.png
)

## SSH密码

这个脚本用于配置SSH并设置root用户的密码。


## 一键脚本

  ```bash
curl -sS -o root.sh https://raw.githubusercontent.com/passeway/root/main/root.sh && chmod +x root.sh && ./root.sh
```
## 详细说明
- 脚本会根据用户选择，生成随机密码或者设置自定义密码，并将其应用于root用户。

- 脚本会修改SSH服务器的配置文件以允许root用户登录和使用密码进行身份验证，并重启SSH服务以应用更改。
## 注意事项
- 在使用脚本之前，请确保您拥有管理员权限。

- 在执行脚本之前，请确保您了解脚本的操作，并且备份您的系统或者重要数据。

- 如果您在使用过程中遇到任何问题或者有任何建议，请随时提交GitHub Issues。

