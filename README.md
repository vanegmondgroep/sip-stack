# Smart Industry Platform Stack

This stack can be used for a standalone installation of the Smart Industry Platform.

## Requirements

* [Ubuntu 20.04](https://ubuntu.com/)
* [Install Docker](https://github.com/vanegmondgroep/engineering-best-practices/blob/main/docs/Docker.md#install-docker)
* [Install Docker Compose](https://github.com/vanegmondgroep/engineering-best-practices/blob/main/docs/Docker.md#install-docker-compose)
* [Authenticate to GitHub](https://github.com/vanegmondgroep/engineering-best-practices/blob/main/docs/Git.md#authenticate-to-github)
* [Authenticate to the GitHub Container registry](https://github.com/vanegmondgroep/engineering-best-practices/blob/main/docs/Docker.md#authenticate-to-github-container-registry)

## Install

* Clone this repository to your server or VM (over SSH).

* Navigate to the root of the stack folder.

* Create a `.env`-file with the contents of [.env.example](https://github.com/vanegmondgroep/smart-industry-platform/blob/main/.env.example) from the Smart Industry Platform repository.

*  Run the following commands to initialize the stack:

```bash
# Start containers
./sip up -d

# Migrate the database
./sip artisan migrate

# Generate application key
./sip artisan key:generate
```

* Navigate to `http://<ip-address>/register` and register a new user.

## Commands

```bash
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
