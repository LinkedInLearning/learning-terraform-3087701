FROM ubuntu:18.04

RUN apt-get update && apt-get install -y curl

COPY app.js /app/app.js

CMD ["echo", "Lab container for Snyk scanning"]
