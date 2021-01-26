构建镜像
```
docker build -t nginx_php .
```

运行镜像
```
docker run -d -p 80:80 -v /data/www:/var/www/html -v /data/nginx/conf.d:/usr/local/nginx/conf/conf.d nginx_php

docker run -d -p 80:80 nginx_php
```


还差一个nginx的守护进程，要与不要都行