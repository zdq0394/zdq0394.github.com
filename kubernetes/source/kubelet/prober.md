# Kubelet Prober Manager
Kubelet Prober Manager管理pod的探测（probing）。
针对每个指定了prober的container，它创建一个probe worker。
该probe worker周期性的probe容器的状态并缓存结果。
