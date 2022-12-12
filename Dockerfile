FROM node:16
COPY ./ /deploy
WORKDIR /deploy
RUN chmod -R 777 .
RUN npm config rm proxy
RUN npm config rm https-proxy
RUN yarn --network-timeout 1000000
EXPOSE 3000
ENTRYPOINT ./runExampleApp.sh