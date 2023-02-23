FROM php:7.2.34-fpm

# 更改阿里云源
COPY ./conf/sources.list /etc/apt/sources.list

# 配置时区，安装环境依赖
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone && apt-get update && apt-get install vim zip unzip libjpeg-dev libzip-dev libwebp-dev openssl libssl-dev libpng-dev libpcre3 libpcre3-dev cron procps -y && apt-get clean &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

# 安装php扩展
RUN pecl install -o -f redis seaslog yaconf && docker-php-ext-enable redis seaslog yaconf && echo "extension=redis.so" >> docker-php-ext-redis.ini && echo "extension=seaslog.so" >> docker-php-ext-seaslog.ini && echo "extension=yaconf.so" >> docker-php-ext-yaconf.ini && docker-php-ext-install pdo pdo_mysql gd zip sockets bcmath && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && sed -i 's/memory_limit = 128M/memory_limit = 2048M/g' /usr/local/etc/php/php.ini  &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

# 安装xdebug
RUN cd /tmp && curl -Ok https://xdebug.org/files/xdebug-3.1.6.tgz && tar -zxvf /tmp/xdebug-3.1.6.tgz && cd xdebug-3.1.6 && phpize && ./configure && make && make install && echo "extension=xdebug.so" >>  /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && rm -rf /tmp/* /var/tmp/*

# 安装composer
RUN cd /tmp && curl -Ok https://getcomposer.org/download/2.5.3/composer.phar && mv /tmp/composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 安装nginx
RUN cd /tmp && curl -Ok http://nginx.org/download/nginx-1.18.0.tar.gz && tar -zxvf nginx-1.18.0.tar.gz && cd nginx-1.18.0 && ./configure --prefix=/usr/local/nginx --user=www-data --group=www-data --with-http_v2_module --with-http_ssl_module --with-http_gzip_static_module --with-http_stub_status_module && make && make install && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

# 配置nginx和php-fpm的配置文件
COPY ./conf/nginx.conf /usr/local/nginx/conf/nginx.conf
COPY ./conf/php.ini /usr/local/etc/php/php.ini
COPY ./conf/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY ./conf/run.sh /run.sh
COPY ./conf/nginx /etc/init.d/nginx
RUN mkdir /usr/local/nginx/conf/conf.d && chmod +x /run.sh && chmod +x /etc/init.d/nginx

# 设置工作目录
WORKDIR /var/www/html

# 暴露端口
EXPOSE 80 443

# 启动php-fpm和nginx
ENTRYPOINT ["/run.sh"]
