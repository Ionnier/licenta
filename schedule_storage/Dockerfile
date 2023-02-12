FROM node:alpine
WORKDIR /app/
COPY package.json .
RUN npm install
COPY . .
RUN npm run autogen
EXPOSE 3000
CMD ["npx", "ts-node", "./index.ts"]