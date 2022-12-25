
@testset "dictionary loading: tiny" begin
    dict = ChineseDictionary("res/tiny_dict.txt")

    @test length(dict) == 39
    @test all(haskey.(Ref(dict), ["展销会", "反目成仇", "村民", "歐巴桑", "可恃", "戄"]))
end

@testset "dictionary loading: mini" begin
    dict = ChineseDictionary("res/mini_dict.txt")

    @test length(dict) == 115
    @test all(haskey.(Ref(dict), ["仁术", "周遊世界", "和睦", "代數拓撲", "未冠", "棒冰"]))
end

@testset "dictionary loading: small" begin
    dict = ChineseDictionary("res/small_dict.txt")

    @test length(dict) == 744
    @test all(haskey.(Ref(dict), ["代數拓撲", "做事", "優惠券", "优惠券"]))
end

@testset "dictionary headword search" begin

end

@testset "dictionary sense/meaning search" begin
    dict = ChineseDictionary("res/tiny_dict.txt")

    ids = idioms(dict)
    @test length(ids) == 2

    villager_defn = first(search_senses(dict, "villager"))
    @test traditional_headword(villager_defn) == simplified_headword(villager_defn) == "村民"
    @test pinyin_pronunciation(villager_defn) == "cun1 min2"
    @test length(word_senses(villager_defn)) == 1
    @test first(word_senses(villager_defn)) == "villager"

    with_terms = search_senses(dict, "with")
    @test length(with_terms) == 2
end
