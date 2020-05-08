FROM arm64v8/golang:1.13-alpine AS build

WORKDIR /go/src/github.com/aibeb/raspberrypi-pwm-fan

COPY go.mod .

RUN go mod download

COPY pwm-fan.go .

RUN go build -o main pwm-fan.go


FROM arm64v8/ubuntu

COPY --from=build /go/src/github.com/aibeb/raspberrypi-pwm-fan/main /app/main

RUN sed -i "s/http:\/\/ports.ubuntu.com/http:\/\/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list

CMD ["/app/main"]