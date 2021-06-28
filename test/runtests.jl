using CEDICT

using Test

@testset "unit tests" begin
    @testset "pinyin fuzzy matching" begin
        re = CEDICT._convert_pinyin_regex("jue2 dai4 shuang1 jiao1")
        @test match(re, "jue2 dai4 shuang1 jiao1") !== nothing
        @test match(re, "jue2 dai4 shuang1 jiao2") === nothing
        @test match(re, "wu2 jue2 dai4 shuang1 jiao1") === nothing
        @test match(re, "jue2 shuang1 jiao1") === nothing
        @test match(re, "jue2 dai4 shuang1 jiao1 ji4") === nothing
    end

    @testset "dictionary" begin
        dict = ChineseDictionary("res/small_dict.txt")

        @testset "loading" begin
            @test length(dict) == 744
        end

        @testset "contains" for key in ["代數拓撲", "做事", "優惠券", "优惠券"]
            @test haskey(dict, key)
        end

    end

    @testset "dictionary headword search" begin

    end

    @testset "dictionary sense/meaning search" begin

    end
end
