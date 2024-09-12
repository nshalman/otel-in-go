default: collector

collector:
	mkdir -p logs
	chmod 777 logs
	docker compose up -d --build

browser:
	open http://localhost:16686/
