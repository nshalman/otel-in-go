HASH=6e253e8afaa1a8073867fca7563fb468337cb12c

examples: $(HASH).tar.gz deps.patch trace.patch
	rm -rf $@
	tar --strip-components=1 -x -f $< grpc-go-$(HASH)/examples
	patch -p0 < deps.patch
	patch -p0 < trace.patch

$(HASH).tar.gz:
	curl -o $@ -L https://github.com/grpc/grpc-go/archive/$@
