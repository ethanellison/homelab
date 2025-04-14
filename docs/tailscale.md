# Tailscale

One of the biggest challenges with a homelab is securely accessing it from outside your home network.  For me, Tailscale has been a game-changer.  And when it comes to my K3s cluster, the Tailscale Kubernetes operator is pure magic.  Imagine being able to expose your services with just a few lines of YAML!  It boils down to creating an Ingress resource, pointing it to your service, and adding `ingressClassName: tailscale`.

I use ArgoCD as my GitOps engine, and I'm a big fan of the App of Apps approach.  To ensure I was on the right track and maybe even discover some improvements, I decided to get a second opinion from Gemini.

**TLDR:**

* `targetRevision` - Use a specific version
* Consider a Dedicated Argo CD Project

I realized after the fact that k3s includes a Helm controller to manage helm charts using a HelmChart CRD. I plan on looking into using this along with the Argo to deploy and manage helm charts in my homelab (while also implementing some of Gemini recommendations). For now, it works! And I can access cluster services on my tailnet.

---

## Thoughts from Gemini

This is a good starting point for an Argo CD Application that deploys the Tailscale Kubernetes Operator. Here's a breakdown of the configuration and some suggestions for improvements:

**Explanation:**

* **`apiVersion: argoproj.io/v1alpha1`**:  Specifies the API version for Argo CD Applications.
* **`kind: Application`**:  Defines this as an Argo CD Application resource.
* **`metadata:`**:
  * **`name: tailscale`**:  The name of the Argo CD Application.  This should be unique within the Argo CD namespace.
  * **`namespace: argocd`**:  The namespace where the Argo CD Application is deployed.  This is typically `argocd`.
* **`spec:`**:
  * **`project: default`**:  The Argo CD project the application belongs to.  You can create custom projects for better organization.
  * **`source:`**:  Defines the source of the application's manifests.
    * **`repoURL: "https://github.com/tailscale/tailscale"`**: The URL of the Git repository containing the Tailscale source code.
    * **`targetRevision: HEAD`**:  Uses the latest commit on the default branch (usually `main` or `master`).  **Important Note:** Using `HEAD` is generally discouraged for production environments.  It's better to use a specific tag, branch, or commit SHA for stability.
    * **`path: cmd/k8s-operator/deploy/chart`**:  The path within the repository to the Helm chart.  This is the directory containing the `Chart.yaml` file.
    * **`helm:`**:
      * **`values:`**:  Allows you to override default values in the Helm chart's `values.yaml` file.
        * **`replicaCount: 2`**:  Sets the number of replicas for the Tailscale Operator deployment.
        * **`resources:`**:  Defines resource requests and limits for the Tailscale Operator pods.  This helps Kubernetes schedule the pods effectively.
          * **`limits:`**:  The maximum resources a pod can use.
          * **`requests:`**:  The minimum resources a pod requires to start.
  * **`destination:`**:  Defines where the application will be deployed.
    * **`server: "https://kubernetes.default.svc"`**: The Kubernetes API server URL.  This is the standard in-cluster URL and should work in most cases.
    * **`namespace: tailscale`**: The Kubernetes namespace where the Tailscale Operator will be deployed.
  * **`syncPolicy:`**:  Defines how Argo CD should synchronize the application with the desired state.
    * **`automated:`**:
      * **`prune: true`**:  Deletes Kubernetes resources that are no longer defined in the Git repository.
      * **`selfHeal: true`**:  Automatically corrects any deviations from the desired state.
    * **`syncOptions:`**:
      * **`CreateNamespace=true`**:  Automatically creates the `tailscale` namespace if it doesn't exist.

**Improvements and Considerations:**

1. **`targetRevision` - Use a Specific Version:*

   * **Problem:**  Using `HEAD` can lead to unpredictable deployments if the Tailscale repository is updated.  You could experience breaking changes or unexpected behavior.
   * **Solution:**  Change `targetRevision` to a specific tag, branch, or commit SHA.  For example:
     * **Tag:** `targetRevision: v1.50.0` (or the latest stable tag)
     * **Branch:** `targetRevision: release-1.50` (if they have release branches)
     * **Commit SHA:** `targetRevision: 0a1b2c3d4e5f67890abcdef1234567890abcdef`
   * **How to choose:**  Using tags is generally the best practice.  Release branches can be useful for tracking specific release cycles.  Commit SHAs are the most specific but can be difficult to manage.

2. **Consider a Dedicated Argo CD Project (Optional):**

   * If you have multiple applications, consider creating a dedicated Argo CD project for Tailscale.  This helps with organization and access control.
   * Example:

     ```yaml
     apiVersion: argoproj.io/v1alpha1
     kind: AppProject
     metadata:
       name: tailscale-project
       namespace: argocd
     spec:
       description: Project for Tailscale deployments
       sourceRepos:
         - "https://github.com/tailscale/tailscale"  # Limit to the Tailscale repo
       destinations:
         - namespace: tailscale
           server: "https://kubernetes.default.svc"
       clusterResourceWhitelist:
         - group: '*'
           kind: '*'
     ```

     Then, in your Application:

     ```yaml
     spec:
       project: tailscale-project
     ```

3. **Helm Values - Externalize for Easier Management (Optional):**

   * For complex configurations, consider storing the Helm values in a separate file within the repository or using a dedicated configuration management system.  This makes the Argo CD Application definition cleaner and easier to maintain.
   * You could create a `values-tailscale.yaml` file in your repository and then reference it in the Argo CD Application.

4. **Health Checks:**

   * While not directly in the Application definition, ensure the Tailscale Operator's deployment and pods have proper health checks (liveness and readiness probes) configured in the Helm chart itself.  This helps Kubernetes automatically restart unhealthy pods.  These should already be present in the Tailscale Helm chart.

5. **Update Strategies:**

   * The default update strategy for deployments is often RollingUpdate.  You can customize this in the Helm chart or override it using Helm values.  Consider the impact of updates on your Tailscale network.

6. **Resource Limits and Requests:**

   * Carefully consider the resource limits and requests you've specified.  Monitor the Tailscale Operator's resource usage and adjust them as needed.  Insufficient resources can lead to performance issues or instability.  Too much can waste resources.

7. **Security Considerations:**

   * **RBAC:** Ensure that the Tailscale Operator has the necessary RBAC permissions to manage the resources it needs to.  This is typically handled by the Helm chart.  Review the roles and rolebindings.
   * **Secrets:**  If the Tailscale Operator requires any secrets (e.g., API keys), manage them securely using Kubernetes Secrets or a dedicated secrets management solution like HashiCorp Vault.

8. **Testing:**

   * Thoroughly test your Tailscale deployment after applying the Argo CD Application.  Verify that the Tailscale network is functioning correctly and that the operator is managing resources as expected.

**Example with Tag and Dedicated Project:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: tailscale-project
  namespace: argocd
spec:
  description: Project for Tailscale deployments
  sourceRepos:
    - "https://github.com/tailscale/tailscale"
  destinations:
    - namespace: tailscale
      server: "https://kubernetes.default.svc"
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: tailscale
  namespace: argocd
spec:
  project: tailscale-project
  source:
    repoURL: "https://github.com/tailscale/tailscale"
    targetRevision: v1.50.0  # Use a specific tag!
    path: cmd/k8s-operator/deploy/chart
    helm:
      values: |
        replicaCount: 2
        resources:
          limits:
            cpu: "500m"
            memory: "256Mi"
          requests:
            cpu: "250m"
            memory: "128Mi"

  destination:
    server: "https://kubernetes.default.svc"
    namespace: tailscale
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

**How to Apply:**

1. Save the YAML to a file (e.g., `tailscale-app.yaml`).
2. Apply it to your Kubernetes cluster: `kubectl apply -f tailscale-app.yaml -n argocd`

Remember to replace `v1.50.0` with the actual tag you want to use.  Also, carefully review the Tailscale Operator's documentation and Helm chart for any specific configuration requirements.  Good luck!
