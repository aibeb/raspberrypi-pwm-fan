FROM arm64v8/golang:1.13-alpine AS build

WORKDIR /go/src/github.com/aibeb/raspberrypi-pwm-fan

COPY go.mod .

RUN go mod download

COPY pwm-fan.go .

RUN go build -o main pwm-fan.go


FROM arm64v8/alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN apk add --no-cache tzdata\
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*

RUN apk add sudo

COPY --from=build /go/src/github.com/aibeb/raspberrypi-pwm-fan/main /app/main

CMD ["/app/main"]