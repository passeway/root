# SSL 证书配置

IP证书： https://zerossl.com

创建文件夹 
```
mkdir -p /etc/ssl/zerossl
```
```
mkdir -p ./.well-known/pki-validation
```

创建验证文件
```
cat << EOF | sudo tee ./.well-known/pki-validation/替换.txt

EOF
```
临时HTTP服务器：python3 -m http.server 80

## 证书文件路径

- **证书文件 (Certificate)**  
  `/etc/ssl/zerossl/certificate.crt`
  
- **证书链 (CA Bundle)**  
  `/etc/ssl/zerossl/ca_bundle.crt`
  
- **私钥文件 (Private Key)**  
  `/etc/ssl/zerossl/private.key`
  
- **完整证书 (fullchain.pem)**  
  `/etc/ssl/zerossl/fullchain.pem`


合并服务器证书（certificate.crt）和证书链文件（ca_bundle.crt）
```
cat /etc/ssl/zerossl/certificate.crt /etc/ssl/zerossl/ca_bundle.crt > /etc/ssl/zerossl/fullchain.pem
```
## AdGuardHome指令
sudo /opt/AdGuardHome/AdGuardHome -s start

sudo /opt/AdGuardHome/AdGuardHome -s stop

sudo /opt/AdGuardHome/AdGuardHome -s restart

sudo /opt/AdGuardHome/AdGuardHome -s status

https://adguard-dns.io/kb/zh-CN/adguard-home/faq/#verboselog
