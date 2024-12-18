Potentially useful notes if hacking the codebase.

## AppImage rules

what must be in an AppImage?

See <https://github.com/AppImage/AppImageSpec/blob/master/draft.md#contents-of-the-image>

Assuming $APPNAME is the name of the app, there should be the following within the squashfs tree:

- Must be one $APPNAME.desktop file. (It looks like in some appimages, this is a symlink, tho)
- May be one $APPICON.png file, an icon. (Again, looks like sometimes this is made a symlink.
  What exactly $APPICON is, is specified in the desktop file - easiest to make it same as $APPNAME.)
- Must have .DirIcon file. (In all appimages I've seen, this is just a symlink to the .png file)

We are also supposed to have another "metainfo" file:

> An AppImage SHOULD ship AppStream metadata in
> `usr/share/metainfo/$ID.appdata.xml` with $ID being the AppStream ID. Shipping
> AppStream information enables the AppImage to be discoverable in application
> centers and/or application directory websites. If it does, then it MUST
> follow the AppStream guidelines for applications. See examples for such files
> in the debian repository.

There's an interactive form for creating one at <https://www.freedesktop.org/software/appstream/metainfocreator/#/consoleapp>

And we edit the result xml file a bit and put it in `resources/`.

But validating it requires a reverse-dns ID, and I can't be bothered, so we don't
validate it.

See e.g. <https://github.com/arch1t3cht/Aegisub/issues/134>. We'd need to rename pptx2md.desktop
to a reverse-dns equivalent, and rename the appdata.xml similarly, and adjust the `id` (and `provides`?)
fields within the xml file.

## pptx2md.desktop file (in resources)

- format documented at <https://specifications.freedesktop.org/desktop-entry-spec/latest/>
- more info at <https://wiki.archlinux.org/title/Desktop_entries>,
  baeldung <https://www.baeldung.com/linux/desktop-entry-files>

trap for the unwary:

- The "Version" key, if present, is the version of the _desktop file_ specification.
  (Probably 1.0 or 1.5.)
- To specify the version of the app, we want `X-AppImage-Version`

## tasks involved in creating a python appimage from a base

Outlined here in case we ever need to do it ourselves. Currently, `python-appimage`
handles most of these tasks. See commit 0da3741d or earlier for all the details of what we
used to do.

- download a "base" appimage - we use `python3.10.16-cp310-cp310-manylinux2014_x86_64.AppImage`
- extract the squashfs directory from the appimage by invoking it with
  `--appimage-extract`
- invoke `python3.10 -m pip install` to install pptx2md (==2.0.6) and all its
  prerequisites. Ideally, we want them all to be binary wheels, and for all of them to be
  versions that `cp310-manylinux2014_x86` would've picked up.

  pptx2md itself is pure python, so we could theoretically download any binary wheel for
  that and it should work.

- fix the `AppRun` "entry point" so instead of invoking python3.10, it invokes our desired
  script
- remove old python .desktop, .png, .DirIcon, and metainfo XML files
- install our own versions of those files - in e.g. directories like usr/share/icons, with nice symlinks to
  "top-level" versions of those files.
- invoke `appimagetool-x86_64.AppImage` on the squashfs directory, to build a new
  AppImage.

Some comments:

- `appimagetool-x86_64.AppImage`

  This is built "continuously", there are no versions.

  So in the interests of repeatable builds, a copy of the tool was checked into the repo,
  but is deleted from later commits as we now use `python-appimage`.



