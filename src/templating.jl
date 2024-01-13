"""
### DOCTYPE() -> ::String
------------------
DOCTYPE occassionally needs to be written to the top of files to make HTML render
properly.
#### example
```
write!(c, DOCTYPE())
```
"""
DOCTYPE() = "<!DOCTYPE html>"

const templating = nothing

const style_properties = nothing

const arguments = nothing

"""
"""
const elements = nothing

div(name::String, args::Any ...; keyargs ...) = Component(Component{:div}(), name, args ...; keyargs ...)

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

function style! end

push!(s::AbstractComponent, d::AbstractComponent ...) = [push!(s[:children], c) for c in d]

style!(c::Component{:sheet}, child::String, p::Pair{String, String} ...) = style!(c[:children][child], p ...)

"""

"""
const style = Style

function style!(c::AbstractComponent, s::Pair{String, <:Any} ...)
    if "style" in keys(c.properties)
        c["style"] = c["style"][1:length(c["style"]) - 1]
    else
        c["style"] = "'"
    end
    for style in s
        k, v = style[1], style[2]
        c["style"] = c["style"] * "$k:$v;"
    end
    c["style"] = c["style"] * "'"
end

function style!(args::Any ...)
    styles = filter(v -> typeof(v) <: AbstractComponent, args)
    comps = filter(v -> ~(typeof(v) <: AbstractComponent), args)
    [style!(comp, styles ...) for comp in comps]
    nothing
end


"""
"""
function keyframes(name::String, pairs::Pair{String, Vector{String}} ...; delay::Number, length::Number, 
    iterations::Number)
    KeyFrameAnimation(name, Dict())
end

"""
**Defaults**
### textdiv(name::String, p::Pair{String, Any} ...; text::String = "example", args ...)
------------------
A textdiv is a considerably advanced textbox. This includes an additional
property -- to be read by a ComponentModifier -- called `rawtext`.
#### example
```
route("/") do c::Connection
    mytxtdiv = ToolipsDefaults.textdiv("mydiv")
    on(c, mytxtdiv, "click") do cm::ComponentModifier
        txtdiv_rawtxt = cm[mytxtdiv]["rawtext"]
    end
    write!(c, mytxtdiv)
end
```
"""
function textdiv(name::String, p::Pair{String, <:Any} ...; text::String = "example",
    args ...)
    raw = element("raw$name")
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
function setCurrentCursorPosition$(name)(chars) {
    chars = chars + 3;
    if (chars >= 0) {
        var selection = window.getSelection();

        range = createRange(document.getElementById("$(name)").parentNode, { count: chars });

        if (range) {
            range.collapse(false);
            selection.removeAllRanges();
            selection.addRange(range);
        }
    }
};""")
    style!(raw, "display" => "none")
    box = div(name, p ..., contenteditable = true, text = text, rawtext = "`text`",
    caret = "0",
    oninput="document.getElementById('raw$name').innerHTML=document.getElementById('$name').textContent;getCaretIndex$(name)(this);",
    args ...)
    push!(box.extras, raw, caretpos)
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

option(name::String, ps::Pair{String, String} ...; args ...) = Component(name,
 "option", ps ..., args ...)

function dropdown(name::String, options::Vector{Servable}, p::Pair{String, <:Any} ...; args ...)
    thedrop = Component(name, "select", p ..., args ...)
    thedrop["oninput"] = "\"this.setAttribute('value',this.value);\""
    thedrop[:children] = options
    thedrop
end

function checkbox(name::String, p::Pair{String, <:Any} ...; value::Bool = false,
    args ...)
    ch = input(name, p  ..., type = "checkbox", value = value,
    oninput = "this.setAttribute('value',this.checked);", args ...)
    if value
        ch["checked"] = value
    end
    ch::Component{:input}
end

function colorinput(name::String, p::Pair{String, <:Any} ...;
    value::String = "#ffffff", args ...)
    input(name, type = "color", value = value,
    oninput = "\"this.setAttribute('value',this.value);\"", p ...,
    args ...)::Component{:input}
end

function progress(name::String, ps::Pair{String, String} ...; args ...)
    Component(name, "progress", ps..., args ...)
end

function cursor(name::String, p::Pair{String, Any} ...; args ...)
    cursor_updater = script(name, p ..., args ...)
    cursor_updater["x"] = "1"
    cursor_updater["y"] = "1"
    cursor_updater[:text] = """
    function updatecursor(event) {
        document.getElementById("$name").setAttribute("x", event.clientX);
        document.getElementById("$name").setAttribute("y", event.clientY);
    }
    document.getElementsByTagName("body")[0].addEventListener("mousemove", updatecursor);
   """
   cursor_updater::Component{:script}
end

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
    push!(menu.extras, scr)
    style!(menu, "opacity" => 0percent, "position" => "absolute")
    menu::Component{<:Any}
end

function keyinput(name::String, p::Pair{String, <:Any} ...; text = "w", args ...)
    button(name, p ..., text = text,
    onkeypress = "this.innerHTML=event.key;this.setAttribute('value',event.key);",
    onclick = "this.focus();", value = "W",  args ...)
end

function (:)(s::Style, name::String, ps::Vector{Pair{String, String}})
    newstyle = Style("$(s.name):$name")
    [push!(newstyle.properties, p) for p in ps]
    push!(s[:extras], newstyle)
end

(:)(s::Style, name::String) = s.extras[s.name * ":$name"]::AbstractComponent

(:)(s::AbstractComponent, name::String) = s.extras[name]::AbstractComponent

(:)(s::String, spairs::Vector{Pair{String, <:Any}} ...) = begin

end

(:)(s::Vector{String}, spairs::Vector{Pair{String, <:Any}} ...) = begin

end

(:)(s::StyleComponent ...) = begin

end

function (:)(sheet::Component{:sheet}, s::StyleComponent ...)

end

function (:)(sheet::Component{:sheet}, s::String, vec::Vector{Pair{String, String}})

end



mutable struct WebMeasure{format} end

*(i::Any, p::WebMeasure{<:Any}) = "$(i)$(typeof(p).parameters[1])"

"""
###### measures

"""
const measures = WebMeasure{:measure}()
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

"""
"""
const from = "from"

"""
"""
const to = "to"


translateX(s::String) = "translateX($s)"
translateY(s::String) = "translateX($s)"
rotate(s::String) = "rotate($s)"
matrix(n::Int64 ...) = "matrix(" * join([string(i) for i in n], ", ") * ")"
translate(x::String, y::String) = "translate()"
skew(one::String, two::String) = "skew($one, $two)"
scale(n::Any, n2::Any) = "scale($one, $two)"

scale(n::Any) = "scale($n)"