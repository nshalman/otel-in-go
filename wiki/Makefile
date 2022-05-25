traced.go: final.go trace.patch
	cp final.go $@
	patch $@ trace.patch

run: sources
run: final.go
	go run $<

run-traced: sources
run-traced: traced.go
	go run $<

sources: final.go edit.html view.html
final.go edit.html view.html:
	curl -o $@ -L "https://raw.githubusercontent.com/golang/website/0473aa5/_content/doc/articles/wiki/$@"
