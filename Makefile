.PHONY: all build clean codesign

all: build codesign

build: out/vfkit

clean:
	rm -rf out

codesign: out/vfkit
	codesign --entitlements vf.entitlements -s - $<

out/vfkit-amd64 out/vfkit-arm64: out/vfkit-%: force-build
	@mkdir -p $(@D)
	CGO_ENABLED=1 GOOS=darwin GOARCH=$* go build -o $@ ./cmd/vfkit

out/vfkit: out/vfkit-amd64 out/vfkit-arm64
	cd $(@D) && lipo -create $(^F) -output $(@F)

# the go compiler is doing a good job at not rebuilding unchanged files
# this phony target ensures out/vfkit-* are always considered out of date
# and rebuilt. If the code was unchanged, go won't rebuild anything so that's
# fast. Forcing the rebuild ensure we rebuild when needed, ie when the source code
# changed, without adding explicit dependencies to the go files/go.mod
.PHONY: force-build
force-build:
