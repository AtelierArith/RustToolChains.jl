module RustToolChain

const ARTIFACTS_TOML = joinpath(pkgdir(@__MODULE__), "Artifacts.toml")
const EXE_EXT = Sys.iswindows() ? ".exe" : ""

export cargo, rustc

using Pkg.Artifacts: ensure_artifact_installed, artifact_path, artifact_hash

"""
    ensure_rust_toolchain_installed()

Ensures that the Rust toolchain artifact is installed and available.
If not already installed, downloads and installs the Rust toolchain artifact.
Returns the installation prefix directory containing the Rust binaries.
"""
function ensure_rust_toolchain_installed()
    ensure_artifact_installed("RustToolChain", ARTIFACTS_TOML)
    toolchain_dir = artifact_path(artifact_hash("RustToolChain", ARTIFACTS_TOML))
    # The Rust toolchain is unpacked inside a rust-*-*/ directory
    rust_dirs = filter(x -> startswith(x, "rust-"), readdir(toolchain_dir))
    isempty(rust_dirs) && error("Could not find rust-* directory in artifact")
    rust_dir = first(rust_dirs)
    prefix = joinpath(toolchain_dir, rust_dir, "prefix")

    if isdir(prefix)
        return prefix
    else
        run(`bash $(joinpath(toolchain_dir, rust_dir, "install.sh")) --prefix=$(prefix) --disable-ldconfig`)
        return prefix
    end
end

"""
    cargo_cmd_from_artifacts()

Get the cargo executable command from Julia's Artifacts system.
Downloads and installs the Rust toolchain if not already present.
"""
function cargo_cmd_from_artifacts()
    prefix = ensure_rust_toolchain_installed()
    cargo_path = joinpath(prefix, "bin", "cargo" * EXE_EXT)
    @assert isfile(cargo_path) "Cargo executable not found at $cargo_path"

    env = copy(ENV)
    env["RUSTC"] = joinpath(prefix, "bin", "rustc" * EXE_EXT)
    return setenv(`$cargo_path`, env)
end

"""
    rustc_exe_cmd_from_artifacts()

Get the rustc executable command from Julia's Artifacts system.
Downloads and installs the Rust toolchain if not already present.
"""
function rustc_cmd_from_artifacts()
    prefix =ensure_rust_toolchain_installed()
    rustc_path = joinpath(prefix, "bin", "rustc" * EXE_EXT)
    return `$rustc_path --sysroot $(prefix)`
end

"""
    cargo()

Get a command object for executing Rust's cargo command.
First checks if cargo is available in the system PATH.
If not found, uses the cargo from Julia's Artifacts system.

# Returns
- `Cmd` object (usable with Julia's backtick syntax)

# Examples
```julia
using RustToolChain: cargo

# Check cargo version
run(`\$(cargo()) --version`)

# Build a project
run(`\$(cargo()) build`)
```
"""
function cargo()
    # Try to use system cargo first (case A)
    system_cargo = Sys.which("cargo")
    if system_cargo !== nothing
        return `$system_cargo`
    end

    # Fall back to Artifacts cargo (case B)
    return cargo_cmd_from_artifacts()
end

"""
    rustc()

Get a command object for executing Rust's rustc compiler.
First checks if rustc is available in the system PATH.
If not found, uses the rustc from Julia's Artifacts system.

# Returns
- `Cmd` object (usable with Julia's backtick syntax)

# Examples
```julia
using RustToolChain: rustc

# Check rustc version
run(`\$(rustc()) --version`)

# Compile a Rust file
run(`\$(rustc()) main.rs`)
```
"""
function rustc()
    # Try to use system rustc first (case A)
    system_rustc = Sys.which("rustc")
    if system_rustc !== nothing
        return `$system_rustc`
    end

    # Fall back to Artifacts rustc (case B)
    return rustc_cmd_from_artifacts()
end

end # module RustToolChain
