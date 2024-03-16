using ToolipsServables
using ToolipsServables: htmlcomponent
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
        c2 = Component{:tag}("name")
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
        comp = ToolipsServables.Style("div.main", "color" => "blue", "background-color" => "red")
        @test typeof(comp) == ToolipsServables.Style
    end
    @testset "KeyFrames" begin
        frames = ToolipsServables.KeyFrames("fadein")
        @test typeof(frames) == ToolipsServables.KeyFrames
    end
end

@testset "templating" verbose = true begin
    comp = div("sample", text = "example")
    @testset "component templating" begin
        @test string(comp) == "<div id=\"sample\" >example</div>"
        father = body("bod")
        push!(father, comp)
        @test father[:children][1].name == comp.name

    end
    @testset "style templating" verbose = true begin
    
    end
    @testset "special components" verbose = true begin

    end
end

@testset "IO" verbose = true begin
    @testset "input (htmlcomponent)" begin
        html = """<div id="sample"><sample id="textbox">text</sample></div><example><sampletext/example>"""
        comps = htmlcomponent(html)
        @test "sample" in comps
        @test "textbox" in comps
        @test comps["textbox"]["text"] == "text"
        @test length(comps) == 2
        comps = htmlcomponent(html, ["textbox"])
        @test comps["textbox"]["text"] == "text"
    end
    @testset "output (String, IOBuffer)" begin

    end
end