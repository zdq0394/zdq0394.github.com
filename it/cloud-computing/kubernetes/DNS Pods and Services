# Services
## A Records
### Normal Services(ClusterIP)
> my-svc.my-namespace.svc.cluster.local: {ClusterIP of the service}


### Headless Services(without a ClusterIP)
>my-svc.my-namespace.svc.cluster.local: [{PodIP of the pods selected by the service}]

## SRV Records
### Normal Services(ClusterIP)
> \_my-port-name._my-port-protocol.my-svc.my-namespace.svc.cluster.local: {PORT my-svc.my-namespace.svc.cluster.local}


### Headless Services(without a ClusterIP)
> \_my-port-name._my-port-protocol.my-svc.my-namespace.svc.cluster.local: [{PORT auto-generated-name.my-svc.my-namespace.svc.cluster.local}]

# Pods
## A Records
>pod-ip-address.my-namespace.pod.cluster.local: {IP of the POD}

## A Records and hostname based on Pod's hostname and subdomain
>hostname.subdomain.my-namespace.svc.cluster.local: {IP of the POD}
