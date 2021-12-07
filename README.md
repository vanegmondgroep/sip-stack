# Smart Industry Platform Stack

The SIP stack can be used for a standalone installation of the Smart Industry Platform.

## Requirements

* Ubuntu 20.04
* Composer
* Docker
* Docker Compose

## Installation

* Authenticate to the GitHub container registry with your username and a personal access token as password (permissions: `read:packages`):

```bash
docker login ghcr.io
```
* Create a new SIP Stack project (replace `<client>` and `<project>`):

```bash
composer create-project vanegmondgroep/sip-stack sip-<client>-<project>
```

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

## Configuration

### Backups

Add the following line to the `.env` file if you would like to move backups to another location (for example a network share):

```
BACKUPS_PATH=/mnt/share/Backups
```

### Exports

Modify `./config/export.flux` to change the InfluxDB export query and add the following line to the `.env` file if you would like to move exports to another location (for example a network share):

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
