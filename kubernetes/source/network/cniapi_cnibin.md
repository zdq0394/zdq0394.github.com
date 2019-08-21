# 从CNI API到CNI二进制
Kubelet通过cniNetworkPlugin调用CNI API接口实现与CNI二进制插件的调用。
CNI API是如何调用CNI二进制插件的呢？
## invoke
代码：containernetworking/cni/pkg/invoke包中
### Exec
Exec可以认为是一个二进制执行引擎。
```
type Exec interface {
	ExecPlugin(ctx context.Context, pluginPath string, stdinData []byte, environ []string) ([]byte, error)
	FindInPath(plugin string, paths []string) (string, error)
	Decode(jsonBytes []byte) (version.PluginInfo, error)
}

```
invoke包提供了一个默认的二进制执行引擎——`DefaultExec`，`DefaultExec`主要由`RawExec`来实现执行功能。

### RawExec
#### ExecPlugin
结构体RawExec实现了方法ExecPlugin：

```go
func (e *RawExec) ExecPlugin(ctx context.Context, pluginPath string, stdinData []byte, environ []string) ([]byte, error) {
	stdout := &bytes.Buffer{}
	c := exec.CommandContext(ctx, pluginPath)
	c.Env = environ
	c.Stdin = bytes.NewBuffer(stdinData)
	c.Stdout = stdout
	c.Stderr = e.Stderr
	if err := c.Run(); err != nil {
		return nil, pluginErr(err, stdout.Bytes())
	}

	return stdout.Bytes(), nil
}
```

从代码可以看出，本质上是通过os/exec库，调用Command的run方法。
其中ExecPlugin的四个参数：
1. ctx，作为Cmd的context
2. pluginPath，是执行的二进制命令
3. stdinData，作为二进制命令的标准输入传入
4. environ，作为二进制命令的环境变量出入
可以看出，二进制命令没有args，所有的参数通过标准输入和环境变量传进来，分别是ExecPlugin的第3和第4个参数。

如此，二进制代码里只要解析环境变量和标准输入就可以获取上游代码（cniNetworkPlugin/cniapi）传递过来的参数。而上游代码只要直接将准备传入的参数作为ExecPlugin的第3个和第4个参数就可以传递给二进制。

#### FindInPath
前面讲了ExecPlugin的第2个参数是二进制命令，那这个命令是如何找到的呢？
```go
func (e *RawExec) FindInPath(plugin string, paths []string) (string, error) {
	return FindInPath(plugin, paths)
}
```
这个方法比较简单，就是遍历paths路径，找到plugin的二进制（当然根据系统环境会加上必要的可执行文件扩展名，Linux没有扩展名）是否存在。如果存在，则返回二进制文件的全路径。

### 调用接口helper
exec提供了公共的调用Exec(DefaultExec/RawExec)的方法：
* func ExecPluginWithResult(ctx context.Context, pluginPath string, netconf []byte, args CNIArgs, exec Exec) (types.Result, error) 
* func ExecPluginWithoutResult(ctx context.Context, pluginPath string, netconf []byte, args CNIArgs, exec Exec) error

两个方法参数一样，只有返回值不一样。

```go
func ExecPluginWithoutResult(ctx context.Context, pluginPath string, netconf []byte, args CNIArgs, exec Exec) error {
	if exec == nil {
		exec = defaultExec
	}
	_, err := exec.ExecPlugin(ctx, pluginPath, netconf, args.AsEnv())
	return err
}
```
根据我们掌握的RawExec.ExecPlugin可以知道：
Helper方法的第3个参数`netconf`将会作为标准输入传入二进制代码；第4个参数CNIArgs类型，将进行转换，作为env传入二进制代码。

转换方式如下，可以发现，不但包括args的所有内容，还包括当前的Env。
```go
func (args *Args) AsEnv() []string {
    env := os.Environ()
    ...
	env = append([]string{
		"CNI_COMMAND=" + args.Command,
		"CNI_CONTAINERID=" + args.ContainerID,
		"CNI_NETNS=" + args.NetNS,
		"CNI_ARGS=" + pluginArgsStr,
		"CNI_IFNAME=" + args.IfName,
		"CNI_PATH=" + args.Path,
	}, env...)
	return env
}
```

## cni api
cni提供了如下接口：
```go
type CNI interface {
	AddNetworkList(ctx context.Context, net *NetworkConfigList, rt *RuntimeConf) (types.Result, error)
	CheckNetworkList(ctx context.Context, net *NetworkConfigList, rt *RuntimeConf) error
	DelNetworkList(ctx context.Context, net *NetworkConfigList, rt *RuntimeConf) error

	AddNetwork(ctx context.Context, net *NetworkConfig, rt *RuntimeConf) (types.Result, error)
	CheckNetwork(ctx context.Context, net *NetworkConfig, rt *RuntimeConf) error
	DelNetwork(ctx context.Context, net *NetworkConfig, rt *RuntimeConf) error
	GetNetworkCachedResult(net *NetworkConfig, rt *RuntimeConf) (types.Result, error)

	ValidateNetworkList(ctx context.Context, net *NetworkConfigList) ([]string, error)
	ValidateNetwork(ctx context.Context, net *NetworkConfig) ([]string, error)
}
```
CNIConfig是CNI接口的一个具体实现。
```go
type CNIConfig struct {
	Path []string
	exec invoke.Exec
}

// CNIConfig implements the CNI interface
var _ CNI = &CNIConfig{}
```

那CNI如何实现上述接口的呢？我们以addNetwork为例：
```go
func (c *CNIConfig) addNetwork(ctx context.Context, name, cniVersion string, net *NetworkConfig, prevResult types.Result, rt *RuntimeConf) (types.Result, error) {
	c.ensureExec()
	pluginPath, err := c.exec.FindInPath(net.Network.Type, c.Path)
	if err != nil {
		return nil, err
	}

	newConf, err := buildOneConfig(name, cniVersion, net, prevResult, rt)
	if err != nil {
		return nil, err
	}

	return invoke.ExecPluginWithResult(ctx, pluginPath, newConf.Bytes, c.args("ADD", rt), c.exec)
}
```
分析以上代码：
* c.ensureExec保证c.exec存在，并默认配置DefaultExec。
* pluginPath，二进制执行文件由c.Path和网络类型决定，比如calico，那就/path/to/cnibin/calico。(默认为/opt/cni/bin/calico)。
* newConf由网络配置networkConfig和运行时参数runtimeConf和合成，然后作为stdinData传入二进制代码。
* 运行时参数runtimeConf增加网络动作（ADD/DEL/CHECK）生成args类型，然后转换为env传入二进制代码。

## cni二进制
cni提供了骨架代码以方便实现网络插件。任何网络插件实现时都要调用如下代码：
```go
func PluginMain(cmdAdd, cmdCheck, cmdDel func(_ *CmdArgs) error, versionInfo version.PluginInfo, about string) {
	if e := PluginMainWithError(cmdAdd, cmdCheck, cmdDel, versionInfo, about); e != nil {
		if err := e.Print(); err != nil {
			log.Print("Error writing error JSON to stdout: ", err)
		}
		os.Exit(1)
	}
}

```
也就是网络插件只需要实现三个方法：
* cmdAdd
* cmdCheck
* cmdDel
这三个方法都是接受CmdArgs的参数。

是的，这三个方法不是直接接收上游代码传过来的stdin和env获取参数。那一定是在调用cmdAdd/cmdCheck/cmdDel等具体方法之前作了转换。
```go

func (t *dispatcher) getCmdArgsFromEnv() (string, *CmdArgs, error) {
	var cmd, contID, netns, ifName, args, path string

	vars := []struct {
		name      string
		val       *string
		reqForCmd reqForCmdEntry
	}{
		{
			"CNI_COMMAND",
			&cmd,
			reqForCmdEntry{
				"ADD":   true,
				"CHECK": true,
				"DEL":   true,
			},
		},
		{
			"CNI_CONTAINERID",
			&contID,
			reqForCmdEntry{
				"ADD":   true,
				"CHECK": true,
				"DEL":   true,
			},
		},
		{
			"CNI_NETNS",
			&netns,
			reqForCmdEntry{
				"ADD":   true,
				"CHECK": true,
				"DEL":   false,
			},
		},
		{
			"CNI_IFNAME",
			&ifName,
			reqForCmdEntry{
				"ADD":   true,
				"CHECK": true,
				"DEL":   true,
			},
		},
		{
			"CNI_ARGS",
			&args,
			reqForCmdEntry{
				"ADD":   false,
				"CHECK": false,
				"DEL":   false,
			},
		},
		{
			"CNI_PATH",
			&path,
			reqForCmdEntry{
				"ADD":   true,
				"CHECK": true,
				"DEL":   true,
			},
		},
	}

	argsMissing := make([]string, 0)
	for _, v := range vars {
		*v.val = t.Getenv(v.name)
		if *v.val == "" {
			if v.reqForCmd[cmd] || v.name == "CNI_COMMAND" {
				argsMissing = append(argsMissing, v.name)
			}
		}
	}

	stdinData, err := ioutil.ReadAll(t.Stdin)

	cmdArgs := &CmdArgs{
		ContainerID: contID,
		Netns:       netns,
		IfName:      ifName,
		Args:        args,
		Path:        path,
		StdinData:   stdinData,
	}
	return cmd, cmdArgs, nil
}

```
可以发现分别从环境变量和标准输入读取了参数值，然后生成具体方法需要的参数CmdArgs类型。




