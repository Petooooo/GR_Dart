FROM node:16.15.1-slim
WORKDIR /app
COPY conversionserver.js .
COPY package.json .
COPY env.json .
RUN npm install
EXPOSE 8082
CMD ["node", "conversionserver.js"]