# Recursive wildcard function (from: https://stackoverflow.com/a/18258352)
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

# Source files
SVG := $(patsubst src/svg/%.svg, build/%.png, $(call rwildcard, src/svg, *.svg))
XCF := $(patsubst src/xcf/%.xcf, build/%.png, $(call rwildcard, src/xcf, *.xcf))

# Build all files
.PHONY: all
all: $(XCF) $(SVG)

.PHONY: clean
clean:
	@rm -rf build
	

build/%.png: src/svg/%.svg
	@mkdir -p $$(dirname $@)
	inkscape $< --export-png $@

build/%.png: src/xcf/%.xcf
	@mkdir -p $$(dirname $@)
	convert $< -flatten -transparent white $@