# TARGET Conventions

`tools/Makefile` is the single ThorMaker entry point. A project Makefile
selects its mode by which variable it sets before the include:

```make
# Leaf project — builds files in the current directory:
TARGET  = foo.prog bar.slib
include $(THORSANVIL_ROOT)/build/tools/Makefile

# Driver — recurses into a list of subdirectories:
SUBDIRS = src tools doc
include $(THORSANVIL_ROOT)/build/tools/Makefile
```

Setting neither (or both) is an error.

This file documents the **leaf mode** — the suffix semantics of the items
in `TARGET`. The suffix on each name determines what is built. The
`TARGET` variable may list multiple items.

## TARGET suffix semantics

| Suffix   | Meaning                                                                 |
|----------|-------------------------------------------------------------------------|
| `.prog`  | An executable. The `.prog` is not part of the final name.               |
|          | (Older versions used `.app`; that is not viable on a Mac.)              |
| `.dir`   | Build a subdirectory.                                                   |
| `.a`     | A static library. The `lib` prefix is added automatically.              |
| `.slib`  | A shared library. `lib` prefix added; platform-specific suffix replaces `slib`. |
| `.head`  | A header-only library.                                                  |
| `.defer` | Build object files but do not build a library. See below.               |
| `.test`  | Only build and run the test. No debug/release/install action.           |
| `.lib`   | Static or shared, depending on `THOR_TARGETLIBS` (usually set by configure). |
|          | Empty `THOR_TARGETLIBS` defaults to shared. Each value in `THOR_TARGETLIBS` |
|          | adds a version of the library to the target.                            |
|          | `TARGET=XXX.lib THOR_TARGETLIBS="slib a"` → `NEW_TARGET=XXX.slib XXX.a`  |

Artifacts are built into `$(TARGET_MODE)/` (debug / release / coverage).

Multiple `.dir` or `.prog` targets are fine — each installs to `$(PREFIX_BIN)/<App-Name>`.
Only **one** library may be built per directory. A library consists of:
1. All header files `*.h` `*.tpp` in the current directory,
   installed into `$(PREFIX_INC)/<Lib-Name>/`.
2. A library with the appropriate extension, installed into
   `$(PREFIX_LIB)/<Lib-Name><Type>.<Ext>`. Built from all source files in the
   current directory, minus any file whose basename matches a `.prog` target
   (so `TARGET=bob.prog glib.slib` excludes `bob.cpp` from `glib.so`).

## Defer mode

`.defer` builds object files without producing a library. Headers are deployed
normally. Object files are saved to the build directory for later use by a
subsequent library specified via `DEFER_LIBS`.

```
Dir: ThorsDB         Makefile: TARGET = ThorsDB.defer
Dir: ThorsDBCommon   Makefile: TARGET = ThorsDBCommon.defer
Dir: MySQL           Makefile: TARGET = ThorsMySQL.defer
Dir: ThorsDBBuild    Makefile: TARGET     = ThorsDB.lib
                               DEFER_LIBS = ThorsDB ThorsDBCommon ThorsMySQL
```

This builds `ThorsDB.lib` from the three defer projects above.

## Flags

| Flag                | Purpose                                                  | Default            |
|---------------------|----------------------------------------------------------|--------------------|
| `CXXSTDVER`         | 03 / 11 / 14 / 17 / 20                                   | `11`               |
| `CXX_STD_FLAG`      | Explicit `-std=` flag                                    | `-std=c++11`       |
| `VERBOSE=On`        | Print the full compile command rather than a summary     | `NONE`             |
| `NO_HEADER`         | Prevents header files from being installed (for libs)    | unset              |
| `TEST_ONLY=YES`     | Build locally only; do not push to `$(BUILD_ROOT)`       | `NO`               |
| `COVERAGE_REQUIRED` | Minimum coverage %. Override per-project to reduce.      | `80`               |

### LDLIBS_EXTERN_BUILD — the magic flag

```
LDLIBS_EXTERN_BUILD = yaml
```

For each name `foo` listed, if `$(foo_ROOT_DIR)` is defined, these are auto-set:

```
LDLIBS   += -L$(foo_ROOT_DIR)/lib    -lfoo
CXXFLAGS += -I$(foo_ROOT_DIR)/include
RPATH    := $(RPATH):$(foo_ROOT_DIR)/lib
```

Intended to be used with a `Makefile.config` produced by configure — you will
usually see `foo_ROOT_DIR` defined there.

### Per-target / per-file flags

```
<TARGET>_LDLIBS     = <libs>           # literal, no processing
<TARGET>_LINK_LIBS  = <libs>           # each expanded with -l<lib><build-extension>
UNITTEST_LDLIBS             = <libs>
UNITTEST_LINK_LIBS          = <libs>
UNITTEST_LDLIBS_HEADERONLY  = <libs>
UNITTEST_CXXFLAGS
<SOURCE>_CXXFLAGS   = <flags>          # per-source, usually to suppress warnings
FILE_WARNING_FLAGS  = <flags>          # project-wide extra warning flags
```

## Useful goals

```
make test-<TestName>       # <TestName> may be *  ClassName.*  or ClassName.TestMethod
make testrun.<TestName>    # only run, don't rebuild
make debugrun.<TestName>   # run under lldb
make coverage-file.h       # display coverage for file.h
```
