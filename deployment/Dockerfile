FROM java:latest

MAINTAINER Australian Antarctic Data Centre (AADC)

# Set the environment proxy variables for the AAD network
ENV http_proxy http://proxy.aad.gov.au:8080
ENV https_proxy http://proxy.aad.gov.au:8080
ENV HTTP_PROXY http://proxy.aad.gov.au:8080
ENV HTTPS_PROXY http://proxy.aad.gov.au:8080

# Set the APT-GET proxy details
RUN echo 'Acquire::http::proxy "http://proxy.aad.gov.au:8080";' >> /etc/apt/apt.conf
RUN echo 'Acquire::https::proxy "http://proxy.aad.gov.au:8080";' >> /etc/apt/apt.conf

RUN apt-get update && apt-get install -y --no-install-recommends cron
 
# Add crontab file in the cron directory
ADD crontab /etc/cron.d/conversion-cron
 
# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/conversion-cron
 
# Create the log file to be able to run tail
RUN touch /var/log/cron.log
 
# Run the command on container startup
CMD cron && tail -f /var/log/cron.log