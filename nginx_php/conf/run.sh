#!/bin/sh

# 后台启动
php-fpm -D
# 关闭后台启动，hold住进程
/usr/local/nginx/sbin/nginx -g 'daemon off;'