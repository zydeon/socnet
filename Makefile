all:
	javac -cp :/Library/Tomcat/lib/* -d WEB-INF/classes src/*.java
	cp -r `ls | grep -v Makefile` /usr/local/apache-tomcat-7.0.32/webapps/socnet
	stop_tomcat
	start_tomcat
	tail -f /usr/local/apache-tomcat-7.0.32/logs/catalina.out
