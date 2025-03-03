# SSL 证书配置

## 证书文件路径

- **证书文件 (Certificate)**  
  `/etc/ssl/certs/certificate.crt`
  
- **证书链 (CA Bundle)**  
  `/etc/ssl/certs/ca_bundle.crt`
  
- **私钥文件 (Private Key)**  
  `/etc/ssl/private/private.key`
  
- **完整证书 (fullchain.pem)**  
  `/etc/ssl/certs/fullchain.pem`

## 下载和配置证书

1. 下载证书链文件、证书文件和私钥文件：
   ```bash
   wget -O /etc/ssl/certs/ca_bundle.crt https://raw.githubusercontent.com/passeway/root/refs/heads/main/ca_bundle.crt
   wget -O /etc/ssl/certs/certificate.crt https://raw.githubusercontent.com/passeway/root/refs/heads/main/certificate.crt
   wget -O /etc/ssl/private/private.key https://raw.githubusercontent.com/passeway/root/refs/heads/main/private.key
   cat /etc/ssl/certs/certificate.crt /etc/ssl/certs/ca_bundle.crt > /etc/ssl/certs/fullchain.pem

