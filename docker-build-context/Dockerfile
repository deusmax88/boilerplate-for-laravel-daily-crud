## Build nodejs part of our application
# I'am gonna use node:lts which is for moment of doing is 10.15.3
FROM node:lts AS npm-build-phase

# Making space for our intermediate operations
RUN mkdir /app
WORKDIR /app

# Retreiving source code from repository of our interest
RUN git clone https://github.com/LaravelDaily/Laravel-Vue-First-CRUD.git .

# Building node part of our application - according to original documentation
RUN npm install
RUN npm run dev

## And here i'am also gonna add some usefull shell sciprts
# wait-for-it.sh as my first attempt waiting for mysqldb container.
RUN mkdir shell-scripts
RUN curl -fsSL https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
-o shell-scripts/wait-for-it.sh
# making it executable offcourse
RUN chmod +x shell-scripts/wait-for-it.sh

## Installing composer php dependencies
FROM composer:latest AS composer-build-phase

# Copying builded node application from previous phase
COPY --from=npm-build-phase /app /app

# Running composer install without scripts
RUN composer install

# Now let's give it a try
# Building nice

## At our final step we are gonna use php-fpm as our application server
FROM php:7.2-fpm

# Copying installed php dependensies from composer build phase
COPY --from=composer-build-phase /app /var/www/html

# Installing required php modules - as pdo_mysql in our case
RUN docker-php-ext-install pdo_mysql

# Let's do another preparation steps from project repository guide -
# First lets substitute mysqldb server credentials
RUN sed -e 's/DB_HOST=.*$/DB_HOST=mysqldb/' \
-e 's/DB_PORT=.*$/DB_PORT=3306/' \
-e 's/DB_DATABASE=.*$/DB_DATABASE=sample/' \
-e 's/DB_USERNAME=.*$/DB_USERNAME=test/' \
-e 's/DB_PASSWORD=.*$/DB_PASSWORD=test/' \
.env.example > .env && rm .env.example

# After that we would generate our application key in .env file
RUN php artisan key:generate

# As php-fpm runs as www-data:www-data,
# But after all manipulations everything belongs to root:root.
# For our purposes i'am gonna change group ownership to www-data
# And grand proper privileges
# (maybe there is another way to fix this - try using google?)
RUN chgrp -R www-data storage bootstrap/cache
RUN chmod -R g+rwx storage bootstrap/cache

# But before we proceed further - we have to run runtime steps
# such as database migrations which are needed for our laravel
# installation.
# so here i'am gonna use my custom entryscript.sh
COPY ./entryscripts/application.sh /usr/local/bin/application.sh

# I'am gonna make it executable obviously
RUN chmod +x /usr/local/bin/application.sh

ENTRYPOINT ["application.sh"]