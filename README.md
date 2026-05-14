connect_redis

connect_redis is a small terminal helper for connecting to Redis instances from a local config file. It reads a list of Redis endpoints, ignores blank lines and comments, prints a Redis-style logo/banner, and helps you connect quickly without retyping host, port, or instance details every time.

⸻

🚀 What it does

* Reads Redis connection entries from a config file
* Skips blank lines and comment lines
* Displays a Redis logo/banner in the terminal
* Connects to a selected Redis instance
* Simplifies switching between environments (local, staging, production)

⸻

📦 Requirements

* Bash
* redis-cli
* figlet (for the banner)

⸻

⚙️ Setup

Make the script executable:

chmod +x connect_redis.sh

Install dependencies:

macOS

brew install redis figlet

Debian / Ubuntu

sudo apt-get install redis-tools figlet

⸻

🧾 Configuration

Create a config file with one Redis instance per line.

Example:

# Redis instances
redis://localhost:6379
redis://cache-prod.example.com:6379
redis://cache-staging.example.com:6379

Notes

* Lines starting with # are ignored
* Blank lines are ignored
* Each line should represent a valid Redis connection string

⸻

▶️ Usage

Run the script:

./connect_redis.sh

Or with a custom config file:

./connect_redis.sh /path/to/config.conf

⸻

🔄 Behavior

When executed, the script:

1. Reads the config file
2. Filters out empty lines and comments
3. Displays a Redis banner in the terminal
4. Allows you to connect to a Redis instance

⸻

💡 Example

./connect_redis.sh

Select your desired Redis instance from the list and connect.

⸻

🛠 Troubleshooting

figlet: command not found

Install figlet:

brew install figlet
# or
sudo apt-get install figlet

redis-cli: command not found

Install Redis CLI tools:

brew install redis
# or
sudo apt-get install redis-tools

Script not running correctly

Ensure you’re using Bash:

#!/usr/bin/env bash

Run with:

bash ./connect_redis.sh

Config file not being read

Check:

* File path is correct
* No malformed entries
* Comments use #
* No hidden characters or extra spaces

⸻

📌 Notes

This tool is designed to streamline connecting to multiple Redis instances from the terminal, especially when working across different environments.

⸻

📄 License

Add your license here.# connect_redis
