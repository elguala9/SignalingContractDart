FROM node:18-alpine

WORKDIR /app

# Installa dipendenze di build (python/make/g++ per moduli nativi)
RUN apk add --no-cache python3 make g++

COPY package.json package-lock.json ./
RUN npm install

COPY . .

# Crea la directory TypeChain richiesta da hardhat.config.ts
RUN mkdir -p ../signaling-sdk/src/typeschain

# Compila i contratti
RUN npx hardhat compile

# Copia entrypoint script
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Deploy sul network ganache (configurabile via env)
ENTRYPOINT ["./entrypoint.sh"]
