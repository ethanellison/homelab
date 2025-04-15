# Secret manager

In my tailscale kubernetes operator, the missing piece to achieve a fully automated deployment into my homelab k3s cluster is automated secret management.

**My Core Principles for Secure GitOps Secrets Management:**

* **Never commit secrets directly to the Git repository.**  This is the cardinal rule.
* **Separate secrets from configuration:** Treat secrets as data to be injected into my configuration.
* **Automate secret rotation:**  Regularly rotate secrets to minimize the impact of a potential compromise.
* **Least privilege:** Grant only the necessary permissions to access secrets.
* **Auditability:** Track who accessed what secrets and when.

## Options analysis

I asked gemini to provide a quick summary of secret management tools I should explore.

### Options Summary Table

| Feature          | Sealed Secrets         | SOPS                 | HashiCorp Vault        | External Secrets Operator |
|-------------------|------------------------|----------------------|-------------------------|---------------------------|
| Complexity       | Low                    | Medium               | High                    | Medium                     |
| Security         | Good (Cluster-Bound)   | Excellent            | Excellent               | Excellent                 |
| Cross-Environment| Limited                | Good                 | Excellent               | Good                      |
| Cloud Provider   | No direct integration | Supports KMS         | Supports KMS, Secrets   | Integrates with Secrets Managers |
| Git Repository   | Encrypted Secrets      | Encrypted Secrets    | Configuration Only     | Configuration Only      |
| Rotation         | Manual (Re-sealing)    | Backend-Dependent    | Automated              | Dependent on External Manager |
| ArgoCD Integration| Easy                   | Requires Plugin/Hook | Requires Application Changes | Easy                       |

### Recommendations

* **For a simple homelab with a single k3s cluster, Sealed Secrets is a great starting point.** It's easy to set up and provides reasonable security.
* **If you need to manage secrets across multiple environments or want to use cloud provider KMS, SOPS is a good choice.**  Be prepared for the added complexity of setting up encryption and decryption.
* **For a more robust and feature-rich solution, especially in a production environment, HashiCorp Vault is the best option.**  However, it requires a significant investment in time and resources.
* **If you are already using a cloud provider's secret manager and want to keep your secrets centralized there, the External Secrets Operator is a good option.**

The two main options that stood out to me were:

#### Option 1: Sealed Secrets (Recommended for Simplicity and Homelab Focus)

* **How it Works:**
  * Sealed Secrets encrypt Kubernetes secrets using a public/private key pair.
  * The public key is stored in your Git repository.  The private key *never* leaves your Kubernetes cluster.
  * You use the `kubeseal` command-line tool to encrypt secrets locally.  `kubeseal` only needs the public key.
  * The encrypted secret (a `SealedSecret` resource) can be safely committed to your Git repository.
  * The Sealed Secrets controller, running in your cluster, decrypts the `SealedSecret` using the private key and creates a standard Kubernetes `Secret` resource.  Only the controller can decrypt the secret.

* **Pros:**
  * Simple to set up and use, especially for a homelab.
  * No external dependencies (besides the Sealed Secrets controller itself).
  * Secrets are encrypted at rest in your Git repository.
  * Well-integrated with Kubernetes.
  * Easy to automate with ArgoCD.

* **Cons:**
  * Tied to a single Kubernetes cluster.  Moving secrets to another cluster requires re-encryption.
  * Not ideal for sharing secrets across multiple environments (dev, staging, prod).
  * Secret rotation requires re-sealing.
  * Not directly integrated with external cloud provider secret managers.

#### Option 4: External Secrets Operator (ESO)

* **How it Works:**
  * ESO synchronizes secrets from external secret management systems (AWS Secrets Manager, GCP Secret Manager, Azure Key Vault, HashiCorp Vault, etc.) into Kubernetes Secrets.
  * You define a `SecretStore` custom resource that points to your external secret manager.
  * You define an `ExternalSecret` custom resource that specifies which secrets to fetch from the external store and how to map them to a Kubernetes Secret.
* **Pros:**
  * Centralized secrets management in your cloud provider or other system.
  * Avoids storing secrets directly in Git.
  * Leverages the security features of your chosen secret manager (IAM, access policies).
  * Relatively easy to set up and use compared to directly integrating with Vault in every application.
* **Cons:**
  * Introduces a dependency on an external secret management system.
  * Requires configuring authentication to the external system (e.g., IAM roles for AWS Secrets Manager).
  * Might have latency depending on the location of your cluster and the external secret manager.
  * Requires careful management of IAM permissions in the external secret manager.

Due to the cluster-scoped encryption key limitation in Sealed Secrets, a future migration to a new cluster, like the Talos cluster I'm planning, would necessitate re-sealing all existing secrets with a new key.  This lack of portability was a major concern.

Enter External Secrets Operator (ESO). Leveraging my existing Google Cloud project and Secret Manager, I found ESO to be a surprisingly elegant and cost-effective solution. The setup process was surpisingly simple.  Currently, the only manual step is creating a Kubernetes Secret containing the service account credentials, allowing ESO to seamlessly connect to my GCP project.  This approach provides a far more flexible and future-proof method for managing secrets in my homelab.
