# Make Commands

## Building

| Command | Description |
|---|---|
| `make` | Build everything (runs tests, then builds debug and release, installs to build dir) |
| `make debug` | Build debug version only |
| `make release` | Build release version only |
| `make release-only` | Build release and install headers/release libs (skip tests and debug) |
| `make VERBOSE=On` | Build with full compiler commands printed instead of summaries |

## Testing

| Command | Description |
|---|---|
| `make test` | Run all unit tests, coverage analysis, and static analysis (vera++) |
| `make test-*` | Run all unit tests (no coverage or vera) |
| `make test-ClassName.*` | Run all tests in a specific test class |
| `make test-ClassName.Method` | Run a single test method |
| `make testrun.ClassName.*` | Run tests without rebuilding first |
| `make debugrun.ClassName.*` | Run tests under lldb debugger |

## Coverage

| Command | Description |
|---|---|
| `make coverage-file.h` | Display coverage report for a specific header file |
| `make coverage-file.cpp` | Display coverage report for a specific source file |

## Installation

| Command | Description |
|---|---|
| `make install` | Build and install to system prefix (headers, libs, binaries) |
| `make uninstall` | Remove installed files from system prefix |

## Cleaning

| Command | Description |
|---|---|
| `make clean` | Remove build artifacts (debug, release, coverage, reports) |
| `make veryclean` | Deep clean: runs clean then also uninstalls from build directory |

## IDE / Editor Support

| Command | Description |
|---|---|
| `make .clangd` | Generate a `.clangd` config file with correct include paths and flags |
| `make neovimflags` | Print compiler flags for NeoVim integration |
| `make neovimruntime` | Print runtime library paths for NeoVim test execution |

## Linting

| Command | Description |
|---|---|
| `make lint` | Run static analysis (vera++ and cppcheck) |

## Documentation

| Command | Description |
|---|---|
| `make doc` | Build API documentation (requires andvari) |

## Diagnostics

| Command | Description |
|---|---|
| `make print` | Print key build variables (paths, flags, libraries) |
| `make tools` | Print platform and tool information (compiler, yacc, lex, etc.) |
| `make check` | Print build root and path resolution info |

## Header-Only

| Command | Description |
|---|---|
| `make header-only` | Convert project to header-only format and verify tests pass |
