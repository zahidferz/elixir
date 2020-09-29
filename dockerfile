FROM elevacontainerregistry.azurecr.io/elixir as builder
COPY . .
RUN npm install --prefix ./assets
RUN npm run deploy --prefix ./assets