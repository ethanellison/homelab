# Guide to Sequence Argo CD Sync Phases Using `sync-wave` and `hook` Annotation

Argo CD allows you to control the order in which resources are applied during a sync operation using the `argocd.argoproj.io/sync-wave` annotation. This is particularly useful when certain resources depend on others being created or updated first.

## What is `sync-wave`?

The `sync-wave` annotation specifies the order in which resources are applied during a sync. Resources with lower `sync-wave` values are applied first. By default, all resources have a `sync-wave` value of `0`.

## How to Use `sync-wave`

1. **Add the Annotation**  
    Add the `argocd.argoproj.io/sync-wave` annotation to your Kubernetes manifests. For example:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: my-app
      annotations:
         argocd.argoproj.io/sync-wave: "1"
    spec:
      # Deployment spec here
    ```

2. **Assign Sync Waves**  
    Assign `sync-wave` values to your resources based on their dependencies. For example:
    - Resources with `sync-wave: "0"` are applied first.
    - Resources with `sync-wave: "1"` are applied next, and so on.

3. **Example**  
    Consider the following resources:
    - A ConfigMap (`sync-wave: "0"`) that must exist before a Deployment.
    - A Deployment (`sync-wave: "1"`) that depends on the ConfigMap.

    ```yaml
    # ConfigMap
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: my-config
      annotations:
         argocd.argoproj.io/sync-wave: "0"
    data:
      key: value

    ---
    # Deployment
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: my-app
      annotations:
         argocd.argoproj.io/sync-wave: "1"
    spec:
      replicas: 1
      selector:
         matchLabels:
            app: my-app
      template:
         metadata:
            labels:
              app: my-app
         spec:
            containers:
            - name: my-container
              image: nginx
              envFrom:
              - configMapRef:
                    name: my-config
    ```

4. **Sync Behavior**  
    During a sync operation, Argo CD will:
    - Apply the ConfigMap first (`sync-wave: "0"`).
    - Apply the Deployment next (`sync-wave: "1"`).

## Using the `hook` Annotation for PreSync Phase

Argo CD also provides the `argocd.argoproj.io/hook` annotation, which allows you to specify when a resource should be applied during the sync process. The `PreSync` phase is particularly useful for resources that need to be created or updated before the main sync operation begins.

### What is the `hook` Annotation?

The `hook` annotation defines the lifecycle phase during which a resource should be applied. For example, setting the annotation to `PreSync` ensures the resource is applied before any other resources in the sync operation.

### How to Use the `hook` Annotation

1. **Add the Annotation**  
    Add the `argocd.argoproj.io/hook` annotation to your Kubernetes manifests. For example:

    ```yaml
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: pre-sync-job
      annotations:
          argocd.argoproj.io/hook: PreSync
    spec:
      # Job spec here
    ```

2. **Example**  
    Consider a Job that initializes a database before deploying an application:

    ```yaml
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: db-init-job
      annotations:
          argocd.argoproj.io/hook: PreSync
    spec:
      template:
         spec:
            containers:
            - name: db-init
              image: my-db-init-image
              command: ["sh", "-c", "initialize-database.sh"]
            restartPolicy: OnFailure
    ```

3. **Sync Behavior**  
    During a sync operation, Argo CD will:
    - Apply the Job in the `PreSync` phase.
    - Wait for the Job to complete before proceeding with the main sync operation.

### Best Practices

- **Use Hooks Sparingly**  
    Only use the `hook` annotation for resources that are truly required in the `PreSync` phase to avoid unnecessary complexity.

- **Monitor Hook Resources**  
    Ensure that resources applied in the `PreSync` phase are monitored and do not block the sync operation indefinitely.

- **Combine with `sync-wave`**  
    You can combine the `hook` annotation with `sync-wave` to further control the order of resource application within the `PreSync` phase.

- **Use Incremental Waves**  
    Use small, incremental `sync-wave` values (e.g., `0`, `1`, `2`) to make it easier to adjust the order later.

- **Document Dependencies**  
    Clearly document why specific `sync-wave` values are assigned to resources to help maintainers understand the sync order.

- **Test Syncs**  
    Test your syncs in a staging environment to ensure resources are applied in the correct order.

## Conclusion

The `hook` annotation is a powerful feature for managing resources that need to be applied in specific phases of the sync process. By using the `PreSync` phase, you can ensure that critical initialization tasks are completed before the main sync operation begins.

The `sync-wave` annotation is a powerful tool for sequencing resource application in Argo CD. By carefully assigning `sync-wave` values, you can ensure that resources are applied in the correct order, avoiding dependency issues during sync operations.