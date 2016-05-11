FROM mhart/alpine-node:latest
ADD app /data/app
ADD package.json /data/package.json
RUN ln -s /data/app /bin/app
RUN chmod +x /bin/app
WORKDIR /data
RUN npm install
CMD ["app"]
