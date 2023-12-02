FROM node:16.15.1-slim
WORKDIR /app
COPY databaseserver.js .
COPY package.json .
COPY env.json .
RUN npm install
EXPOSE 8081
CMD ["node", "databaseserver.js"]