# Development Environment Setup

This document provides detailed instructions for setting up the development environment included in this NixOS configuration.

## Included Development Tools

### Programming Languages

- **Python 3.11+** with pip, virtualenv, poetry, pipenv
- **Node.js 20** with npm, yarn, pnpm
- **Rust** with cargo, rustfmt, rust-analyzer
- **Go** with gopls
- **Java 17** with Maven and Gradle
- **.NET 8** SDK
- **C/C++** with GCC, Clang, and LLVM

### Editors and IDEs

- **Neovim** with LazyVim configuration (primary)
- **Visual Studio Code** with extensions support

### Development Databases

- **PostgreSQL** (local development)
- **Redis** (local development)
- **SQLite** (embedded)

### Container Technologies

- **Docker** with rootless support
- **Podman** as Docker alternative
- **Docker Compose** / **Podman Compose**

### Cloud and DevOps

- **kubectl** for Kubernetes
- **Terraform** for infrastructure as code
- **Ansible** for configuration management
- **AWS CLI**, **Azure CLI**, **Google Cloud SDK**

### Version Control

- **Git** with enhanced configuration
- **LazyGit** for terminal UI
- **GitHub CLI** (gh)

## Neovim Configuration

The Neovim setup is based on LazyVim and includes:

### Core Features

- **LSP Support** for all included languages
- **Syntax Highlighting** with Treesitter
- **Auto-completion** with nvim-cmp
- **File Explorer** with Neo-tree
- **Fuzzy Finding** with Telescope
- **Git Integration** with Gitsigns
- **Status Line** with Lualine
- **Code Formatting** with conform.nvim

### Key Mappings

| Key | Mode | Action |
|-----|------|--------|
| `<Space>` | n | Leader key |
| `<leader>e` | n | Toggle file explorer |
| `<leader>ff` | n | Find files |
| `<leader>fg` | n | Live grep |
| `<leader>fb` | n | Find buffers |
| `gd` | n | Go to definition |
| `gr` | n | Find references |
| `<leader>ca` | n | Code actions |
| `<leader>cr` | n | Rename symbol |

### Language Servers

The following language servers are automatically configured:

- **Nix**: nil_ls
- **Lua**: lua-ls
- **Python**: pyright
- **Rust**: rust-analyzer
- **Go**: gopls
- **TypeScript/JavaScript**: tsserver
- **HTML/CSS**: html, cssls
- **JSON**: jsonls
- **YAML**: yamlls
- **Dockerfile**: dockerls
- **Bash**: bashls

## Terminal Setup

### Alacritty Configuration

The terminal is configured with:

- **Font**: JetBrains Mono
- **Theme**: Catppuccin Mocha
- **Opacity**: 95%
- **Key bindings** for copy/paste and font sizing

### Tmux Configuration

- **Vi-mode** key bindings
- **Mouse support** enabled
- **Custom status bar**
- **Vim-like pane navigation**

### Shell Enhancement

- **Zsh** with Oh My Zsh
- **Starship** prompt
- **Auto-suggestions** and **syntax highlighting**
- **Modern alternatives**: eza (ls), bat (cat), ripgrep (grep), fd (find)

## Database Development

### PostgreSQL Setup

```bash
# Start PostgreSQL service
sudo systemctl start postgresql

# Create a database
sudo -u postgres createdb myapp

# Connect to database
sudo -u postgres psql myapp
```

### Redis Setup

```bash
# Start Redis service
sudo systemctl start redis

# Connect to Redis
redis-cli
```

## Container Development

### Docker Usage

```bash
# Run a container
docker run -it ubuntu:latest

# Build an image
docker build -t myapp .

# Use docker-compose
docker-compose up -d
```

### Podman Usage

```bash
# Podman works similarly to Docker
podman run -it ubuntu:latest

# Use podman-compose
podman-compose up -d
```

## Language-Specific Setup

### Python Development

```bash
# Create virtual environment
python -m venv myenv
source myenv/bin/activate

# Use poetry for dependency management
poetry init
poetry add requests
```

### Node.js Development

```bash
# Initialize a new project
npm init -y

# Install dependencies
npm install express

# Use yarn alternative
yarn init -y
yarn add express
```

### Rust Development

```bash
# Create new project
cargo new myproject
cd myproject

# Build and run
cargo run

# Add dependencies in Cargo.toml
```

### Go Development

```bash
# Initialize module
go mod init mymodule

# Get dependencies
go get github.com/gin-gonic/gin

# Run
go run main.go
```

## Cloud Development

### Kubernetes

```bash
# Check cluster info
kubectl cluster-info

# Get pods
kubectl get pods

# Use k9s for terminal UI
k9s
```

### AWS Development

```bash
# Configure AWS CLI
aws configure

# List S3 buckets
aws s3 ls
```

## Development Workflow

### 1. Project Setup

```bash
# Create project directory
mkdir ~/Projects/myproject
cd ~/Projects/myproject

# Initialize git repository
git init

# Create development environment
echo "use flake" > .envrc
direnv allow
```

### 2. IDE Setup

```bash
# Open with Neovim
nvim .

# Or use VS Code
code .
```

### 3. Database Setup

For applications requiring databases:

```bash
# Start required services
sudo systemctl start postgresql redis

# Create application database
sudo -u postgres createdb myapp_dev
```

### 4. Container Development

```bash
# Create Dockerfile
cat > Dockerfile << EOF
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

# Build and run
docker build -t myapp .
docker run -p 3000:3000 myapp
```

## Tips and Tricks

### Performance

- Use `hyperfine` for benchmarking
- Use `btop` for system monitoring
- Use `bandwhich` for network monitoring

### Debugging

- Use `gdb` for C/C++ debugging
- Use the integrated debuggers in language servers
- Use `strace` for system call tracing

### Code Quality

- Use formatters: `black` (Python), `prettier` (JS/TS), `rustfmt` (Rust)
- Use linters: configured in language servers
- Use `git hooks` for pre-commit checks

### Productivity

- Use `tmux` for session management
- Use `lazygit` for Git operations
- Use `fzf` for fuzzy searching
- Use `direnv` for project-specific environments

## Troubleshooting

### Language Server Issues

If a language server isn't working:

1. Check if it's installed: `:checkhealth` in Neovim
2. Restart the LSP: `:LspRestart`
3. Check logs: `:LspLog`

### Database Connection Issues

```bash
# Check if service is running
sudo systemctl status postgresql

# Check logs
sudo journalctl -u postgresql

# Restart service
sudo systemctl restart postgresql
```

### Container Issues

```bash
# Check Docker daemon
sudo systemctl status docker

# Check container logs
docker logs container_name

# Clean up
docker system prune
```