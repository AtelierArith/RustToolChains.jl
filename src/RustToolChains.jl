module RustToolChains

const ARTIFACTS_TOML = joinpath(pkgdir(@__MODULE__), "Artifacts.toml")
const EXE_EXT = Sys.iswindows() ? ".exe" : ""

export cargo

using Pkg.Artifacts: ensure_artifact_installed, artifact_path, artifact_hash

function cargo_exe_path()
	ensure_artifact_installed("RustToolChain", ARTIFACTS_TOML)
	toolchain_dir = artifact_path(artifact_hash("RustToolChain", ARTIFACTS_TOML))
	return joinpath(toolchain_dir, "cargo", "bin", "cargo" * EXE_EXT)
end

function cargo()
	cargo_exe = cargo_exe_path()
	`$cargo_exe`
end

end # module RustToolChains
