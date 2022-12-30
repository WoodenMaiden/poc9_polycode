FROM node:lts-alpine
WORKDIR /app
COPY ./dist/apps/hello-consumer .
COPY package.json package-lock.json ./

ENV PORT=3000

EXPOSE ${PORT}

RUN npm ci

# dependencies that express needs
CMD node ./main.js