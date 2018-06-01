FROM golang:1.10.2
MAINTAINER FOUCHARD Tony <t.fouchard@qwant.com>

ENV COMMIT_HASH ca85fa819caaa3b78ac016fc573bd480a20c0280
RUN apt-get update
RUN apt-get install -qy --no-install-recommends wget git
RUN wget -O - https://glide.sh/get | sh
#RUN chmod +x /bin/glide
RUN [ -d ${GOPATH}/bin ] || mkdir ${GOPATH}/bin
RUN mkdir -p ${GOPATH}/src/github.com/osrg 
WORKDIR /go/src/github.com/osrg
RUN git clone https://github.com/osrg/goplane.git
WORKDIR /go/src/github.com/osrg/goplane
RUN git remote add hightoxicity https://github.com/hightoxicity/goplane.git && git fetch hightoxicity && git checkout ${COMMIT_HASH}
RUN glide install
RUN ls -al ./vendor
RUN CGO_ENABLED=0 GOOS=linux go build -o /bin/goplane -ldflags "-w -s -v -extldflags -static"

FROM alpine:latest
RUN apk update
RUN apk add iptables
RUN rm -rf /var/cache/apk/
RUN rm -rf /var/lib/apk/
RUN rm -rf /var/apk/cache/
COPY --from=0 /bin/goplane /bin/goplane
CMD ["/bin/goplane", "-f", "/config.conf"]
