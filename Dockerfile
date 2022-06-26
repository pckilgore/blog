FROM ocaml/opam:alpine as build

# Install system dependencies
RUN sudo apk add --update libev-dev openssl-dev sqlite-dev

WORKDIR /home/opam

# Install dependencies
ADD blog.opam .
RUN opam install --deps-only --with-test .

# Build project
ADD . .
RUN opam exec -- dune build


## Runtime
FROM alpine:3.12 as run

RUN apk add --update libev curl

COPY --from=build /home/opam/_build/default/app.exe /bin/app
HEALTHCHECK --start-period=5s CMD curl --fail http://localhost:8080/health/check || exit 1

ENTRYPOINT /bin/app
