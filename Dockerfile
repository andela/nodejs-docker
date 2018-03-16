FROM node:8

ENV GRPC_HEALTH_CHECK_TAG %GRPC_HEALTH_CHECK_TAG%
ENV DEPLOYMENT_TAG %IMG_TAG%
ARG NPM_TOKEN

RUN apt-get update && apt-get install -y supervisor
RUN mkdir -p /opt/yarn/bin && ln -s /opt/yarn/yarn-v1.5.1/bin/yarn /opt/yarn/bin/yarn

# setup app
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY app/ /usr/src/app/
COPY supervisor/supervisord-app.ini /etc/supervisor/conf.d/supervisord-app.conf

RUN echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" >> ~/.npmrc && yarn config set registry https://registry.npmjs.org/ && yarn --prod

EXPOSE 8080
EXPOSE 50050

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
