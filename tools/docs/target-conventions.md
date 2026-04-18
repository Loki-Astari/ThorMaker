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

Setting neither (or both) is an error. For initial setup (first clone, gtest
install, etc.) see [setup.md](setup.md).

### SUBDIRS platform filters

In driver mode, individual subdirectory names can be suffixed to restrict
them to specific platforms:

| Suffix       | Effect                              |
|--------------|-------------------------------------|
| `.NotMac`    | Build on every platform except Mac  |
| `.NotLinux`  | Build on every platform except Linux|
| `.NotWin`    | Build on every platform except Windows |
| `.OnlyMac`   | Build on Mac only                   |
| `.OnlyLinux` | Build on Linux only                 |
| `.OnlyWin`   | Build on Windows only               |

The suffix is stripped from the directory name before recursing. Example:

```make
SUBDIRS = Core NetworkLib.NotWin GuiApp.OnlyMac
```

This builds `Core` everywhere, `NetworkLib` on Linux and Mac, and `GuiApp`
on Mac only.

---

This file documents **leaf mode** — the suffix semantics of items in
`TARGET`, what each build goal does, and the flags that control it.

## Build goals

| Goal        | What it does                                                                                   |
|-------------|------------------------------------------------------------------------------------------------|
| _(none)_    | `all` → `build`.                                                                               |
| `debug`     | Builds the debug version of each `TARGET`.                                                     |
| `release`   | Builds the release version of each `TARGET`.                                                   |
| `test`      | Builds coverage, builds unit tests, runs them, generates a coverage report, runs the style checker. Requires coverage to meet `COVERAGE_REQUIRED` (default 80%). |
| `build`     | `test` → `debug` → `release` → copy artifacts to local `$(BUILD_ROOT)/{bin,lib,include}`.      |
| `install`   | Same pipeline as `build` but copies to system prefixes (`$(PREFIX_BIN)`, etc.). **Blocks on test failure** — you cannot install broken code. |
| `uninstall` | Remove installed files from the system prefixes.                                               |
| `clean`     | Remove generated files.                                                                        |
| `veryclean` | `clean` plus remove from `$(BUILD_ROOT)` (uninstall of locally-staged artifacts).              |
| `lint`      | Run cppcheck + vera++.                                                                         |
| `doc`       | Build documentation (via `andvari`).                                                           |

Each mode builds object files into its own directory: `debug/`, `release/`,
`coverage/`. A single tree holds all modes simultaneously.

## TARGET suffix semantics

| Suffix   | Meaning                                                                                        |
|----------|------------------------------------------------------------------------------------------------|
| `.prog`  | An executable. The `.prog` suffix is stripped from the final name.                             |
| `.lib`   | Static or shared, depending on `THOR_TARGETLIBS` (usually set by configure).                   |
| `.a`     | Specifically static library. The `lib` prefix is added automatically.                          |
| `.slib`  | Specifically shared library. Platform specific prefix added.                                   |
| `.head`  | A header-only library.                                                                         |
| `.defer` | Build object files but do not build a library. See [Defer mode](#defer-mode).                  |
| `.test`  | Only build and run the test. No debug/release/install action.                                  |
| -------  | --------                                                                                       |
|          | Empty `THOR_TARGETLIBS` defaults to shared. Each value in `THOR_TARGETLIBS` adds a version of the library to the target. `TARGET=XXX.lib THOR_TARGETLIBS="slib a"` → `NEW_TARGET=XXX.slib XXX.a`  |

## Artifact naming

Libraries and executables are suffixed so that multiple builds can coexist
on disk and links resolve to the correct version.

```
libX11.so     X, C++11, release
libX11D.so    X, C++11, debug
libX03.so     X, C++03, release
libX03D.so    X, C++03, debug
libX17.so     X, C++17, release
libX17D.so    X, C++17, debug
```

Format: `lib<Name><CXXSTDVER>[D].<platform-ext>` where the trailing `D` appears for debug builds. Note: When fully installed symbolic links are provided from `lib<Name>.<platform-ext>` -> Current release version.

## Source files

The build picks up these extensions from the current directory:

| Extension                    | Role                         |
|------------------------------|------------------------------|
| `*.cpp`                      | C++ source                   |
| `*.h` `*.hpp` `*.tpp`        | C++ headers                  |
| `*.y`                        | Bison/yacc grammar           |
| `*.l`                        | Flex/lex lexer               |
| `*.gperf`                    | gperf perfect-hash input     |

Plain `*.c` files are not picked up — compile everything through a C++ compiler.

## Multiple targets and the "only target" rule

Multiple `.dir` or `.prog` targets are fine — each installs to
`$(PREFIX_BIN)/<App-Name>`.

**Only one library may be built per directory.** A library consists of:
1. All header files `*.h` `*.tpp` in the current directory, installed into
   `$(PREFIX_INC)/<Lib-Name>/`.
2. A library file with the appropriate extension, installed into
   `$(PREFIX_LIB)/<Lib-Name><Type>.<Ext>`, built from all source files in
   the current directory, minus any file whose basename matches a `.prog`
   target (so `TARGET=bob.prog glib.slib` excludes `bob.cpp` from
   `glib.so`).

For applications:
- If a `.prog` is the **only** target in the directory, **all** sources in
  the directory are compiled into it (same rule as a library).
- If a `.prog` is **one of several** targets, **only** the same-named
  source file (`bob.cpp` for `bob.prog`) is compiled into it.

## Tests

No extra setup required — if the build finds a `test/` directory next to
your sources, it will:

1. Build a unit-test binary from the files in `test/` with flags to get coverage information.
2. Run the binary.
3. Compute coverage against the code in the parent directory.

Only google-test is supported. See `tools/mock/` for the mocking machinery
exposed through `MOCK_FUNC` / `MOCK_TFUNC`.

## Defer mode

`.defer` builds object files without producing a library. Headers are
deployed normally. Object files are saved to the build directory for later
use by a subsequent library specified via `DEFER_LIBS`.

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
| `CXXSTDVER`         | 03 / 11 / 14 / 17 / 20                                   | `20`               |
| `VERBOSE=On`        | Print the full compile command rather than a summary     | `NONE`             |
| `NO_HEADER`         | Prevents header files from being installed (for libs)    | unset              |
| `TEST_ONLY=YES`     | Build locally only; do not push to `$(BUILD_ROOT)`       | `NO`               |
| `COVERAGE_REQUIRED` | Minimum coverage %. Override per-project to reduce.      | `80`               |
| `CMAKE_CONFIG=yes`  | **Driver mode only.** Install ThorsAnvil CMake package config files so downstream CMake consumers can `find_package()`. Typically set only at the top-level project-root Makefile. | unset |
| `THOR_DEBUG_LOAD=1` | **Leaf mode only.** Disable goal-based lazy-loading and force every fragment to load. Use when diagnosing "why isn't goal X defined?" or when `make print` needs the full variable surface. Normal builds leave this unset. | unset |
| `CONFIG_NAME`       | Subproject name used to locate `third/<CONFIG_NAME>/Makefile.config`. Set in every leaf Makefile that belongs to a third-party subproject so that configure-generated settings are picked up. | unset |
| `NAMESPACE`         | C++ namespace used by the header-only conversion tool (`build-honly` / `build-hcont`). | unset |
| `DEFER_NAME`        | Grouping name for `.defer` targets. Object files are saved under `$(PREFIX_DEFER_OBJ)/<DEFER_NAME>/`. Automatically extracted from the `.defer` suffix in `TARGET` — only set it explicitly if you need a name that differs from the target basename. | auto |
| `DEFER_LIBS`        | List of defer project names whose objects should be combined into the final library. Used in the "collector" directory that builds a `.lib` from multiple `.defer` projects. | unset |
| `EXCLUDE_HEADERS`   | Header files to exclude from installation. Applied as a `filter-out` against the discovered `*.h *.tpp *.hpp` files. | unset |
| `EXTRA_HEADERS`     | Additional header files to install that are not matched by the default `*.h *.tpp *.hpp` globs. | unset |

### Standard Make flag variables

These behave as make documents them:

```
CPPFLAGS   CXXFLAGS   LDFLAGS   LOADLIBES   LDLIBS
```

When setting them in a project Makefile, **use `+=`, not `=`**. ThorMaker
builds these values up internally; a plain `=` will wipe out everything
the build system needs to add.

### LDLIBS vs LINK_LIBS

These look similar but serve different roles:

- **`LDLIBS`** — system / third-party libraries. Passed to the linker
  verbatim. Example: `LDLIBS += -lpthread -lyaml`.
- **`LINK_LIBS`** — libraries built by **this** repo (or any repo using
  ThorMaker). Each name is auto-suffixed with the current build extension
  so you link against the matching debug/release/C++-standard variant.
  Example: `LINK_LIBS = ThorsLogging ThorSerialize` → `-lThorsLogging20D
  -lThorSerialize20D` in a C++20 debug build.

### Per-target / per-file flags

```
<TARGET>_LDLIBS               = <libs>   # literal, no processing
<TARGET>_LINK_LIBS            = <libs>   # each expanded with -l<lib><build-extension>
UNITTEST_LDLIBS               = <libs>
UNITTEST_LINK_LIBS            = <libs>
UNITTEST_LDLIBS_HEADERONLY    = <libs>
UNITTEST_CXXFLAGS             = <flags>
UNITTEST_FILE_WARNING_FLAGS   = <flags>
<SOURCE>_CXXFLAGS             = <flags>  # per-source, usually to suppress warnings
FILE_WARNING_FLAGS            = <flags>  # project-wide extra warning flags
FILE_WARNING_FLAGS_<PLATFORM> = <flags>  # platform-specific warning flags (Darwin, Linux, MSYS_NT, MINGW64_NT)
LDLIBS_<PLATFORM>             = <libs>   # platform-specific linker libs
CONAN_FILE_WARNING_FLAGS      = <flags>  # extra warning flags applied only in Conan builds
```

You can also use make's target-specific variable syntax on the generated
object file to override flags for a single source, optionally scoped to
a build mode:

```make
%/File.o:          CXXFLAGS += -Wno-deprecated-declarations   # all modes
debug/File.o:      CXXFLAGS += -gExtra                        # debug only
release/File.o:    CXXFLAGS += -OMyFlag                       # release only
```

### LDLIBS_EXTERN_BUILD — the magic flag

```
LDLIBS_EXTERN_BUILD = yaml
```

For each name `foo` listed, if `$(foo_ROOT_DIR)` is defined, these are
auto-set:

```
LDLIBS   += -L$(foo_ROOT_DIR)/lib    -lfoo
CXXFLAGS += -I$(foo_ROOT_DIR)/include
RPATH    := $(RPATH):$(foo_ROOT_DIR)/lib
```

Intended to be used with a `Makefile.config` produced by configure — you
will usually see `foo_ROOT_DIR` defined there.

## Useful goals

```
make test-<TestName>       # <TestName> may be *, ClassName.*, or ClassName.TestMethod
make testrun.<TestName>    # only run, don't rebuild
make debugrun.<TestName>   # run under lldb
make coverage-<FileName>   # display coverage for "FileName"
```
