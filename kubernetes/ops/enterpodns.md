# 进入POD的NS
1. 查看指定pod运行的容器 ID
kubectl describe pod <pod> -n <namespace>
2. 获得容器进程的pid
docker inspect -f {{.State.Pid}} <container>
3. 进入该容器的network namespace
nsenter -n --target <PID>

## Shell
```sh
function e() {
    set -eu
    ns=${2-"default"}
    pod=`kubectl -n $ns describe pod $1 | grep -A10 "^Containers:" | grep -Eo 'docker://.*$' | head -n 1 | sed 's/docker:\/\/\(.*\)$/\1/'`
    pid=`docker inspect -f {{.State.Pid}} $pod`
    echo "entering pod netns for $ns/$1"
    cmd="nsenter -n --target $pid"
    echo $cmd
    $cmd
}
```
