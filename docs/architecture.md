# Architecture

## Project Architecture

This project demonstrates a production-style Linux server provisioning and hardening workflow using Infrastructure as Code and Configuration Management.

```text
Developer / DevOps Engineer
          |
          v
      Terraform
          |
          v
   AWS Infrastructure
          |
    +-----+-----+
    |           |
   VPC       Security Group
    |           |
 Subnet      SSH / HTTP
    |
    v
 EC2 Ubuntu Server
    |
    v
    Ansible
    |
    +-----------------------------+
    |                             |
    v                             v
Configuration                 Verification
    |
    +-- Administrative user
    +-- SSH key authentication
    +-- SSH hardening
    +-- UFW firewall
    +-- Nginx
    +-- Fail2Ban
    +-- Automatic security updates
    +-- Hostname / timezone
    +-- Backup
    +-- Server health check
