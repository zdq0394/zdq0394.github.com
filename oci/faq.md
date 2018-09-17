# FAQ
## WHAT IS THE RELATIONSHIP BETWEEN CONTAINERD, OCI AND RUNC?
Docker donated the OCI specification to the Linux Foundation in 2015, along with a reference implementation called runc.

**Containerd** integrates **OCI/runc** into a feature-complete, production-ready core container runtime. 

**Runc** is a component of **containerd**, the executor for containers. 

Containerd has a wider scope than just executing containers: downloading container images, managing storage and network interfaces, calling runc with the right parameters to run containers. 

Containerd fully leverages the Open Container Initiative’s (OCI) runtime, image format specifications and OCI reference implementation (runc) and will pursue OCI certification when it is available. 

Because of its massive adoption, Containerd is the industry standard for implementing OCI.

**总结：OCI规范包括runtime-spec、image-spec、distribution-spec等。Runc仅仅实现了runtime-spec规范，而Containerd实现了完整的规范——并且在runtime-spec规范利用了Runc。**