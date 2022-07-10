FROM ocaml/opam:alpine as build

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

# Build project
ADD . .
RUN opam exec -- dune build --profile=release -j 4

## Runtime
FROM alpine:3.12 as run

RUN apk add --update \
  curl \
  libev-dev \
  openssl-dev \
  sqlite-dev \
  zlib-dev \
  gmp-dev \
  linux-headers

COPY --from=build /home/opam/posts /posts
COPY --from=build /home/opam/_build/default/app.exe /bin/app
COPY --from=build /home/opam/public /public
HEALTHCHECK --start-period=5s CMD curl --fail http://localhost:8080/health/check || exit 1

ENTRYPOINT /bin/app
