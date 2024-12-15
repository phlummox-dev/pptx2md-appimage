# variables

TARGET = pptx2md-x86_64.AppImage

PYTHON_APPIMAGE = python3.10.16-cp310-cp310-manylinux2014_x86_64.AppImage
PYTHON_APPIMAGE_URL = https://github.com/niess/python-appimage/releases/download/python3.10/$(PYTHON_APPIMAGE)

SHELL = bash

# recipes

all: $(TARGET)

# construct a .tgz of all binary wheels that would've been installed for manylinux2014_x86_64 python 3.10
# would be nice if `python-appimage` could be convinced to do this for us, but there doesn't seem to be
# an obvious way.
# (NB we don't actually _use_ wheels.tgz, except as an artifact on github, since the files we need are all
# in `wheels` anyway ... the tgz is really just a marker that everything completed ok)
wheels.tgz:
	mkdir -p wheels
	docker run --rm -i -v $(PWD):/work --workdir /work quay.io/pypa/manylinux2014_x86_64 \
		sh -c '/opt/python/cp310-cp310/bin/pip3 download pptx2md==2.0.6 --only-binary=:all: -d ./wheels'
	set -e -o pipefail && (cd wheels && find . -type f) | sort | tar -C wheels -cf - --owner=root:0 --group=root:0 --format=ustar -T - --mtime='UTC 1970-01-01 00:00:00'  | gzip --no-name > wheels.tgz


# download python appimage if needed
$(PYTHON_APPIMAGE):
	curl -LO $(PYTHON_APPIMAGE_URL)
	chmod +x $(PYTHON_APPIMAGE)

# assumes we already have `python-appimage` installed,
# e.g. via pip
$(TARGET): wheels.tgz $(PYTHON_APPIMAGE)
	rm -rf ./resources/requirements.txt
	: "construct requirements.txt with exact wheel files specified"
	for file in wheels/*whl; do \
		echo "file://$(PWD)/$$file" >> ./resources/requirements.txt; \
	done
	python-appimage -v build app --base-image $(PYTHON_APPIMAGE) --linux-tag manylinux2014_x86_64 --python-version 3.10 --name pptx2md ./resources
	: "make a copy of the appimage with version in filename"
	cp -a $(TARGET) pptx2md-2.0.6-x86_64.AppImage

clean:
	rm -rf $(TARGET) pptx2md-2.0.6-x86_64.AppImage \
		wheels.tgz wheels resources/requirements.txt

.PHONY: all clean

.DELETE_ON_ERROR:

