FROM python:3.9-buster

RUN apt-get update && \
    apt-get install -y \
    vim-tiny \
    supervisor \
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/log/uwsgi && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /var/run/uwsgi && \
    mkdir -p /usr/src/django_app

COPY docker_conf/uwsgi.ini /usr/src/uwsgi.ini
COPY docker_conf/supervisor.conf /etc/supervisor.conf
COPY docker_conf/docker-entrypoint.sh /usr/src/django_app
COPY docker_conf/requirements.txt /usr/src/requirements.txt

WORKDIR /usr/src
RUN pip install -r requirements.txt --no-cache-dir

ADD ./tmp_django_app /usr/src/django_app
WORKDIR /usr/src/django_app
ENTRYPOINT ["/usr/src/django_app/docker-entrypoint.sh"]
EXPOSE 8000 8001
CMD ["supervisord", "-c", "/etc/supervisor.conf"]

