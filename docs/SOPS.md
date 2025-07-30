# SOPS Secrets Management Guide

This document explains how to use SOPS (Secrets OPerationS) for managing encrypted secrets in your NixOS configuration.

## What is SOPS?

SOPS (Secrets OPerationS) is a tool for managing secrets in configuration files. It encrypts values in YAML, JSON, ENV, INI files while leaving the keys unencrypted, making it easy to see what secrets are being managed while keeping their values secure.

## Setup

### 1. Generate Age Key

Age is the recommended encryption method for SOPS with NixOS:

```bash
# Create the directory
mkdir -p ~/.config/sops/age

# Generate a new age key
age-keygen -o ~/.config/sops/age/keys.txt

# View your public key
age-keygen -y ~/.config/sops/age/keys.txt
```

### 2. Update Configuration

Update `secrets/.sops.yaml` with your public age key:

```yaml
keys:
  - &user_age age1your_actual_public_key_here

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - *user_age
```

### 3. Configure NixOS

The SOPS configuration in `modules/system/security.nix` should be updated with your key path:

```nix
sops = {
  defaultSopsFile = ../../secrets/secrets.yaml;
  defaultSopsFormat = "yaml";
  age.keyFile = "/home/yourusername/.config/sops/age/keys.txt";
};
```

## Creating and Managing Secrets

### Creating a New Secrets File

```bash
# Create a new encrypted file
sops secrets/secrets.yaml
```

This will open your default editor with an encrypted file. Add secrets in YAML format:

```yaml
# User password hash (generate with: mkpasswd -m sha-512)
user-password: "your_password_hash_here"

# Database passwords
database:
  postgres-password: "secure_postgres_password"
  redis-password: "secure_redis_password"

# API keys
api-keys:
  github-token: "ghp_your_github_token"
  openai-key: "sk-your_openai_key"

# WiFi credentials
wifi:
  home-password: "your_wifi_password"
  work-password: "work_wifi_password"
```

### Editing Existing Secrets

```bash
# Edit the secrets file
sops secrets/secrets.yaml

# Edit with a specific editor
EDITOR=nvim sops secrets/secrets.yaml
```

### Viewing Secrets

```bash
# View decrypted content (without editing)
sops -d secrets/secrets.yaml

# View specific key
sops -d --extract '["api-keys"]["github-token"]' secrets/secrets.yaml
```

## Using Secrets in NixOS Configuration

### 1. Define Secrets

In your NixOS configuration, define which secrets you want to use:

```nix
sops.secrets = {
  "user-password" = {
    neededForUsers = true;
  };
  "database/postgres-password" = {
    owner = "postgres";
    group = "postgres";
    mode = "0440";
  };
  "api-keys/github-token" = {
    owner = "user";
    group = "users";
    mode = "0400";
  };
  "wifi/home-password" = {};
};
```

### 2. Use Secrets in Configuration

Reference secrets using the generated paths:

```nix
# User password
users.users.user = {
  hashedPasswordFile = config.sops.secrets."user-password".path;
};

# Database password
services.postgresql = {
  enable = true;
  authentication = ''
    local all all ident map=mapping
  '';
  identMap = ''
    mapping root postgres
    mapping user user
  '';
  initialScript = pkgs.writeText "postgres-init" ''
    CREATE ROLE user WITH LOGIN PASSWORD '$(cat ${config.sops.secrets."database/postgres-password".path})';
  '';
};

# Environment variable from secret
systemd.services.myapp = {
  environment = {
    GITHUB_TOKEN_FILE = config.sops.secrets."api-keys/github-token".path;
  };
};
```

### 3. Accessing Secrets in Scripts

```bash
#!/usr/bin/env bash
# Read secret from file
GITHUB_TOKEN=$(cat /run/secrets/api-keys/github-token)

# Use in API call
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

## Common Use Cases

### User Password

Generate a password hash and store it securely:

```bash
# Generate password hash
mkpasswd -m sha-512

# Add to secrets.yaml
sops secrets/secrets.yaml
# Add: user-password: "$6$your_hash_here"
```

Use in configuration:
```nix
sops.secrets."user-password".neededForUsers = true;

users.users.user = {
  hashedPasswordFile = config.sops.secrets."user-password".path;
};
```

### SSH Keys

Store SSH private keys securely:

```yaml
ssh-keys:
  github-deploy-key: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    your_private_key_here
    -----END OPENSSH PRIVATE KEY-----
```

Use in configuration:
```nix
sops.secrets."ssh-keys/github-deploy-key" = {
  owner = "user";
  mode = "0600";
};

environment.etc."ssh/github_deploy_key" = {
  source = config.sops.secrets."ssh-keys/github-deploy-key".path;
  mode = "0600";
  user = "user";
};
```

### Database Credentials

Store database passwords:

```yaml
databases:
  production:
    host: "db.example.com"
    username: "myapp"
    password: "secure_password_here"
```

Use in application:
```nix
systemd.services.myapp = {
  environment = {
    DB_PASSWORD_FILE = config.sops.secrets."databases/production/password".path;
  };
};
```

### API Keys and Tokens

Store various API credentials:

```yaml
api-credentials:
  aws:
    access-key: "AKIA..."
    secret-key: "secret..."
  stripe:
    public-key: "pk_live_..."
    secret-key: "sk_live_..."
```

## Security Best Practices

### 1. Key Management

- **Never commit private keys** to version control
- **Backup your age private key** securely
- **Use different keys** for different environments (dev/staging/prod)
- **Rotate keys periodically**

### 2. File Permissions

Configure appropriate file permissions for secrets:

```nix
sops.secrets."my-secret" = {
  owner = "myapp";
  group = "myapp";
  mode = "0440";  # Read-only for owner and group
};
```

### 3. Principle of Least Privilege

Only give services access to secrets they actually need:

```nix
# Good: Specific secret for specific service
systemd.services.web-app = {
  environment.SECRET_FILE = config.sops.secrets."web-app/secret".path;
};

# Bad: Giving access to all secrets
systemd.services.web-app = {
  environment.SECRETS_DIR = "/run/secrets";
};
```

### 4. Environment Separation

Use different secrets files for different environments:

```
secrets/
├── .sops.yaml
├── development.yaml
├── staging.yaml
└── production.yaml
```

Configure different keys in `.sops.yaml`:
```yaml
creation_rules:
  - path_regex: secrets/development\.yaml$
    key_groups:
      - age: [dev_key]
  - path_regex: secrets/production\.yaml$
    key_groups:
      - age: [prod_key]
```

## Troubleshooting

### Common Issues

#### 1. "no key could be found"

```bash
# Check if age key exists
ls -la ~/.config/sops/age/keys.txt

# Verify key path in configuration
grep -r "age.keyFile" /etc/nixos/
```

#### 2. "failed to decrypt"

```bash
# Check if your public key is in .sops.yaml
cat secrets/.sops.yaml

# Verify the file is properly encrypted
sops -d secrets/secrets.yaml
```

#### 3. "permission denied"

```bash
# Check file permissions
ls -la /run/secrets/

# Verify service user matches secret owner
systemctl status your-service
```

### Debugging

Enable SOPS debugging:

```bash
export SOPS_DEBUG=1
sops secrets/secrets.yaml
```

Check NixOS secrets directory:

```bash
# List all managed secrets
ls -la /run/secrets/

# Check specific secret
cat /run/secrets/your-secret-name
```

Verify SOPS service status:

```bash
systemctl status sops-nix
journalctl -u sops-nix
```

## Advanced Usage

### Multiple Key Types

You can use both age and GPG keys:

```yaml
keys:
  - &age_key age1your_age_key
  - &gpg_key 1234567890ABCDEF

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age: [*age_key]
        pgp: [*gpg_key]
```

### Key Rotation

To rotate encryption keys:

1. Generate new key
2. Update `.sops.yaml` with new key
3. Re-encrypt existing files:
   ```bash
   sops updatekeys secrets/secrets.yaml
   ```

### Templating

Use SOPS with templating for complex configurations:

```yaml
# In secrets.yaml
app-config:
  database-url: "postgresql://user:password@localhost/myapp"
  redis-url: "redis://localhost:6379"
```

```nix
# Generate config file from template
environment.etc."myapp/config.yaml".source = pkgs.substituteAll {
  src = ./config.template.yaml;
  database_url = config.sops.secrets."app-config/database-url".path;
  redis_url = config.sops.secrets."app-config/redis-url".path;
};
```

## Integration with Home Manager

You can also use SOPS with Home Manager:

```nix
# In home.nix
sops = {
  age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  defaultSopsFile = ./secrets/home-secrets.yaml;
  
  secrets = {
    "git/github-token" = {};
    "ssh/private-key" = {};
  };
};

programs.git = {
  extraConfig = {
    github.token = config.sops.secrets."git/github-token".path;
  };
};
```

This guide covers the essential aspects of using SOPS with your NixOS configuration. For more advanced use cases, refer to the [official SOPS documentation](https://github.com/mozilla/sops).