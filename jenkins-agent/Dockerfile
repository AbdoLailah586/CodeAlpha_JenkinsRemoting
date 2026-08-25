# ==============================================================================
# Task 2: Jenkins Remote Agent (Worker Node)
FROM jenkins/ssh-agent:alpine

LABEL maintainer="CodeAlpha Intern"
LABEL description="Isolated Jenkins Remote Agent communicating via SSH Remoting"

# Install essential build tools on the agent
RUN apk add --no-cache bash curl git docker-cli sudo

# Add jenkins user to sudoers for flexible build operations
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

EXPOSE 22
