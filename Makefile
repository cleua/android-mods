# make [module]  ->  out/<module>-<version>.zip     (NDK=/path/ndk for zygisk modules)
# Per-module metadata lives in <module>.mk; a module with <module>.c is built as zygisk.
MODULES := pixie unveil hosts
include $(MODULES:%=%.mk)

NDK    ?= $(ANDROID_NDK_HOME)
API    ?= 35
ABIS   ?= arm64-v8a
CFLAGS ?= -Os -fPIC -Wall -Wextra -fvisibility=hidden
LDFLAGS ?= -shared -Wl,--build-id=none -Wl,-z,max-page-size=16384 -s


define zygisk
test -d "$(NDK)" || { echo "set NDK=/path/to/android-ndk"; exit 1; }
mkdir -p build/$(1)/zygisk
for a in $(ABIS); do \
  $(lastword $(wildcard $(NDK)/toolchains/llvm/prebuilt/*))/bin/$$(echo $$a | sed 's/arm64-v8a/aarch64-linux-android/;s/armeabi-v7a/armv7a-linux-androideabi/;s/x86_64/x86_64-linux-android/;s/^x86$$/i686-linux-android/')$(API)-clang \
    $(CFLAGS) -I. $(LDFLAGS) -o build/$(1)/zygisk/$$a.so $(1).c || exit 1; done
endef

.PHONY: all clean $(MODULES)
all: $(MODULES)

define module
$(1): out/$(1)-$$(VERSION_$(1)).zip
out/$(1)-$$(VERSION_$(1)).zip: $(1).mk module/module.prop $$(FILES_$(1):%=module/%) \
    $$(wildcard $(1).c zygisk.h)
	rm -rf build/$(1) $$@ && mkdir -p build/$(1) out
	sed 's|@ID@|$(1)|;s|@NAME@|$$(NAME_$(1))|;s|@VERSION@|$$(VERSION_$(1))|;s|@VERSIONCODE@|$$(VERSIONCODE_$(1))|;s|@AUTHOR@|Ayne (soluvyn)|;s|@DESCRIPTION@|$$(DESC_$(1))|' \
	    module/module.prop > build/$(1)/module.prop
	$$(if $$(FILES_$(1)),cd module && cp --parents $$(FILES_$(1)) ../build/$(1))
	$$(if $$(wildcard $(1).c),$$(call zygisk,$(1)))
	cd build/$(1) && zip -r9DX $$(CURDIR)/$$@ .
endef
$(foreach m,$(MODULES),$(eval $(call module,$(m))))

clean:
	rm -rf build out
