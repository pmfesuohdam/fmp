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
