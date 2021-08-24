# Smart Industry Platform Stack

This stack can be used for a standalone installation of the Smart Industry Platform.

## Requirements

* [Ubuntu 20.04](https://ubuntu.com/)
* [Docker](https://docs.docker.com/engine/install/ubuntu/)
* [Docker Compose](https://docs.docker.com/compose/install/)

To install or update the stack you need to have access to this repository from the server or VM. The authentication method you use depends on wether you're installing a server for a client or for yourself / development:

* Generate a new SSH key pair (don't overwrite existing keys, press enter on every step):
   ```bash
   # Personal installation
   ssh-keygen -t ed25519 -C "<your-email>"

   # Client installation
   ssh-keygen -t ed25519 -C "sip-<client>-<project>"
   ```
* Copy the contents of the public key to your clipboard:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
* Add the SSH public key to GitHub:
   * **Personal installation:** [add the public SSH key to your GitHub account.](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) _Note: the server can access all the repository you have access to._

   * **Client installation:** [add the public SSH key as deployment key to a repository.](https://docs.github.com/en/developers/overview/managing-deploy-keys#deploy-keys) _Note: the server can only access a single repository._
   
To pull our private Docker containers you need to have access to the GitHub container registry from the server or VM. Authentication is done through a personal access token with a short expiration date and minimal scope:

* [Create a personal access token](https://github.com/settings/tokens) with scope `read:packages` and set the expiration to `7 days`. You can extend the expiry date when you're installing a server for personal use.
* Login to the GitHub container registry with your username and the generated token (password):
  ```
  docker login ghcr.io
  ```

## Install

1. Clone this repository to your server or VM (over SSH).

1. Navigate to the root of the stack folder.

1. Create a `.env` file with the contents of [.env.example](https://github.com/vanegmondgroep/smart-industry-platform/blob/main/.env.example) from the Smart Industry Platform repository.

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
