构建镜像
```
docker build -t nginx_php .
```

运行镜像
```
docker run -d -p 80:80 -v /data/www:/var/www/html -v /data/nginx/conf.d:/usr/local/nginx/conf/conf.d nginx_php

docker run -d -p 80:80 nginx_php
```

如果增加了虚拟域名配置，可使用 `service nginx reload` 进行配置文件重新加载


配置虚拟域名， 在容器里的路径为 `/usr/local/nginx/conf/conf.d/`, 创建一个已".conf" 为后缀的文件， 具体内容可参考以下模板，在nginx.conf 也有类似的模板
```
# filename test.com.conf
server {
        listen       80;
        listen  [::]:80;
        server_name  test.com;
        
        root   /var/www/html/test.com;

        location / {
            index  index.html index.htm index.php;
        }

        location ~ \.php$ {
            fastcgi_pass localhost:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
    }
```