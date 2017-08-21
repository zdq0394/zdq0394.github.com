# Namespaces

## 概要

一个Kubernetes集群，通过命名空间（namespace）将用户创建的资源**逻辑上进行分组**。

## 动机

单一集群应该满足多个用户团体（租户）的需求。

每个租户都希望能够与其他租户隔离开来。

每个租户都希望拥有自己的：

1. 资源 (pods, services, replication controllers等)
2. 访问策略 (who can or cannot perform actions in their community)
3. 配额限制 (this community is allowed this much quota, etc.)

集群管理员可以为每个租户创建一个**Namespace**。


**Namespace** 为下面的资源和操作提供了唯一的作用域（scope）：

1. named resources (to avoid basic naming collisions)
2. delegated management authority to trusted users
3. ability to limit community resource consumption

## 案例

1.  作为集群管理员，我想在单一集群服务多个租户。
2.  作为集群管理员，我想将集群一部分（仅供某租户使用）的管理授权给租户的某个成员。
3.  作为集群管理员，我想限制某个租户对资源的使用量，以免对集群造成重大影响。
4.  作为集群租户，我想独立的使用（隔离的）与我的租户相关的资源。

## 设计

### 数据模型

A *Namespace* defines a logically named group for multiple *Kind*s of resources.

```go
type Namespace struct {
  TypeMeta   `json:",inline"`
  ObjectMeta `json:"metadata,omitempty"`

  Spec NamespaceSpec `json:"spec,omitempty"`
  Status NamespaceStatus `json:"status,omitempty"`
}
```

A *Namespace* name is a DNS compatible label.

A *Namespace* must exist prior to associating content with it.

A *Namespace* must not be deleted if there is content associated with it.

To associate a resource with a *Namespace* the following conditions must be satisfied:

1.  The resource's *Kind* must be registered as having *RESTScopeNamespace* with the server
2.  The resource's *TypeMeta.Namespace* field must have a value that references an existing *Namespace*

The *Name* of a resource associated with a *Namespace* is unique to that *Kind* in that *Namespace*.

### Authorization

A *Namespace* provides an authorization scope for accessing content associated with the *Namespace*.

### Limit Resource Consumption

A *Namespace* provides a scope to limit resource consumption.

A *LimitRange* defines min/max constraints on the amount of resources a single entity can consume in a *Namespace*.

A *ResourceQuota* tracks aggregate usage of resources in the *Namespace* and allows cluster operators to define *Hard* resource usage limits that a *Namespace* may consume.

### Finalizers

Upon creation of a *Namespace*, the creator may provide a list of *Finalizer* objects.

```go
type FinalizerName string

// These are internal finalizers to Kubernetes, must be qualified name unless defined here
const (
  FinalizerKubernetes FinalizerName = "kubernetes"
)

// NamespaceSpec describes the attributes on a Namespace
type NamespaceSpec struct {
  // Finalizers is an opaque list of values that must be empty to permanently remove object from storage
  Finalizers []FinalizerName
}
```

A *FinalizerName* is a qualified name.

The API Server enforces that a *Namespace* can only be deleted from storage if and only if it's *Namespace.Spec.Finalizers* is empty.

A *finalize* operation is the only mechanism to modify the *Namespace.Spec.Finalizers* field post creation.

Each *Namespace* created has *kubernetes* as an item in its list of initial *Namespace.Spec.Finalizers* set by default.

### Phases

A *Namespace* may exist in the following phases.

```go
type NamespacePhase string
const(
  NamespaceActive NamespacePhase = "Active"
  NamespaceTerminating NamespacePhase = "Terminating"
)

type NamespaceStatus struct { 
  ...
  Phase NamespacePhase 
}
```

A *Namespace* is in the **Active** phase if it does not have a *ObjectMeta.DeletionTimestamp*.

A *Namespace* is in the **Terminating** phase if it has a *ObjectMeta.DeletionTimestamp*.

**Active**

Upon creation, a *Namespace* goes in the *Active* phase. This means that content may be associated with a namespace, and all normal interactions with the namespace are allowed to occur in the cluster.

If a DELETE request occurs for a *Namespace*, the *Namespace.ObjectMeta.DeletionTimestamp* is set to the current server time. A *namespace controller* observes the change, and sets the *Namespace.Status.Phase* to *Terminating*.

**Terminating**

A *namespace controller* watches for *Namespace* objects that have a *Namespace.ObjectMeta.DeletionTimestamp* value set in order to know when to initiate graceful termination of the *Namespace* associated content that are
known to the cluster.

The *namespace controller* enumerates each known resource type in that namespace and deletes it one by one.

**Admission control** blocks creation of new resources in that namespace in order to prevent a race-condition where the controller could believe all of a given resource type had been deleted from the namespace, when in fact some other rogue client agent had created new objects. Using admission control in this scenario allows each of registry implementations for the individual objects to not need to take into account Namespace life-cycle.

Once all objects known to the *namespace controller* have been deleted, the *namespace controller* executes a *finalize* operation on the namespace that
removes the *kubernetes* value from the *Namespace.Spec.Finalizers* list.

If the *namespace controller* sees a *Namespace* whose
*ObjectMeta.DeletionTimestamp* is set, and whose *Namespace.Spec.Finalizers*
list is empty, it will signal the server to permanently remove the *Namespace*
from storage by sending a final DELETE action to the API server.
