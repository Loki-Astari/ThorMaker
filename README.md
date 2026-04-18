# ThorMaker

A drop-in C++ build system for multi-project repositories, built on GNU make.

A project Makefile declares one of two things —

```make
TARGET  = foo.prog bar.slib          # leaf:  build artifacts in this dir
SUBDIRS = lib app tools              # driver: recurse into these subdirs
```

— and ThorMaker handles the rest: debug / release / coverage builds, unit
tests with google-test plus coverage reporting, cppcheck + vera++ static
analysis, parallel compilation under a progress display, autotools
integration, and install / uninstall to either a local sandbox
(`$(THORSANVIL_ROOT)/build/`) or a system prefix (`/usr/local`).

## Features

- Four build modes — debug, release, coverage, test — coexisting on disk.
- Artifact naming tracks C++ standard and build mode so variants link
  cleanly (`libFoo11D.so` = C++11 debug shared).
- Per-target, per-source, and per-object-file flag overrides.
- Parallel builds under a background monitor pipe that keeps output
  readable (summary lines; expand on error; colour-coded).
- Google-test + coverage gate (configurable, default 80%).
- Static analysis via cppcheck and vera++.
- Autotools integration (auto-loads `Makefile.config`).
- Header-only library variant with automated conversion workflow.
- Opt-in CMake package-config installation so downstream CMake consumers
  can `find_package()`.
- Editor integration (`.clangd` generation for clangd / nvim+coc / etc.).

## Quick start

Install prerequisites (autoconf, automake, libtool — see
[tools/docs/setup.md](tools/docs/setup.md)), then bootstrap a new project:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Loki-Astari/ThorMaker/master/autotools/Notes) MyProj
cd MyProj
```

### Example
A minimal leaf-project Makefile:

```make
THORSANVIL_ROOT = $(realpath ../../)
TARGET          = MyLib.slib
include $(THORSANVIL_ROOT)/build/tools/Makefile
```

A minimal driver Makefile:

```make
THORSANVIL_ROOT = $(realpath ./)
SUBDIRS         = lib app tools
include $(THORSANVIL_ROOT)/build/tools/Makefile
```

Then:

```bash
make                 # default — runs test, debug, release, install locally
make debug           # just the debug build
make test            # unit tests + coverage + static analysis
make install         # install to $prefix (blocks if tests fail)
make clean           # remove build artifacts
```

## Documentation

| File | What's in it |
|---|---|
| [tools/docs/setup.md](tools/docs/setup.md) | Prerequisites, initial clone, `./setup`, autotools integration, minimal Makefile templates, opt-in CMake config. |
| [tools/docs/target-conventions.md](tools/docs/target-conventions.md) | Build goals (what each one does end-to-end), TARGET suffix semantics (`.prog` / `.a` / `.slib` / `.lib` / `.head` / `.defer` / `.test`), artifact naming, source-file conventions, tests, defer mode, flag reference (`CXXSTDVER`, `LINK_LIBS`, `LDLIBS`, `LDLIBS_EXTERN_BUILD`, `CMAKE_CONFIG`, per-target / per-file overrides), and useful goals like `make test-<name>` and `make coverage-file.h`. |

## Example project

[ThorsAnvil](https://github.com/Loki-Astari/ThorsAnvil) uses
[ThorsSerializer](https://github.com/Loki-Astari/ThorsSerializer) uses
ThorMaker end-to-end and is a good reference for feature usage.

## Supported platforms

macOS, Linux, MSYS2 / MinGW64 on Windows.
