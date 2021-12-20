# php-fpm
php-fpm 是一个基于docker官方的php-fpm为基础的扩展镜像，安装一些常用的php扩展、composer 1.10、nginx 1.18。是一个较完整的lnmp环境，可直接用于测试或生产。


## 构建镜像
假设要构建的镜像名为”php-fpm“，那么可进入到项目目录里面，通过下面的命令完成自定义镜像的构建。
```
docker build -t php-fpm .
```

## 容器运行
容器运行的两种方式，一种是将程序代码打包入容器里面，该方式通常建议一个项目一个镜像，不同的项目之间互不干扰，适用于生产环境；另一种是将程序目录通过voloume映射的方式映射在本地的程序目录，开发人员可以根据自己的需求决定多项目的运行方式，或多容器，或虚拟域名、或映射不同的端口，该方式适用于开发环境。

### 通过vlomue和虚拟域名实现容器运行多个项目
```
# data/www 是本地的目录
# var/www/html 是容器的目录
# data/nginx/conf.d 是本地的虚拟域名配置目录


docker run -d -p 80:80 --name=project -v /data/www:/var/www/html -v /data/nginx/conf.d:/usr/local/nginx/conf/conf.d php-fpm


docker run -d -p 80:80 project
```

**如果增加了虚拟域名配置，可进入容器中使用 `service nginx reload` 进行配置文件重新加载**

配置虚拟域名， 在容器里的路径为 `/usr/local/nginx/conf/conf.d/`, 创建一个已".conf" 为后缀的文件， 或者在容器运行时将容器虚拟域名配置目录隐射到本地。具体内容可参考以下模板，在nginx.conf 也有类似的模板
```
# filename test.com.conf
server {
        listen       80;
        listen  [::]:80;
        server_name  test.com;
        index  index.html index.htm index.php;
        
        root   /var/www/html/test.com;

        # 如果你使用的是laravel、thinkPHP，需要隐藏入口，可参考下面的配置
        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }



        location ~ \.php$ {
            fastcgi_pass localhost:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
    }
```