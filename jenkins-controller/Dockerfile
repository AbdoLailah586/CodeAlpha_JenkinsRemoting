# ==============================================================================
# Task 2: Jenkins Controller (Master Orchestrator)
# ==============================================================================
FROM jenkins/jenkins:lts-jdk17

LABEL maintainer="CodeAlpha Intern"
LABEL description="Jenkins Controller pre-configured with JCasC, SSH remoting, and plugins"

# Disable initial setup wizard for fully automated provisioning
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV CASC_JENKINS_CONFIG="/var/jenkins_home/casc.yaml"

# Pre-install required plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# Copy Jenkins Configuration as Code (JCasC) definition
COPY casc.yaml /var/jenkins_home/casc.yaml

EXPOSE 8080 50000
