FROM alpine
RUN apk add --no-cache git && \
  apk add --no-cache curl && \
  apk add --no-cache kubectl
CMD tail -f /dev/null