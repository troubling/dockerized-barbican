FROM ubuntu:16.04

RUN apt-get update && apt-get install -y barbican-api barbican-keystone-listener barbican-worker

COPY bootstrap-barbican.sh /etc/bootstrap-barbican.sh
RUN chown root:root /etc/bootstrap-barbican.sh && chmod a+x /etc/bootstrap-barbican.sh

ENTRYPOINT ["/etc/bootstrap-barbican.sh"]

EXPOSE 9311
