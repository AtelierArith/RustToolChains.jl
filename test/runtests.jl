
using Test
using RustToolChain: RustToolChain, cargo, rustc

@testset "RustToolChain" begin
    @test cargo() isa Cmd
    @test rustc() isa Cmd
end

@testset "cargo --version" begin
    @test success(`$(cargo()) --version`)
end

@testset "rustc --version" begin
    @test success(`$(rustc()) --version`)
end

@testset "cargo run with examples/hello" begin
    cd(joinpath(pkgdir(RustToolChain), "examples", "hello")) do
        @test success(`$(cargo()) run`)
    end
end
