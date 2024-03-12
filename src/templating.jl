
"""
##### toolips servables HTML templating
`Component` templating revolves primarily around the `Component` 
and the `Style` with additional functionality being provided through the 
`File` and `Animation` `Servables`. Components are created via **element constants**. 
For a full list of these elements, use `?(elements)`. When constructing from 
one of these tag names, the first positional argument will always be a name. 
From here, some components *do* have separate arguments they can take but 
for the most part any argument can be provided in the form of a `Pair` or 
a key-word argument.
```julia
mycomp::Component{:div} = div("example-name", text = "hello world!", align = "center")
```
The following functions are used to compose components:
- `style!`
- `push!`
- `set_children!`
- `delete!`
```julia
mydiv = div("example", text = "sample")
style!(mydiv, "background-color" => "purple", "border-radius" => 2px)

child_comp = a("samplecomp")
style!(child_comp, "color" => "blue")
push!(mydiv, child_comps)

childs = [b("samp\$(e)", text = e) for e in 1:5]

set_children!(child_chomp, childs)

delete!(childs["samp1"])
```

Components are indexable by both `Symbol` and `String`, this will retrieve stored 
properties.
- See also: `arguments`, `style_properties`, `elements`, `div`, `style`, `set_children!`, `push!`, `Style`
"""
const templating = 1

"""
The following is a *comprehensive list of all component elements. Elements are called 
with the first positional argument of a `String` and then infinite `Pair{String, <:Any}` and 
key-word arguments.
```example
dv = div("name", align = "center", text = "hello!")
```
- See also: `templating`, `Component`, `arguments`, `div`, `body`, `a`, `measures`, `DOCTYPE`
```julia
- `img`
- `link`
- `meta`
- `input`
- `a`
- `p`
- `ul`
- `li`
- `br`
- `i`
- `i`
- `title`
- `span`
- `iframe`
- `svg`
- `h1`
- `h2`
- `h3`
- `h4`
- `h5`
- `h6`
- `element`
- `label`
- `script`
- `nav`
- `button`
- `form`
- `section`
- `body`
- `header`
- `footer`
- `b`
- `source`
- `audio`
- `video`
- `tr`
- `th`
- `td`
- `hr`
- `progress`
- `option`
- `select`
- `select(name::String, options::Vector{Servable}, p::Pair{String, <:Any} ...; args ...)`
- `options(options::String ...)`
- `base64img(name::String, raw::Any, filetype::String = "png")`
- `textdiv`
- `textbox`
- `password`
- `numberinput`
- `rangeslider`
- `checkbox`
- `colorinput`
- `cursor`
- `context_menu!(menu::Component{<:Any})`
- `keyinput`
```
"""
const elements = 1

"""
```julia
DOCTYPE() -> ::String
```
In cases which utilize minimal HTML, it might be necessary to write the document 
type to the page. In this case, simply write the return of this `Function` to your `IO`.
---
```example
io = IOBuffer()

write!(io, DOCTYPE())
```
"""
DOCTYPE() = "<!DOCTYPE html>"

div(name::String, args::Any ...; keyargs ...) = Component{:div}(name, args ...; keyargs ...)
const img = Component{:img}
const link = Component{:link}
const meta = Component{:meta}
const input = Component{:input}
const a = Component{:a}
const p = Component{:p}
const ul = Component{:ul}
const li = Component{:li}
const br = Component{:br}
const i = Component{:i}
const title = Component{:title}
const span = Component{:span}
const iframe = Component{:iframe}
const svg = Component{:svg}
const h1 = Component{:h1}
const h2 = Component{:h2}
const h3 = Component{:h3}
const h5 = Component{:h5}
const h4 = Component{:h4}
const h6 = Component{:h6}
const element = Component{:element}
const label = Component{:label}
const script = Component{:script}
const nav = Component{:nav}
const button = Component{:button}
const form = Component{:form}
const section = Component{:section}
const body = Component{:body}
const header = Component{:header}
const footer = Component{:footer}
const b = Component{:b}
const source = Component{:source}
const audio = Component{:audio}
const video = Component{:video}
const table = Component{:table}
const tr = Component{:tr}
const th = Component{:th}
const td = Component{:td}
const hr = Component{:hr}
const progress = Component{:progress}
const option = Component{:option}

push!(s::AbstractComponent, d::AbstractComponent ...) = push!(s[:children], d ...)

"""
```julia
set_children!(comp::Component{<:Any}, children::Vector{<:Servable}) -> ::Nothing
```
`set_children!` sets the children of `comp` to `children`. Children can be accessed 
by indexing `:children` on a `Component`.
---
```example
comp = body("example-body")
mainheader = div("mainheader")
greeter = h3("greet", text = "welcome to my site")
set_children!(comp, [mainheader, greeter])
```
"""
set_children!(comp::Component{<:Any}, children::Vector{<:Servable}) = begin
    comp[:children] = Vector{AbstractComponent}(children)
    nothing
end

const style = Style

"""
```julia
style!(::AbstractComponent, ...) -> ::Nothing
```
`style!` is used to mutate the style of components and style components 
using CSS pairs, or in the case of components using a `Style` or `Animation`. 
`style!` will take a component followed by what to style that component with. 
This can be an infinite list of properties and values, the keys must be strings, 
(`?style_properties`) or a `Style`/`Animation`.
```julia
style!(c::AbstractComponent, s::Pair{String, <:Any} ...)
style!(c::Component{<:Any}, child::String, p::Pair{String, String} ...)
style!(comp::Component{<:Any}, sty::Style)
style!(sty::Style, anim::AbstractAnimation)
style!(comp::Component{<:Any}, anim::AbstractAnimation)
```
- See also: `keyframes`, `set_children!`, `style!`, `templating`, `measures`
---
```example
mycomp = div("mysample", text = "hello world!")
style!(mycomp, "display" => "inline-block", "background-color" => "black")

myclass = style("div.sample", "color" => "white")

style!(mycomp, myclass)
```
"""
function style! end

function style!(c::AbstractComponent, s::Pair{String, <:Any} ...)
    if ~(:style in keys(c.properties))
        c[:style] = ""
    end
    c[:style] = c[:style] * join("$(k[1]):$(k[2]);" for k in s)
    nothing
end

style!(c::Component{<:Any}, child::String, p::Pair{String, String} ...) = style!(c[:children][child], p ...)

function style!(sty::AbstractComponent, anim::AbstractAnimation)
    iters = anim.iterations
    if iters == 0
        iters = "infinite"
    end
    style!(sty, "animation-duration" => anim.duration, 
    "animation-name" => anim.name, "animation-iteration-count" => anim.iterations, 
    "animation-direction" => anim.direction)
    nothing
end

style!(sty::Style, s::Pair{String, <:Any}) = push!(sty.properties, s ...)

function style!(comp::Component{<:Any}, sty::Style)
    if contains(sty.name, comp.tag)
        clname::SubString = split(sty.name, ".")[1]
        comp[:class] = string(clname)
    elseif contains(sty.name, "#")
        comp[:class] = sty.name[2:length(sty.name)]
    else
        comp[:class] = sty.name
    end
    nothing
end

"""
```julia
keyframes(name::String) -> ::KeyFrames
```
Constructs a `:keyframes` `Animation`, which can have frames added with `keyframes!`. To `keyframes!` we provide, 
`to`, `from`, or a percentage with style pairs to create an animation.
---
```example
frames = keyframes()

keyframes!(frames, from, "opacity" => 0percent)
keyframes!(frames, to, "opacity" => 100percent)
# we may now use `style!`, making sure to `write!` our `Animation` as it is a `StyleComponent`.
mycomp = h2("heading", text = "this text fades in")

style!(mycomp, frames)
```
"""
keyframes = KeyFrames

function keyframes!(comp::KeyFrames, name::String, spairs::Pair{String, <:Any} ...)
    push!(comp.properties, name => join(("$(p[1]):$(p[2])" for p in spairs), ";"))
end

"""
```julia
select(name::String, options::Vector{<:AbstractComponent}, p::Pair{String, <:Any} ...; keyargs ...) -> ::Component{:select}
```
Creates a combobox components from a `Vector` of options. This provides 
a quick way to make a selection combobox using the 
`options(names::String ...)` Method and providing the return as the second 
positional argument to this `select` method. Both of these Components may also 
be constructed normally.
---
```example
myopts = options("emmy", "henry", "jessica")

mysel = select("mainselect", myopts, value = "henry")
```
"""
function select(name::String, options::Vector{<:AbstractComponent}, p::Pair{String, <:Any} ...; args ...)
    thedrop = Component(name, "select", p ..., args ...)
    thedrop["oninput"] = "\"this.setAttribute('value',this.value);\""
    thedrop[:children] = options
    thedrop::Component{:select}
end

"""
```julia
options(options::String ...s) -> ::Vector{AbstractComponent}
```
Provide `options` to a `select` to make a dropbox very quickly.
---
```example
myopts = options("emmy", "henry", "jessica")

mysel = select("mainselect", myopts, value = "henry")
```
"""
options(options::String ...) = Vector{AbstractComponent}([option(opt, text = opt) for opt in options])

function select(name::String,  p::Pair{String, <:Any} ...; args ...)
    thedrop = Component(name, "select", p ...; args ...)
    thedrop["oninput"] = "\"this.setAttribute('value',this.value);\""
    thedrop::Component{:select}
end

"""
```julia
base64img(name::String, raw::Any, filetype::String = "png", 
p::Pair{String, Any} ...; args ...) -> Component{:img}
```
Constructs a `Component{:img}`, making the `src` a `Base64` 
encoded version of the type `raw`. The `filetype` here is the `MIME` 
that is to be encoded into `Base64`. `raw` can be any type binded to 
`show` with this MIME -- a `Plot` from Plots.jl, or an `Image` from `Images`,
for example.
---
```example
using Plots
using ToolipsServables

plt = plot([5, 10, 12, 13], [4, 3, 1, 88])
img = base64img("myplot", plt)
# uses show(::IO, mime "image/**filetype**", ::Any) where `Any` is `plt`

o = IOBuffer()
write!(o, img)
```
"""
function base64img(name::String, raw::Any, filetype::String = "png",
    p::Pair{String, Any} ...; args ...)
    io::IOBuffer = IOBuffer();
    b64 = Base64.Base64EncodePipe(io)
    show(b64, "image/$filetype", raw)
    close(b64)
    mysrc::String = String(io.data)
    img(name, src = "'data:image/$filetype;base64," * mysrc * "'", p ...,
    args ...)::Component{:img}
end

"""
```julia
textdiv(name::String, p::Pair{String, <:Any} ...; text::String = "", keyargs ...) -> ::Component{:div}
```
A premade textdiv, includes a `raw'name'` `script` which stores the raw text, without 
spaces.
---
```example
mytdiv = textdiv("example", text = "sample")
```
"""
function textdiv(name::String, p::Pair{String, <:Any} ...; text::String = "",
    args ...)
    raw = element("raw$name")
    style!(raw, "display" => "none")
    box = div(name, p ..., contenteditable = true, text = text, rawtext = "`text`",
    caret = "0",
    oninput="document.getElementById('raw$name').innerHTML=document.getElementById('$name').textContent;getCaretIndex$(name)(this);",
    args ...)
    push!(box[:extras], raw)
    return(box)::Component{:div}
end

function textbox(name::String, range::UnitRange = 1:10, p::Pair{String, <:Any} ...;
    text::String = "", size::Integer = 10, args ...)
input(name, type = "text", minlength = range[1], maxlength = range[2],
value = text, size = size,
oninput = "\"this.setAttribute('value',this.value);\"", p ...,
args ...)::Component{:input}
end

function password(name::String, range::UnitRange = 1:10, p::Pair{String, Any} ...;
    text::String = "", size::Integer = 10, args ...)
input(name, type = "password", minlength = range[1], maxlength = range[2],
value = text, size = size,
oninput = "\"this.setAttribute('value',this.value);\"", p ...,
args ...)::Component{:input}
end

function numberinput(name::String, range::UnitRange = 1:10, p::Pair{String, Any} ...
    ; value::Integer = 5, args ...)
    input(name, type = "number", min = range[1], max = range[2],
    selected = value, oninput = "\"this.setAttribute('value',this.value);\"", p ...,
    args ...)::Component{:input}
end

function rangeslider(name::String, range::UnitRange = 1:100,
    p::Pair{String, <:Any} ...; value::Integer = 50, step::Integer = 5,
    args ...)
    input(name, type = "range", min = string(minimum(range)),
     max = string(maximum(range)), value = value, step = step,
            oninput = "\"this.setAttribute('value',this.value);\"", p ..., args ...)
end

function checkbox(name::String, p::Pair{String, <:Any} ...; value::Bool = false,
    args ...)
    ch = input(name, p  ..., type = "checkbox", value = value,
    oninput = "this.setAttribute('value',this.checked);", p ...; args ...)
    if value
        ch["checked"] = value
    end
    ch::Component{:input}
end

function colorinput(name::String, p::Pair{String, <:Any} ...;
    value::String = "#ffffff", args ...)
    input(name, type = "color", value = value,
    oninput = "\"this.setAttribute('value',this.value);\"", p ...;
    args ...)::Component{:input}
end

"""
```julia
cursor(name::String, args ...; args ...) -> ::Component{:script}
```
Creates a `cursor` `Component` (a `Component{:cursor}`). This is a special `Component` which 
tracks the `x` and `y` position of the cursor in its properties (`:x` and `:y` respectively.) 
Ideally, this is for use with a `ComponentModifier` from `ToolipsSession`.
---
```example
using Toolips
using Toolips.Components
using ToolipsSession

r = route("/") do c::Connection
    curs = cursor("example")
    bod = body("exbod")
    on(c, bod, "click") do cm::ComponentModifier
        alert!(cm, cm["example"]["x"])
    end
    push!(bod, curs)
    write!(c, bod)
end
```
"""
function cursor(name::String, p::Pair{String, Any} ...; args ...)
    cursor_updater = Component{:cursor}(name, p ..., tag = "script"; args ...)
    cursor_updater["x"], cursor_updater["y"] = 1, 1
    cursor_updater[:text] = """
    function updatecursor(event) {
        document.getElementById("$name").setAttribute("x", event.clientX);
        document.getElementById("$name").setAttribute("y", event.clientY);}
    document.getElementsByTagName("body")[0].addEventListener("mousemove", updatecursor);
   """
   cursor_updater::Component{:cursor}
end

"""
```julia
context_menu!(menu::Component{<:Any}) -> ::Component{:script}
```
Makes your `Component` a context menu -- a menu that appears when the page is right-clicked.
Note that this creates the same context menu across the page. If we wanted to right click individual items, 
we might instead `append!` something using a `ComponentModifier`. 
---
```example
comp = div("popup", text = "i pop up when you right click")
style!(comp, "background-color" => "dark-red", "color" => "white")
context_menu!(comp)

write!("", comp)
```
"""
function context_menu!(menu::Component{<:Any})
    name = menu.name
    scr = script("$name-script", text = """
const scope = document.querySelector("body");
    scope.addEventListener("contextmenu", (event) => {
    event.preventDefault();
    const { clientX: mouseX, clientY: mouseY } = event;
    document.getElementById("$name").style.top = `\${mouseY}px`;
    document.getElementById("$name").style.left = `\${mouseX}px`;
    document.getElementById("$name").style["opacity"] = 100;
    });""")
    push!(menu[:extras], scr)
    style!(menu, "opacity" => 0percent, "position" => "absolute")
    menu::Component{<:Any}
end

function keyinput(name::String, p::Pair{String, <:Any} ...; text = "w", args ...)
    button(name, p ..., text = text,
    onkeypress = "this.innerHTML=event.key;this.setAttribute('value',event.key);",
    onclick = "this.focus();", value = "W",  args ...)
end

function (:)(s::Style, name::String, ps::Vector{Pair{String, String}})
    newstyle = Style("$(s.name):$name", ps ...)
    push!(s[:extras], newstyle)
end

(:)(s::AbstractComponent, name::String) = s.properties[:extras][name]::AbstractComponent

(:)(s::String, spairs::Vector{Pair{String, <:Any}}) = Style(s, spairs ...)

(:)(s::StyleComponent ...) = begin
    Component{:sheet}(name, children = Vector{AbstractComponent}(s))
end

function (:)(sheet::Component{:sheet}, s::StyleComponent ...)
    sheet[:children] = vcat(sheet[:children], Vector{AbstractComponent}([comp for comp in s]))
end

(:)(sheet::Component{:sheet}, s::String, vec::Vector{Pair{String, String}}) = push!(sheet[:children], Style(s, vec ...))



mutable struct WebMeasure{format} end

*(i::Any, p::WebMeasure{<:Any}) = "$(i)$(typeof(p).parameters[1])"

"""
###### measures
`ToolipsServables` includes a number of *measurement constants* which 
help to facilitate high-level syntax. This includes a number of different 
constants which are applicable in a variety of different contexts. These measurement 
units are meant to be provided after a number.
```example
mybutton = button("example-button", text = "press me!")

style!(mybutton, "font-size" => 22pt, "border-radius" => 5px, "transition" => 800ms)
```
Here is a comprehensive list of measures for each application:
```julia
# size
px
pt
inch
pc
mm
cm
# relative size
perc, per, percent
em
# time
seconds, s
ms
# angles
deg
turn

# animation
to
from
perc, per, percent

# transforms, colors
rgba
translateX
translateY
rotate
matrix
skey
translate
scale
```
"""
const measures = WebMeasure
# size
const px = WebMeasure{:px}()
const pt = WebMeasure{:pt}()
const inch = WebMeasure{:in}()
const pc = WebMeasure{:pc}()
const mm = WebMeasure{:mm}()
const cm = WebMeasure{:cm}()
# relative size
const percent = WebMeasure{:%}()
const per = WebMeasure{:%}()
const perc = WebMeasure{:%}()
const em = WebMeasure{:em}()
# time
const seconds = WebMeasure{:s}()
const s = WebMeasure{:s}()
const ms = WebMeasure{:ms}()
# angles
const deg = WebMeasure{:deg}()
const turn = WebMeasure{:turn}()
# colors and transforms
function rgba(r::Number, g::Number, b::Number, a::Float64)
    "rgb($r $g $b $a / a)"
end

const from = "from"

const to = "to"

translateX(s::String) = "translateX($s)"
translateY(s::String) = "translateY($s)"
rotate(s::String) = "rotate($s)"
matrix(n::Int64 ...) = "matrix(" * join([string(i) for i in n], ", ") * ")"
translate(x::String, y::String) = "translate()"
skew(one::String, two::String) = "skew($one, $two)"
scale(n::Any, n2::Any) = "scale($one, $two)"
scale(n::Any) = "scale($n)"