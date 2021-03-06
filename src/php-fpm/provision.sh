#!/bin/bash
set -e
APK_ADD="apk add --no-cache"

#
# Install runtime dependencies
#
printf "\e[1;34m### RUN apk add \n \e[0m"

# Login and passwd utilities (usermod, useradd, ...)
# required for later manipulation of file permission and ownership
$APK_ADD shadow

# A high-quality data compression program
# required for composer
$APK_ADD bzip2

# TrueType font rendering library
# required to build php imagick extension
$APK_ADD freetype-dev

# accelerated baseline JPEG compression and decompression library
# required to build php imagick extension
$APK_ADD libjpeg-turbo-dev

# Portable Network Graphics library
# required to build php imagick extension
$APK_ADD libpng-dev

# Zip
$APK_ADD libzip-dev

# libxml2
$APK_ADD libxml2-dev

# Soap
# $APK_ADD soap

# Collection of tools and libraries for many image formats
# required to build php imagick extension
$APK_ADD imagemagick
$APK_ADD imagemagick-dev
cat /tmp/imagemagick-policy.xml >> /etc/ImageMagick-7/policy.xml

# A uniform interface to several symmetric encryption algorithms
# required to @TODO
$APK_ADD libmcrypt-dev

# SSH client
# required for Sitegeist.MagicWand and composer
$APK_ADD openssh-client

# Distributed version control system
# required for composer
$APK_ADD git

# A file transfer program to keep remote files in sync
# reuired for Sitegeist.MagicWand
$APK_ADD rsync

# Dummy package for mysql-client migration for mariadb
# required for pdo_mysql php extension
$APK_ADD mysql-client

#
# Install PECL dependencies
#
printf "\e[1;34m### RUN pecl install \n \e[0m"

#
# These dependencies are only needed during the build and will be
# removed afterwards.
#
export PHPIZE_DEPS="autoconf g++ libtool make pcre-dev"

#
# Install build dependencies
#
printf "\e[1;34m### RUN apk add with .phpize-deps-configure \n \e[0m"
$APK_ADD --virtual .phpize-deps-configure $PHPIZE_DEPS
docker-php-source extract

#
# APC (Alternative PHP Cache) User Cache
# free, open, and robust framework for caching and optimizing
# PHP intermediate code
pecl install apcu

#
# Provides a wrapper to the ImageMagick library
# required for image manipulation in Neos
pecl install imagick

#
# PHP extension for interfacing with Redis
# required to provide Redis as a cache backend for several
# Neos caches
pecl install redis

#
# PHP exension for highly performant serialization
pecl install igbinary

docker-php-ext-enable apcu imagick redis
apk del .phpize-deps-configure
docker-php-source delete

#
# Install additional PHP extensions
#

# PHP PDO MySQL driver
# required to connect neos with MariaDB
docker-php-ext-install pdo_mysql

# Improves PHP performance by storing precompiled script bytecode
# in shared memory
docker-php-ext-install opcache

# PHP ZIP
docker-php-ext-configure zip --with-libzip=/usr/include
docker-php-ext-install zip

# PHP Soap
docker-php-ext-install soap

#
# Internationalization extension (a wrapper for ICU library)
#
$APK_ADD icu-dev
docker-php-ext-install intl

#
# Install Composer
#
printf "\e[1;34m### Install composer \n \e[0m"
curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/bin --filename=composer

#
# Composer plugin for parallel install of plugins
#
composer global require hirak/prestissimo

