VERSION ?= `git describe --tags 2>/dev/null || git rev-parse --short HEAD`


.PHONY: build release
default:
	@echo $(VERSION)

build:
	@docker build -t imkulikov/pureftpd .
	@docker build -t imkulikov/pureftpd:$(VERSION) .

release:
	@docker push imkulikov/pureftpd
	@docker push imkulikov/pureftpd:$(VERSION)