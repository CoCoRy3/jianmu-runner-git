FROM python:3.8-slim-buster
ADD script/* /usr/local/bin/
RUN apt-get update
RUN apt-get -y install git
ENTRYPOINT ["sh"]
CMD ["/usr/local/bin/log.sh"]