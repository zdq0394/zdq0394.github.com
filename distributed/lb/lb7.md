# 七层负载均衡器
## Protocol support
Modern L7 load balancers are adding explicit support for many different protocols. The more knowledge that the load balancer has about the application traffic, the more sophisticated things it can do with regard to observability output, advanced load balancing and routing, etc. 

## Dynamic configuration
As described above, the increasingly dynamic nature of distributed systems is requiring a parallel investment in creating dynamic and reactive control systems. 

**Istio** is one example of such a system.

## Advanced load balancing
L7 load balancers now commonly have built-in support for advanced load balancing features such as timeouts, retries, rate limiting, circuit breaking, shadowing, buffering, content based routing, etc.

## Observability
As described in the section above on general load balancer features, the increasingly dynamic systems that are being deployed are becoming increasingly hard to debug. 

Robust protocol specific observability output is possibly the most important feature that modern L7 load balancers provide. Outputting numeric stats, distributed traces, and customizable logging is now virtually required for any L7 load balancing solution.

## Extensibility
Users of modern L7 load balancers often want to easily extend them to add custom functionality. This can be done via writing pluggable filters that are loaded into the load balancer. Many load balancers also support scripting, typically via Lua.

## Fault tolerance
I wrote quite a bit above about L4 load balancer fault tolerance. What about L7 load balancer fault tolerance? 

In general, we treat L7 load balancers as **expendable** and **stateless**. 

Using commodity software allows L7 load balancers to be easily horizontally scaled. 
Furthermore, the processing and state tracking that L7 load balancers perform is substantially more complicated than L4. 
Attempting to build an HA pairing of an L7 load balancer is technically possible but it would be a major undertaking.

Overall, in both the L4 and L7 load balancing domains, the industry is moving away from HA pairing towards horizontally scalable systems that converge via consistent hashing.
