
# pptx2md AppImage

An AppImage wrapping a known-working version of [pptx2md](https://github.com/ssine/pptx2md).

This allows us to convert PowerPoint .pptx files to Markdown.

## details

A Python AppImage is used as a source, and munged a bit to get a working pptx2md appimage.

See HACKING.md for more details.

## build prerequisites

You'll need GNU Make, `curl`, and the python package `python-appimage` installed
(install with `python3 -m pip install python-appimage`).

## building

Run `make all`. Any additional tools or artifacts (beyond those specified in
'prerequisites') will be downloaded as part of the build. The appimage will
be created as `pptx2md-2.0.6-x86_64.AppImage`.

## why?

Because I only need to use pptx2md very occasionally, and want a version that's known to work, doesn't
rely on the version of Python (or Python packages) I have on whatever development box I'm using, and is
easy to use.

## why not "freeze" pptx2md?

I probably could, but I find the various "freezing" tools a pain to work with. 

## compatibility

A wheel is built for pptx2md using compatibility tag `manylinux2014_x86_64`.
It should be compatible with Linux distributions that use glibc version 2.17 or higher
(e.g. Ubuntu 18.04 and newer, CentOS 7 and newer).

