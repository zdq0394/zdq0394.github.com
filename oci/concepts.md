# OCI术语
## Bundle
A directory structure that is written ahead of time, distributed, and used to seed the runtime for creating a container and launching a process within it.

## Configuration
The config.json file in a bundle which defines the intended container and container process.

## Container
An environment for executing processes with configurable isolation and resource limitations. For example, namespaces, resource limits, and mounts are all part of the container environment.

## Container namespace
On Linux,the namespaces in which the configured process executes.

## JSON
All configuration JSON MUST be encoded in UTF-8. JSON objects MUST NOT include duplicate names. The order of entries in JSON objects is not significant.

## Runtime
An implementation of this specification. It reads the configuration files from a bundle, uses that information to create a container, launches a process inside the container, and performs other lifecycle actions.

## Runtime namespace
On Linux, the namespaces from which new container namespaces are created and from which some configured resources are accessed.