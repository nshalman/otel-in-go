default: collector

collector:
	docker compose up -d

browser:
	open http://localhost:16686/
	open https://ui.honeycomb.io/${HONEYCOMB_COMPANY?}/datasets/${HONEYCOMB_DATASET?}/home
