NAME=ctop
VERSION=$(shell cat VERSION)
BUILD=$(shell git rev-parse --short HEAD)
LD_FLAGS="-w -X main.version=$(VERSION) -X main.build=$(BUILD)"

clean:
	rm -rf build/ release/

build:
	glide install
	CGO_ENABLED=0 go build -tags release -ldflags $(LD_FLAGS) -o ctop

build-dev:
	go build -ldflags "-w -X main.version=$(VERSION)-dev -X main.build=$(BUILD)"

build-all:
	mkdir -p build
	GOOS=darwin GOARCH=amd64 go build -tags release -ldflags $(LD_FLAGS) -o build/ctop-$(VERSION)-darwin-amd64
	GOOS=linux GOARCH=amd64 go build -tags release -ldflags $(LD_FLAGS) -o build/ctop-$(VERSION)-linux-amd64
	GOOS=linux GOARCH=arm go build -tags release -ldflags $(LD_FLAGS) -o build/ctop-$(VERSION)-linux-arm

image:
	docker build -t ctop_build -f Dockerfile_build .
	docker run -ti --rm -v $(shell pwd):/target ctop_build cp -v /go/bin/ctop /target/
	docker build -t ctop -f Dockerfile .

release:
	mkdir release
	go get github.com/progrium/gh-release/...
	cp build/* release
	gh-release create bcicen/$(NAME) $(VERSION) \
		$(shell git rev-parse --abbrev-ref HEAD) $(VERSION)

.PHONY: build
