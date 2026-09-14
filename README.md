# Linux Server Hardening & Configuration

A production-style Linux server setup and security hardening project based on Ubuntu.

The goal is to provision a fresh Linux server, configure it according to common operational and security best practices, verify the configuration, and eventually automate the process using Terraform and Ansible.

## Project Goals

- Configure a non-root administrative user
- Secure SSH access using SSH keys
- Disable password-based SSH authentication
- Configure UFW firewall
- Configure automatic security updates
- Install and configure Fail2Ban
- Configure hostname and timezone
- Manage Linux services using systemd
- Inspect system and service logs
- Perform a final security verification
- Document the configuration and troubleshooting process
- Automate infrastructure provisioning with Terraform
- Automate server configuration with Ansible

## Architecture

```text
Developer
    |
    v
 GitHub
    |
    +----------------+
    |                |
    v                v
Terraform         Ansible
    |                |
    v                v
AWS EC2 -------> Ubuntu Server
                    |
          +---------+---------+
          |         |         |
         SSH       UFW     Fail2Ban
          |         |         |
          +---------+---------+
                    |
                    v
             Hardened Server


Technologies
AWS EC2
Ubuntu Linux
Git / GitHub
Bash
SSH
UFW
Fail2Ban
systemd
journald
Terraform
Ansible
Project Status

🚧 In Progress

Documentation
Architecture
Security
Troubleshooting
Interview Notes
