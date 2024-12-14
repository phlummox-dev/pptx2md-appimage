# variables

PYTHON_APPIMAGE = python3.10.16-cp310-cp310-manylinux2014_x86_64.AppImage
PYTHON_APPIMAGE_URL = https://github.com/niess/python-appimage/releases/download/python3.10/$(PYTHON_APPIMAGE)
SQUASHFS_DIR = ./squashfs-root
APPIMAGE_TOOL_APPIMAGE = appimagetool-x86_64.AppImage
APPIMAGE_TOOL_APPIMAGE_URL = https://github.com/AppImage/AppImageKit/releases/download/continuous/$(APPIMAGE_TOOL_APPIMAGE)

TARGET = pptx2md-2.0.6-x86_64.AppImage

# recipes

all: $(TARGET)

# download python appimage if needed
$(PYTHON_APPIMAGE):
	curl -LO $(PYTHON_APPIMAGE_URL)
	chmod +x $(PYTHON_APPIMAGE)

# download appimage tool if needed
$(APPIMAGE_TOOL_APPIMAGE):
	curl -LO $(APPIMAGE_TOOL_APPIMAGE_URL)
	chmod +x $(APPIMAGE_TOOL_APPIMAGE)

# extract squashfs dir
$(SQUASHFS_DIR): $(PYTHON_APPIMAGE)
	./$(PYTHON_APPIMAGE) --appimage-extract

$(TARGET): $(SQUASHFS_DIR) $(APPIMAGE_TOOL_APPIMAGE)
	# install pptx2md under ./squashfs-root/opt/python3.10/lib/python3.10/site-packages
	$(SQUASHFS_DIR)/opt/python3.10/bin/python3.10 -m pip install 'pptx2md==2.0.6'

	# edit the AppRun file to call pptx2md
	sed -i 's/^\# Call Python.*/\# Invoke pptx2md/' $(SQUASHFS_DIR)/AppRun
	sed -i '\|APPDIR/opt/python3.10/bin/python3.10| s|bin/python3.10|bin/pptx2md|' $(SQUASHFS_DIR)/AppRun

	# remove old python .desktop, .png, .DirIcon, metainfo files
	rm -rf $(SQUASHFS_DIR)/python* $(SQUASHFS_DIR)/.DirIcon
	rm -rf $(SQUASHFS_DIR)/usr/share/metainfo/python*

	# install new icon, desktop etc. files
	
	# icon
	install -d $(SQUASHFS_DIR)/usr/share/icons
	install -m 0755 resources/pptx2md.png $(SQUASHFS_DIR)/usr/share/icons
	
	# .desktop
	install -d $(SQUASHFS_DIR)/usr/share/applications
	install -m 0755 resources/pptx2md.desktop $(SQUASHFS_DIR)/usr/share/applications
	
	# metainfo file
	install -d $(SQUASHFS_DIR)/usr/share/metainfo
	install -m 0755 resources/pptx2md.appdata.xml $(SQUASHFS_DIR)/usr/share/metainfo

	# create symlinks
	ln -s -r $(SQUASHFS_DIR)/pptx2md.png $(SQUASHFS_DIR)/.DirIcon
	ln -s -r $(SQUASHFS_DIR)/usr/share/applications/pptx2md.desktop $(SQUASHFS_DIR)/
	ln -s -r $(SQUASHFS_DIR)/usr/share/icons/pptx2md.png $(SQUASHFS_DIR)/

	# build AppImage file
	./$(APPIMAGE_TOOL_APPIMAGE) --no-appstream $(SQUASHFS_DIR) $@

clean:
	rm -rf $(APPIMAGE_TOOL_APPIMAGE) $(SQUASHFS_DIR) $(PYTHON_APPIMAGE)	$(TARGET)

.PHONY: all clean
