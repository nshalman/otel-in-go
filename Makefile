default: collector browser
	@echo Try running "make run-wiki" or "make run-grpc"

collector:
	docker compose up -d

browser:
	open http://localhost:16686/

run-wiki: collector
	(sleep 3; open http://localhost:8080/view/ANewPage)&
	$(MAKE) -C wiki run-traced

run-grpc:
	$(MAKE) -C grpc

clean:
	git clean -fdx
