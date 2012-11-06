all:
	javac -d WEB-INF/classes src/*.java
	stop_tomcat
	tomcat.sh
