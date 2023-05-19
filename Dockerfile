#registry.redhat.io/rhel9/php-80@sha256:899b745880964837e950af54bce6706aa06bc495881fd088457963438e021233
#FROM registry.access.redhat.com/ubi8/php-74@sha256:5ed84b43958bdc48325578d5df7bb57e5da2536454ae407af21b5a64a3d9c2f5

FROM registry.access.redhat.com/ubi8/php-74

# Add application sources to a directory that the assemble script expects them
# and set permissions so that the container runs without root access
USER 0
COPY --chmod=777 ./assets/assemble /usr/libexec/s2i/assemble

ADD app-src /tmp/src
RUN chown -R 1001:0 /tmp/src

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer  && \
    rm composer-setup.php

# install laravel
RUN composer global require laravel/installer
RUN chmod 777 /opt/app-root/src

USER 1001
RUN cd /opt/app-root/src && \
    composer create-project --prefer-dist laravel/laravel:^7.0 laravel

# install laravel modules
#https://github.com/jeroennoten/Laravel-AdminLTE/wiki/Basic-Forms-Components
RUN cd /opt/app-root/src/laravel && \
    composer require jeroennoten/laravel-adminlte && \
    php artisan adminlte:install && \
    composer require laravel/ui && \
    php artisan ui bootstrap --auth && \
    php artisan adminlte:install --only=auth_views
    
# Install the dependencies
RUN /usr/libexec/s2i/assemble

# modify config
ENV DOCUMENTROOT=/laravel/public
# Set the default command for the resulting image
CMD /usr/libexec/s2i/run


# https://larainfo.com/blogs/how-to-use-material-dashboard-in-laravel-9