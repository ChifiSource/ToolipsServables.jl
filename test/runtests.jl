using ToolipsServables
using Test
dir = @__DIR__
@testset "types" verbose = true begin
    @testset "File" begin
        f = File(dir * "/runtests.jl")
        @test typeof(f) == File{:jl}
        @test f.name == "runtests.jl"
        @test f[] == dir * "/runtests.jl"
    end
    @testset "Component" begin
        comp = Component{:star}("example", text = "sample")
        @test comp[:text] == "sample"
        @test comp["text"] == "sample"
        @test typeof(comp) == Component{:star}
        c2 = Component("tag", "name")
        @test c2.name == "name"
        @test typeof(c2) == Component{:tag}
        c3 = Component{:test}("sample", tag = "div")
        @test c3.tag == "div"
        @test typeof(c3) == Component{:test}
        c4 = copy(c3)
        @test c4.tag == c3.tag
        @test typeof(c4) <: AbstractComponent
    end
    @testset "Style" begin
        comp = Style("div.main", "color" => "blue", "background-color" => "red")
        @test typeof(comp) == Style
    end
    @testset "KeyFrames" begin
        frames = KeyFrames("fadein")
        @test typeof(frames) == KeyFrames
    end
end

@testset "templating" verbose = true begin
    
end