using ToolipsServables
using ToolipsServables: htmlcomponent
using Test
dir = @__DIR__
@testset "toolips servables!" verbose = true begin
    # //begin tests
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
        @test string(comp) == "<div id='sample' >example</div>"
        father = body("bod")
        push!(father, comp)
        @test father[:children][1].name == comp.name
        style!(comp, "color" => "blue")
        @test contains(comp["style"], "color:blue;")
        set_children!(father, [comp, copy(comp)])
        @test length(father[:children]) == 2
    end
    @testset "style templating" verbose = true begin
        newsty = style("newsample", "color" => "red")
        divsty = style("div.sample", "color" => "orange")
        style!(comp, divsty)
        @testset "style" begin
            @test comp[:class] == "sample"
            @test contains(string(divsty), "div.sample {color:orange;}")
        end
        @testset "keyframes" begin
            frames = keyframes("fadein")
            keyframes!(frames, from, "opacity" => 0percent)
            keyframes!(frames, to, "opacity" => 100percent)
            style!(newsty, frames)
            @test newsty["animation-name"] == "fadein"
            style!(comp, frames)
            @test contains(comp["style"], "animation-name")
        end
    end
    @testset "special components" verbose = true begin
        @testset "select/options" begin
            opts = options("alien", "human", "person")
            @test length(opts) == 3
            @test :text in keys(opts[1].properties)
            box = select("sampbox", opts, value = opts[1]["text"])
            @test length(box[:children]) == 3
            @test box[:value] == opts[1]["text"]
            sel = select("sampbox2", value = "testbox")
            @test sel[:value] == "testbox"
        end
        tdiv = textdiv("mysample", text = "sample")
        @testset "canonical input components" begin
            @test tdiv.name == "mysample"
            @test typeof(tdiv) == Component{:div}
            tbox = textbox("newsample", 1:10)
            @test typeof(tbox) == Component{:input}
            tbox = password("newsample", 1:10)
            @test typeof(tbox) == Component{:input}
            @test tbox[:type] == "password"
            numinput = ToolipsServables.numberinput("sample", 1:50, selected = 15)
            @test typeof(numinput) == Component{:input}
            @test string(numinput[:selected]) == string(15)
            r = rangeslider("sample")
            @test r.name == "sample"
            @test r["type"] == "range"
            checkbx = checkbox("mycheck", text = "check me!", value = false)
            @test string(checkbx[:value]) == "false"
            colinp = colorinput("testbox")
            @test colinp[:value] == "#ffffff"
        end
        @testset "special input components" begin
            curs = cursor("sample")
            @test typeof(curs) == Component{:cursor}
            @test curs.tag == "script"
            ToolipsServables.context_menu!(tdiv)
            @test length(tdiv[:extras]) > 0
            kinput = keyinput("sample", text = "W")
            @test typeof(kinput) == Component{:keyinput}
        end
    end
end

@testset "IO" verbose = true begin
    @testset "input (htmlcomponent)" begin
        html = """<div id="sample"><sample id="textbox" propr="hello">text</sample></div><example><sampletext/example>"""
        comps = htmlcomponent(html)
        @test "sample" in comps
        @test "textbox" in comps
        @test comps["textbox"]["text"] == "text"
        @test length(comps) == 2
        comps = htmlcomponent(html, ["textbox"])
        @test comps["textbox"]["text"] == "text"
        html = """<a id="sample" contenteditable="true"></a>"""
        comps = htmlcomponent(html)
        @test comps[1]["contenteditable"] == "true"
        html = """<div id="sample"><sample id="textbox" propr="hello">text</sample></div><example><sampletext/example>"""
        comps = htmlcomponent(html)
        comp = htmlcomponent(html, "textbox")
        @test comp["text"] == "text"
        @test comp["propr"] == "hello"
    end
    @testset "output (String, IOBuffer)" begin
        io = IOBuffer()
        comp = div("sample", text = "example")
        write!(io, comp, comp)
        @test contains(String(io.data), "id='sample'")
        @test string(comp) == "<div id='sample' >example</div>"
    end
end 

@testset "recompose" begin
    html = """<div id="sample"><button id="hello">hello</button></div><element id="third" x="5"></element>"""
    comps = htmlcomponent(html)
    comps[1][:text] = ""
    push!(comps[1], comps[2])
    reps = (" " => "", "'" => "", "\"" => "")
    @test replace(write!("", comps[1], comps[3]), reps ...) == replace(html, reps ...)
end
end #// tests