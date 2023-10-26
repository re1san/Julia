## LLVMDialects
# ifneq ($(USE_BINARYBUILDER_LLVMDIALECTS),1)

LLVMDIALECTS_GIT_URL := https://github.com/GPUOpen-Drivers/llvm-dialects.git
LLVMDIALECTS_TAR_URL = https://api.github.com/repos/GPUOpen-Drivers/llvm-dialects/tarball/$1
$(eval $(call git-external,llvmdialects,LLVMDIALECTS,CMakeLists.txt,,$(SRCCACHE)))

ifeq ($(USE_SYSTEM_LLVM), 0)
$(BUILDDIR)/$(LLVMDIALECTS_SRC_DIR)/build-configured: | $(build_prefix)/manifest/llvm
endif

# TODO: We are not shipping `lib/cmake/llvm`
LLVMDIALECTS_OPTS := $(CMAKE_COMMON) -DCMAKE_BUILD_TYPE=Release -DLLVM_ROOT=/home/vchuravy/.julia/artifacts/37aff39f8136bf0e699383f120c151d890207338/lib/cmake/llvm
LLVMDIALECTS_SRC_PATH := $(SRCCACHE)/$(LLVMDIALECTS_SRC_DIR)

$(BUILDDIR)/$(LLVMDIALECTS_SRC_DIR)/build-configured: $(LLVMDIALECTS_SRC_PATH)/source-extracted
	mkdir -p $(dir $@)
	cd $(dir $@) && \
	$(CMAKE) $(dir $<) $(LLVMDIALECTS_OPTS)
	echo 1 > $@

$(BUILDDIR)/$(LLVMDIALECTS_SRC_DIR)/build-compiled: $(BUILDDIR)/$(LLVMDIALECTS_SRC_DIR)/build-configured
	$(MAKE) -C $(dir $<)
	echo 1 > $@

$(BUILDDIR)/$(LLVMDIALECTS_SRC_DIR)/build-checked: $(BUILDDIR)/$(LLVMDIALECTS_SRC_DIR)/build-compiled
ifeq ($(OS),$(BUILD_OS))
	$(MAKE) -C $(dir $@) test
endif
	echo 1 > $@

$(eval $(call staged-install, \
	llvmdialects,$(LLVMDIALECTS_SRC_DIR), \
	MAKE_INSTALL,,, \
	$$(INSTALL_NAME_CMD)llvmdialects.$$(SHLIB_EXT) $$(build_shlibdir)/llvmdialects.$$(SHLIB_EXT)))

clean-llvmdialects:
	-rm -f $(BUILDDIR)/$(LLVMDIALECTS_SRC_DIR)/build-configured $(BUILDDIR)/$(LLVMDIALECTS_SRC_DIR)/build-compiled
	-$(MAKE) -C $(BUILDDIR)/$(LLVMDIALECTS_SRC_DIR) clean

get-llvmdialects: $(LLVMDIALECTS_SRC_FILE)
extract-llvmdialects: $(SRCCACHE)/$(LLVMDIALECTS_SRC_DIR)/source-extracted
configure-llvmdialects: $(BUILDDIR)/$(LLVMDIALECTS_SRC_DIR)/build-configured
compile-llvmdialects: $(BUILDDIR)/$(LLVMDIALECTS_SRC_DIR)/build-compiled
fastcheck-llvmdialects: #none
check-llvmdialects: $(BUILDDIR)/$(LLVMDIALECTS_SRC_DIR)/build-checked

#else # USE_BINARYBUILDER_LIBGIT2

# $(eval $(call bb-install,libgit2,LIBGIT2,false))

# # BB tarball doesn't create a manifest, so directly depend the `install` target
# install-libgit2: $(build_datarootdir)/julia/cert.pem
# endif

# # Also download and install a cacert.pem file, regardless of whether or not
# # we're using BinaryBuilder-sourced binaries
# $(SRCCACHE)/cacert-$(MOZILLA_CACERT_VERSION).pem:
# 	$(JLDOWNLOAD) $@ https://curl.haxx.se/ca/cacert-$(MOZILLA_CACERT_VERSION).pem

# $(build_datarootdir)/julia/cert.pem: $(SRCCACHE)/cacert-$(MOZILLA_CACERT_VERSION).pem | $(build_datarootdir)
# 	$(JLCHECKSUM) $<
# 	mkdir -p $(build_datarootdir)/julia
# 	cp $< $@

# checksum-mozillacert: $(SRCCACHE)/cacert-$(MOZILLA_CACERT_VERSION).pem
# 	$(JLCHECKSUM) $<

# # When "get"'ing libgit2, download the .pem
# get-libgit2: $(SRCCACHE)/cacert-$(MOZILLA_CACERT_VERSION).pem
