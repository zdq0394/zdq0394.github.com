# DNS相关命令
## nslookup
nslookup
```sh
# nslookup www.163.com
Server:		10.129.254.253
Address:	10.129.254.253#53

Non-authoritative answer:
www.163.com	canonical name = www.163.com.lxdns.com.
Name:	www.163.com.lxdns.com
Address: 112.65.92.117
```

## dig
```sh
# dig +trace +nodnssec www.163.com

; <<>> DiG 9.9.4-RedHat-9.9.4-61.el7 <<>> +trace +nodnssec www.163.com
;; global options: +cmd
.			141	IN	NS	b.root-servers.net.
.			141	IN	NS	d.root-servers.net.
.			141	IN	NS	c.root-servers.net.
.			141	IN	NS	i.root-servers.net.
.			141	IN	NS	a.root-servers.net.
.			141	IN	NS	h.root-servers.net.
.			141	IN	NS	m.root-servers.net.
.			141	IN	NS	l.root-servers.net.
.			141	IN	NS	j.root-servers.net.
.			141	IN	NS	g.root-servers.net.
.			141	IN	NS	f.root-servers.net.
.			141	IN	NS	e.root-servers.net.
.			141	IN	NS	k.root-servers.net.
;; Received 411 bytes from 10.129.254.253#53(10.129.254.253) in 711 ms

com.			172800	IN	NS	f.gtld-servers.net.
com.			172800	IN	NS	k.gtld-servers.net.
com.			172800	IN	NS	l.gtld-servers.net.
com.			172800	IN	NS	a.gtld-servers.net.
com.			172800	IN	NS	b.gtld-servers.net.
com.			172800	IN	NS	g.gtld-servers.net.
com.			172800	IN	NS	h.gtld-servers.net.
com.			172800	IN	NS	d.gtld-servers.net.
com.			172800	IN	NS	c.gtld-servers.net.
com.			172800	IN	NS	i.gtld-servers.net.
com.			172800	IN	NS	e.gtld-servers.net.
com.			172800	IN	NS	m.gtld-servers.net.
com.			172800	IN	NS	j.gtld-servers.net.
;; Received 836 bytes from 192.112.36.4#53(g.root-servers.net) in 537 ms

163.com.		172800	IN	NS	ns3.nease.net.
163.com.		172800	IN	NS	ns4.nease.net.
163.com.		172800	IN	NS	ns5.nease.net.
163.com.		172800	IN	NS	ns6.nease.net.
163.com.		172800	IN	NS	ns1.nease.net.
163.com.		172800	IN	NS	ns2.166.com.
163.com.		172800	IN	NS	ns8.166.com.
;; Received 227 bytes from 192.42.93.30#53(g.gtld-servers.net) in 323 ms

www.163.com.		600	IN	CNAME	www.163.com.lxdns.com.
;; Received 72 bytes from 220.181.36.234#53(ns3.nease.net) in 65 ms

```