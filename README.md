
# pptx2md AppImage

An AppImage wrapping a known-working version of [pptx2md](https://github.com/ssine/pptx2md).

## details

A Python AppImage is used as a source, and munged a bit to get a working pptx2md appimage.

See HACKING.md for more details.

## build prerequisites

You'll need GNU Make, the `install` app, and `curl`.

## building

Run `make all`. Any necessary tools will be downloaded as part of the build, and the appimage
will be created as `pptx2md-2.0.6-x86_64.AppImage`.

## why?

Because I only need to use pptx2md very occasionally, and want a version that's known to work, doesn't
rely on the version of Python (or Python packages) I have on whatever development box I'm using, and is
easy to use.

## why not "freeze" pptx2md?

I probably could, but I find the various "freezing" tools a pain to work with. 


