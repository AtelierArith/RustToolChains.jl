using RustToolChain: cargo

cd(joinpath(@__DIR__, "hello")) do
    run(`$(cargo()) run`)
end
