# python - name of base image on Docker Hub
# 3.9-alpine3.13 - name of the Tag
# alpine is lightweight version of linux, bare minimum
FROM python:3.9-alpine3.13
LABEL maintainer="dpuljic01@gmail.com"

# python logs will be printed directly on console and not buffered
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# copies requirements and code from local machine into the docker image
# workdir is default dir from which commands run (eg. python manage.py ...)
# expose allows us to connect to django development server
# when combined in a single statement we reduce number of layers created by docker image, improves build performance
COPY ./requirements.txt ./requirements.dev.txt /tmp/


COPY ./app /app
WORKDIR /app
EXPOSE 8000

# by default we are not running app in development mode
# this will be set to true in docker-compose.yml which is used for local development
ARG DEV=false

# RUN - runs command on the alpine base image
# venv - creates and uses virtual env inside docker image
# --upgrade - upgrades packages inside venv
# install -r - installs app requirements inside venv
# rm -rf - removes tmp directory, we want to keep image lightweight (saves space and speed when deploying app)
# adduser - adds new user with name 'django-user' inside image because it's not recommended to use root user
# disabled-password - no need to login
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    # install postgres client, needed for psycopg2 package
    apk add --update --no-cache postgresql-client && \
    # groups packages under name tmp-build-deps which we use to remove packages later
    # we need tmp-build-deps to be able to install psycopg2 inside requirements.txt
    apk add --update --no-cache --virtual .tmp-build-deps build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    # shell statement, install dev deps if DEV=true
    if [ "${DEV}" = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# updates env variable inside image, we add our virtual env to PATH
# enables execution of commands without specifying full path
ENV PATH="/py/bin:$PATH"

# specifies user that we are switching to
# everything above this was done with root user
# everything after this (every container created) will use our custom django-user
USER django-user
