Global load balancing and the centralized control plane

Figure 13: Global load balancing
The future of load balancing will increasingly treat the individual load balancers as commodity devices. In my opinion, the real innovation and commercial opportunities all lie within the control plane. Figure 13 shows an example of a global load balancing system. In this example, a few different things are happening:
Each sidecar proxy is communicating with backends in three different zones (A, B, and C).
As illustrated, 90% of traffic is being sent to zone C while 5% of traffic is being sent to both zone A and B.
The sidecar proxy and the backends are all reporting periodic state to the global load balancer. This allows the global load balancer to make decisions that take into account latency, cost, load, current failures, etc.
The global load balancer periodically configures each sidecar proxy with current routing information.
The global load balancer will increasingly be able to do sophisticated things that no individual load balancer can do on its own. For example:
Automatically detect and route around zonal failure.
Apply global security and routing policies.
Detect and mitigate traffic anomalies including DDoS attacks using machine learning and neural networks.
Provide centralized UI and visualizations that allow engineers to understand and operate the entire distributed system in aggregate.
In order to make global load balancing possible, the load balancer used as the data plane must have sophisticated dynamic configuration capabilities. Please see my posts on Envoy’s universal data plane API as well as the service mesh data plane vs. control plane for more information on this topic.
