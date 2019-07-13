# Recursive wildcard function (from: https://stackoverflow.com/a/18258352)
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

# Configuration variables for the pack
VERSION := 0.1.0
GAMEUID := ULJS00244
PREFIX := ${HOME}/.config/ppsspp/PSP/TEXTURES/${GAMEUID}
SRCDIR := src
BLDDIR := build
DSTDIR := dist

# Source files.
SVG := $(patsubst ${SRCDIR}/svg/%.svg, ${BLDDIR}/%.png, $(call rwildcard, ${SRCDIR}/svg, *.svg))
XCF := $(patsubst ${SRCDIR}/xcf/%.xcf, ${BLDDIR}/%.png, $(call rwildcard, ${SRCDIR}/xcf, *.xcf))
INI := ${BLDDIR}/textures.ini
MD  := ${BLDDIR}/README.md ${BLDDIR}/COPYING.md ${BLDDIR}/CHANGELOG.md
ZIP := ${GAMEUID}-v${VERSION}.zip

# Build all files.
.PHONY: all
all: $(XCF) $(SVG) $(INI)

.PHONY: clean
clean:
	@rm -rf ${BLDDIR}

.PHONY: distclean
distclean:
	@rm -rf ${BLDDIR} ${DSTDIR}

.PHONY: deploy
deploy: all
	@tar c -C ${BLDDIR} .  | tar xv -C ${PREFIX}

.PHONY: dist
dist: ${DSTDIR}/${ZIP}

${BLDDIR}/%.md: %.md
	@mkdir -p $$(dirname $@)
	@cp $< $@

${BLDDIR}/textures.ini: ${SRCDIR}/textures.ini
	@mkdir -p $$(dirname $@)
	@cp $< $@

${BLDDIR}/%.png: ${SRCDIR}/svg/%.svg
	@mkdir -p $$(dirname $@)
	inkscape $< --export-png $@

${BLDDIR}/%.png: ${SRCDIR}/xcf/%.xcf
	@mkdir -p $$(dirname $@)
	magick $< -background transparent -flatten $@

${DSTDIR}/${ZIP}: $(XCF) $(SVG) $(INI) $(MD)
	@cd ${BLDDIR} && zip -r ${ZIP} $(patsubst ${BLDDIR}/%, %, $^)
	@mkdir -p $$(dirname $@)
	@mv ${BLDDIR}/${ZIP} ${DSTDIR}/${ZIP}
