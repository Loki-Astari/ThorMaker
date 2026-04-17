# Setup

The short version:

```bash
git clone https://github.com/Loki-Astari/ThorMaker.git build
cd build/third && ./setup
```

That's it. `./setup`:

1. Creates `bin/`, `lib/`, `include/`, `3rd/` under the repo root.
2. Fetches and installs the third-party dependencies ThorMaker needs (currently google-test).

After setup, a minimal leaf-project Makefile is three lines:

```make
THORSANVIL_ROOT = $(realpath ../../)
TARGET          = MyLib.slib
include $(THORSANVIL_ROOT)/build/tools/Makefile
```

A minimal driver (multi-subdir) Makefile is the same shape but with
`SUBDIRS` instead of `TARGET`:

```make
THORSANVIL_ROOT = $(realpath ./)
SUBDIRS         = lib app tools
include $(THORSANVIL_ROOT)/build/tools/Makefile
```

See [target-conventions.md](target-conventions.md) for the full surface
(TARGET suffixes, flags, goals, test conventions, artifact naming).

## Integration with autotools

ThorMaker automatically includes `$(THORSANVIL_ROOT)/Makefile.config` if
it exists, so it drops cleanly into an autotools setup (autoconf /
automake / libtool). Generated config values become make variables with
no further plumbing.

## Example project

For a worked-through example of how these features come together, see
[ThorsSerializer](https://github.com/Loki-Astari/ThorsSerializer).
