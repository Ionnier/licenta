FROM node:alpine
WORKDIR /app/
COPY package.json .
RUN npm install
COPY . .
RUN npm run autogen
CMD ["npx", "ts-node", "./index.ts"]