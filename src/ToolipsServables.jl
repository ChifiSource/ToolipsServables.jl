module ToolipsServables
import Base: write, div, in, getindex, setindex!, delete!, push!, string, (:), show, display
abstract type Servable end

function write(io::IO, servables::Servable ...)
    write(io, join([string(serv) for serv in servables]))
end

function write(io::String, servables::Servable ...)
    io = io * join([string(serv) for serv in servables])
end

"""

"""
mutable struct File <: Servable
    uri::String
    function File(dir::String)
        new(dir)::File
    end
end

string(f::File) = read(f.uri, String)

"""
### abstract type AbstractComponent <: Servable
Components are html elements.
### Consistencies
- properties::Dict{<:Any, Any}
- extras::Vector{Servable}
- name::String
### Servable Consistencies
```
"""
abstract type AbstractComponent <: Servable end

function in(name::String, v::Vector{<:AbstractComponent})

end

function getindex()

end

function delete!(name::String, v::Vector{<:AbstractComponent})

end

"""
### Component{tag} <: AbstractComponent <: Servable
- name::String
- f::Function
- tag::String
- properties::Dict
A component is a standard servable which is used to represent HTML tag
structures. Indexing a Component with a Symbol or a String will return or set
a Component's property to that index. The two special indexes are :children and
:text. :text will change the inner content of the Component and :children is
where components that will be written inside the Component go. You can add to
these with push!(c::Servable, c2::Servable)
#### example
```
using Toolips

image_style = Style("example")
image_anim = Animation("img_anim")
image_anim[:from] = "opacity" => "0%"
image_anim[:to] = "opacity" => "100%"
animate!(image_style)

r = route("/") do c::AbstractConnection
    newimage = img("newimage", src = "/logo.png")
    style!(newimage, image_style)
    write!(c, newimage)
end
```
------------------
#### field info
- name::String - The name field is the way that a component is denoted in code.
- f::Function - The function that gets called with the Connection as an
argument.
- properties::Dict - A dictionary of symbols and values.
------------------
##### constructors
- Component(name::String = "", tag::String = "", properties::Dict = Dict())
- Component(name::String, tag::String, props::Base.Pairs)
"""
mutable struct Component{T <: Any} <: AbstractComponent
    name::String
    properties::Dict{Symbol, Any}
    tag::String
    function Component{T}(name::String = "-", properties::Any ...; tag::String = string(T), args ...) where {T <: Any}
        children = Vector{AbstractComponent}()
        if length(properties) > 1
            children = Vector{AbstractComponent}(filter(prop -> typeof(prop) <: AbstractComponent, properties))
            properties = filter!(prop -> typeof(prop) <: AbstractComponent, properties)
        end
        properties = Dict{Symbol, Any}(vcat([Symbol(prop[1]) => string(prop[2]) for prop in properties],
        [Symbol(prop[1]) => string(prop[2]) for prop in args], :children => children, 
        :extras => Vector{AbstractComponent}()) ...)
        new{T}(name, properties, tag)::Component{T}
    end
    function Component(tag::String, name::String, props::Any ...; args ...)
        Component{Symbol(tag)}(name, props ...; args ...)
    end
end

getindex(s::AbstractComponent, symb::Symbol) = s.properties[symb]
getindex(s::AbstractComponent, symb::String) = s.properties[Symbol(symb)]

setindex!(s::AbstractComponent, a::Any, symb::Symbol) = s.properties[symb] = a
setindex!(s::AbstractComponent, a::Any, symb::String) = s.properties[Symbol(symb)] = a

"""
**Interface**
### copy(c::AbstractComponent) -> ::AbstractComponent
------------------
copies c.
#### example
```
c = p("myp")
t = copy!(c)
```
"""
function copy(c::Component{<:Any})
    props = copy(c.properties)
    extras = copy(c.extras)
    tag = copy(c.tag)
    name = copy(c.name)
    comp = Component(name, tag, props)
    comp.extras = extras
    comp
end

push!(s::AbstractComponent, d::AbstractComponent ...) = [push!(s[:children], c) for c in d]

string(comp::Component{<:Any}) = begin
    propstring()
    special_keys::Vector{Symbol} = [:text, :children]
    extras::Vector{Servable} = comp.extras
    tag::String = comp.tag
    name::String = comp.name
    open_tag::String = "<$tag id=$name"
    text::String = ""
    [begin
        if ~(property in special_keys)
            prop::String = string(properties[property])
            propkey::String = string(property)
           open_tag = open_tag * " $propkey=$prop"
        else
            if property == :text
                text = properties[property]
            end
        end
    end for property in keys(properties)]
    write!(c, open_tag * ">")
    if length(properties[:children]) > 0
        write!(c, properties[:children])
   end
   write!(c, "$text</$tag>")
   write!(c, extras)
end

"""
### abstract type StyleComponent <: Servable
Not much different from a normal **AbstractComponent**, simply an abstract type step for the
interface to separate working with Animations and Styles.
### AbstractComponent Consistencies
 - properties::Dict{Any, Any}
 - extras::Vector{Servable}
 - name::String
### Servable Consistencies
```
Servables can be written to a Connection via thier f() function and the
interface. They can also be indexed with strings or symbols to change properties
##### Consistencies
- f::Function - Function whose output to be written to http. Must take a single
positonal argument of type ::Connection or ::AbstractConnection
```
"""
abstract type StyleComponent <: AbstractComponent end

"""
### Animation
- name::String
- properties::Dict
- f::Function
- delay::Float64
- length::Float64
- iterations::Integer
An animation can be used to animate Styles with the animate! method. Animating
is done by indexing by either percentage, or symbols, such as from and to.
##### example
```
anim = Animation("myanim")
anim[:from] = "opacity" => "0%"
anim[:to] = "opacity" => "100%"
style = Style("example")
animate!(style, anim)
```
------------------
##### field info
- name::String - The name of the animation.
- properties::Dict - The properties that have been pushed so far.
- f::Function - The function called when writing to a Connection.
- delay::Float64 - The delay before the animation begins.
- length::Float64 - The amount of time the animation should play.
- iterations::Integer - The number of times the animation should repeat. When
set to 0 the animation will loop indefinitely.
------------------
##### constructors
Animation(name::String = "animation", delay::Float64 = 0.0,
        length::Float64 = 5.2, iterations::Integer = 1)
    """
mutable struct Animation <: StyleComponent
    name::String
    properties::Dict
    extras::Vector{Servable}
    f::Function
    delay::Float64
    length::Float64
    iterations::Integer
    function Animation(name::String = "animation"; delay::Float64 = 0.0,
        length::Float64 = 5.2, iterations::Integer = 1)
       #== f(c::AbstractConnection) = begin
            s::String = "<style id=$name> @keyframes $name {"
            [begin
                vals = properties[anim]
                s = s * "$anim {" * vals * "}"
            end for anim in keys(properties)]
            write!(c, string(s * "}</style>"))
        end
        f() = begin
            s::String = "<style> @keyframes $name {"
            for anim in keys(properties)
                vals = properties[anim]
                s = s * "$anim {" * vals * "}"
            end
            string(s * "}</style>")::String
        end
        ==#
        properties::Dict = Dict()
        new(name, properties, Vector{Servable}(), f, delay, length, iterations)::Animation
    end
end

"""
### Style
- name::String
- f::Function
- properties::Dict{Any, Any}
- extras::Vector{Servable}
Creates a style from attributes, can style a Component using the style! method.
Names should be consistent with CSS names. For example, a default h1 style would
be named "h1". A heading style for a specific class should be "h1.myheading"
##### example
```
style = Style("p.mystyle", color = "blue")
style["opacity"] = "50%"
comp = Component()
style!(comp, style)
```
------------------
##### field info
- name::String - The name of the style. Should be consistent with CSS naming.
- f::Function - The function f, called by write! when writing to a Connection.
- properties::Dict{Any, Any} - A dict of style attributes.
- extras::String - Extra components to be written along with the style. Usually
this is an animation.
------------------
##### constructors
- Style(name::String; props ...)
"""
mutable struct Style <: StyleComponent
    name::String
    properties::Dict{Any, Any}
    extras::Vector{Servable}
    function Style(name::String, properties::Dict{Any, Any}, extras::Vector{Servable})
        new(name, properties, extras)::Style
    end
    function Style(name::String, a::Pair ...; args ...)
        props::Vector{Pair{Any, Any}} = Base.vect(args ..., a ...)
        properties::Dict{Any, Any} = Dict{Any, Any}(props)
        extras::Vector{Servable} = Vector{Servable}()
        Style(name, properties, extras)::Style
    end
end

string(comp::Style) = begin
    properties = comp.properties
    name = comp.name
    extras = comp.extras
    css::String = "<style id=$name>$name { "
    [begin
        property::String = string(rule)
        value::String = string(properties[rule])
        css = css * "$property: $value; "
    end for rule in keys(properties)]
    css = css * "}</style>"
    write!(c, css)
    write!(c, extras)
end

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
**Interface**
### animate!(s::Style, a::Animation) -> _
------------------
Sets the Animation as a property of the style.
#### example
```
anim = Animation("fade_in")
anim[:from] = "opacity" => "0%"
anim[:to] = "opacity" => "100%"

animated_style = Style("example")
animate!(animated_style, anim)
```
"""
function animate!(s::Style, a::Animation)
    s["animation-name"] = string(a.name)
    s["animation-duration"] = string(a.length) * "s"
    if a.iterations == 0
        s["animation-iteration-count"] = "infinite"
    else
        s["animation-iteration-count"] = string(a.iterations)
    end
    push!(s.extras, a)
end

function animate!(s::Component{<:Any}, a::Animation)

end


function show(io::Base.TTY, c::AbstractComponent)
    print("""$(c.name) ($(c.tag))\n
    $(join([string(prop[1]) * " = " * string(prop[2]) * "\n" for prop in c.properties]))
    $(showchildren(c))
    """)
end

function show(io::Base.TTY, c::StyleComponent)
    println("$(c.name) $(typeof(c))\n")
end

function show(io::IO, f::File)
    println("File: $(f.dir)")
end

display(io::IO, m::MIME"text/html", s::Servable) = show(io, m, s)

show(io::IO, m::MIME"text/html", s::Servable) = begin
    sc = Toolips.SpoofConnection()
    write!(sc, s)
    show(io, sc.http.text)
end

include("templating.jl")

export Servable, Component, AbstractComponent
export animate!, style!
export templating, DOCTYPE, h, img, link, meta, input, a, p, h, ul, li
export br, i, title, span, iframe, svg, h1, h2, h3, h4, h5, h6
export element, label, script, nav, button, form, section, body, header, footer, b
export source, audio, video, table, tr, th, td
end # module ToolipsServables
