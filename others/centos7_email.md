# centos7下发送邮件设置
## 只发送邮件
安装软件包
```sh
yum -y install sendmail
service sendmail start
yum install mailx
```
编辑邮件正文
```sh
vim body.txt
test mail from linux.
```
发送邮件
```sh
mail -s "test mail from linux" yourname@163.com,yourname2@163.com <body.txt
```