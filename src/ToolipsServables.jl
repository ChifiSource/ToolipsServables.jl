"""
#### toolips servables - composable and versatile parametric components
- 0.3 January
- Created in February, 2022 by [chifi](https://github.com/orgs/ChifiSource)
- This software is MIT-licensed.

`ToolipsServables` provides a composable parametric platform for templating 
    UIs.
```example
using ToolipsServables
# (From Toolips ?):
#using Toolips.Components

# creating components:
maindiv::Component{:div} = div("centered", align = "center")
greeter_heading::Component{:h3} = h3("greeter", text = "hello world!")
# creating a style
bgstyle::Style = style("greeter_style", "color" => "white", 
"font-weight" => "bold")

# styling a component directly:
style!(maindiv, "background-color" => "purple", "margin-top" => 5px)
leavebutton = button("leave", text = "leave")
gobutton = button("go", text = "go!")

style!(gobutton, leavebutton)

# composing a body:

# components can be written to <: IO or `Strings` with `write!`
```
###### servable base
- abstract type `Servable` end
- `File` <: `Servable`
- `AbstractComponent` <: `Servable`
- `Component{T <: Any}` <: `AbstractComponent`
- abstract type `StyleComponent` <: `AbstractComponent`
- `Servables` (type alias for `Vector{<:Servable}`)
- `write!(::IO, ::Servable)`
- `write!(::String, ::Servable)`
- `copy(c::Component{<:Any})`
- `Style` <: `AbstractComponent`
- abstract type `AbstractAnimation` <: `StyleComponent`

###### templating
- `templating` (`?templating`)
- `style_properties` (`?style_properties`)
- `arguments` (`?arguments`)
- `Components` (`?Components`)
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
  - `h`
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
  - `table`
  - `tr`
  - `th`
  - `td`
- `keyframes`
- `style!`
- `push!`
- `textdiv`
- `textbox`
- `password`
- `numberinput`
- `rangeslider`
- `option`
- `dropdown`
- `checkbox`
- `colorinput`
- `progress`
- `cursor`
- `context_menu!`
- `keyinput`
- `WebMeasure{format <: Any}`
- `measures` (`?measures`)
  - `px`
  - `pt`
  - `inch`
  - `pc`
  - `mm`
  - `cm`
  - `percent`
  - `per`
  - `em`
  - `seconds`
  - `s`
  - `ms`
  - `deg`
  - `turn`
  - `rgba(r::Number, g::Number, b::Number, a::Float64)`
  - `from`
  - `to`
  - `translateX(s::String)`
  - `translateY(s::String)`
  - `rotate(s::String)`
  - `matrix(n::Int64 ...)`
  - `translate(x::String, y::String)`
  - `skew(one::String, two::String)`
  - `scale(n::Any)`
  - `scale(n::Any, n2::Any)`
- **io**
"""
module ToolipsServables
import Base: div, in, getindex, setindex!, delete!, push!, string, (:), show, display, *
using Base64

"""
```julia
abstract type Servable
```
A `Servable` is a type intended to be written to IO that is served to a server. ToolipsServables 
comes with two `Servable` types,
- All servables have a `name`.
- All servables are dispatched to `string`.
- `Servables` (?Servables) can be indexed using a `String` corresponding to `name`.
---
- See also: `Servables`, `File`, `Component`, `templating`
"""
abstract type Servable end

"""
```julia
Servables{T} (alias for Vector{T} where {T <: Servable})
```
`Servables` are able to be written to `IO` or a `String` using `write!`. Indexing a 
`Vector` of `Servables` will grab a `Servable` by `name`
- See also: `Servable`
##### consistencies
- `name`**::String**
- `string(**::Servable**)`
"""
const Servables{T} = Vector{T} where {T <: Servable}

string(s::Servable) = s.name::String

string(s::Servables) = join(string(serv) for serv in s)

"""
```julia
write!(io, args ...) -> _
````
The `write` `Function` is used to `write!` `Servables` to 
a `<: IO` or a `String`.
```julia
write!(io::IO, servables::Servable ...) -> ::Nothing
write!(io::String, servables::Servable ...) -> ::String
```
---
```example
using ToolipsServables
# write candidate
str_sample = ""
buff = IOBuffer()

# templating
mycomp = div("example", align = "center")

# writing
write!(buff, mycomp)
str_sample = write!(str_sample, mycomp)
```
```example
# writing a file
file::File{:txt} = File("texts/example.txt")

rawfile = write!("", file)
```
"""
function write! end

function write!(io::IO, servables::Servable ...)
    write(io, join(string(serv) for serv in servables))
    nothing
end

function write!(io::String, servables::Servable ...)
    io = io * join(string(serv) for serv in servables)
end

function getindex(vs::Vector{<:Servable}, n::String)
    f = findfirst(c::Servable -> c.name == name, vs)
    if ~(isnothing(f))
        return(vec[f])::Servable
    end
    inside = join((comp.name for comp in vec), "| ")
    println("component $name not in $inside")
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
File(`dir`**::String**)
```
---
```example
# write! candidate
io = IOBuffer()

# make a file
myf::File{:jl} = File("myfiles/example.jl")
# writing
write!(io, myf)
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
Components are html elements, 
##### consistencies
- `name`**::String**
- `string(**::AbstractComponent**)`
- `properties**::Dict{Symbol, <:Any}**`
```
"""
abstract type AbstractComponent <: Servable end

string(s::Vector{<:AbstractComponent}) = join(string(serv) for serv in s)

function in(name::String, v::Vector{<:AbstractComponent})
    pos = findfirst(c::AbstractComponent -> c.name == name, pos)
    ~(isnothing(pos))
end

function getindex(vec::Vector{<:AbstractComponent}, name::String)::AbstractComponent
    f = findfirst(c::AbstractComponent -> c.name == name, vec)
    if ~(isnothing(f))
        return(vec[f])::AbstractComponent
    end
    println("component $name not in $vec")
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
```julia
Component{T <: Any} <: AbstractComponent <: Servable
```
- name**::String**
- properties**::Dict{Symbol, Any}**
- tag**::String**

The `Component` is the `ToolipsServables` structure for representing an `HTML` element.
Components may be indexed using both strings and symbols; they are typed to their element name, 
but the `tag` field will be the element tag written. Components may be composed with `push!` and 
`set_children!`, styled with `style!`, and are written to a `Connection` with `write!`.

`Components` initialize with a few special properties (if they are not provided); `:text`, `:children`, and `:extras`.
- :extras are written before the `Component`.
- :children are written inside of the `Component`.
- :text is also written inside of the `Component`.
Components are usually constructed through high-level constants, which are calls to the 
`Component{T}(name::String = "-", properties ...; args ...)` constructor.

- See also: `templating`, `StyleComponent`, `AbstractComponent`, `elements`, `arguments`
```julia
Component{T}(name::String, tag::String, properties::Dict{Symbol, Any}) where {T <: Any}
Component{T}(name::String = "-", properties ...; args ...) where {T <: Any}
Component(tag::String, name::String, props::Any ...; args ...)
```
---
```example
# creating components
myd::Component{:div} = div("example", text = "hello world!")

myheading::Component{:h1} = h1("myheading", text = "example")

elements::Vector{<:AbstractComponent} = [p("example", text = e) for e in 1:10]

# composing components
style!(myheading, "color" => "white", "font-size" => 10pt)
push!(myd, myheading)
set_children!(myheading, elements)
# writing components
write!(c, myd)
```
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
    function Component{T}(name::String = "-", properties ...; args ...) where {T <: Any}
        properties = Dict{Symbol, Any}([Symbol(prop[1]) => string(prop[2]) for prop in properties])
        [push!(properties, Symbol(prop[1]) => string(prop[2])) for prop in args]
        Component{T}(name,  string(T), properties)::Component{T}
    end
    function Component(tag::String, name::String, props::Any ...; args ...)
        Component{Symbol(tag)}(name, props ...; args ...)
    end
end

getindex(s::AbstractComponent, symb::Symbol) = s.properties[symb]
getindex(s::AbstractComponent, symb::String) = s.properties[Symbol(symb)]

setindex!(s::AbstractComponent, a::Any, symb::Symbol) = begin
    if symb in keys(s.properties)
        return(s.properties[Symbol(symb)]::typeof(a) = a)
    end
    push!(s.properties, symb => a)
end

setindex!(s::AbstractComponent, a::Any, symb::String) = begin
    if Symbol(symb) in keys(s.properties)
        return(s.properties[Symbol(symb)]::typeof(a) = a)
    end
    push!(s.properties, Symbol(symb) => a)
end

function propstring(properties::Dict{Symbol, Any})::String
    notupe::Tuple{Symbol, Symbol, Symbol} = (:text, :children, :extras)
   join((begin
        "$(prop[1])=\"$(prop[2])\"" 
    end for prop in filter(c -> ~(c[1] in notupe), properties)), " ")
end

string(comp::Component{<:Any}) = begin
    text::String = comp.properties[:text]
    children = string(comp[:children])
    extras = string(comp[:extras])
    "$extras<$(comp.tag) id=\"$(comp.name)\" $(propstring(comp.properties))>$children$text</$(comp.tag)>"::String
end

function copy(c::Component{<:Any})
    comp = Component(c.name, c.tag, copy(c.properties))
    comp
end

"""
### abstract type StyleComponent <: AbstractComponent
StyleComponents are components which can be written inside of a `Component{:style}` (CSS styles). 
For base `ToolipsServables`, this includes the parametric `Animation` type and `Style` type. These carry 
the same consistencies as a `Component`, but don't hold a `tag`.
##### consistencies
- `name`**::String**
- `string(**::AbstractComponent**)`
- `properties**::Dict{Symbol, <:Any}**`
- See also: `style!`, `style`, `AbstractAnimation`, `keyframes`, `Component`, `templating`, `style_properties`
"""
abstract type StyleComponent <: AbstractComponent end

"""
```julia
Style <: StyleComponent <: AbstractComponent <: Servable
```
- name::String
- properties::Dict{Symbol, Any}

Styles hold and translate CSS styling pairs. For example, a default h1 style would
be named "h1". A heading style for a specific class should be "h1.myheading". A 
universal class that works on all components should be `#`. 
A high-level `style` component is available to construct styles. We can use `style!` 
to `style!` a `Component` directly, `style!` to mutate the styles of a `Style`, or `style` to 
create new styles. 

- See also: `style`, `style!`, `StyleComponent`, `style_properties`, `templating`, `AbstractAnimation`
##### constructors
- Style(name::String; props ...)
---
- There is a canonical method for `style` which can be used similarly to other `Component` templating methods (without key-word arguments).
```julia
style(name::String, stylepairs::Pair{String, <:Any}) -> Style
```
A `Style` can be written using `write!`, and converted to a `String` using the `string` 
function.
---
##### example
```julia
# create a style
comp_style::Style = style("div.sample", "color" => "red")

# create a `Component`:
comp::Component{:div} = div("example")

# set class to sample
style!(comp, comp_style)

# style! a `Component`
style!(comp, "background-color" => "black", "border-radius" => 2px)
```
"""
mutable struct Style <: StyleComponent
    name::String
    properties::Dict{Symbol, Any}
    function Style(name::String, a::Pair{String, <:Any} ...)
        properties::Dict{Symbol, Any} = Dict{Any, Any}([Symbol(k[1]) => k[2] for k in a])
        if ~(:extras in keys(properties))
            push!(properties, :extras => Vector{AbstractComponent}())
        end
        new(name, properties)::Style
    end
end

function copy(c::Style)
    Style(c.name, copy(c.properties) ...)
end

string(comp::Style) = begin
    properties = comp.properties
    name = comp.name
    extras = ""
    if :extras in keys(properties)
        extras = join(string(comp) for comp in properties[:extras])
    end
    spairs = join(("$(p[1]):$(p[2])" for p in filter!(p -> p[1] != :extras, properties)), ";")
    "$(extras) <style id=$name>$name {$(spairs);}</style>"
end

"""
### abstract type AbstractAnimation <: StyleComponent
Animations are changes to the style of components that happen to the screen over time.
Toolips provides parametric anaimations that are intended to be used through high-level methods.
##### consistencies
- `name`**::String**
- `string(**::AbstractAnimation**)`
- `properties**::Dict{Symbol, <:Any}**`
```
- See also: `Animation`, `keyframes`, `style!`, `style`, `StyleComponent`
"""
abstract type AbstractAnimation <: StyleComponent end

"""
```julia
Animation{T <: Any} <: AbstractAnimation <: StyleComponent ...
```
- name**::String**
- properties**::Dict{Symbol, Vector{String}}**

The `Animation` is a parametric type meant to hold animation properties 
for different types of animations. `ToolipsServables` provides one animation 
type, `keyframes`, or `Animation{:keyframes}`. To construct it, use the 
`keyframes` function. An `Animation` is then styled to a `style!` or 
`Component` using `style!`.
    
- See also: `keyframes`, `style!`, `style`, `StyleComponent`, `templating`
```julia
Animation{T}(name::String, properties::Pair{String, <:Any} ...; delay::Any = 0.0, length::Any = 5.2,
iterations::Integer = 1, keyargs ...)
```
---
```example

```
"""
mutable struct Animation{T <: Any} <: AbstractAnimation
    name::String
    properties::Dict{Symbol, Vector{String}}
    function Animation{T}(name::String, properties::Pair{String, <:Any} ...; 
        delay::Any = 0.0, length::Any = 5.2, iterations::Integer = 1, keyargs ...) where {T <: Any}
        properties::Dict{Symbol, String} = Dict{Symbol, Any}([Symbol(prop[1]) => string(prop[2]) for prop in properties])
        new(name, properties)
    end
end

function string(anim::Animation{:keyframes})
    properties = anim.properties
    props::String = join(("$(p[1]):$(p[2])" for p in properties), ";")
    """<style id="$(anim.name)">@keyframes $(anim.name){$(props)}</style>"""
end

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
    show(io, join(string(comp) for comp in s))
end

include("templating.jl")
include("componentio.jl")


export px, pt, per, s, ms, deg, turn, perc
export rgba, translate, matrix, skew, rotate, scale, translateY, translateX
export Servable, Component, AbstractComponent, File, write!, Style
export style!, seconds, percent, set_children!
export templating, DOCTYPE, h, img, link, meta, input, a, p, h, ul, li
export br, i, title, span, iframe, svg, h1, h2, h3, h4, h5, h6
export element, label, script, nav, button, form, section, body, header, footer, b
export source, audio, video, table, tr, th, td, style, textdiv
end # module ToolipsServables
