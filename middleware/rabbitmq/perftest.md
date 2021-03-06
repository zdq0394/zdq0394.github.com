# 吞吐量测试
## 测试工具
[官方测试工具:RabbitMQ PerfTest](https://rabbitmq.github.io/rabbitmq-perf-test/snapshot/htmlsingle/#running-producers-and-consumers-on-different-machines)

## 命令行详解
```sh
bin/runjava com.rabbitmq.perf.PerfTest --help
usage: <program>
 -?,--help                                   show usage
 -a,--autoack                                auto ack
 -A,--multi-ack-every <arg>                  multi ack every
 -ad,--auto-delete <arg>                     should the queue be
                                             auto-deleted, default is true
 -b,--heartbeat <arg>                        heartbeat interval
 -B,--body <arg>                             comma-separated list of files
                                             to use in message bodies
 -c,--confirm <arg>                          max unconfirmed publishes
 -C,--pmessages <arg>                        producer message count
 -ct,--confirm-timeout <arg>                 waiting timeout for
                                             unconfirmed publishes before
                                             failing (in seconds)
 -ctp,--consumers-thread-pools <arg>         number of thread pools to use
                                             for all consumers, default is
                                             to use a thread pool for each
                                             consumer
 -d,--id <arg>                               test ID
 -D,--cmessages <arg>                        consumer message count
 -dcr,--disable-connection-recovery          disable automatic connection
                                             recovery
 -e,--exchange <arg>                         exchange name
 -E,--exclusive                              use server-named exclusive
                                             queues. Such queues can only
                                             be used by their declaring
                                             connection!
 -env,--environment-variables                show usage with environment
                                             variables
 -f,--flag <arg>                             message flag(s), supported
                                             values: persistent and
                                             mandatory. Use the option
                                             several times to specify
                                             several values.
 -h,--uri <arg>                              connection URI
 -H,--uris <arg>                             connection URIs (separated by
                                             commas)
 -hst,--heartbeat-sender-threads <arg>       number of threads for
                                             producers and consumers
                                             heartbeat senders
 -i,--interval <arg>                         sampling interval in seconds
 -k,--routing-key <arg>                      routing key
 -K,--random-routing-key                     use random routing key per
                                             message
 -l,--legacy-metrics                         display legacy metrics
                                             (min/avg/max latency)
 -L,--consumer-latency <arg>                 consumer latency in
                                             microseconds
 -m,--ptxsize <arg>                          producer tx size
 -M,--framemax <arg>                         frame max
 -mh,--metrics-help                          show metrics usage
 -mp,--message-properties <arg>              message properties as
                                             key/pair values, separated by
                                             commas, e.g. priority=5
 -ms,--use-millis                            should latency be collected
                                             in milliseconds, default is
                                             false. Set to true if
                                             producers are consumers run
                                             on different machines.
 -n,--ctxsize <arg>                          consumer tx size
 -niot,--nio-threads <arg>                   number of NIO threads to use
 -niotp,--nio-thread-pool <arg>              size of NIO thread pool,
                                             should be slightly higher
                                             than number of NIO threads
 -o,--output-file <arg>                      output file for timing
                                             results
 -p,--predeclared                            allow use of predeclared
                                             objects
 -P,--publishing-interval <arg>              publishing interval in
                                             seconds (opposite of producer
                                             rate limit)
 -prsd,--producer-random-start-delay <arg>   max random delay in seconds
                                             to start producers
 -pst,--producer-scheduler-threads <arg>     number of threads to use when
                                             using --publishing-interval
 -q,--qos <arg>                              consumer prefetch count
 -Q,--global-qos <arg>                       channel prefetch count
 -qa,--queue-args <arg>                      queue arguments as key/pair
                                             values, separated by commas,
                                             e.g. x-max-length=10
 -qp,--queue-pattern <arg>                   queue name pattern for
                                             creating queues in sequence
 -qpf,--queue-pattern-from <arg>             queue name pattern range
                                             start (inclusive)
 -qpt,--queue-pattern-to <arg>               queue name pattern range end
                                             (inclusive)
 -r,--rate <arg>                             producer rate limit
 -R,--consumer-rate <arg>                    consumer rate limit
 -rkcs,--routing-key-cache-size <arg>        size of the random routing
                                             keys cache. See
                                             --random-routing-key.
 -S,--slow-start                             start consumers slowly (1 sec
                                             delay between each)
 -s,--size <arg>                             message size in bytes
 -sb,--skip-binding-queues                   don't bind queues to the
                                             exchange
 -se,--sasl-external                         use SASL EXTERNAL
                                             authentication, default is
                                             false. Set to true if using
                                             client certificate
                                             authentication with the
                                             rabbitmq_auth_mechanism_ssl
                                             plugin.
 -st,--shutdown-timeout <arg>                shutdown timeout, default is
                                             5 seconds
 -t,--type <arg>                             exchange type
 -T,--body-content-type <arg>                body content-type
 -u,--queue <arg>                            queue name
 -udsc,--use-default-ssl-context             use JVM default SSL context
 -v,--version                                print version information
 -x,--producers <arg>                        producer count
 -X,--producer-channel-count <arg>           channels per producer
 -y,--consumers <arg>                        consumer count
 -Y,--consumer-channel-count <arg>           channels per consumer
 -z,--time <arg>                             run duration in seconds
                                             (unlimited by default)
```sh