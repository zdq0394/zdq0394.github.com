Load balancer features
In this section I will briefly summarize the high level features that load balancers provide. Not all load balancers provide all features.
Service discovery
Service discovery is the process by which a load balancer determines the set of available backends. The methods are quite varied and some examples include:
Static configuration file.
DNS.
Zookeeper, Etcd, Consul, etc.
Envoy’s universal data plane API.
Health checking
Health checking is the process by which the load balancer determines if the backend is available to serve traffic. Health checking generally falls into two categories:
Active: The load balancer sends a ping on a regular interval (e.g., an HTTP request to a /healthcheck endpoint) to the backend and uses this to gauge health.
Passive: The load balancer detects health status from the primary data flow. e.g., an L4 load balancer might decide a backend is unhealthy if there have been three connection errors in a row. An L7 load balancer might decide a backend is unhealthy if there have been three HTTP 503 response codes in a row.
Load balancing
Yes, load balancers have to actually balance load! Given a set of healthy backends, how is the backend selected that will serve a connection or request? Load balancing algorithms are an active area of research and range from simplistic ones such as random selection and round robin, to more complicated algorithms that take into account variable latency and backend load. One of the most popular load balancing algorithms given its performance and simplicity is known as power of 2 least request load balancing.
Sticky sessions
In certain applications, it is important that requests for the same session reach the same backend. This might have to do with caching, temporary complex constructed state, etc. The definition of a session varies and might include HTTP cookies, properties of the client connection, or some other attribute. Many L7 load balancers have some support for sticky sessions. As an aside, I will note that session stickiness is inherently fragile (the backend hosting the session can die), so caution is advised when designing a system that relies on them.
TLS termination
The topic of TLS and its role in both edge serving and securing service-to-service communication is worthy of its own post. With that said, many L7 load balancers do a large amount of TLS processing that includes termination, certificate verification and pinning, certificate serving using SNI, etc.
Observability
As I like to say in my talks: “Observability, observability, observability.” Networks are inherently unreliable and the load balancer is often responsible for exporting stats, traces, and logs that help operators figure out what is wrong so they can remediate the problem. Load balancers vary widely in their observability output. The most advanced load balancers offer copious output that includes numeric stats, distributed tracing, and customizable logging. I will point out that enhanced observability is not free; the load balancer has to do extra work to produce it. However, the benefits of the data greatly outweigh the relatively minor performance implications.
Security and DoS mitigation
Especially in the edge deployment topology (see below), load balancers often implement various security features including rate limiting, authentication, and DoS mitigation (e.g., IP address tagging and identification, tarpitting, etc.).
Configuration and control plane
Load balancers need to be configured. In large deployments, this can become a substantial undertaking. In general, the system that configures the load balancers is known as the “control plane” and varies widely in its implementation. For more information on this topic please see my post on service mesh data plane vs. control plane.
And a whole lot more
This section has just scratched the surface of the types of functionality that load balancers provide. Additional discussion can be found in the section on L7 load balancers below.