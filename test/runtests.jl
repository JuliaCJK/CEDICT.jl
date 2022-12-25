using CEDICT

using Test

@testset "all tests" begin

    include("dict_dict_tests.jl")

    @testset "pinyin fuzzy matching" begin
        re = CEDICT._prepare_pinyin_regex("jue2 dai4 shuang1 jiao1")
        @test match(re, "jue2 dai4 shuang1 jiao1") !== nothing
        @test match(re, "jue2 dai4 shuang1 jiao2") === nothing
        @test match(re, "wu2 jue2 dai4 shuang1 jiao1") === nothing
        @test match(re, "jue2 shuang1 jiao1") === nothing
        @test match(re, "jue2 dai4 shuang1 jiao1 ji4") === nothing
    end
end
