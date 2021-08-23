# Smart Industry Platform Stack

This stack can be used for a standalone installation of the Smart Industry Platform.

## Requirements

* [Ubuntu 20.04](https://ubuntu.com/)
* [Docker](https://docs.docker.com/engine/install/ubuntu/)
* [Docker Compose](https://docs.docker.com/compose/install/)

## Install

_**Important:** [create a personal access token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) with a short expiry date (scopes: `repo` and `read:packages`) before proceding with the following steps. You can use this token as your password. Don't save the token on the system when you're installing a server or VM for a client ._

1. Clone this repository and login with your GitHub username and token.

   ```
   git clone https://github.com/vanegmondgroep/sip-stack.git
   ```

1. Login to the GitHub container registry with your GitHub username and token.
   
   ```bash
   docker login ghcr.io
   ```

1. Create a `.env` file in the root of the project with the contents of [.env.example](https://github.com/vanegmondgroep/smart-industry-platform/blob/main/.env.example) from the Smart Industry Platform repository.

1. Start the containers.
   ```bash
   ./sip up -d
   ```

1. Migrate the database.
   ```bash
   ./sip artisan migrate
   ```

1. Generate application key.
   ```bash
   ./sip artisan key:generate
   ```

1. Navigate to `http://<ip-address>/register` and register a new user.

### Client Install

Follow these additonal steps if you're installing a server or VM for a client:

1. Create a new GitHub repository with the following name: `sip-<client>-<project>` (example: `sip-septo-cotac`).
1. Navigate to the root of the stack folder.
1. Update the remote configuration and push changes to GitHub (login with your username and personal access token).

   ```bash
   git remote rm origin
   git remote add origin https://github.com/vanegmondgroep/sip-<client>-<project)>.git
   git push origin main
   ```

## Commands

```bash
# Start containers
./sip up -d

# Stop containers
./sip down

# Shell access
./sip bash

# SIP CLI
./sip cli

# PHP
./sip php --help

# Reload runtime
./sip runtime reload

# Backup
./sip backup
```
