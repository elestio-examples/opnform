<a href="https://elest.io">
  <img src="https://elest.io/images/elestio.svg" alt="elest.io" width="150" height="75">
</a>

[![Discord](https://img.shields.io/static/v1.svg?logo=discord&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=Discord&message=community)](https://discord.gg/4T4JGaMYrD "Get instant assistance and engage in live discussions with both the community and team through our chat feature.")
[![Elestio examples](https://img.shields.io/static/v1.svg?logo=github&color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=github&message=open%20source)](https://github.com/elestio-examples "Access the source code for all our repositories by viewing them.")
[![Blog](https://img.shields.io/static/v1.svg?color=f78A38&labelColor=083468&logoColor=ffffff&style=for-the-badge&label=elest.io&message=Blog)](https://blog.elest.io "Latest news about elestio, open source software, and DevOps techniques.")

# OpnForm, verified and packaged by Elestio

[OpnForm](https://opnform.com), create beautiful forms and share them anywhere. It super fast, you don't need to know how to code. Get started for free!
<img src="https://github.com/elestio-examples/opnform/blob/master/screenshot.png?raw=true" alt="opnform" width="800">

Deploy a <a target="_blank" href="https://elest.io/open-source/opnform">fully managed OpnForm</a> on <a target="_blank" href="https://elest.io/">elest.io</a> if you want automated backups, reverse proxy with SSL termination, firewall, automated OS & Software updates, and a team of Linux experts and open source enthusiasts to ensure your services are always safe, and functional.

[![deploy](https://github.com/elestio-examples/opnform/blob/master/deploy-on-elestio.png?raw=true)](https://dash.elest.io/deploy?source=cicd&social=dockerCompose&url=https://github.com/elestio-examples/opnform)

# Why use Elestio images?

- Elestio stays in sync with updates from the original source and quickly releases new versions of this image through our automated processes.
- Elestio images provide timely access to the most recent bug fixes and features.
- Our team performs quality control checks to ensure the products we release meet our high standards.

# Usage

## Git clone

You can deploy it easily with the following command:

    git clone https://github.com/elestio-examples/opnform.git

Copy the .env file from tests folder to the project directory

    cp ./tests/.env ./.env

Edit the .env file with your own values.

Run the project with the following commands

    docker-compose up -d
    ./scripts/postInstall.sh

You can access the Web UI at: `http://your-domain:35551`

## Docker-compose

Here are some example snippets to help you get started creating a container.

    version: "3.7"
    services:

    minio:
        image: minio/minio
        restart: always
        command: server /data
        ports:
            - "172.17.0.1:9999:9000"
        environment:
            MINIO_ROOT_USER: minio
            MINIO_ROOT_PASSWORD: ${ADMIN_PASSWORD}
        volumes:
            - ./s3_data:/data

    createbuckets:
        image: minio/mc
        depends_on:
            - minio
        entrypoint: >
            /bin/sh -c "
            sleep 10;
            /usr/bin/mc config host add minio http://minio:9000 minio ${ADMIN_PASSWORD};
            /usr/bin/mc mb minio/opnform;
            /usr/bin/mc anonymous set public minio/opnform/public;
            exit 0;
            "

    opnform:
        image: elestio4test/opnform:latest
        restart: always
        volumes:
            - ./forms:/persist
            - ./.env:/app/.env
        ports:
            - 172.17.0.1:35551:80
        depends_on:
            - postgres
    redis:
        image: elestio/redis:7.0
        restart: always
        volumes:
            - ./redis-data:/data
    postgres:
        image: elestio/postgres:15
        restart: always
        volumes:
            - ./postgres-data:/var/lib/postgresql/data
        environment:
            - POSTGRES_DB=${DB_DATABASE}
            - POSTGRES_USER=${DB_USERNAME}
            - POSTGRES_PASSWORD=${DB_PASSWORD}
        ports:
            - "172.17.0.1:27779:5432"

### Environment variables

|          Variable           |                 Value (example)                 |
| :-------------------------: | :---------------------------------------------: |
|    SOFTWARE_VERSION_TAG     |                     latest                      |
|           DOMAIN            |                 your.domain.com                 |
|         ADMIN_EMAIL         |                 admin@email.com                 |
|       ADMIN_PASSWORD        |                  your-password                  |
|          APP_NAME           |                     OpnForm                     |
|           APP_ENV           |                      local                      |
|          APP_DEBUG          |                      false                      |
|        APP_LOG_LEVEL        |                      debug                      |
|           APP_URL           |             https://your.domain.com             |
|         LOG_CHANNEL         |                    errorlog                     |
|          LOG_LEVEL          |                      debug                      |
|        DB_CONNECTION        |                      pgsql                      |
|           DB_HOST           |                    postgres                     |
|           DB_PORT           |                      5432                       |
|         DB_DATABASE         |                     opnform                     |
|         DB_USERNAME         |                    postgres                     |
|         DB_PASSWORD         |                  your-password                  |
|      FILESYSTEM_DRIVER      |                       s3                        |
|       FILESYSTEM_DISK       |                       s3                        |
|      BROADCAST_DRIVER       |                       log                       |
|        CACHE_DRIVER         |                      redis                      |
|      QUEUE_CONNECTION       |                      redis                      |
|       SESSION_DRIVER        |                      file                       |
|      SESSION_LIFETIME       |                       120                       |
|         REDIS_HOST          |                      redis                      |
|       REDIS_PASSWORD        |                      null                       |
|         REDIS_PORT          |                      6379                       |
|         MAIL_MAILER         |                      smtp                       |
|          MAIL_HOST          |                 your.smtp.host                  |
|          MAIL_PORT          |                 your.smtp.port                  |
|        MAIL_USERNAME        |                      null                       |
|        MAIL_PASSWORD        |                      null                       |
|       MAIL_ENCRYPTION       |                      null                       |
|      MAIL_FROM_ADDRESS      |                 from@email.com                  |
|       MAIL_FROM_NAME        |                     OpnForm                     |
|           JWT_TTL           |                      1440                       |
|      AWS_ACCESS_KEY_ID      |                      minio                      |
|    AWS_SECRET_ACCESS_KEY    |                  your-password                  |
|           AWS_URL           |          https://your.domain.com:58624          |
|        AWS_ENDPOINT         |          https://your.domain.com:58624          |
|         AWS_BUCKET          |                     opnform                     |
|     AWS_DEFAULT_REGION      |                    us-east-1                    |
| AWS_USE_PATH_STYLE_ENDPOINT |                      true                       |
|           APP_KEY           | `let it blank, it will be automatically filled` |
|         JWT_SECRET          | `let it blank, it will be automatically filled` |

# Maintenance

## Logging

The Elestio OpnForm Docker image sends the container logs to stdout. To view the logs, you can use the following command:

    docker-compose logs -f

To stop the stack you can use the following command:

    docker-compose down

## Backup and Restore with Docker Compose

To make backup and restore operations easier, we are using folder volume mounts. You can simply stop your stack with docker-compose down, then backup all the files and subfolders in the folder near the docker-compose.yml file.

Creating a ZIP Archive
For example, if you want to create a ZIP archive, navigate to the folder where you have your docker-compose.yml file and use this command:

    zip -r myarchive.zip .

Restoring from ZIP Archive
To restore from a ZIP archive, unzip the archive into the original folder using the following command:

    unzip myarchive.zip -d /path/to/original/folder

Starting Your Stack
Once your backup is complete, you can start your stack again with the following command:

    docker-compose up -d

That's it! With these simple steps, you can easily backup and restore your data volumes using Docker Compose.

# Links

- <a target="_blank" href="https://github.com/JhumanJ/OpnForm">OpnForm Github repository</a>

- <a target="_blank" href="https://github.com/elestio-examples/opnform">Elestio/OpnForm Github repository</a>
