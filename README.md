# WordPress Image

This image can be used to quickly standup a wordpress site locally.

## Environment variables

All environment variables are optional and likely not needed if you are just developing locally.

Variable | Description | Default
--|--|--
MYSQL_DATABASE | database name to use | wordpress
MYSQL_USER | username to connect to db | wordpress
MYSQL_PASSWORD | password to use to connect to db | iekalj4h2e3hi
PREFIX | WordPress table prefix | wp_
PORT | HTTP port for Apache | 80
RESET_ADMIN | Updates the primary user login to admin with a password of changeme when the value is 1 | **blank**

## Restoring Your Existing Database

Mount the directory with your SQL scripts to /src/db. The startup command will restore them on the first run. You cannot add the files later as it will not do this on subsequent runs.
