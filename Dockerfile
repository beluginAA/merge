FROM python:3.12 AS python-build-stage

RUN apt-get update && apt-get install --no-install-recommends -y build-essential 

COPY requirements.txt .

RUN pip wheel --wheel-dir /usr/src/app/wheels  \
  -r requirements.txt

FROM python:3.12-slim AS python-run-stage

ARG APP_HOME=/app
WORKDIR ${APP_HOME}

RUN apt update && apt upgrade --assume-yes \
         libexpat1 \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/log/* \
    && rm -rf /var/cache/*

COPY ./script ${APP_HOME}
COPY --from=python-build-stage /usr/src/app/wheels  /wheels/

RUN pip install --no-cache-dir --no-index --find-links=/wheels/ /wheels/* \
  && rm -rf /wheels/
