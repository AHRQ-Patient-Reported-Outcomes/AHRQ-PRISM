FROM node:11.13

# set working directory
RUN mkdir /usr/src/app
WORKDIR /usr/src/app

# add `/usr/src/app/node_modules/.bin` to $PATH
ENV PATH /usr/src/app/node_modules/.bin:$PATH

# bundle app sources
COPY ./auth/app.js /usr/src/app
COPY ./auth/app.local.js /usr/src/app
COPY ./auth/config/ /usr/src/app/config
COPY ./auth/lambda.js /usr/src/app
COPY ./auth/lib/ /usr/src/app/lib
COPY ./auth/package.json /usr/src/app
COPY ./auth/package-lock.json /usr/src/app

# Install app dependencies
RUN npm install

COPY ./docker/auth/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
