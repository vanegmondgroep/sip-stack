# Smart Industry Platform Stack

This stack can be used for a standalone installation of the Smart Industry Platform.

## Requirements

* [Ubuntu 20.04](https://ubuntu.com/)
* [Docker](https://docs.docker.com/engine/install/ubuntu/)
* [Docker Compose](https://docs.docker.com/compose/install/)

## Install

1. Clone this repository to your computer or server.
   ```bash
   git clone git@github.com:vanegmondgroep/sip-stack.git 
   ```
1. Create a `.env` file in the root of the project with the contents of [.env.example](https://github.com/vanegmondgroep/smart-industry-platform/blob/main/.env.example) from the Smart Industry Platform repository.
1. Login to the GitHub container registry with your GitHub username and [a personal access token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) as password (scope: `read:packages`). 
   ```bash
   docker login ghcr.io
   ```
1. Start the containers.
   ```bash
   ./sip up -d
   ```
1. Migrate the database.
   ```bash
   ./sip artisan migrate
   ```
1. Navigate to `http://<ip-address>/register` and register a new user.

## Configuration

By default, Docker Compose reads two files, a `docker-compose.yml` and an optional `docker-compose.override.yml` file. By convention, the `docker-compose.yml` contains the base configuration for the Smart Industry Platform. The override file, as its name implies, can contain configuration overrides for existing services or entirely new services. All additional data (for example configuration files or volume mounts) should be created in the `custom` folder. More information about overriding container configuration can be found [here](https://docs.docker.com/compose/extends/).

## Upgrade

1. Stop the containers.
   ```bash
   ./sip down
   ```
1. Pull the latest stack updates.
   ```bash
   git pull
   ```
1. Pull the latest container builds.
   ```bash
   ./sip pull 
   ```
1. Start the containers.
   ```bash
   ./sip up -d
   ```
1. Migrate the database.
   ```bash
   ./sip artisan migrate
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
```
