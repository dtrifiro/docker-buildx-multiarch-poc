FROM --platform=$BUILDPLATFORM alpine:3.19 AS base

RUN apk add --no-cache musl-dev gcc

WORKDIR /app

COPY hello.c .

# Build for the target platform
FROM base AS builder
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "Building on $BUILDPLATFORM for $TARGETPLATFORM"

RUN gcc -static -o hello hello.c

# Final minimal image
FROM scratch AS final
COPY --from=builder /app/hello /hello
ENTRYPOINT ["/hello"]
