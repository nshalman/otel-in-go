FROM otel/opentelemetry-collector:0.38.0
COPY config-honeycomb.yaml /config.yaml
