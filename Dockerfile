FROM golang:1.13.4-alpine AS build

ENV GOGIT_DIR /go/src/github.com/aibeb/gogit
ENV DOCKER_BUILDTAGS gogit

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN set -ex \
    && apk add --no-cache make git file

WORKDIR $GOGIT_DIR

COPY go.mod $GOGIT_DIR

RUN go mod download

COPY main.go $GOGIT_DIR

RUN go build -o gogit main.go


FROM alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN apk add --no-cache tzdata\
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*

RUN set -ex \
    && apk add --no-cache ca-certificates apache2-utils git

RUN git config --global user.email "gogit@aibeb.com"
RUN git config --global user.name "GoGit"

COPY --from=build /go/src/github.com/aibeb/gogit/gogit /bin/gogit

VOLUME ["/var/lib/gogit"]

EXPOSE 1024

ENTRYPOINT ["gogit"]

CMD [""]