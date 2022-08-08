FROM node:16-alpine AS node
FROM ocaml/opam:alpine as build

# Grab Node & Friends
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# Install system dependencies
RUN sudo apk add --update \
  libev-dev \
  openssl-dev \
  sqlite-dev \
  zlib-dev \
  gmp-dev \
  linux-headers

WORKDIR /home/opam

# Install dependencies
ADD blog.opam .
RUN opam install --deps-only --with-test .
RUN sudo npm install yarn --force --location=global 

# Build project
ADD . .
RUN opam exec -- dune build @css
RUN opam exec -- dune build --profile=release -j 4

ADD https://github.com/benbjohnson/litestream/releases/download/v0.3.8/litestream-v0.3.8-linux-amd64-static.tar.gz /litestream.tar.gz
USER root
RUN ls -l / && chmod 0755 /litestream.tar.gz
RUN tar -C /bin -xzf /litestream.tar.gz


## Runtime
FROM alpine:3.12 as run

RUN apk add --update \
  bash \
  libev-dev \
  openssl-dev \
  sqlite-dev \
  zlib-dev \
  gmp-dev \
  linux-headers

COPY --from=build /home/opam/posts /posts
COPY --from=build /home/opam/style.build.css /style.build.css
COPY --from=build /home/opam/_build/default/app.exe /bin/app
COPY --from=build /home/opam/entrypoint.sh /bin/entrypoint.sh
COPY --from=build /home/opam/litestream.yml /etc/litestream.yml
COPY --from=build /bin/litestream /bin/litestream

CMD ["bash", "/bin/entrypoint.sh"]
