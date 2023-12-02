FROM node:16.15.1-slim
WORKDIR /app
COPY facadeserver.js .
COPY package.json .
COPY env.json .
RUN npm install
EXPOSE 8080
CMD ["node", "facadeserver.js"]