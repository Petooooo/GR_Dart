FROM node:lts-slim
WORKDIR /app
COPY facadeserver.js .
COPY package.json .
COPY env.json .
RUN npm install
EXPOSE 8080
CMD ["node", "facadeserver.js"]