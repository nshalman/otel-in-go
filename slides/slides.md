title: OpenTelemetry In Golang
class: center

# OpenTelemetry In Golang

![OpenTelemetry](https://opentelemetry.io/img/logos/opentelemetry-horizontal-color.svg)
![Golang](https://go.dev/images/go-logo-blue.svg)

.footnote[Presentation powered by [remark](https://github.com/gnab/remark)]

---
class: center

# OpenTelemetry All The Things

![All The Things](https://c.tenor.com/wSGnuU9TOFgAAAAC/all-the-things-hyperbole-and-a-half.gif)

???

Part of the ongoing process of adding OpenTelemetry to all of our software so that our mental models can more closely resemble the complex system we are building.

See [Taking Human Performance Seriously: "Above The Line"
](https://www.youtube.com/watch?v=8bxj-FLEi10) by [John Allspaw](https://twitter.com/allspaw)

(via https://twitter.com/allspaw/status/1389719728839659522)

---

# Agenda

1. Setting up my sandbox
 1. Jaeger
 1. Honeycomb
1. Adding tracing to HTTP services
 1. Tracing the example Wiki
 1. Gin middleware
 1. Tracing the HTTP Client
1. Adding tracing to GRPC services
 1. Tracing an example GRPC service
1. Adding custom attributes
 1. Tracing examples in Tinkerbell services
1. otel-init-go: How the magic is done

---

# Setting up my sandbox

This repo uses [direnv](https://direnv.net/).

`.direnv` looks like this:
```shell
# read in the content of .env too
dotenv_if_exists

# https://github.com/equinix-labs/otel-init-go#configuration
export OTEL_EXPORTER_OTLP_ENDPOINT=localhost:4317
export OTEL_EXPORTER_OTLP_INSECURE=true
```

`.env` is like this (but populated):
```shell
HONEYCOMB_TEAM=
HONEYCOMB_DATASET=
HONEYCOMB_COMPANY=
```

Bring up the exporter and Jaeger
```console
docker compose up -d
```

???

Why environment variables? That's how we configure things in Kubernetes.

---

# Setting up my sandbox

## Jaeger

[Jaeger](https://www.jaegertracing.io/docs/1.34/#about), inspired by Dapper and OpenZipkin, is a distributed tracing system released as open source by Uber Technologies.
Jaeger, Dapper, and OpenZipkin all predate OpenTelemetry.

## Honeycomb

[Honeycomb](https://www.honeycomb.io/) is a SaaS Vendor, also predates OpenTelemetry, and is where we (Equinix) send our production traces.

## Why run the collector at all?

[See Shelby's Blog Post](https://metal.equinix.com/blog/opentelemetry-whats-a-collector-and-why-would-i-want-one/)

---

# Adding tracing to HTTP services
## Tracing the example Wiki

Take the [Example Wiki](https://go.dev/doc/articles/wiki/)

- Add otel-init-go
- otelinit.InitOpenTelemetry
- otelhttp.NewHandler

[Yes, it really is that simple](https://github.com/nshalman/otel-in-go/blob/main/wiki/trace.patch)

---

# Adding tracing to HTTP services
##  Gin middleware


- [Gin Middleware](https://github.com/open-telemetry/opentelemetry-go-contrib/blob/main/instrumentation/github.com/gin-gonic/gin/otelgin/gintrace.go)
- [Private URL](https://github.com/equinixmetal/archetype-service/blob/b6f1fa7/internal/httpsrv/server.go#L92)

Basically:

```go
r := gin.New()
// Stuff
tp := otel.GetTracerProvider()
// More stuff
r.Use(otelgin.Middleware(hostname, otelgin.WithTracerProvider(tp)))
```

.footnote[(Apologies to the general public that some of these examples are closed source...)]

---

# Adding tracing to HTTP services
## Tracing the HTTP Client

- [Private URL](https://github.com/equinixmetal/tank/commit/c371dac991343c03d5faaa69214b4c0c5fd9c505)

Basically
```diff
-		httpClient:    http.DefaultClient,
+		httpClient:    otelhttp.DefaultClient,
```

.footnote[(Apologies to the general public that some of these examples are closed source...)]

---
# Adding tracing to GRPC services
## Tracing an example GRPC service

- Add otel-init-go
- otelinit.InitOpenTelemetry
- Add otelgrpc.UnaryClientInterceptor

This works on both [Servers](https://github.com/nshalman/otel-in-go/blob/main/grpc/trace.patch#L68-L72) and [Clients](https://github.com/nshalman/otel-in-go/blob/main/grpc/trace.patch#L16-L28)

---

# Adding custom attributes

Let's trace a cache lookup ([Private URL](https://github.com/equinixmetal/tank/blob/624023d/cache.go#L34-L48)):

Basically:
```go
func (o *cachedDataSource) CacheLookup(ctx context.Context, id string) (Thing, error) {
	span := trace.SpanFromContext(ctx)
	o.rwMu.RLock()
	thing, hasIt := o.cache[id]
	o.rwMu.RUnlock()
	if hasIt {
		span.SetAttributes(attribute.Bool("cache.hit", true))
		return &thing, nil
	}
	span.SetAttributes(attribute.Bool("cache.hit", false))
	// Do the lookup to find the thing.
```

[Private URL](https://github.com/equinixmetal/tank/commit/fb0648ba06229e156d10fe46d9ff74d9bc89a4d9)

.footnote[(Apologies to the general public that some of these examples are closed source...)]

---

# Adding custom attributes
## Tracing examples in Tinkerbell services

PBnJ:
- [Instrument machine.BootDeviceSet](https://github.com/tinkerbell/pbnj/commit/3afb732a96bfa24182bbefe0906e50607784df26#diff-58e9fa0e549a798eb5175bffdc3b82999c98e43ac5ada9340d5b2f93babb117a)
- [Add bmclib client metadata to to OTEL spans](https://github.com/tinkerbell/pbnj/commit/d6f2763384465ed918828d9f0691ec5e89ffc441)

---

# otel-init-go: How the magic is done

- https://github.com/equinix-labs/otel-init-go
- https://github.com/equinix-labs/otel-init-go/blob/d3a4ca4/otelinit/config.go#L24-L39
- https://github.com/equinix-labs/otel-init-go/blob/main/otelinit/public.go#L15-L37
- https://github.com/equinix-labs/otel-init-go/blob/d3a4ca4/otelinit/tracing.go

???

otel-init-go is responsible for parsing our standardized environment variables and wiring up the code to emit traces
