# DOCKER PHP-DEV ENVIRONMENT

## Disclaimer
This container is not intended for productive use, as it was not checked for security flaws and should therefore only be used for development purposes.
It makes use of the network_mode:host option so this container won't work with Mac OS.

## What it does
This Docker container sets up a basic DEV environment for PHP/JS Development. It uses **apache2** as the webserver. **Domains** are handled via wildcard.

A **cli** is also included with **php, composer and node.js / npm** installed.
 
It uses **MariaDB** on port 3306 for access with a prefered db client.

## Used Images
>- ubuntu:apache2
>- php:fpm-alpine
>- php:cli
>- mariadb:latest

## Usage
1. Rename **.env.sample** file to **.env** and change the contents as desired.

**Constants used in .env file:**
>- **WORKDIR**
>The relative path to the directory containing all your projects. 
>- **PHP_VERSION**
> The desired PHP version for the cli container, uncomment desired version, leave rest commented.
>- **PHP_EXTENSIONS**
> The PHP extensions that should be installed on image build. Enter space separated. If new modules are added after initial build process, repeat build process using `docker compose build web` and `docker compose build cli`
>- **MYSQL_DATABASE (optional)**
> Database that gets created on container creation
>- **MYSQL_USER (optional)**
> Database user with read/write access for MYSQL_DATABASE
>- **MYSQL_PASSWORD (optional)**
> Password for MYSQL_USER
>- **MYSQL_ROOT_PASSWORD**
> Password for mysql root user
>- **BASH_EXTENSIONS**
> The os extensions that should be installed for use in cli and fpm. Enter space separated. If new extensions are added after initial build process, repeat build process using `docker compose build cli`
>- **NODE_VERSION**
> The desired NODE version, enter "node" to install latest version else enter version in format xx.xx.x
>- **APACHE_EXTENSIONS**
> The desired apache modules which should be enabled. Enter space separated. If new modules are added after initial build process, repeat build process using `docker compose build web`
Required Modules: vhost_alias rewrite proxy_fcgi
>- **USERNAME**
> The desired username which will be used in the cli image
>- **UID**
> The userID which will be used in the cli image (should be 1000 in most cases)
>- **GID**
> The groupID which will be used in the cli image (should be 1000 in most cases)

2. Use `docker compose --build` this will start pulling and building the images. This process will take a lot of time so be patient. If the **PHP_VERSION** is changed in the **.env** file the build process for the cli container needs to be repeated. This step is only needed once for every **PHP_VERSION** if you need them.

3. If you need to switch the server php-fpm version, create an empty file in your project root with one of the following names: **80.phpversion** / **81.phpversion** / **82.phpversion** no restart required.

4. Once the images are built, the container can be started with `docker compose up -d`.

5. All your projects will be reachable via wildcard domain, the pattern is **foldername.test** to reach the **root** of your project or **foldername.public.test** to reach the **public** folder of your project, if you wish to change the domain ending it has to be changed in **./data/apache/wildcard.conf**.

6. Domains ending in .test require a local DNS resolver like **dnsmasq** or manual entries in **/etc/hosts** (e.g. `127.0.0.1 foldername.test`) to resolve to 127.0.0.1.

7. **.ssh** and **.gitconfig** for the **cli** image will be mounted from the host home directory to the container user home directory as defined in the .env file. So the files need to be created and stored on the host first.

8. **php.ini** changes can be made in **./data/php/php.ini**, the container needs to be restarted afterwards with `docker compose restart`.

9. **xdebug.ini** rename either **xdebug.ini.unix** for Mac and Linux or **xdebug.ini.wsl2** for Windows WSL2 to **xdebug.ini** in the **./data/php** directory, the container needs to be restarted afterwards with `docker compose restart`.

10. **MariaDB Database** can be accessed with external database management tool like **dbeaver** and alike using **localhost:3306** as host. Databases will be persisted in **./databases** folder.

11. To access the **bash cli** run the following command to start a cli container which closes itself after exiting: `docker compose run --rm cli`

## Shell Aliases
To make working with the container easier, you can register a set of aliases that wrap the most common `docker compose` commands so you can run them from any directory.

To avoid hardcoding the path, run the following snippet **from the repository root** (the directory containing `docker-compose.yml`). It captures the current path with `$(pwd)` and writes the aliases with the absolute path baked in into your `~/.zshrc` (use `~/.bashrc` for bash):

```bash
DEV_CONTAINER_PATH="$(pwd)"
cat >> ~/.zshrc <<EOF

# php-dev-container aliases
alias devup="(cd $DEV_CONTAINER_PATH && docker compose up -d)"
alias devdown="docker compose -f $DEV_CONTAINER_PATH/docker-compose.yml down"
alias devrestart="(cd $DEV_CONTAINER_PATH && docker compose down && docker compose up -d)"
alias devlogs="docker compose -f $DEV_CONTAINER_PATH/docker-compose.yml logs"
EOF
```

Since the heredoc is unquoted, `$DEV_CONTAINER_PATH` is expanded **at the time the snippet runs**, so the resulting lines in `~/.zshrc` will contain the absolute path of the repository.

The start aliases (`devup` / `devrestart`) `cd` into the repository in a subshell instead of pointing at `docker-compose.yml` directly. This way `docker compose` automatically merges a `docker-compose.override.yml` if one is present. The subshell `( ... )` ensures the working directory of your shell does not change.

After running it, reload your shell config (e.g. `source ~/.zshrc`) and use the aliases as follows:

>- **devup**
> Starts the dev container in detached mode.
>- **devdown**
> Stops and removes the dev container.
>- **devrestart**
> Stops the container and starts it again in detached mode.
>- **devlogs**
> Shows the logs of the dev container.
