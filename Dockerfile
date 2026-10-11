FROM node:22-alpine
WORKDIR /app
COPY server/package*.json ./server/
RUN cd server && npm install --omit=dev
COPY client ./client
COPY server/server.js ./server/server.js
ENV NODE_ENV=production
EXPOSE 8080
CMD ["node", "server/server.js"]
