# android-mods

my android modules live here, currently 3, the first two need zygisk to run

**pixie** - spoof device so google photos unlocks those "exclusive" features

**unveil** - drops FLAG_SECURE system-wide so you can abuse protected apps (Android 16+)

**hosts** - systemless hosts file, intentionally minimal for AdAway

## building

needs the android ndk (zygisk modules only) and `zip`

```
make NDK=/path/to/ndk     # all modules (or set ANDROID_NDK_HOME)
make pixie                # one module
make hosts
make clean
```
