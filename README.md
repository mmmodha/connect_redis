# connect_redis

`connect_redis` is a small terminal helper for connecting to Redis instances from a local config file. It reads a list of Redis endpoints and helps you connect quickly without retyping host, port, or instance details every time.

---

## 🚀 What it does

* Reads Redis connection entries from a config file
* Skips blank lines and comment lines
* Displays a Redis logo/banner in the terminal
* Connects to a selected Redis instance
* Simplifies switching between environments (local, staging, production)

---

## 📦 Requirements

* Bash
* `redis-cli`
* `figlet` (for the banner)

---

## ⚙️ Setup

Make the script executable:

```bash
chmod +x connect_redis.sh
```

Install dependencies:

### macOS

```bash
brew install figlet
```

---

## 🧾 Configuration

The script reads Redis instances from a **hard-coded config file**:

```bash
CONFIG_FILE="redis_hosts.conf"
```

If you rename or move this file, you must update this variable in `connect_redis.sh`.

---

### 📄 Config File Format

Each line in the config file should follow this format:

```txt
# name host port password db
```

Example:

```txt
# name host port password db
local localhost 6379 mypassword 0
staging cache-staging.example.com 6379 stagingpass 1
prod cache-prod.example.com 6379 prodpass 0
```

---

### 📝 Rules

* Lines starting with `#` are treated as comments and ignored
* Blank lines are ignored
* Fields are space-separated
* Order matters: `name host port password db`

---

### ⚠️ Important

If the script cannot find or read `redis_hosts.conf`, it will not load any instances.

If you change the filename or location, update the script:

```bash
CONFIG_FILE="/new/path/to/redis_hosts.conf"
```

---


## ▶️ Usage

Run the script:

```bash
./connect_redis.sh
```

---

## 🔄 Behavior

When executed, the script:

1. Reads the config file
2. Allows you to connect to a Redis instance

---

## 💡 Example

```bash
./connect_redis.sh
```

Select your desired Redis instance from the list and connect.

---

## 🛠 Troubleshooting

### `figlet: command not found`

Install `figlet`:

```bash
brew install figlet
# or
sudo apt-get install figlet
```

### `redis-cli: command not found`

Install Redis CLI tools:

```bash
brew install redis
# or
sudo apt-get install redis-tools
```

### Script not running correctly

Ensure you're using Bash:

```bash
#!/usr/bin/env bash
```

Run with:

```bash
bash ./connect_redis.sh
```

### Config file not being read

Check:

* File path is correct
* No malformed entries
* Comments use `#`
* No hidden characters or extra spaces

---

## 📌 Notes

This tool is designed to streamline connecting to multiple Redis instances from the terminal, especially when working across different environments.

---

