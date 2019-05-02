#!/bin/sh
set -e

## If our argument list is empty we will do our default stuff
if [ -z $1 ]; then

    ## We need to run migrations if we haven't run them already
    # but first we need to wait for our mysqldb container for
    # finishing init process

    # On my machine it took 41 seconds for initial mysql bootstraping process
    ./shell-scripts/wait-for-it.sh mysqldb:3306 -s -t 120 -- php artisan migrate

    # After that we will launch our original docker-php-entrypoint
    exec docker-php-entrypoint php-fpm
fi

## Otherwise we will run custom command
exec "$@"