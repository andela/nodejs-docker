FROM node:8

ENV GRPC_HEALTH_CHECK_TAG %GRPC_HEALTH_CHECK_TAG%
ENV DEPLOYMENT_TAG %IMG_TAG%
ARG NPM_TOKEN

RUN apt-get update && apt-get install -y supervisor

# setup health-check
ADD https://github.com/andela/grpc-health/releases/download/v${GRPC_HEALTH_CHECK_TAG}/artifact /healthcheck-artifact
COPY supervisor/supervisord-healthcheck.ini /etc/supervisor/conf.d/supervisord-healthcheck.ini
RUN chmod +x /healthcheck-artifact

# setup app
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY app/ /usr/src/app/
COPY supervisor/supervisord-app.ini /etc/supervisor/conf.d/supervisord-app.conf

RUN echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" >> ~/.npmrc && yarn --prod

EXPOSE 8080
EXPOSE 50050

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
