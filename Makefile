PROTO_ROOT=.
DOCKER_IMAGE=proto-builder
GO_MODULE=github.com/GinciuuKitakaze/messenger-contracts

.PHONY: docker-build gen clean

docker-build:
	docker build -t $(DOCKER_IMAGE) .

gen: docker-build
	docker run --rm \
		-v $(abspath $(PROTO_ROOT)):/app \
		$(DOCKER_IMAGE) \
		bash -c '\
		set -e; \
		echo ">> Processing users"; \
		protoc \
			-I /app \
			-I /usr/local/include/googleapis \
			--go_out=/app \
			--go_opt=module=$(GO_MODULE) \
			--go-grpc_out=/app \
			--go-grpc_opt=module=$(GO_MODULE) \
			--grpc-gateway_out=/app \
			--grpc-gateway_opt=module=$(GO_MODULE) \
			--openapiv2_out=/app \
			/app/users/*.proto; \
		echo ">> Processing auth"; \
        protoc \
        	-I /app \
        	-I /usr/local/include/googleapis \
        	--go_out=/app \
        	--go_opt=module=$(GO_MODULE) \
        	--go-grpc_out=/app \
        	--go-grpc_opt=module=$(GO_MODULE) \
        	/app/auth/*.proto; \
		echo ">> Processing pagination"; \
		protoc \
			-I /app \
			-I /usr/local/include/googleapis \
			--go_out=/app \
			--go_opt=module=$(GO_MODULE) \
			/app/pagination/*.proto;'

clean:
	find . -type f \( -name "*.pb.go" -o -name "*.pb.gw.go" -o -name "*.swagger.json" \) -delete