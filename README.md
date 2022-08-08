# Creating an user with limited rights in Kubernetes

This will create an user with limited rights in a Kubernetes cluster: anything in a specified namespace plus read-only on a few cluster-wide resources like namespaces, nodes and others (see `templates/50clusterrole.yaml`). 

To use it, you just need to edit the first lines from the script `00run.sh`. After you run it, you will have a file called `config-,,,` which can be used as `KUBECONFIG`. For example:

```
$ export KUBECONFIG=config-iship-dev-user 
$ kubectl -n kube-system get pods
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:dev:dev-user" cannot list resource "pods" in API group "" in the namespace "kube-system"
```

