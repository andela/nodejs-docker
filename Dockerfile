FROM node:6-alpine

ENV GRPC_HEALTH_CHECK_TAG %GRPC_HEALTH_CHECK_TAG%

RUN apk add --update make gcc g++ python libc6-compat postgresql-dev git bash curl supervisor && \
apk del make gcc g++ python postgresql-dev

# setup health-check
ADD https://github.com/andela/grpc-health/releases/download/v${GRPC_HEALTH_CHECK_TAG}/artifact /healthcheck-artifact
COPY supervisor/supervisord-healthcheck.ini /etc/supervisor.d/supervisord-healthcheck.ini
RUN chmod +x /healthcheck-artifact

# setup app
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY app/ .
RUN yarn install --prod  && \
  rm -rf /tmp/* /var/cache/apk/* /root/.npm /root/.node-gyp

COPY supervisor/supervisord-app.ini /etc/supervisor.d/supervisord-app.ini

EXPOSE 8080
EXPOSE 50050

CMD ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
