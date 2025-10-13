# GitOps Kubernetes Homelab Portfolio

This repository showcases a Gitops-driven Kubernetes homelab environment. It demonstrates infrastructure-as-code, automation, and maintainability for personal projects.

## Structure

- `clusters`: Contains cluster-specific configurations.
- `infrastructure`: Defines core infrastructure components.
- `applications`: Contains application-specific configurations.
- `scripts`: Includes automation scripts.
- `docs`: Contains detailed documentation.

## Usage

Refer to the `docs` directory for detailed setup and usage instructions.

### Pi-hole DNS Configuration

To configure your client devices to use Pi-hole for DNS, follow these steps:

1.  **Obtain Pi-hole Server IP Address:** The Pi-hole container will be running on your Docker host. You need to find the IP address of the machine running Docker.
    *   **Linux/macOS:** Open a terminal and run `ip addr show docker0` (if using the default bridge network) or `ip addr show <your_docker_network_interface>` to find the IP address of your Docker bridge network. Alternatively, you can use `docker inspect pihole | grep "IPv4Address"` to get the container\'s IP directly, but using the host\'s IP for client configuration is generally more stable.
    *   **Windows (WSL2):** If running Docker Desktop with WSL2, the Docker host IP will be the WSL2 VM\'s IP. You can find this by running `ip addr show eth0` inside the WSL2 terminal.

2.  **Configure Client Devices:**
    *   **Router:** (Recommended) Log in to your router\'s administration interface and change the primary DNS server to the IP address obtained in step 1. This will apply Pi-hole DNS to all devices on your network.
    *   **Individual Device (e.g., Computer, Phone):**
        *   **Windows:** Go to Network and Internet settings -> Change adapter options -> Right-click your active network adapter -> Properties -> Select "Internet Protocol Version 4 (TCP/IPv4)" -> Properties -> Select "Use the following DNS server addresses" and enter the Pi-hole IP as the Preferred DNS server.
        *   **macOS:** Go to System Preferences -> Network -> Select your active network connection -> Advanced -> DNS tab -> Click \'+\' to add the Pi-hole IP.
        *   **Linux:** Edit `/etc/resolv.conf` or your network manager settings to include the Pi-hole IP.
        *   **Mobile Devices:** Adjust Wi-Fi network settings to use a custom DNS server.

### (Optional) Accessing Pi-hole Web Interface via Reverse Proxy

If you have a Traefik (or similar) reverse proxy set up as assumed in `docker-compose.yml`, you can access the Pi-hole web interface via a custom domain.

1.  **Ensure Traefik Network:** Make sure your `docker-compose.yml` includes the `traefik_proxy` network and it\'s defined as `external: true`, pointing to your existing Traefik network.
2.  **Update Domain:** In the `pihole` service definition within `docker-compose.yml`, change `pihole.your_domain.com` in the `traefik.http.routers.pihole.rule` label to your desired domain (e.g., `pihole.homelab.local`).
3.  **DNS Entry:** Create a DNS A record in your DNS server (or `/etc/hosts` file for local testing) pointing `pihole.your_domain.com` to the IP address of your Traefik reverse proxy.
4.  **Access:** Open your web browser and navigate to `https://pihole.your_domain.com`. You will be prompted for the password you set in the `WEBPASSWORD` environment variable.

## Devcontainer Configurations

This repository provides two devcontainer configurations tailored for different development needs:

### 1. Kubernetes Devcontainer

This configuration is ideal for working with Kubernetes-specific tasks. It includes:

- **Base Image:** Ubuntu 22.04
- **Features:** Neovim, Kubectl, Helm, Minikube, Argo CD, K3d, K9s
- **Extensions:** Prettier, Markdownlint, Remote-Containers, GitHub Pull Request, Kubernetes Tools, YAML

**When to use:** Choose this option if you are primarily developing, deploying, or managing Kubernetes resources within the homelab.

**How to select in VS Code:**
1. Open the command palette (Ctrl+Shift+P or Cmd+Shift+P).
2. Type and select "Dev Containers: Open Folder in Container..."
3. Choose the `.devcontainer/kubernetes` option.

### 2. Docker Compose Devcontainer

This configuration is suitable for general Docker-based development, especially when working with `docker-compose.yml` files directly. It includes:

- **Base Image:** Ubuntu 22.04
- **Features:** Neovim, Docker-in-Docker\n- **Extensions:** Prettier, Markdownlint, Remote-Containers, GitHub Pull Request, Docker\n
**When to use:** Select this if your focus is on Docker Compose-based services, local development requiring Docker, or if you don\'t need the full suite of Kubernetes tools.

**How to select in VS Code:**
1. Open the command palette (Ctrl+Shift+P or Cmd+Shift+P).
2. Type and select "Dev Containers: Open Folder in Container..."
3. Choose the `.devcontainer/docker-compose` option.
