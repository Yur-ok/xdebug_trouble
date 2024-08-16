FROM phpswoole/swoole:5.1-php8.2-alpine as runtime

RUN apk add --no-cache bash && \
    docker-php-ext-install pcntl

RUN adduser \
    --disabled-password \
    --no-create-home \
    --shell "/sbin/nologin" \
    --uid "10001" \
    --gecos "" \
    developer

USER developer:developer
WORKDIR /var/www/app
COPY --chown=developer:developer ./app /var/www/app

ENV COMPOSER_HOME="/tmp/composer"
RUN composer install -n --no-ansi --no-autoloader --no-scripts --prefer-dist && \
    composer clear-cache && \
    composer dump --optimize --no-scripts

RUN composer dump-autoload -n --optimize

FROM runtime as dev

USER root
RUN apk add --no-cache \
    autoconf make g++ linux-headers
RUN pecl install xdebug-stable
COPY docker/app/rootfs/ /
USER developer:developer

CMD [ "php" , "/var/www/app/public/index.php" ]

FROM runtime AS prod

CMD [ "php" , "/var/www/app/public/index.php" ]