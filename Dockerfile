FROM golang:alpine as builder

COPY . /code
WORKDIR /code
RUN go mod init
# Run unit tests
RUN go test

# Build app
RUN go build -o sample-app

FROM alpine

COPY --from=builder /code/sample-app /sample-app
CMD /sample-app
