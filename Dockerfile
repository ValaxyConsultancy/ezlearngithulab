# Use Tomcat official image from Docker Hub
FROM tomcat:9.0-jre11

# Remove default web applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file into place
COPY ./TomcatMavenApp-2.3.war /usr/local/tomcat/webapps/ROOT.war

# Optional: Set any environment variables
ENV JAVA_OPTS="-Dsome.option=xyz"

# Expose the port Tomcat will run on
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
