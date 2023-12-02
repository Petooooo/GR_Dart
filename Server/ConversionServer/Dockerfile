FROM node:lts-slim
WORKDIR /app
COPY conversionserver.js .
COPY package.json .
COPY env.json .
RUN npm install
EXPOSE 8082
CMD ["node", "conversionserver.js"]