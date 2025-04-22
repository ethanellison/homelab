# CloudNativePG Operator

**Apply the PostgreSQL Cluster Configuration**:
Create a `postgresql.yaml` file with the following content:
```yaml
    apiVersion: postgresql.cnpg.io/v1
    kind: Cluster
    metadata:
      name: my-cluster
      namespace: my-postgres
    spec:
      instances: 3
      storage:
         size: 1Gi
         storageClass: standard
      postgresql:
         version: "14"
```

Apply the configuration:
```bash
kubectl apply -f postgresql.yaml
```
