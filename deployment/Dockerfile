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

ADD run.sh /srv/git/run.sh

CMD ['python', './run.sh']