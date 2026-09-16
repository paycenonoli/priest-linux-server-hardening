# Linux Server Hardening & Configuration

A production-style Linux server setup, security hardening, and operational readiness project based on Ubuntu running on AWS EC2.

The goal is to provision a fresh Linux server, configure it according to common operational and security best practices, verify the configuration, document the implementation, and eventually automate the process using Terraform and Ansible.

The project follows a deliberate approach:

> Understand and implement the Linux configuration manually first, verify it, document it, and then automate it.

---

## 1. Project Goals

This project covers the following Linux server administration and security practices:

- Configure a non-root administrative user
- Grant controlled sudo privileges
- Secure SSH access using SSH keys
- Disable password-based SSH authentication
- Configure UFW host-based firewall
- Understand AWS Security Groups as an external network layer
- Install and configure Nginx
- Deploy a simple sample website
- Configure automatic security updates
- Install and configure Fail2Ban
- Configure hostname and timezone
- Verify NTP time synchronization
- Manage Linux services using systemd
- Inspect system and application logs
- Add lightweight server health monitoring
- Create and test server backups
- Perform final security and configuration verification
- Document implementation and troubleshooting
- Eventually automate infrastructure provisioning with Terraform
- Eventually automate server configuration with Ansible

---

## 2. Architecture

### Current implementation

The server configuration is being implemented manually first.

```text
Developer
    |
    v
 GitHub Repository
    |
    v
AWS EC2
    |
    v
Ubuntu Linux Server
    |
    +-------------------+
    |                   |
   SSH                  UFW
    |                   |
    |              Host Firewall
    |
    +-------------------+
    |
    +-------------------+
    |                   |
  Nginx              Fail2Ban
    |                   |
    |              SSH Protection
    v
Sample Website
```

### Future automation

After the manual implementation and verification are complete:

```text
Developer
    |
    v
 GitHub
    |
    +------------------+
    |                  |
    v                  v
Terraform           Ansible
    |                  |
    v                  v
AWS EC2 --------> Ubuntu Server
                       |
                       v
                Hardened Server
```

Terraform will eventually manage infrastructure, while Ansible will manage operating-system configuration.

---

## 3. Technologies

- AWS EC2
- Ubuntu Linux
- Git / GitHub
- Bash
- SSH
- UFW
- Nginx
- Fail2Ban
- systemd
- systemd-journald
- tar
- unattended-upgrades
- Terraform
- Ansible

---

## 4. Implementation

## 4.1 Baseline Server Inspection

Before making configuration changes, the server was inspected to establish a baseline.

Important commands include:

```bash
whoami
hostnamectl
lsb_release -a
uptime
df -h
free -h
sudo ufw status verbose
```

The baseline inspection establishes:

- Current user
- Hostname
- Operating system
- Kernel
- System uptime
- Disk usage
- Memory usage
- Firewall state

This provides a reference point for later verification.

---

## 4.2 Create a Non-Root Administrative User

A dedicated administrative account was created instead of performing normal administration directly as `root`.

```bash
sudo adduser devopsadmin
sudo usermod -aG sudo devopsadmin
```

Verify group membership:

```bash
groups devopsadmin
```

Test the account:

```bash
su - devopsadmin
whoami
sudo whoami
```

Expected result:

```text
devopsadmin
root
```

The account can perform administrative operations through `sudo` while normal sessions run as a non-root user.

---

## 4.3 Configure SSH Key Authentication

SSH key authentication was configured for the administrative account.

The public key was installed in:

```text
/home/devopsadmin/.ssh/authorized_keys
```

Permissions were configured as:

```bash
sudo chown -R devopsadmin:devopsadmin /home/devopsadmin/.ssh
sudo chmod 700 /home/devopsadmin/.ssh
sudo chmod 600 /home/devopsadmin/.ssh/authorized_keys
```

The private key remains on the administrator's local machine and must never be copied to the server or committed to Git.

Test direct SSH access:

```bash
ssh -i ~/.ssh/id_rsa devopsadmin@<SERVER_PUBLIC_IP>
```

Verify:

```bash
whoami
```

Expected:

```text
devopsadmin
```

---

## 4.4 Harden SSH

The effective SSH configuration was verified with:

```bash
sudo sshd -T | grep -E 'passwordauthentication|pubkeyauthentication'
```

Expected configuration:

```text
pubkeyauthentication yes
passwordauthentication no
```

The effective configuration is more important than inspecting only the main `/etc/ssh/sshd_config` file because Ubuntu can apply settings from configuration snippets under:

```text
/etc/ssh/sshd_config.d/
```

On this server, password authentication is disabled through the cloud-image SSH configuration.

### Important distinction

Disabling SSH password authentication does **not** disable passwords for:

- `sudo`
- `su`
- local Linux account authentication

It specifically controls password authentication for remote SSH login.

---

## 4.5 Configure UFW Firewall

UFW (Uncomplicated Firewall) provides host-level firewall protection inside the Ubuntu server.

The configuration was initially inspected:

```bash
sudo ufw status verbose
```

SSH was allowed before enabling the firewall:

```bash
sudo ufw allow 22/tcp
```

Then UFW was enabled:

```bash
sudo ufw enable
```

The resulting policy uses:

```text
Default: deny incoming
Default: allow outgoing
```

HTTP was subsequently allowed for the Nginx web server:

```bash
sudo ufw allow 80/tcp
```

Verify:

```bash
sudo ufw status verbose
```

Expected relevant rules:

```text
22/tcp    ALLOW IN    Anywhere
80/tcp    ALLOW IN    Anywhere
```

### AWS Security Group vs UFW

Two separate network-control layers are used:

```text
Internet
   |
   v
AWS Security Group
   |
   v
EC2 Instance
   |
   v
UFW
   |
   v
Linux Services
```

The AWS Security Group operates at the AWS/network level before traffic reaches the operating system.

UFW operates inside the Ubuntu host.

Using both provides layered network filtering.

---

## 4.6 Install and Configure Nginx

Nginx was installed as the web server:

```bash
sudo apt install nginx -y
```

Verify the service:

```bash
systemctl status nginx
```

Useful checks:

```bash
systemctl is-active nginx
systemctl is-enabled nginx
```

Expected:

```text
active
enabled
```

`active` means the service is running now.

`enabled` means the service is configured to start automatically during boot.

Nginx configuration can be tested with:

```bash
sudo nginx -t
```

---

## 4.7 Add a Sample Website

The default Nginx document root is:

```text
/var/www/html
```

A custom:

```text
/var/www/html/index.html
```

was created for the project.

Example:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Linux Server Hardening</title>
</head>
<body>
    <h1>Linux Server Hardening Project</h1>

    <p>Nginx is running successfully.</p>

    <h2>Server Status</h2>

    <ul>
        <li>Operating System: Ubuntu Linux</li>
        <li>Web Server: Nginx</li>
        <li>Firewall: UFW</li>
        <li>SSH: Key-based authentication</li>
        <li>Security Updates: Enabled</li>
    </ul>

    <p>Server configuration and security hardening are in progress.</p>
</body>
</html>
```

Test locally:

```bash
curl http://localhost
```

Test externally:

```bash
curl http://<SERVER_PUBLIC_IP>
```

### How Nginx selects the page

When a request is made to:

```text
http://server/
```

Nginx uses its configured document root and index directives.

For example:

```text
root /var/www/html;
```

The request for `/` can therefore resolve to an index file such as:

```text
/var/www/html/index.html
```

The original Ubuntu file:

```text
/var/www/html/index.nginx-debian.html
```

was retained as a fallback/reference file.

---

## 4.8 Enable Automatic Security Updates

The `unattended-upgrades` package was checked:

```bash
dpkg -l unattended-upgrades
```

The automatic update schedule is configured in:

```text
/etc/apt/apt.conf.d/20auto-upgrades
```

Example:

```text
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

The value `1` means the operation is scheduled daily.

### What the two configuration files do

`20auto-upgrades` primarily controls **when** periodic update operations run.

`50unattended-upgrades` controls **which packages/origins** are eligible for unattended installation.

This distinction is important when troubleshooting automatic updates.

### Fallback configuration

If `unattended-upgrades` is not installed:

```bash
sudo apt update
sudo apt install unattended-upgrades -y
```

Ensure the periodic configuration exists:

```bash
sudo nano /etc/apt/apt.conf.d/20auto-upgrades
```

Use:

```text
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

Verify the security origin in:

```text
/etc/apt/apt.conf.d/50unattended-upgrades
```

A minimal Ubuntu security origin is:

```text
Unattended-Upgrade::Allowed-Origins {
        "${distro_id}:${distro_codename}-security";
};
```

---

## 4.9 Install and Configure Fail2Ban

Fail2Ban was installed:

```bash
sudo apt install fail2ban -y
```

Verify the service:

```bash
sudo systemctl status fail2ban
```

Check available jails:

```bash
sudo fail2ban-client status
```

The SSH jail was verified with:

```bash
sudo fail2ban-client status sshd
```

The `sshd` jail monitors SSH authentication failures and can temporarily ban IP addresses that repeatedly fail authentication.

### Configuration principle

Avoid modifying:

```text
/etc/fail2ban/jail.conf
```

Directly.

Local overrides should instead be placed in:

```text
/etc/fail2ban/jail.local
```

or:

```text
/etc/fail2ban/jail.d/*.local
```

The current server's SSH jail is active and functioning with the default Ubuntu/Fail2Ban configuration, so unnecessary customization was avoided.

---

## 4.10 Configure Hostname and Timezone

The hostname was changed to:

```text
linux-hardening
```

Command:

```bash
sudo hostnamectl set-hostname linux-hardening
```

Verify:

```bash
hostname
hostnamectl
```

### Timezone

The server uses UTC:

```bash
timedatectl
```

Fallback configuration:

```bash
sudo timedatectl set-timezone UTC
```

Verify:

```bash
timedatectl
```

### NTP synchronization

Network Time Protocol keeps the server clock synchronized.

Enable NTP:

```bash
sudo timedatectl set-ntp true
```

Verify:

```bash
timedatectl
```

Look for:

```text
System clock synchronized: yes
NTP service: active
Time zone: Etc/UTC
```

Using UTC on servers helps keep timestamps consistent across infrastructure, logs, and geographically distributed systems.

---

## 4.11 Manage Services with systemd

Linux services are managed through systemd.

Important commands:

```bash
systemctl status nginx
systemctl is-active nginx
systemctl is-enabled nginx
```

The same approach applies to Fail2Ban and SSH:

```bash
systemctl is-active nginx fail2ban ssh
```

Expected:

```text
active
active
active
```

And:

```bash
systemctl is-enabled nginx
systemctl is-enabled fail2ban
```

Expected:

```text
enabled
enabled
```

### Active vs enabled

These terms answer different questions:

- `active` → Is the service running right now?
- `enabled` → Will the service start automatically at boot?

A service can therefore be enabled but currently inactive, or active without being enabled for boot.

---

## 4.12 Inspect System and Application Logs

Systemd service logs can be inspected with:

```bash
sudo journalctl -u nginx --no-pager -n 20
```

This shows Nginx service lifecycle events recorded by systemd's journal.

Nginx also maintains application-level logs:

```text
/var/log/nginx/access.log
/var/log/nginx/error.log
```

Inspect recent requests:

```bash
sudo tail -n 10 /var/log/nginx/access.log
```

Inspect recent errors:

```bash
sudo tail -n 10 /var/log/nginx/error.log
```

### Important distinction

```text
journalctl -u nginx
```

primarily shows systemd/service lifecycle information such as:

- service starting
- service stopping
- service restarting
- startup failures

Whereas:

```text
/var/log/nginx/access.log
```

contains HTTP requests handled by Nginx.

For example:

```text
GET / HTTP/1.1
GET /favicon.ico HTTP/1.1
```

The access log is therefore useful for observing actual web traffic.

---

## 4.13 Basic Server Monitoring

Because the project uses a small EC2 instance, lightweight Linux tools are used instead of deploying a large monitoring stack.

Useful commands:

```bash
uptime
free -h
df -h /
```

These provide visibility into:

- CPU/load
- Memory
- Disk usage

### Server health-check script

The project includes:

```text
scripts/verify-server.sh
```

The script checks:

- Hostname
- Uptime
- Memory
- Root filesystem usage
- SSH service
- Nginx service
- Fail2Ban service

Run:

```bash
bash scripts/verify-server.sh
```

On the server, the script can be copied with `scp` and executed locally.

This is intentionally lightweight and appropriate for a small practice/portfolio server.

---

## 4.14 Backup Procedures

Important configuration and application directories were identified:

```text
/etc
/var/www/html
/home/devopsadmin
```

Their sizes were checked before creating the backup:

```bash
sudo du -sh /etc /var/www/html /home/devopsadmin
```

A dedicated backup directory was created outside the directories being archived:

```bash
sudo mkdir -p /var/backups/linux-hardening
```

This avoids placing the archive inside the directory tree being archived.

### Create the backup

```bash
sudo tar -czf /var/backups/linux-hardening/linux-hardening-backup.tar.gz \
    /etc \
    /var/www/html \
    /home/devopsadmin
```

Verify the archive:

```bash
sudo ls -lh /var/backups/linux-hardening/
```

Inspect the archive contents:

```bash
sudo tar -tzf /var/backups/linux-hardening/linux-hardening-backup.tar.gz | head -30
```

Check the web and administrative directories:

```bash
sudo tar -tzf /var/backups/linux-hardening/linux-hardening-backup.tar.gz \
    | grep -E '^(var/www/html|home/devopsadmin)'
```

### Restore test

A backup should not be considered trustworthy simply because the archive was created successfully.

A restore test was performed into a temporary directory:

```bash
sudo mkdir -p /tmp/backup-restore-test

sudo tar -xzf \
    /var/backups/linux-hardening/linux-hardening-backup.tar.gz \
    -C /tmp/backup-restore-test
```

Verify:

```bash
sudo ls /tmp/backup-restore-test/
sudo ls /tmp/backup-restore-test/home/devopsadmin/
```

The health-check script was also inspected from the restored copy.

Cleanup:

```bash
sudo rm -rf /tmp/backup-restore-test/
```

### Production consideration

The current backup is stored on the same EC2 instance.

That protects against accidental deletion or configuration mistakes but does **not** provide disaster recovery if the instance or its storage is lost.

A future production-oriented implementation should store backups in durable external storage such as Amazon S3, ideally with appropriate encryption, access controls, retention, and lifecycle policies.

Also note that backing up an entire home directory can include:

- shell history
- SSH configuration
- cached files
- credentials or other sensitive data

A production backup policy should therefore define exactly what must be backed up and protect the backup accordingly.

---

## 5. Security & Configuration Verification

The final verification phase will validate the complete server configuration.

Planned checks include:

- Verify the administrative user exists
- Verify sudo privileges
- Verify SSH key-based authentication
- Verify password-based SSH authentication is disabled
- Verify UFW is active
- Verify only required ports are exposed
- Verify Nginx is running
- Verify Fail2Ban is running
- Verify automatic security updates are enabled
- Verify hostname and timezone configuration
- Verify NTP synchronization
- Verify critical services are enabled
- Verify system and application logs
- Verify backup creation and restoration
- Run the server health-check script

The goal is to confirm that the server is not only configured, but also operationally ready and verifiably secure according to the project's defined requirements.

---

## 6. Documentation & Evidence

The project will maintain documentation showing how the server was configured and how each requirement was verified.

Evidence may include:

- Command output
- Configuration files
- Service status
- Firewall status
- SSH configuration verification
- Fail2Ban status
- NTP synchronization
- Backup verification
- Health-check output
- Troubleshooting notes

Evidence will be stored under:

```text
evidence/
├── screenshots/
└── command-output/
```

The objective is not simply to say that a configuration exists, but to demonstrate how it was implemented and verified.

---

## 7. Terraform Infrastructure Automation

Terraform will be introduced after the manual server configuration is complete.

The Terraform portion will focus on infrastructure provisioning, including:

- AWS provider configuration
- EC2 instance
- Security Group
- Networking requirements
- SSH key configuration
- Variables
- Outputs
- Reusable infrastructure structure

Terraform's responsibility will be infrastructure.

It will not replace Ansible for detailed operating-system configuration.

---

## 8. Ansible Configuration Automation

Ansible will eventually automate the Linux configuration performed manually in this project.

Potential tasks include:

- Create administrative user
- Configure sudo
- Install required packages
- Configure SSH
- Configure UFW
- Install Nginx
- Install Fail2Ban
- Configure automatic updates
- Configure hostname and timezone
- Manage services
- Deploy configuration files
- Run verification tasks

The intended separation is:

```text
Terraform
    |
    | Infrastructure
    v
AWS EC2

Ansible
    |
    | Configuration
    v
Ubuntu Server
```

---

## 9. Final Production-Style Project

The final version of the project will combine:

```text
Terraform
    |
    v
AWS Infrastructure
    |
    v
EC2 Ubuntu Server
    |
    v
Ansible Configuration
    |
    +-------------------------+
    |                         |
    v                         v
Security Hardening       Application Setup
    |                         |
    +------------+------------+
                 |
                 v
        Verification
                 |
                 v
       Operationally Ready
             Server
```

The final objective is a reproducible Linux server build where infrastructure and operating-system configuration can be recreated through code.

---

## 10. Project Structure

Current repository structure:

```text
priest-linux-server-hardening/
├── README.md
├── .gitignore
├── docs/
│   ├── architecture.md
│   ├── interview-notes.md
│   ├── security.md
│   └── troubleshooting.md
├── scripts/
│   └── verify-server.sh
└── evidence/
    ├── screenshots/
    └── command-output/
```

As automation is added, the repository can be expanded with Terraform and Ansible directories.

For example:

```text
priest-linux-server-hardening/
├── README.md
├── docs/
├── evidence/
├── scripts/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── providers.tf
└── ansible/
    ├── inventory/
    ├── playbooks/
    ├── roles/
    └── group_vars/
```

---

## 11. Project Status

🚧 **In Progress**

### Completed

- [x] AWS EC2 Ubuntu server created
- [x] Baseline server inspection
- [x] Non-root administrative user
- [x] Sudo privileges
- [x] SSH key authentication
- [x] SSH password authentication disabled
- [x] UFW firewall
- [x] Nginx installation
- [x] Sample website
- [x] Automatic security update configuration verified
- [x] Fail2Ban installation and SSH jail verification
- [x] Hostname configuration
- [x] UTC timezone
- [x] NTP synchronization
- [x] systemd service verification
- [x] System and Nginx log inspection
- [x] Lightweight server health-check script
- [x] Backup creation
- [x] Backup contents verification
- [x] Backup restore test

### In progress

- [ ] Complete security and configuration verification
- [ ] Collect final evidence
- [ ] Expand documentation

### Future

- [ ] Terraform infrastructure automation
- [ ] Ansible configuration automation
- [ ] End-to-end reproducible server deployment
- [ ] Final production-style project documentation

---

## 12. Production Considerations

This project is designed as a production-style learning and portfolio project.

A real production environment would require additional considerations depending on the workload, including:

- Centralized logging
- Centralized monitoring and alerting
- Secrets management
- Backup retention
- Off-instance backups
- Encryption
- IAM least privilege
- Network segmentation
- Patch management
- Vulnerability management
- Configuration management
- Disaster recovery
- Incident response
- Infrastructure-as-code
- Change management
- Auditability

The project deliberately starts with the fundamentals before introducing more complex tooling.

---

## 13. Project Philosophy

The purpose of this project is not to memorize commands.

Each configuration is approached in the following sequence:

```text
Understand
    |
    v
Inspect
    |
    v
Configure
    |
    v
Verify
    |
    v
Document
    |
    v
Automate
```

This makes the eventual Terraform and Ansible automation easier to understand because the underlying Linux configuration has already been implemented and verified manually.

---

## 14. Documentation

Additional project documentation:

- [Architecture](docs/architecture.md)
- [Security](docs/security.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Interview Notes](docs/interview-notes.md)
