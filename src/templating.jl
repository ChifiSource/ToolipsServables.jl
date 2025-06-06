

"""
The following is a *comprehensive list of all component elements. Elements are called 
with the first positional argument of a `String` and then infinite `Pair{String, <:Any}` and 
key-word arguments.
```example
dv = div("name", align = "center", text = "hello!")
```
A Component is *primarily* mutated with `style!`, `setindex!`, `push!`, and `set_children!`. After mutating, 
a `Component` can be turned directly into HTML by calling `string` on the `Component`.
```julia
my_example = div("sample")
# styling:
style!(my_example, "background-color" => "red")
buttons = [button("b\$e", text = "this is button \$e") for e in 1:5]

# setting children:
set_children!(my_example, buttons)

# editing arguments:
my_example["contenteditable"] = true
my_example[:contenteditable] = true

# :children, :extras, and :text are special keys.
# the extras are written before, and the text and children are written within the element.
```
There is also templating for CSS classes and keyframes, see `style` and `keyframes` for more information on those. 
    For scripting, `ToolipsServables` includes a JavaScript scripting interface in the `ClientModifier`. For more 
    information, see `ClientModifier` and `on`.
- See also: `templating`, `Component`, `arguments`, `div`, `body`, `a`, `measures`, `DOCTYPE`, `on`

Here is a comprehensive list of provided `Component` constants (and some `Method` bindings) for 
templating convenience. Note that some of these options do extra things or have extra dispatches -- 
for example, `select` and `options` both have alternate methods that make them far easier to work with.

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

To make a `Component` that isn't on this list, simply provide `Component{:tag}` in place of the constant names:
```julia
# we want a <circle> element:
new_circ = Component{:circle}()
```
"""
function templating end

"""
```julia
DOCTYPE() -> ::String
```
In cases which utilize minimal HTML, it might be necessary to write the document 
type to the page. In this case, simply write the return of this `Function` to your `IO`.
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
function script(name::String = "-", args ...; keyargs ...)
    Component{:script}(name, args ...; keyargs ...)
end
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
compress!(comp::AbstractComponent) -> ::Nothing
```
`compress!` will turn the `:children` of a given `Component` into its `:text`, 
resulting in the same `Component` with less memory usage. The trade-off to this is 
that we can no longer pull elements from the children.
```example
comp = body("example-body")
push!(comp, [div("sample", text = "hello", align = "center") for x in 1:1000])
# sizeof(comp)
compress!(comp)
# sizeof(comp)
```
"""
function compress!(comp::AbstractComponent)
    comp[:text] = comp[:text] * string(comp[:children])
    comp[:children] = Vector{AbstractComponent}()
    nothing::Nothing
end

"""
```julia
set_children!(comp::Component{<:Any}, children::Vector{<:Servable}) -> ::Nothing
```
`set_children!` sets the children of `comp` to `children`. Children can be accessed 
by indexing `:children` on a `Component`.
```example
comp = body("example-body")
mainheader = div("mainheader")
greeter = h3("greet", text = "welcome to my site")
set_children!(comp, [mainheader, greeter])
```
"""
set_children!(comp::Component{<:Any}, children::Vector{<:Servable}) = begin
    comp[:children] = Vector{AbstractComponent}(children)
    nothing::Nothing
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
# response-side style!
# style a `Component` directly:
style!(c::AbstractComponent, s::Pair{String, <:Any} ...)
# style a Component's child:
style!(c::Component{<:Any}, child::String, p::Pair{String, String} ...)
# set a `Component`'s class to a style's name.
style!(comp::Component{<:Any}, sty::Style)
style!(c::Component{<:Any}, classname::String)
# styles a style with the animation `anim`(be sure to write `anim`):
style!(sty::Style, anim::AbstractAnimation)
# styles a component with the animation `anim` (be sure to write `anim`):
style!(comp::Component{<:Any}, anim::AbstractAnimation)
```
- See also: `keyframes`, `set_children!`, `style!`, `templating`, `measures`
```example
mycomp = div("mysample", text = "hello world!")
style!(mycomp, "display" => "inline-block", "background-color" => "black")

myclass = style("div.sample", "color" => "white")

style!(mycomp, myclass)
```
"""
function style! end

function style!(c::Component{<:Any}, s::Pair{String, <:Any} ...)
    if ~(:style in keys(c.properties))
        c[:style] = ""
    end
    c[:style] = c[:style] * join("$(k[1]):$(k[2]);" for k in s)
    nothing
end

style!(c::Component{<:Any}, child::String, p::Pair{String, String} ...) = style!(c[:children][child], p ...)

style!(c::Component{<:Any}, classname::String) = c[:class] = classname

function style!(sty::AbstractComponent, anim::AbstractAnimation)
    iters = anim.iterations
    if string(iters) == "0"
        iters = "infinite"
    end
    style!(sty, "animation-duration" => anim.duration, 
    "animation-name" => anim.name, "animation-iteration-count" => iters)
    nothing
end

style!(sty::Style, s::Pair{String, <:Any} ...) = push!(sty.properties, (Symbol(p[1]) => string(p[2]) for p in s) ...)

function style!(comp::Component{<:Any}, sty::Style)
    if contains(sty.name, comp.tag)
        splts::Vector{SubString} = split(sty.name, ".")
        comp[:class] = string(join(splts[2:length(splts)]))
    elseif contains(sty.name, "#")
        comp[:class] = string(join(sty.name[2:length(sty.name)]))
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
```example
frames = keyframes("fadein")

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
```example
myopts = options("emmy", "henry", "jessica")

mysel = select("mainselect", myopts, value = "henry")
```
"""
function select(name::String, options::Vector{<:Servable}, p::Pair{String, <:Any} ...; value::Any = options[begin][:text], args ...)
    thedrop::Component{:select} = Component{:select}(name, p ..., value = value, args ...)
    thedrop["oninput"], thedrop["onload"] = "this.setAttribute('value',this.value);", "this.setAttribute('value','$value');"
    thedrop[:children]::Vector{AbstractComponent} = options
    thedrop::Component{:select}
end

"""
```julia
options(options::String ...s) -> ::Vector{AbstractComponent}
```
Provide `options` to a `select` to make a dropbox very quickly.
```example
myopts = options("emmy", "henry", "jessica")

mysel = select("mainselect", myopts, value = "henry")
```
"""
options(options::String ...) = Vector{AbstractComponent}([option(opt, text = opt) for opt in options])

function select(name::String,  p::Pair{String, <:Any} ...; value::Any = "", args ...)
    thedrop = Component{:select}(name, p ...; value = value, args ...)
    thedrop["oninput"], thedrop["onload"] = "this.setAttribute('value',this.value);", "this.setAttribute('value','$value');"
    thedrop::Component{:select}
end

"""
```julia
tmd(name::String, md::String = "", args::Pair{String, <:Any} ...; args ...) -> ::Component{:div}
```
Creates a `Component` directly from a raw markdown String. The `Component's` children will be 
the markdown provided rendered to HTML.
```example
mymd = "# hello\\n **this** is markdown"

comp = tmd("mygreeting", mymd)
```
"""
function tmd(name::String, s::String = "", p::Pair{String, <:Any} ...;
    args ...)
    md = Markdown.parse(replace(s * "\n", "<" => "", ">" => "", "\"" => ""))
    htm::String = html(md)
    div(name, text = rep_in(htm), p ...; args ...)::Component{:div}
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

# to make this work for strings:
show(b::Base64.Base64EncodePipe, m::MIME{<:Any}, s::AbstractString) = write(b, s)

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
    box = div(name, p ..., contenteditable = true, text = text, rawtext = "`text`", caret = "0",
    oninput="document.getElementById('raw$name').innerHTML=document.getElementById('$name').textContent;", args ...)
    push!(box[:extras], raw)
    return(box)::Component{:div}
end

"""
```julia
textdiv_caret_tracker!(comp::Component{:div}) -> 
```
Adds a caret tracking script to a `Component{:div}`, likely a `textdiv` given we are trying to track 
the text cursor. This function will add a new attribute, `caret`, to a `textdiv` alongside a script 
that tracks the updates its position. This way, we can access the `caret` through a `ComponentModifier`.
```example
mytdiv = textdiv("example", text = "sample")
text_div_caret_tracker!(mytdiv)

bind(mytdiv, "Enter") do cl::ClientModifier
    alert!(cl, cl["example", "caret"])
end
```
"""
function textdiv_caret_tracker!(comp::Component{:div})
    name = comp.name
    caretpos = script("caretposition", text = """
    function getCaretIndex$(name)(element) {
  let position = 0;
  const isSupported = typeof window.getSelection !== "undefined";
  if (isSupported) {
    const selection = window.getSelection();
    if (selection.rangeCount !== 0) {
      const range = window.getSelection().getRangeAt(0);
      const preCaretRange = range.cloneRange();
      preCaretRange.selectNodeContents(element);
      preCaretRange.setEnd(range.endContainer, range.endOffset);
      position = preCaretRange.toString().length;
    }
  }
  document.getElementById('$name').setAttribute('caret',position);
}
function createRange(node, chars, range) {
    if (!range) {
        range = document.createRange()
        range.selectNode(node);
        range.setStart(node, 0);
    }

    if (chars.count === 0) {
        range.setEnd(node, chars.count);
    } else if (node && chars.count >0) {
        if (node.nodeType === Node.TEXT_NODE) {
            if (node.textContent.length < chars.count) {
                chars.count -= node.textContent.length;
            } else {
                 range.setEnd(node, chars.count);
                 chars.count = 0;
            }
        } else {
            for (var lp = 0; lp < node.childNodes.length; lp++) {
                range = createRange(node.childNodes[lp], chars, range);

                if (chars.count === 0) {
                   break;
                }
            }
        }
   }

   return range;
};

function setCaretPosition$name(pos) {
	// Get the editable div
	let el = document.getElementById('$name');
	let range = document.createRange();
	let selection = window.getSelection();

	// Helper function to find the correct text node and offset
	function getTextNodeAtPosition(root, index) {
		let nodeStack = [root], node, foundNode = null;
		while (nodeStack.length > 0) {
			node = nodeStack.pop();
			if (node.nodeType === Node.TEXT_NODE) {
				if (index <= node.length) {
					foundNode = node;
					break;
				}
				index -= node.length;
			} else {
				for (let i = node.childNodes.length - 1; i >= 0; i--) {
					nodeStack.push(node.childNodes[i]);
				}
			}
		}
		return { node: foundNode, offset: index };
	}

	// Find the correct text node and offset
	let { node, offset } = getTextNodeAtPosition(el, pos);

	// If we found a valid node, set the caret position
	if (node) {
		range.setStart(node, offset);
		range.collapse(true);
		selection.removeAllRanges();
		selection.addRange(range);
	}
}""")
    push!(comp[:extras], caretpos)
    comp[:oninput] = comp[:oninput] * "getCaretIndex$(name)(this);"
    comp::Component{:div}
end

"""
```julia
textbox(name::String, range::UnitRange = 1:10, args::Pair{String, <:Any} ...; text::String = "", 
size::Integer = 10, keyargs ...) -> ::Component{:input}
```
Creates an `input` `Component` of type `text` -- using this `Function` will 
automatically set the `value` of the `textbox` for a `ComponentModifier`.
```example
mybox = textbox("sample", 1:10)
```
"""
function textbox(name::String, range::UnitRange = 1:10, p::Pair{String, <:Any} ...;
    text::String = "", size::Integer = 10, args ...)
    input(name, type = "text", minlength = range[1], maxlength = range[2],
    value = text, size = size, oninput = "this.setAttribute('value',this.value);", p ...; args ...)::Component{:input}
end

"""
```julia
password(name::String, range::UnitRange = 1:10, args::Pair{String, <:Any} ...; text::String = "", 
size::Integer = 10, value::Integer = range[1], keyargs ...) -> ::Component{:input}
```
Creates an `input` `Component` of type `password` -- using this `Function` will 
automatically set the `value` of the `password` box for a `ComponentModifier`.
```example
mybox = textbox("sample", 1:10)
```
"""
function password(name::String, range::UnitRange = 1:10, p::Pair{String, Any} ...;
    text::String = "", size::Integer = 10, value::Integer = range[1], args ...)
    input(name, type = "password", minlength = range[1], maxlength = range[2],
    value = text, size = size, oninput = "this.setAttribute('value',this.value);", p ...; args ...)::Component{:input}
end

"""
```julia
numberinput(name::String, range::UnitRange = 1:10, args::Pair{String, <:Any} ...; text::String = "", 
size::Integer = 10, keyargs ...) -> ::Component{:input}
```
Creates a number input component (`Component{:input}`). `value` will be set for 
a `ComponentModifier`, the default value will be the first step in `range`.
```example
num_inp = numberinput("sample", range = 30:40, value = 35)
```
"""
function numberinput(name::String, range::UnitRange = 1:10, p::Pair{String, Any} ...
    ; selected::Integer = 5, args ...)
    input(name, type = "number", min = range[1], max = range[2],
    selected = selected, oninput = "this.setAttribute('selected',this.value);", p ...;
    args ...)::Component{:input}
end

"""
```julia
rangeslider(name::String, range::UnitRange{Int64} = 1:100, args::Pair{String, <:Any} ...;
value::Integer = 50, step::Integer = 5) -> `Component{:input}`
```
Creates a `Component{:input}` of type "range".
```example
slider = rangeslider("sample", 1:500, value = 1, step = 50)
```
"""
function rangeslider(name::String, range::UnitRange = 1:100,
    p::Pair{String, <:Any} ...; value::Integer = 50, step::Integer = 5,
    args ...)
    input(name, type = "range", min = string(minimum(range)),
     max = string(maximum(range)), value = value, step = step,
            oninput = "'this.setAttribute('value',this.value);'", p ...; args ...)::Component{:input}
end

"""
```julia
checkbox(name::String, p::Pair{String, <:Any} ...; value::Bool = false,
    args ...) -> ::Component{:input}
```
Creates a `Component{:input}` of type `checkbox`. Will update `value` as it is checked.
```example
box = checkbox("example", value = true)
```
"""
function checkbox(name::String, p::Pair{String, <:Any} ...; value::Bool = false,
    args ...)
    ch = input(name, p  ..., type = "checkbox", value = value,
    oninput = "this.setAttribute('value',this.checked);", p ...; args ...)
    if value
        ch["checked"] = value
    end
    ch::Component{:input}
end

"""
```julia
colorinput(name::String, p::Pair{String, <:Any} ...;
    value::String = "#ffffff", args ...) -> ::Component{:input}
```
Creates a `Component{:input}` of type `checkbox`. Will update `value` as it is checked.
```example
colorbox = colorinput("mycolors", value = "#ddd3de")
```
"""
function colorinput(name::String, p::Pair{String, <:Any} ...;
    value::String = "#ffffff", args ...)
    input(name, type = "color", oninput = "this.setAttribute('value',this.value);", 
    value = value, p ...; args ...)::Component{:input}
end

"""
```julia
cursor(name::String, args ...; args ...) -> ::Component{:script}
```
Creates a `cursor` `Component` (a `Component{:cursor}`). This is a special `Component` which 
tracks the `x` and `y` position of the cursor in its properties (`:x` and `:y` respectively.) 
Ideally, this is for use with a `ComponentModifier` from `ToolipsSession`.
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
    cursor_updater = Component{:cursor}(name, p ..., tag = "script", x = 1, y = 1, scrolly = 1, scrollx = 1; args ...)
    cursor_updater[:text] = """
    function updatecursor(event) {
        document.getElementById("$name").setAttribute("x", event.clientX);
        document.getElementById("$name").setAttribute("y", event.clientY);
        document.getElementById("$name").setAttribute("scrollx", window.scrollX);
        document.getElementById("$name").setAttribute("scrolly", window.scrollY);
        }
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

"""
```julia
keyinput(name::String, p::Pair{String, <:Any} ...; text = "W", args ...) -> ::Component{:keyinput}
```
Creates a customized `Component` that is clicked to register the next key-press. This is useful for binding 
controls, for example. The `value` of the `keyinput` will become the key that is pressed. Note that 
you cannot bind the `keypress` or `click` events of this `Component`, as these are used to create the 
component's functionality. Ideally, this `Component` is used alongside a submit button.
```example
comp = div("popup", text = "i pop up when you right click")
style!(comp, "background-color" => "dark-red", "color" => "white")
context_menu!(comp)

write!("", comp)
```
"""
function keyinput(name::String, p::Pair{String, <:Any} ...; text = "W", args ...)
    Component{:keyinput}(name, p ..., text = text, tag = "button",
    onkeypress = "this.innerHTML=event.key;this.setAttribute('value',event.key);",
    onclick = "this.focus();", value = text,  args ...)
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
function rgba(r::Any, g::Any, b::Any, a::Any = 1.0)
    "rgb($r,$g,$b,$a)"::String
end

const from = "from"

const to = "to"

translateX(a::Any) = "translateX($a)"
translateY(a::Any) = "translateY($a)"
scale(a::Any) = "scale($a)"
skew(a::Any) = "skew($a)"

"""
```julia
abstract type Modifier <: Servable
```
A `Modifier` is a type used to create handler callbacks for front-end development. 
These are typically passed as an argument to a function to make some type of changes.
- See also: `AbstractComponentModifier`, `ClientModifier`, `Component`, `on`, `bind`
"""
abstract type Modifier <: Servable end

"""
```julia
abstract type AbstractComponentModifier <: Modifier
```
An `AbstractComponentModifier` is a `Modifier` for components. `Toolips` 
features the `ClientModifier`. This is a limited `ComponentModifier` that 
can be used to execute some commands on the client-side. The shortcoming is that 
we never call the server, so nothing can be done in Julia.
```julia
route("/") do c::Connection
    comp = button("testbutton", text = "press me")
    on(comp, "click") do cl::ClientModifier
        alert!(cl, "you pressed me!")
    end
    bod = body("mainbody")
    push!(bod, comp)
    write!(c, bod)
end
```
For server-side responses, add `ToolipsSession` and use the `ComponentModifier`.
- See also: `ClientModifier`, `Modifier`, Component`, `on`, `bind`
"""
abstract type AbstractComponentModifier <: Modifier end

script(cl::AbstractComponentModifier) = begin
    script(cl.name, text = join(cl.changes))
end

setindex!(cm::AbstractComponentModifier, p::Pair, s::Any) = begin
    if typeof(s) <: AbstractComponent
        s = s.name
    end
    key, val = p[1], p[2]
    push!(cm.changes,
    "document.getElementById('$s').setAttribute('$key','$val');")
end

"""
```julia
abstract type AbstractClientModifier <: AbstractComponentModifier 
```
A `ClientModifier` is a type of `Modifier` that runs exclusively on the client, rather than ever 
making a call back to Julia. This is useful to save some performance in certain contexts, simplify certain calls, 
or add interactivity without `Session` or outside of the server context.
- See also: `AbstractComponentModifier`, `ClientModifier`, `Component`, `on`, `bind`
"""
abstract type AbstractClientModifier <: AbstractComponentModifier end

"""
```julia
ClientModifier <: AbstractClientModifier
```
- name**::String**
- changes**::Vector{String}**

A `ClientModifier` helps to template functions on the client-side. These are 
ran without the use of the server. Base `Toolips` does not include server-handled callbacks. 
The downside to client-side callbacks is that they are limited in what they can do. 
We cannot retrieve data from or use julia for this response. All of the code server-side 
    will be ran on the initial response with this type. `ToolipsSession` provides the `ComponentModifier`, 
    which will provide a lot more capabilities as far as this goes.
    
- See also: `keyframes`, `style!`, `style`, `StyleComponent`, `templating`
```julia
ClientModifier(name::String = gen_ref())
```
An `AbstractComponentModifier` will typically be used with `on`. For a client-side `on` 
event, simply call `on` on a `Component` with the event selected:
```example
module NewServer
using Toolips
using Toolips.Components
route("/") do c::Connection
    butt = button("mainbutton", text = "click me")
    style!(butt, "padding" => 10px, "background-color" => "darkred", 
    "color" => "white")
    on(butt, "click") do cl::ClientModifier
        style!(cl, butt, "transform" => translateX(20percent))
    end
    write!(c, butt)
end
```
Adding `ToolipsSession` will allow us to add server-side callbacks by 
adding `Connection` to our `on` call will create a server-side callback, 
which allows us to read back `Component` properties
```julia
on(c, butt, "click") do cm::ComponentModifier
    sample::String = cm[butt]["text"]
end
```
Here is an example which indexes a `Component{:property}` from a `ClientModifier`.
```julia
route("/") do c::Connection
                                # v   text     #  v  arg
    textbox = textdiv("sample", text = "example", x = 5)
    on(textbox, "focus") do cl::ClientModifier
        set_text!(cl, textbox, "")
    end
    confirmbutt = button("butt", text = "confirm")
    on(confirmbutt, "click") do cl::ClientModifier
        prop = cl["confirm"]

    end
end
```
"""
mutable struct ClientModifier <: AbstractClientModifier
    name::String
    changes::Vector{String}
    ClientModifier(name::String = gen_ref(5)) = begin
        new(name, Vector{String}())::ClientModifier
    end
end

function script(f::Function, s::String = gen_ref(5))
    cl = ClientModifier(s)
    f(cl)
    script(cl.name, text = funccl(cl))::Component{:script}
end

#== do you understand now?
Does this begin to make it make sense? What all this effort was worth.
    `Component{:property}` is so cool.
==#
string(comp::Component{:property}) = comp.name

"""
```julia
get_text(cl::AbstractClientModifier, name::String) -> ::Component{:property}
```
`get_text` is used to retrieve the text of a `Component` in a `ClientModifier`. 
The `Component{:property}` can then be used with `setindex!`.

The following example is the function that makes the searchbar for the 
    `Toolips` app. This simple searchbar uses `get_text` and `redirect_args!` to 
    redirect the client with new `GET` arguments. This is a simple way to create a 
    complex website without using callbacks.
```example
function make_searchbar(text::String)
    scontainer = div("searchcontainer")
    style!(scontainer, "background" => "transparent", 
    "left" => 18perc, "width" => 92perc, "z-index" => "10", "display" => "flex")
    sbar = a("searchbar", text = "enter search ...", contenteditable = true)
    barstyle = ("padding" => 5px, "border-radius" => 1px, "background-color" => "#0b0930", "color" => "white", 
    "font-weight" => "bold", "font-size" => 15pt)
    style!(sbar, "width" => 40percent, "width" => 85perc, "min-width" => 85perc, barstyle ...)
    sbutton = button("sbutton", text = "search")
    style!(sbutton, barstyle ...)
    on(sbar, "click") do cl
        set_text!(cl, sbar, "")
    end
    on(sbutton, "click") do cl
        proptext = get_text(cl, "searchbar")
        redirect_args!(cl, "/docs", :search => proptext)
    end
    push!(scontainer, sbar, sbutton)
    scontainer
end
```
"""
function get_text(cl::AbstractClientModifier, name::String)
    Component{:property}("document.getElementById('$name').textContent")
end

setindex!(cm::AbstractClientModifier, name::String, property::String, comp::Component{:property}) = begin
    push!(cm.changes, "document.getElementById('$name').setAttribute('$property',$comp);")
end

getindex(cl::AbstractClientModifier, name::String, prop::String) = begin
    if prop == "text"
        Component{:property}("document.getElementById('$name').textContent")
    else
        Component{:property}("document.getElementById('$name').getAttribute('$prop');")
    end
end

string(cl::AbstractComponentModifier) = join(cm.changes)

"""
```julia
funccl(cm::ClientModifier, name::String = cm.name) -> ::String
```
Converts a `ClientModifier` to a JavaScript `Function`.
```example
module MyServer
using Toolips

logger = Toolips.Logger()

home = route("/") do c::Connection
    log(c, "hello server!")
    write!(c, "hello client!")
end

export home, logger
end
```
"""
function funccl(cm::ClientModifier = ClientModifier(), name::String = cm.name)
    name = replace(name, "-" => "")
    """function $(name)(event){$(join(cm.changes))}"""
end

"""
```julia
on(f::Function, ...) -> ::Nothing/::Component{:script}
```
`on` is used to register events to components or directly to pages using 
Javascript's EventListeners. `on` will generally be passed a `Component` and 
an event.
```julia
on(f::Function, component::Component{<:Any}, event::String) -> ::Nothing
on(f::Function, event::String) -> ::Component{:script}
```
```julia
# call in a certain amount of time, rather than on an event.
on(f::Function, comp::AbstractComponentModifier, perform_in::Integer; recurring::Bool = false)
on(f::Function, perform_in::Integer; recurring::Bool = false)
```
- See also: `ClientModifier`, `move!`, `remove!`, `append!`, `set_children!`, `bind`, `ToolipsServables`
```example
module MyServer
using Toolips
using Toolips.Components

home = route("/") do c::Connection
    mybutton = div("mainbut", text = "click this button")
    style!(mybutton, "border-radius" => 5px)
    on(mybutton, "click") do cl::ClientModifier
        alert!(cl, "hello world!")
    end
    write!(c, mybutton)
end

export home
end
```
"""
function on end

function on(f::Function, component::Component{<:Any}, event::String)
    cl::ClientModifier = ClientModifier("$(component.name)$(event)")
    f(cl)
    component["on$event"] = "$(cl.name)(event);"
    push!(component[:extras], script(cl.name, text = funccl(cl)))
    nothing::Nothing
end

function on(f::Function, event::String)
    cl = ClientModifier(); f(cl)
    scrpt = """addEventListener('$event', $(funccl(cl)));"""
    script("doc$event", text = scrpt)
end

on(f::Function, perform_in::Integer; recurring::Bool = false) = begin
    clientmod = ClientModifier()
    f(clientmod)
    type::String = "Timeout"
    if recurring
        type = "Interval"
    end
    script(text = "new Promise(resolve => set$type($(funccl(clientmod, gen_ref(4))), $(perform_in)));")
end

on(f::Function, comp::AbstractComponentModifier, perform_in::Integer; recurring::Bool = false) = begin
    clientmod = ClientModifier()
    f(clientmod)
    type::String = "Timeout"
    if recurring
        type = "Interval"
    end
    push!(comp.changes, 
    "set$type($(funccl(clientmod, gen_ref(4))), $(perform_in));")
end


function on(f::Function, cm::AbstractComponentModifier, name::String = gen_ref(3);
    time::Integer = 1000, recurring::Bool = false)
    clientmod = ClientModifier()
    f(clientmod)
    type::String = "Timeout"
    if recurring
        type = "Interval"
    end
    push!(cm.changes,
    "new Promise(resolve => set$type($(funccl(clientmod, name)), $time));")
end

"""
```julia
bind(f::Function, key::String, eventkeys::Symbol ...; on::Symbol = :down) -> ::Component{:script}
```
`bind` is used to bind inputs other than clicks and drags to a `Component` or `Connection`.
This `bind!` simply generates a `Component{:script}` that will bind keyboard events.
- See also: `ClientModifier`, `on`, `set_text!`, `set_children!`, `alert!`
```example
module MyServer
using Toolips
using Toolips.Components

home = route("/") do c::Connection
    scr = bind("Z", :ctrl) do cl::ClientModifier
        alert!(cl, "undo")
    end
end

export home
end
```
"""
function bind end

function bind(f::Function, key::String, eventkeys::Symbol ...; on::Symbol = :down)
    eventstr::String = join(" event.$(event)Key && " for event in eventkeys)
    cl = ClientModifier()
    f(cl)
    script(cl.name, text = """addEventListener('key$on', function(event) {
            if ($eventstr event.key == "$(key)") {
            $(join(cl.changes))
            }
            });""")
end

"""
```julia
move!(cm::AbstractComponentModifier, p::Pair{<:Any, <:Any}) -> ::Nothing
```
`move!` is a `ComponentModifier` `Function` that will move a `Component` into 
another `Component`. The values of `p` -- as is the case in most `ComponentModifier` functions which take 
a `Component` -- can be `Component` names or the Components themselves. The key of the `Pair` 
will become the child of the value.
```example
using Toolips
home = route("/") do c::Connection
    child = div("moved", text = "hello")
    parent = div("movedinto")
    style!(parent, "margin" => 10px, "background-color" => "red")
    on(c, parent, "click") do cl::ClientModifier
        move!(cl, "moved" => "movedinto")
    end
    write!(c, child, parent)
end
```
"""
function move!(cm::AbstractComponentModifier, p::Pair{<:Any, <:Any})
    firstname = p[1]
    secondname = p[2]
    if typeof(firstname) <: AbstractComponent
        firstname = firstname.name
    end
    if typeof(secondname) <: AbstractComponent
        secondname = secondname.name
    end
    push!(cm.changes, "
    document.getElementById('$secondname').appendChild(document.getElementById('$firstname'));
  ")
  nothing::Nothing
end

function set_textdiv_cursor!(cm::AbstractComponentModifier, name::Any, pos::Any)
    if typeof(name) <: AbstractComponent
        name = name.name
    end
    push!(cm.changes, "setCaretPosition$(name)($pos);")
end

"""
```julia
remove!(cm::AbstractComponentModifier, s::Any) -> ::Nothing
```
`remove!` is a `ComponentModifier` `Function` that will remove a `Component` 
from the page. `s` can be either a `String`, the component's `name` or the 
`Component` itself.
```example
using Toolips
home = route("/") do c::Connection
    box = div("sample")
    style!(box, "margin" => 10px, "background-color" => "red")
    on(c, box, "click") do cl::ClientModifier
        remove!(cl, "sample")
    end
    write!(c, box)
end
```
"""
function remove!(cm::AbstractComponentModifier, s::Any)
    if typeof(s) <: AbstractComponent
        s = s.name
    end
    push!(cm.changes, "document.getElementById('$s').remove();")
    nothing::Nothing
end

"""
```julia
set_text!(c::AbstractComponentModifier, s::Any, txt::Any) -> ::Nothing
```
Sets the text of the `Component` (or `Component` `name`) `s`. `txt` can also be a `Component{:property}`
```example
using Toolips
home = route("/") do c::Connection
    mytextbox = div("sampletext", text = "text will change", align = "center")
    changetxt = button("changer", text = "change text", align = "center")
    on(changetxt, "click") do cl::ClientModifier
        set_text!(cl, mytextbox, "text changed!")
    end
    write!(c, mytextbox, changetxt)
end
```
"""
function set_text!(c::AbstractComponentModifier, s::Any, txt::Any)
    if typeof(s) <: AbstractComponent
        s = s.name
    end
    if typeof(txt) <: AbstractComponent
        txt = string(s)
    end
    txt = replace(txt, "`" => "\\`", "\"" => "\\\"", "''" => "\\'", "\n" => "<br>")
    push!(c.changes, "document.getElementById('$s').innerHTML = `$txt`;")
    nothing::Nothing
end

"""
```julia
set_children!(cm::AbstractComponentModifier, s::Any, v::Vector{<:Servable}) -> ::Nothing
```
`set_children!` will set the children of `s`, a `Component` or `Component`'s `name`, to `v` in a callback.
```example
using Toolips
home = route("/") do c::Connection
    mychildbox = div("sampletext", text = "text will change", align = "center")
    change = button("changer", text = "change text")
    on(change, "click") do cl::ClientModifier
        childs = [div("sample", text = string(x)) for x in 1:5]
        set_children!(cl, mychildbox, childs)
    end
    write!(c, mychildbox, change)
end
```
"""
function set_children!(cm::AbstractComponentModifier, s::Any, v::Vector{<:Servable})
    if typeof(s) <: AbstractComponent
        s = s.name
    end
    set_text!(cm, s, join(string(serv) for serv in v))::Nothing
end

"""
```julia
append!(cm::AbstractComponentModifier, name::Any, child::AbstractComponent) -> ::Nothing
```
Appends the `Component` `child` to the `Component` or `Component `name` provided in the argument `name`.
```example
using Toolips
home = route("/") do c::Connection
    mychildbox = div("sampletext", text = "text will change", align = "center")
    change = button("changer", text = "change text")
    on(change, "click") do cl::ClientModifier
        newsect = a("anchor", text = "hello")
        style!(newsect, "opacity" => 50percent, "color" => "red")
        append!(cl, mychildbox, newsect)
    end
    write!(c, mychildbox, change)
end
```
"""
function append!(cm::AbstractComponentModifier, name::Any, child::AbstractComponent)
    if typeof(name) <: AbstractComponent
       name = name.name
    end
    txt::String = replace(string(child), "`" => "\\`", "\"" => "\\\"", "'" => "\\'")
    push!(cm.changes, "document.getElementById('$name').appendChild(document.createRange().createContextualFragment(`$txt`));")
    nothing::Nothing
end

"""
```julia
insert!(cm::AbstractComponentModifier, name::String, i::Int64, child::AbstractComponent) -> ::Nothing
```
Inserts `child` into `name` (a `Component` or its `name`) at index `i`. Note that, in true Julia fashion, 
indexes start at 1.
```example
using Toolips
home = route("/") do c::Connection
    mychildbox = div("sampletext", text = "text will change", align = "center")
    change = button("changer", text = "change text")
    firstsect = a("an", text = "initial message")
    push!(mychildbox, firstsect)
    on(change, "click") do cl::ClientModifier
        newsect = a("anchor", text = "second message")
        style!(newsect, "opacity" => 50percent, "color" => "red")
        insert!(cl, mychildbox, 1, newsect)
    end
    write!(c, mychildbox, change)
end
```
"""
function insert!(cm::AbstractComponentModifier, name::String, i::Int64, child::AbstractComponent)
    txt::String = replace(string(child), "`" => "\\`", "\"" => "\\\"", "'" => "\\'")
    push!(cm.changes, "document.getElementById('$name').insertBefore(document.createRange().createContextualFragment(`$txt`), document.getElementById('$name').children[$(i - 1)]);")
    nothing::Nothing
end

"""
```julia
sleep!(cm::AbstractComponentModifier, time::Any) -> ::Nothing
```
`sleep!` will cause a client-side timeout for `time` milliseconds. This can be used to delay 
different actions in a callback, which might be especially useful in the `ClientModifier` context.
```example
using Toolips
home = route("/") do c::Connection
    mychildbox = div("sampletext", text = "text will change", align = "center")
    change = button("changer", text = "change text")
    firstsect = a("an", text = "initial message")
    push!(mychildbox, firstsect)
    on(change, "click") do cl::ClientModifier
        newsect = a("anchor", text = "second message")
        style!(newsect, "opacity" => 50percent, "color" => "red")
        insert!(cl, mychildbox, 1, newsect)
        sleep!(cl, 500)
        style!(cl, change, "background-color" => "black", "color" => "white")
    end
    write!(c, mychildbox, change)
end
```
"""
function sleep!(cm::AbstractComponentModifier, time::Any)
    push!(cm.changes, "await new Promise(r => setTimeout(r, $time));")
    nothing::Nothing
end

"""
```julia
style!(cm::AbstractComponentModifier, name::Any, sty::Pair{String, <:Any} ...) -> ::Nothing
```
Styles `name` with the stylepairs `sty` in a callback. Note that `style!` will only add to the style, 
whereas `set_style!` may be used to change the style. `name` should be a `Component` or a `Component`'s name.
```example
using Toolips
home = route("/") do c::Connection
    change = button("changer", text = "change text")
    on(change, "click") do cl::ClientModifier
        style!(cl, change, "background-color" => "green", "color" => "white")
    end
    write!(c, change)
end
```
"""
function style!(cm::AbstractComponentModifier, name::Any, sty::Pair{String, <:Any} ...)
    if typeof(name) <: AbstractComponent
        name = name.name
    end
    push!(cm.changes,
        join(("document.getElementById('$name').style['$(p[1])'] = '$(p[2])';" for p in sty)))
    nothing::Nothing
end

"""
```julia
set_style!(cm::AbstractComponentModifier, name::Any, sty::Pair{String, <:Any} ...) -> ::Nothing
```
Sets the style of the `Component` `name` (provided as itself or its `Component.name`) to `sty` in a callback. 
Note that this function sets style, removing all previous styles. In order to simply add to the style, or alter it, 
    use `style!(::AbstractComponentModifier, ...)`.
```example
using Toolips
home = route("/") do c::Connection
    change = button("changer", text = "change text")
    style!(change, "color" => "white", "background-color" => "darkred")
    on(change, "click") do cl::ClientModifier
        set_style!(cl, change, "background-color" => "green")
    end
    write!(c, change)
end
```
"""
function set_style!(cm::AbstractComponentModifier, name::Any, sty::Pair{String, <:Any} ...)
    sstring::String = join(("$(p[1]):$(p[2])" for p in sty), ";")
    if typeof(name) <: AbstractComponent
        name = name.name
    end
    push!(cm.changes, "document.getElementById('$name').style = '$sstring'")
    nothing::Nothing
end

"""
```julia
alert!(cm::AbstractComponentModifier, s::String) -> ::Nothing
```
Alerts the client with the `String` `s` in a callback. This will present a small 
dialog popup on the client's system with `s` as the message.
```example
module Server
using Toolips
home = route("/") do c::Connection
    albutt = button("changer", text = "alert me!")
    style!(change, "color" => "white", "background-color" => "darkred")
    on(albutt, "click") do cl::ClientModifier
        alert!(cl, "hello world!")
    end
    write!(c, albut)
end

export home, start!
end
```
"""
alert!(cm::AbstractComponentModifier, s::String) = push!(cm.changes, "alert('$s');"); nothing::Nothing

alert!(cm::AbstractComponentModifier, prop::Component{:property}) = push!(cm.changes, "alert($(string(prop)));")

"""
```julia
focus!(cm::AbstractComponentModifier, name::String) -> ::Nothing
```
Focuses the `Component` provided in `name` in a callback from the `Client`. `name` will be either 
a `Component`, or the `Component`'s `name`. `focus!` will put the user's cursor/text input into the element. 
The inverse to `focus!` is `blur!`.
```example
using Toolips
home = route("/") do c::Connection
    tbox = textdiv("sample")
    style!(tbox, "background-color" => "red", "color" => "white", "padding" => 5px)
    change = button("changer", text = "enter your name")
    on(change, "click") do cl::ClientModifier
        focus!(cl, tbox)
    end
    write!(c, tbox, change)
end
```
"""
function focus!(cm::AbstractComponentModifier, name::Any)
    if typeof(name) <: AbstractComponent
        name = name.name
    end
    push!(cm.changes, "document.getElementById('$name').focus();")
end

"""
```julia
blur!(cm::AbstractComponentModifier, name::Any) -> ::Nothing
```
Un-focuses the `Component` provided in `name` in a callback from the `Client`. `name` will be either 
a `Component`, or the `Component`'s `name`. This will unselect the currently focused element, the inverse of 
`focus!`
```example
module Server
using Toolips

home = route("/") do c::Connection
    tbox = textdiv("sample")
    style!(tbox, "background-color" => "red", "color" => "white", "padding" => 5px)
    change = button("changer", text = "enter your name")
    on(change, "click") do cl::ClientModifier
        focus!(cl, tbox)
        sleep!(cl, 20)
        blur!(cl, tbox)
    end
    write!(c, tbox, change)
end

export home, start!
end
```
"""
function blur!(cm::AbstractComponentModifier, name::Any)
    if typeof(name) <: AbstractComponent
        name = name.name
    end
    push!(cm.changes, "document.getElementById('$name').blur();")
    nothing::Nothing
end

"""
```julia
redirect!(cm::AbstractComponentModifier, url::AbstractString, ...; new_tab::Bool = false) -> ::Nothing
```
`redirect!` will cause the client to send a `GET` request to `url`. `delay` can be used to add a millisecond delay. 
This can also be used for navigating users around your website. It might also be useful to check out `redirect_args!` 
    for redirecting a `ClientModifier` with arguments.
```julia
# regular redirect:
redirect!(cm::AbstractComponentModifier, url::AbstractString, delay::Int64 = 0; new_tab::Bool = false) -> ::Nothing

# redirect a client with arguments from a `ClientModifier`.
redirect!(cm::AbstractComponentModifier, url::AbstractString, with::Pair{Symbol, Component{:property}} ...; 
delay::Int64 0, new_tab::Bool = false) ->::Nothing
```
```example
using Toolips
home = route("/") do c::Connection
    change = button("changer", text = "go to github")
    on(change, "click") do cl::ClientModifier
        redirect!(cl, "https://github.com/")
    end
    write!(c, hange)
end

# redirecting with arguments (no `ToolipsSession` required!):
function make_searchbar(text::String)
    scontainer = div("searchcontainer")
    style!(scontainer, "background" => "transparent", 
    "left" => 18perc, "width" => 92perc, "z-index" => "10", "display" => "flex")
    sbar = a("searchbar", text = "enter search ...", contenteditable = true)
    barstyle = ("padding" => 5px, "border-radius" => 1px, "background-color" => "#0b0930", "color" => "white", 
    "font-weight" => "bold", "font-size" => 15pt)
    style!(sbar, "width" => 40percent, "width" => 85perc, "min-width" => 85perc, barstyle ...)
    sbutton = button("sbutton", text = "search")
    style!(sbutton, barstyle ...)
    on(sbar, "click") do cl
        set_text!(cl, sbar, "")
    end
    on(sbutton, "click") do cl
        proptext = get_text(cl, "searchbar")
        redirect_args!(cl, "/docs", :search => proptext)
    end
    push!(scontainer, sbar, sbutton)
    scontainer
end
```
"""
function redirect!(cm::AbstractComponentModifier, url::AbstractString, delay::Int64 = 0; new_tab::Bool = false)
    if new_tab
        push!(cm.changes, """setTimeout(
        function () {window.open('$url', '_blank').focus();}, $delay);""")
        return
    end
    push!(cm.changes, """setTimeout(
    function () {window.location.href = "$url";}, $delay);""")
end

function redirect!(cm::AbstractComponentModifier, url::AbstractString, with::Pair{Symbol, Component{:property}} ...; 
    delay::Int64 = 0, new_tab::Bool = false)
    args = join(("'$(w[1])=' + $(w[2].name)" for w in with), " + ")
    if new_tab
        push!(cm.changes, """setTimeout(
        function () {window.open('$url', '_blank').focus();}, $delay);""")
        return
    end
    push!(cm.changes, """setTimeout(
    function () {window.location.href = "$url" + "?" + $args;}, $delay);""")
    nothing::Nothing
end

"""
```julia
next!(f::Function, cl::AbstractComponentModifier, comp::Any) -> ::Nothing
```
`next!` creates a sequence of events to occur after a component's transition as ended. `comp` can be 
the component's `name` or the `Component` itself. Note that the `Component` has to be in a transition to 
use `next!`, which means we will need to mutate its style. For simply creating a delay, there is `sleep!` -- 
among other options. `next!` is ideal for multi-stage client-side animations, and interactive multi-stage callbacks.
```example
module AmericanServer
using Toolips
home = route("/") do c::Connection
    change = button("changer", text = "go to github", align = "center")
    # setting the transition time vvv
    style!(change, "transition" => 500ms)
    on(change, "click") do cl::ClientModifier
        style!(cl, change, "background-color" => "red")
        next!(cl, "changer") do cl2::ClientModifier
            style!(cl2, change, "background-color" => "white")
            next!(cl, "changer") do cl3::ClientModifier
                style!(cl3, change, "background-color" => "blue")
                set_text!(cl3, change, "amurica")
            end
        end
    end
    write!(c, change)
end
export home, start!
end

start!(AmericanServer)
```
- See also: `transition!`, `keyframes!`, `on`, `alert!`, `set_text!`
"""
function next!(f::Function, cl::AbstractComponentModifier, comp::Any)
    if typeof(comp) <: AbstractComponent
        comp = comp.name
    end
    newcl::ClientModifier = ClientModifier()
    f(newcl)
    push!(cl.changes,
    "document.getElementById('$comp').addEventListener('transitionend', $(funccl(newcl)));")
    nothing::Nothing
end

next_transition!(cl::ClientModifier, name::String, gen::AbstractVector, e::Int64) = begin
    if e > length(gen)
        return
    end
    style!(cl, name, "transition" => gen[e][1], gen[e][2] ...)
    next!(cl, name) do cl2
        next_transition!(cl2, name, gen, e + 1)
    end
end

"""
```julia
transition!(cl::ClientModifier, comp::Component{<:Any}, tpairs::Pair{<:Any, <:Any} ...) -> ::Nothing
```
Creates a `next!` transition for each pair in `tpairs`. `tpairs` should be a list `Tuple` (provided as arguments) of
    `Pair{String, Vector{Pair{String, String}}}`. The keys of the pairs will be time increments, likely using `s` or `ms`, and the values will be 
    the styles associated with that portion of the animation.
```example
newcomp = Gattino.div("sss")
style!(newcomp, "width" => 200px, "height" => 200px, "background-color" => "green")
on(newcomp, "click") do cl::ClientModifier
    style!(cl, newcomp, "width" => 100px)
    transition!(cl, newcomp,
        ["2s" => ["background-color" => "orange"],
        "2s" => ["height" => 199px],
        "4s" => ["background-color" => "red"],
        "2s" => ["width" => 200px],
        "1s" => ["background-color" => "green"]] ... )
end
```
Note that some style has to change for a to occur, but the transition can be done on an 
    arbitrary style or a style that does not apply to the `Component`.
```julia
newcomp = Gattino.div("sss")
style!(newcomp, "width" => 200px, "height" => 200px, "background-color" => "green")
on(newcomp, "click") do cl::ClientModifier
    style!(cl, newcomp, "width" => 100px)
    transition!(cl, newcomp,
        ["2s" => ["background-color" => "orange"],
        "1500ms" => ["stroke" => 5px], # pause
        "2s" => ["height" => 199px],
        "4s" => ["background-color" => "red"],
        "2s" => ["width" => 200px],
        "1s" => ["background-color" => "green"]] ... )
end
```
"""
function transition!(cl::ClientModifier, comp::Component{<:Any}, tpairs::Pair{<:Any, <:Any} ...)
    gen = [pair for pair in tpairs]
    e = 1
    next!(cl, comp.name) do cl2
        next_transition!(cl, comp.name, gen, e)
    end
    nothing::Nothing
end

"""
```julia
update!(cm::AbstractComponentModifier, ppane::Any, plot::Any) -> ::Nothing
```
`update!` is used to put a Julia object into a `Component` in a callback. This `Function` will 
use `show(io::IO, ::MIME{Symbol("text/html")}, T::MyType)` with your type. Ensure this binding exists, 
or it will not work with this function.
"""
function update!(cm::AbstractComponentModifier, ppane::Any, plot::Any)
    if typeof(comp) <: AbstractComponent
        comp = comp.name
    end
    io::IOBuffer = IOBuffer()
    show(io, "text/html", plot)
    data::String = String(io.data)
    data = replace(data,
     """<?xml version=\"1.0\" encoding=\"utf-8\"?>\n""" => "")
    set_text!(cm, ppane, data)::Nothing
end

"""
```julia
update_base64!(cm::AbstractComponentModifier, name::Any, raw::Any, filetype::String = "png") -> ::Nothing
```
This `Function` is used to update the `Base64` of a given `base64img` inside of a callback. `name` in this case will 
be the `Component` or the `Component`'s `name` which should hold the image (this should be a `Component{:img}` or the name of one.)
```julia
# example; using Base64 to show `Plots` plot:
module Example
using Toolips
using Toolips.Components
using Plots

plt = plot([5, 10, 15], [5, 10, 15])
plt2 = plot([1, 2, 7], [6, 4, 3])
home = route("/") do c::Connection
    comp = base64img("plot", plt)
    on(comp, "click") do cl::ClientModifier
        update_base64!(cl, comp, plt2)
    end
    write!(c, comp)
end

export home
end
```
"""
function update_base64!(cm::AbstractComponentModifier, name::Any, raw::Any,
    filetype::String = "png")
    io::IOBuffer = IOBuffer();
    b64::Base64EncodePipe = ToolipsServables.Base64.Base64EncodePipe(io)
    show(b64, "image/$filetype", raw)
    close(b64)
    mysrc::String = String(io.data)
    cm[name] = "src" => "data:image/$filetype;base64," * mysrc
    nothing::Nothing
end