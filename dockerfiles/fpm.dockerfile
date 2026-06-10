ARG PHP_VERSION=${PHP_VERSION}
ARG NODE_VERSION=${NODE_VERSION:24}

##########################################################################################################

FROM node:${NODE_VERSION}-alpine AS node

FROM php:${PHP_VERSION}-fpm-alpine

#update/upgrade packages
RUN apk update && apk upgrade

#install desired bash extensions
ARG BASH_EXTENSIONS=${BASH_EXTENSIONS}
RUN apk add ${BASH_EXTENSIONS}

#include php extension installer script because image provided method sucks balls
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

#install desired php extensions
ARG PHP_EXTENSIONS=${PHP_EXTENSIONS}
RUN install-php-extensions ${PHP_EXTENSIONS}

#copy node files from other image
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node /usr/local/bin/npx /usr/local/bin/npx
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

##########################################################################################################