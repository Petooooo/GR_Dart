FROM node:lts-slim
WORKDIR /app
COPY databaseserver.js .
COPY package.json .
COPY env.json .
RUN npm install
EXPOSE 8081
CMD ["node", "databaseserver.js"]