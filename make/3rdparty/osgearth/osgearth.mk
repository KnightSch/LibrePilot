################################
# Targets to build osg and osgearth
#
################################
#
# $ make all_osg
#
# This will:
# - clone the git repositories into the ./3rdparty directory
# - build osg in the build/3rdparty directory
# - intall osg in the build/3rdparty/install directory
# - create distribution files (tar.gz and md5) in the build/3rdparty/install directory
# - [TODO] upload distribution files to the librepilot tools repository
#
################################

# [TODO] should be discovered
QT_VERSION := 5.5.1

################################
#
# common stuff
#
################################

OSG_BUILD_CONF := Release

OSG_NAME_PREFIX :=
OSG_NAME_SUFIX := -qt-$(QT_VERSION)

################################
#
# osg
#
################################

#OSG_VERSION     := 0b63c8ffde
#OSG_GIT_BRANCH  := $(OSG_VERSION)
#OSG_VERSION     := 3.4.0-rc5
#OSG_GIT_BRANCH  := tags/OpenSceneGraph-$(OSG_VERSION)
OSG_VERSION     := 3.4
OSG_GIT_BRANCH  := OpenSceneGraph-$(OSG_VERSION)

OSG_BASE_NAME   := osg-$(OSG_VERSION)

ifeq ($(UNAME), Linux)
	ifeq ($(ARCH), x86_64)
		OSG_NAME := $(OSG_BASE_NAME)-linux-x64
	else
		OSG_NAME := $(OSG_BASE_NAME)-linux-x86
	endif
	OSG_CMAKE_GENERATOR := "Unix Makefiles"
	OSG_CMAKE_MAKE_PROGRAM := make
	OSG_WINDOWING_SYSTEM := "X11"
	# for some reason Qt is not added to the path in make/tools.mk
	OSG_BUILD_PATH := $(QT_SDK_PREFIX)/bin:$(PATH)
else ifeq ($(UNAME), Darwin)
	OSG_NAME := $(OSG_BASE_NAME)-clang_64
	OSG_CMAKE_GENERATOR := "Unix Makefiles"
	OSG_CMAKE_MAKE_PROGRAM := make
	OSG_WINDOWING_SYSTEM := "Cocoa"
	OSG_BUILD_PATH := $(QT_SDK_PREFIX)/bin:$(PATH)
else ifeq ($(UNAME), Windows)
	OSG_NAME := $(OSG_BASE_NAME)-$(QT_SDK_ARCH)
	OSG_CMAKE_GENERATOR := "MinGW Makefiles"
	OSG_CMAKE_MAKE_PROGRAM := /mingw32/bin/mingw32-make
endif

OSG_NAME        := $(OSG_NAME_PREFIX)$(OSG_NAME)$(OSG_NAME_SUFIX)
OSG_SRC_DIR     := $(ROOT_DIR)/3rdparty/osg
OSG_BUILD_DIR   := $(BUILD_DIR)/3rdparty/$(OSG_NAME)
OSG_INSTALL_DIR := $(BUILD_DIR)/3rdparty/install/$(OSG_NAME)
OSG_PATCH_FILE  := $(ROOT_DIR)/make/3rdparty/osgearth/osg-$(OSG_VERSION).patch

.PHONY: osg
osg:
	@$(ECHO) "Building osg $(call toprel, $(OSG_SRC_DIR)) into $(call toprel, $(OSG_BUILD_DIR))"
	$(V1) $(MKDIR) -p $(OSG_BUILD_DIR)
	$(V1) ( $(CD) $(OSG_BUILD_DIR) && \
		if [ -n "$(OSG_BUILD_PATH)" ]; then \
			PATH=$(OSG_BUILD_PATH) ; \
		fi ; \
		$(CMAKE) -G $(OSG_CMAKE_GENERATOR) -DCMAKE_BUILD_TYPE=$(OSG_BUILD_CONF) \
			-DCMAKE_MAKE_PROGRAM=$(OSG_CMAKE_MAKE_PROGRAM) \
			-DOSG_USE_QT=ON \
			-DBUILD_OSG_APPLICATIONS=ON \
			-DBUILD_OSG_EXAMPLES=OFF \
			-DBUILD_OPENTHREADS_WITH_QT=OFF \
			-DOSG_GL3_AVAILABLE=OFF \
			-DOSG_PLUGIN_SEARCH_INSTALL_DIR_FOR_PLUGINS=OFF \
			-DCMAKE_OSX_ARCHITECTURES="x86_64" \
			-DOSG_WINDOWING_SYSTEM=$(OSG_WINDOWING_SYSTEM) \
			-DCMAKE_INSTALL_NAME_DIR=@executable_path/../Plugins \
			-DCMAKE_INSTALL_PREFIX=$(OSG_INSTALL_DIR) $(OSG_SRC_DIR) && \
		$(MAKE) && \
		$(MAKE) install ; \
	)

.PHONY: package_osg
package_osg:
	@$(ECHO) "Packaging $(call toprel, $(OSG_INSTALL_DIR)) into $(notdir $(OSG_INSTALL_DIR)).tar"
	#$(V1) $(CP) $(ROOT_DIR)/make/3rdparty/osgearth/LibrePilotReadme.txt $(OSG_INSTALL_DIR)/
	$(V1) ( \
		$(CD) $(OSG_INSTALL_DIR)/.. && \
		$(TAR) cf $(notdir $(OSG_INSTALL_DIR)).tar $(notdir $(OSG_INSTALL_DIR)) && \
		$(ZIP) -f $(notdir $(OSG_INSTALL_DIR)).tar && \
		$(call MD5_GEN_TEMPLATE,$(notdir $(OSG_INSTALL_DIR)).tar.gz) ; \
	)

.PHONY: install_win_osg
install_win_osg:
	# curl
	$(V1) $(CP) /mingw32/bin/libcurl-4.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libidn-11.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/librtmp-1.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libgmp-10.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libgnutls-30.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libp11-kit-0.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libffi-6.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libtasn1-6.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libhogweed-4-1.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libnettle-6-1.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libssh2-1.dll $(OSG_INSTALL_DIR)/bin/
    # gdal
	$(V1) $(CP) /mingw32/bin/libgdal-20.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libgeos_c.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libgeos.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libjpeg-8.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libtiff-5.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/liblzma-5.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libiconv-2.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/zlib1.dll $(OSG_INSTALL_DIR)/bin/
    # other
	$(V1) $(CP) /mingw32/bin/libproj-9.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libfreetype-6.dll $(OSG_INSTALL_DIR)/bin/
	$(V1) $(CP) /mingw32/bin/libpng16-16.dll $(OSG_INSTALL_DIR)/bin/

.NOTPARALLEL:
.PHONY: prepare_osg
prepare_osg: clone_osg

.PHONY: clone_osg
clone_osg:
	$(V1) if [ ! -d "$(OSG_SRC_DIR)" ]; then \
		$(ECHO) "Cloning osg..." ; \
		$(GIT) clone --no-checkout git://github.com/openscenegraph/osg.git $(OSG_SRC_DIR) ; \
	fi
	@$(ECHO) "Fetching osg..."
	$(V1) ( $(CD) $(OSG_SRC_DIR) && $(GIT) fetch ; )
	@$(ECHO) "Checking out osg $(OSG_GIT_BRANCH)"
	$(V1) ( $(CD) $(OSG_SRC_DIR) && $(GIT) fetch --tags ; )
	$(V1) ( $(CD) $(OSG_SRC_DIR) && $(GIT) checkout --quiet --force $(OSG_GIT_BRANCH) ; )
	$(V1) if [ -e $(OSG_PATCH_FILE) ]; then \
		$(ECHO) "Patching osg..." ; \
		( $(CD) $(OSG_SRC_DIR) && $(GIT) apply $(OSG_PATCH_FILE) ; ) \
	fi

.PHONY: clean_osg
clean_osg:
	@$(ECHO) $(MSG_CLEANING) $(call toprel, $(OSG_BUILD_DIR))
	$(V1) [ ! -d "$(OSG_BUILD_DIR)" ] || $(RM) -r "$(OSG_BUILD_DIR)"
	@$(ECHO) $(MSG_CLEANING) $(call toprel, $(OSG_INSTALL_DIR))
	$(V1) [ ! -d "$(OSG_INSTALL_DIR)" ] || $(RM) -r "$(OSG_INSTALL_DIR)"

.PHONY: clean_all_osg
clean_all_osg: clean_osg
	@$(ECHO) $(MSG_CLEANING) $(call toprel, $(OSG_SRC_DIR))
	$(V1) [ ! -d "$(OSG_SRC_DIR)" ] || $(RM) -r "$(OSG_SRC_DIR)"


################################
#
# osgearth
#
################################
# TODO
# fix Debug build
# add option to not build the applications (in Debug mode in particular)

#OSGEARTH_VERSION     := 1873b3a9489
#OSGEARTH_GIT_BRANCH  := $(OSGEARTH_VERSION)
OSGEARTH_VERSION     := 2.7
OSGEARTH_GIT_BRANCH  := osgearth-$(OSGEARTH_VERSION)

OSGEARTH_BASE_NAME   := osgearth-$(OSGEARTH_VERSION)
OSGEARTH_BUILD_CONF  := $(OSG_BUILD_CONF)

# osgearth cmake script calls the osgversion executable to find the osg version
# this makes it necessary to have osg in the pathes (bin and lib) to make sure the correct one is found
# ideally this should not be necessary
ifeq ($(UNAME), Linux)
	ifeq ($(ARCH), x86_64)
		OSGEARTH_NAME := $(OSGEARTH_BASE_NAME)-linux-x64
	else
		OSGEARTH_NAME := $(OSGEARTH_BASE_NAME)-linux-x86
	endif
	OSGEARTH_CMAKE_GENERATOR := "Unix Makefiles"
	OSGEARTH_CMAKE_MAKE_PROGRAM := make
	# for some reason Qt is not added to the path in make/tools.mk
	OSGEARTH_BUILD_PATH := $(QT_SDK_PREFIX)/bin:$(OSG_INSTALL_DIR)/bin:$(PATH)
	ifeq ($(ARCH), x86_64)
		OSGEARTH_LIB_PATH := $(OSG_INSTALL_DIR)/lib64
	else
		OSGEARTH_LIB_PATH := $(OSG_INSTALL_DIR)/lib
	endif
else ifeq ($(UNAME), Darwin)
	OSGEARTH_NAME := $(OSGEARTH_BASE_NAME)-clang_64
	OSGEARTH_CMAKE_GENERATOR := "Unix Makefiles"
	OSGEARTH_CMAKE_MAKE_PROGRAM := make
	OSGEARTH_BUILD_PATH := $(QT_SDK_PREFIX)/bin:$(OSG_INSTALL_DIR)/bin:$(PATH)
	OSGEARTH_LIB_PATH := $(OSG_INSTALL_DIR)/lib
else ifeq ($(UNAME), Windows)
	OSGEARTH_NAME := $(OSGEARTH_BASE_NAME)-$(QT_SDK_ARCH)
	OSGEARTH_CMAKE_GENERATOR := "MinGW Makefiles"
	OSGEARTH_CMAKE_MAKE_PROGRAM := /mingw32/bin/mingw32-make
	OSGEARTH_LIB_PATH := $(OSG_INSTALL_DIR)/lib
endif

OSGEARTH_NAME        := $(OSG_NAME_PREFIX)$(OSGEARTH_NAME)$(OSG_NAME_SUFIX)
OSGEARTH_SRC_DIR     := $(ROOT_DIR)/3rdparty/osgearth
OSGEARTH_BUILD_DIR   := $(BUILD_DIR)/3rdparty/$(OSGEARTH_NAME)
OSGEARTH_INSTALL_DIR := $(BUILD_DIR)/3rdparty/install/$(OSGEARTH_NAME)
OSGEARTH_PATCH_FILE  := $(ROOT_DIR)/make/3rdparty/osgearth/osgearth-$(OSGEARTH_VERSION).patch

.PHONY: osgearth
osgearth:
	@$(ECHO) "Building osgEarth $(call toprel, $(OSGEARTH_SRC_DIR)) into $(call toprel, $(OSGEARTH_BUILD_DIR))"
	$(V1) $(MKDIR) -p $(OSGEARTH_BUILD_DIR)
	$(V1) ( $(CD) $(OSGEARTH_BUILD_DIR) && \
		if [ -n "$(OSGEARTH_BUILD_PATH)" ]; then \
			PATH=$(OSGEARTH_BUILD_PATH) ; \
		fi ; \
		LD_LIBRARY_PATH=$(OSGEARTH_LIB_PATH) && \
		export DYLD_LIBRARY_PATH=$(OSGEARTH_LIB_PATH) && \
		unset OSG_NOTIFY_LEVEL && \
		$(CMAKE) -G $(OSGEARTH_CMAKE_GENERATOR) -DCMAKE_BUILD_TYPE=$(OSGEARTH_BUILD_CONF) \
			-DCMAKE_MAKE_PROGRAM=$(OSGEARTH_CMAKE_MAKE_PROGRAM) \
			-DOSGEARTH_USE_QT=ON \
			-DINSTALL_TO_OSG_DIR=OFF \
			-DOSG_DIR=$(OSG_INSTALL_DIR) \
			-DCMAKE_INCLUDE_PATH=$(OSG_INSTALL_DIR)/include \
			-DCMAKE_LIBRARY_PATH=$(OSGEARTH_LIB_PATH) \
			-DCMAKE_PREFIX_PATH=$(OSGEARTH_LIB_PATH) \
			-DCMAKE_OSX_ARCHITECTURES="x86_64" \
			-DCMAKE_INSTALL_NAME_DIR=@executable_path/../Plugins \
			-DCMAKE_INSTALL_PREFIX=$(OSGEARTH_INSTALL_DIR) $(OSGEARTH_SRC_DIR) && \
		$(MAKE) && \
		$(MAKE) install ; \
	)

.PHONY: package_osgearth
package_osgearth:
	@$(ECHO) "Packaging $(call toprel, $(OSGEARTH_INSTALL_DIR)) into $(notdir $(OSGEARTH_INSTALL_DIR)).tar"
	$(V1) ( \
		$(CD) $(OSGEARTH_INSTALL_DIR)/.. && \
		$(TAR) cf $(notdir $(OSGEARTH_INSTALL_DIR)).tar $(notdir $(OSGEARTH_INSTALL_DIR)) && \
		$(ZIP) -f $(notdir $(OSGEARTH_INSTALL_DIR)).tar && \
		$(call MD5_GEN_TEMPLATE,$(notdir $(OSGEARTH_INSTALL_DIR)).tar.gz) ; \
	)

.NOTPARALLEL:
.PHONY: prepare_osgearth
prepare_osgearth: clone_osgearth

.PHONY: clone_osgearth
clone_osgearth:
	$(V1) if [ ! -d "$(OSGEARTH_SRC_DIR)" ]; then \
		$(ECHO) "Cloning osgearth..." ; \
		$(GIT) clone --no-checkout git://github.com/gwaldron/osgearth.git $(OSGEARTH_SRC_DIR) ; \
	fi
	@$(ECHO) "Fetching osgearth..."
	$(V1) ( $(CD) $(OSGEARTH_SRC_DIR) && $(GIT) fetch ; )
	@$(ECHO) "Checking out osgearth $(OSGEARTH_GIT_BRANCH)"
	$(V1) ( $(CD) $(OSGEARTH_SRC_DIR) && $(GIT) fetch --tags ; )
	$(V1) ( $(CD) $(OSGEARTH_SRC_DIR) && $(GIT) checkout --quiet --force $(OSGEARTH_GIT_BRANCH) ; )
	$(V1) if [ -f "$(OSGEARTH_PATCH_FILE)" ]; then \
		$(ECHO) "Patching osgearth..." ; \
		( $(CD) $(OSGEARTH_SRC_DIR) && $(GIT) apply $(OSGEARTH_PATCH_FILE) ; ) \
	fi

.PHONY: clean_osgearth
clean_osgearth:
	@$(ECHO) $(MSG_CLEANING) $(call toprel, $(OSGEARTH_BUILD_DIR))
	$(V1) [ ! -d "$(OSGEARTH_BUILD_DIR)" ] || $(RM) -r "$(OSGEARTH_BUILD_DIR)"
	@$(ECHO) $(MSG_CLEANING) $(call toprel, $(OSGEARTH_INSTALL_DIR))
	$(V1) [ ! -d "$(OSGEARTH_INSTALL_DIR)" ] || $(RM) -r "$(OSGEARTH_INSTALL_DIR)"

.PHONY: clean_all_osgearth
clean_all_osgearth: clean_osgearth
	@$(ECHO) $(MSG_CLEANING) $(call toprel, $(OSGEARTH_SRC_DIR))
	$(V1) [ ! -d "$(OSGEARTH_SRC_DIR)" ] || $(RM) -r "$(OSGEARTH_SRC_DIR)"

################################
#
# all
#
################################

.NOTPARALLEL:
.PHONY: all_osg

ifeq ($(UNAME), Windows)
all_osg: prepare_osg prepare_osgearth osg osgearth install_win_osg package_osg package_osgearth
else
all_osg: prepare_osg prepare_osgearth osg osgearth package_osg package_osgearth
endif
