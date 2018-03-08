# 以太坊私有链搭建
## 准备条件
Ubuntu 14.04操作系统
## 安装
执行以下命令：
``` bash
apt-get update
apt-get install software-properties-common
add-apt-repository -y ppa:ethereum/ethereum
add-apt-repository -y ppa:ethereum/ethereum-dev
apt-get update
apt-get install ethereum
```
如此就完成了以太坊客户端的安装，包括：
* geth
* bootnode
* evm
* disasm
* rlpdump
* ethtest

## 构建创世区块
首先进入任意目录，比如/mystore/ethereum。
1、创建如下文件piccgenes.json
```json
{
  "config": {
        "chainId": 15,
        "homesteadBlock": 0,
        "eip155Block": 0,
        "eip158Block": 0
    },
    "coinbase" : "0x0000000000000000000000000000000000000000",
    "difficulty" : "0x40000",
    "extraData" : "",
    "gasLimit" : "0xffffffff",
    "nonce" : "0x0000000000000042",
    "mixhash" : "0x0000000000000000000000000000000000000000000000000000000000000000",
    "parentHash" : "0x0000000000000000000000000000000000000000000000000000000000000000",
    "timestamp" : "0x00",
    "alloc": { }
}
```

2、初始化数据目录：
```
geth --datadir /mystore/ethereum/chain init piccgenesis.json
```

3、 启动geth
```
geth --identity "PICCetherumTestNode"  --rpc  --rpccorsdomain "*" --datadir "/mystore/ethereum/chain" --port "30303"  --rpcapi "db,eth,net,web3" --networkid 95518 --nodiscover console
```
console进入命令控制台
```
Welcome to the Geth JavaScript console!

instance: Geth/PICCetherumTestNode/v1.8.2-stable-b8b9f7f4/linux-amd64/go1.9.4
 modules: admin:1.0 debug:1.0 eth:1.0 miner:1.0 net:1.0 personal:1.0 rpc:1.0 txpool:1.0 web3:1.0
```

这样一条私有以太坊链启动了。
