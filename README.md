# Smart Industry Platform Stack

The SIP stack can be used for a standalone installation of the Smart Industry Platform.

## Requirements

* [Ubuntu 20.04](https://docs.vanegmond.cloud/ubuntu.html#initial-server-setup)
* [Install & configure Git](https://docs.vanegmond.cloud/git.html)
* [Install & configure Docker](https://docs.vanegmond.cloud/docker.html)
* [Install & configure Docker Compose](https://docs.vanegmond.cloud/docker-compose.html)

## Installation

> If you're preparing an installation for a new project [follow these steps first](#project-installation).

* Clone this repository to your server or VM (over SSH).

* Navigate to the root of the stack folder.

* Create a `.env`-file with the contents of [.env.example](https://github.com/vanegmondgroep/smart-industry-platform/blob/main/.env.example) from the Smart Industry Platform repository.

*  Run the following commands to initialize the stack:

```bash
# Start containers
./sip up -d

# Migrate the database
./sip artisan migrate --seed

# Generate application key
./sip artisan key:generate
```

* Navigate to `http://<ip-address>/register` and register a new user.

### Project installation

The stack configuration for each project is stored in GitHub. To prepare a repository for a new project we need to copy the latest stack code to the repository of the project.

* Download the latest version of the SIP stack [here](https://github.com/vanegmondgroep/sip-stack/archive/refs/heads/main.zip) and unzip the files.

* Create a new private repository in GitHub with name: `sip-<client>-<project>`

* Click on the "uploading an existing file"-link.

* Drag & drop the unzipped stack files to the repository.

* Commit files with message: `Initial commit`

* [Follow the normal installation instructions](#installation).

## Configuration

### Backups

Add the following line to the `.env` file if you would like to move backups to another location [(for example a network share)](/ubuntu.html#mount-a-network-share):

```
BACKUPS_PATH=/mnt/share/Backups
```

### Exports

Modify `./config/export.flux` to change the InfluxDB export query. Add the following line to the `.env` file if you would like to move exports to another location [(for example a network share)](/ubuntu.html#mount-a-network-share):

```
EXPORTS_PATH=/mnt/share/Exports
```

### Cleanup

Add the following line to the `.env` file to automatically cleanup backups and exports after x days:

```
CLEANUP_DAYS=30
```

### Cronjobs

Configure a cronjob to automatically export or backup data:

* Open crontab:

```bash
crontab -e
```

* Add the following lines (replace `<path-to-sip>`):

```
# Export data
0 0 * * * <path-to-sip>/sip export > ~/sip-export.log 2>&1

# Backup data
0 1 * * * <path-to-sip>/sip backup > ~/sip-backup.log 2>&1
```

## Commands

```bash
# Start containers
./sip up -d

# Stop containers
./sip down

# Start container shell
./sip bash

# Backup container data
./sip backup

# Export log data
./sip export
```
