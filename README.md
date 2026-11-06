# thost96/infra

This repository documents and automates my personal infrastructure, including on-premise and cloud resources. It serves both as a reference for my environment and as an example of how to manage infrastructure using modern DevOps tooling.

This Infra project represents a complete, reproducible configuration of my homelab and cloud infrastructure. It covers everything from bare-metal virtualization and container orchestration to automation, monitoring, backup and documentation.

I run everything in the open because open source matters.

## High Level Overview

image coming soon ...

## Technologies

- **Proxmox VE** - Virtualization Platform
- **Ansible** - Automation and Configuration Management
- **Packer** - VM Templates
- **Terraform** - Infrastructure Provisioning
- **Docker Compose** - Container orchestration and service hosting
- **Tailscale** - Mesh VPN and Remote Access

## Structure

```sh
├── .git_hooks/                     # Git Hooks

├── .github/                        # Github
    └── linters/                    # Linter Configs
    └── workflows/                  # Workflows

├── ansible/
    └── group_vars/                 # Variables
    └── host_vars/                  # Variables
    └── playbooks/                  # Playbook Files
    └── roles/                      # Ansible roles
    └── tasks/                      # Single Tasks
    └── templates/                  # Template Files
    └── run.yaml                    # Main playbook

├── docs/                           # markdown documentation

├── packer/                         # VM Templates
    └── ubuntu2404                  # Ubuntu 24.04 LTS
    └── ubuntu2504                  # Ubuntu 25.04
    └── ubuntu2604                  # Ubuntu 26.04 LTS
    └── vyos                        # VyOS Routing

├── services/                       # Docker Compose
    └── <hostname>/
        └── <prefix_service>/
            └── compose.yaml
            └── app files

├── terraform/                      # Terraform Provisioning
    └── k8s/                        # K8S Cluster

```