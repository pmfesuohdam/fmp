# fmp

tomcat7的配置server.xml中
```code
<Context path="" docBase="/path/to/FMP_ui" debug="0"/>
```

tomcat部署war包的脚本
```
#!/bin/sh
pwd=$PWD
echo current dir:$pwd
cd /path/to/projectDir
/usr/bin/git pull
/etc/init.d/tomcat7 stop
rm -rf /var/lib/tomcat7/webapps/FMP.war
rm -rf /var/lib/tomcat7/webapps/FMP/
cd /path/to/projectDir/FMP_api
/usr/local/apache-maven/bin/mvn clean package
mv /path/to/projectDir/FMP_api/target/FMP.war /var/lib/tomcat7/webapps/
/etc/init.d/tomcat7 start
```

nginx反向代理tomcat的设置
```
#
# A virtual host using mix of IP-, name-, and port-based configuration
#

server {
    listen       80;
    server_name  localhost;

    location / {
    #    root   /path/to/projectDir/FMP_ui;
    #    index  index.html index.htm;
    #}
    #location  /FMP {
        proxy_pass http://localhost:8080;
        proxy_set_header 'Access-Control-Allow-Origin' 'http://localhost';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE';
        add_header 'Access-Control-Allow-Headers' 'X-Requested-With,Accept,Content-Type, Origin';
        proxy_redirect     off;
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
    }
}
```
