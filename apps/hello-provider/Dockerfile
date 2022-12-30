FROM node:lts-alpine
WORKDIR /app
COPY ./dist/apps/hello-provider .
COPY package.json package-lock.json ./

ENV PORT=3333

EXPOSE ${PORT}

RUN npm ci

# dependencies that express needs
CMD node ./main.js