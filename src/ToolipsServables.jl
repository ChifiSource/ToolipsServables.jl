"""
#### toolips servables - composable and versatile parametric components
- 0.3 January
- Created in February, 2022 by [chifi](https://github.com/orgs/ChifiSource)
- This software is MIT-licensed.

`ToolipsServables` provides a composable parametric platform for templating 
    UIs.
```example

```
- Provides
```julia
- abstract type `Servable`` end
- `File` <: Servable
- `AbstractComponent` <: `Servable`
- `Component{T <: Any}` <: `AbstractComponent`
- abstract type `StyleComponent` <: `AbstractComponent`
- `Servables` (type alias for `Vector{<:Servable}`)
- `write!`
- `copy(c::Component{<:Any})`
- 
```
"""
module ToolipsServables
import Base: div, in, getindex, setindex!, delete!, push!, string, (:), show, display, *

"""
#### abstract type Servable
A `Servable` is a type intended to be written to IO that is served to a server. ToolipsServables 
comes with two `Servable` types,
- All servables have a `name`.
- All servables are dispatched to `string`.
- `Servables` (?Servables) can be indexed using a `String` corresponding to `name`.
###### Consistencies
- name**::String**
- `string(serv:**:Servable**)`
"""
abstract type Servable end

"""
#### Servables (Vector{<:Servable})
`Servables` are able to be written to `IO` or a `String` using `write!`. Indexing a 
set of `Servables` will grab a `Servable` by `name`
"""
const Servables = Vector{<:Servable}

string(s::Servable) = s.name::String

string(s::Servables) = join([string(serv) for serv in s])

"""
```julia
write!
````
The `write` `Function` is used to `write!` `Servables` and Julia data-types to 
a `IO` or a `String`.
```julia
- write!(io, args ...)
- write!(io, towrite, args ...)
```
"""
function write! end

function write!(io::IO, servables::Servable ...)
    write(io, join([string(serv) for serv in servables]))
end

function write!(io::String, servables::Servable ...)
    io = io * join([string(serv) for serv in servables])
end

function getindex(vs::Vector{<:Servable}, n::String)
    f = findfirst(c::Servable -> c.name == name, vs)
    if ~(isnothing(f))
        return(vec[f])::Servable
    end
    println("component $name not in $(join([comp.name for comp in vec], "| "))")
    throw(KeyError(name))
end

"""
```julia
File{T <: Any} <: Servable
```
- name**::String**
- path**::String**

The `File` `Servable` writes a file to a `Connection`. `T` will be the file extension 
of the file, meaning a `.html` file becomes a `File{:html}`. Getting index on a file, `File[]`, 
will yield the field path. Using `string` on a file will read the file as a `String`.
```julia
- File(`dir`**::String**)
```
"""
mutable struct File{T <: Any} <: Servable
    name::String
    path::String
    function File(dir::String)
        dir = replace(dir, "\\" => "/")
        ftsplit = split(dir, ".")
        fending = join(ftsplit[2:length(ftsplit)])
        nsplit = split(dir, "/")
        new{:}(string(nsplit[length(nsplit)]), join(nsplit[1:length(nsplit) - 1], "/"))::File
    end
end

function getindex(f::File{<:Any}, args ...)
    if f.path == ""
        return(f.name)::String
    end
    f.path * "/" * f.name
end

string(f::File{<:Any}) = begin
    read(f[], String)
end

"""
### abstract type AbstractComponent <: Servable
Components are html elements.
### Consistencies
- properties**::Dict{Symbol, Any}**
##### <:Servable
- `name`**::String**
- string(**::AbstractComponent**)
```
"""
abstract type AbstractComponent <: Servable end

string(s::Vector{<:AbstractComponent}) = join([string(serv) for serv in s])

function in(name::String, v::Vector{<:AbstractComponent})
    pos = findfirst(c::AbstractComponent -> c.name == name, pos)
    ~(isnothing(pos))
end

function getindex(vec::Vector{<:AbstractComponent}, name::String)::AbstractComponent
    f = findfirst(c::AbstractComponent -> c.name == name, vec)
    if ~(isnothing(f))
        return(vec[f])::AbstractComponent
    end
    println("component $name not in $(join([comp.name for comp in vec], "| "))")
    throw(KeyError(name))
end

function delete!(name::String, v::Vector{<:AbstractComponent})::Nothing
    f = findfirst(c::AbstractComponent -> c.name == name, vec)
    if ~(isnothing(f))
        deleteat!(vec, f); nothing
    end
    println("component $name not in $(join([comp.name for comp in vec], "| "))")
    throw(KeyError(name))
end

"""

"""
mutable struct Component{T <: Any} <: AbstractComponent
    name::String
    properties::Dict{Symbol, Any}
    tag::String
    Component{T}(name::String, tag::String, properties::Dict{Symbol, Any}) where {T <: Any} = begin
        propkeys = keys(properties)
        if ~(:text in propkeys)
            push!(properties, :text => "")
        end
        if ~(:children in propkeys)
            push!(properties, :children => Vector{AbstractComponent}())
        end
        if ~(:extras in propkeys)
            push!(properties, :extras => Vector{AbstractComponent}())
        end
        new{T}(name, properties, tag)
    end
    function Component{T}(name::String = "-", properties ...) where {T <: Any}
        properties = Dict{Symbol, Any}([Symbol(prop[1]) => string(prop[2]) for prop in properties])
        Component{T}(name,  string(T), properties)::Component{T}
    end
    function Component(tag::String, name::String, props::Any ...; args ...)
        Component{Symbol(tag)}(name, props ...; args ...)
    end
end

getindex(s::AbstractComponent, symb::Symbol) = s.properties[symb]
getindex(s::AbstractComponent, symb::String) = s.properties[Symbol(symb)]

setindex!(s::AbstractComponent, a::Any, symb::Symbol) = s.properties[symb]::typeof(a) = a
setindex!(s::AbstractComponent, a::Any, symb::String) = s.properties[Symbol(symb)]::typeof(a) = a

function propstring(properties::Dict{Symbol, Any})::String
    notupe::Tuple{Symbol, Symbol, Symbol} = (:text, :children, :extras)
   join([begin
        "$(prop[1])=\"$(prop[2])\"" 
    end for prop in filter(c -> ~(c[1] in notupe), properties)], " ")
end

string(comp::Component{<:Any}) = begin
    text::String = comp.properties[:text]
    children = string(comp[:children])
    extras = string(comp[:extras])
    "$extras<$(comp.tag) id=\"$(comp.name)\" $(propstring(comp.properties))>$children$text</$(comp.tag)>"::String
end

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
    comp = Component(name, tag, copy(c.properties))
    comp
end

"""

"""
abstract type StyleComponent <: AbstractComponent end


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
    properties::Dict{Symbol, Any}
    function Style(name::String, a::Pair{String, <:Any} ...; args ...)
        properties::Dict{Any, Symbol} = Dict{Any, Any}([Symbol(k[1]) => k[2] for k in a])
        extras::Vector{Servable} = Vector{Servable}()
        Style(name, properties)::Style
    end
end

string(comp::Style) = begin
    properties = comp.properties
    css::String = "$(string(properties.extras)) <style id=$name>$name {$(join(["$(p[1]);$(p[2])" for p in properties])))}"
    [begin
        property::String = string(rule)
        value::String = string(properties[rule])
        css = css * "$property: $value; "
    end for rule in keys(properties)]
    css = css * "}</style>"
    write!(c, css)
    write!(c, extras)
end

abstract type AbstractAnimation <: StyleComponent end

"""

"""
mutable struct KeyFrameAnimation <: AbstractAnimation
    name::String
    properties::Dict{Symbol, Vector{String}}
    function Animation(name::String = "animation"; delay::Any = 0.0,
        length::Any = 5.2, iterations::Integer = 1)
        properties::Dict{Symbol, String} = Dict{Symbol, AnimationFrame{<:Any}}()
        new(name, properties)::Animation
    end
end

const from = "from"
const to = "to"

function keyframes(name::String, pairs::Pair{String, Vector{String}} ...; delay::Number, length::Number, 
    iterations::Number)
    KeyFrameAnimation(name, Dict())
end

function string(anim::AbstractAnimation)
    properties = anim.properties
    props::String = join(["$(p[1]):$(p[2])" for p in properties], ";")
    """<style id="$(anim.name)">@keyframes $(anim.name){$(props)}"""
end


       #== f(c::AbstractConnection) = begin
@keyframes example {
  from {background-color: red;}
  to {background-color: yellow;}
}
        ==#

function show(io::Base.TTY, c::AbstractComponent)
    show(io, MIME"text/html"(), string(mdcomponent(c)))
end

function show(io::Base.TTY, c::StyleComponent)
    println("$(c.name) $(typeof(c))\n")
end

function show(io::IO, f::File)
    println("File: $(f.path)|$(f.name)")
end

display(io::IO, m::MIME"text/html", s::Servable) = show(io, m, s)

show(io::IO, m::MIME"text/html", s::Servable) = begin
    show(io, string(s))
end

show(io::IO, m::MIME"text/html", s::Vector{<:AbstractComponent}) = begin
    show(io, join([string(comp) for comp in s]))
end

include("templating.jl")
include("componentio.jl")


export px, pt, per, s, ms, deg, turn
export rgba, translate, matrix, skew, rotate, scale
export Servable, Component, AbstractComponent, File, write!
export animate!, style!
export templating, DOCTYPE, h, img, link, meta, input, a, p, h, ul, li
export br, i, title, span, iframe, svg, h1, h2, h3, h4, h5, h6
export element, label, script, nav, button, form, section, body, header, footer, b
export source, audio, video, table, tr, th, td
end # module ToolipsServables
