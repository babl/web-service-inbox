FROM mhart/alpine-node:latest
RUN wget -O- "http://s3.amazonaws.com/babl/babl-server_linux_amd64.gz" | gunzip > /bin/babl-server && chmod +x /bin/babl-server
ADD app /data/app
ADD package.json /data/package.json
RUN ln -s /data/app /bin/app
RUN chmod +x /bin/app
WORKDIR /data
RUN npm install
CMD ["app"]
