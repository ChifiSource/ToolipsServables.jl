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
- abstract type `Servable`` end
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
set of `Servables` will grab a `Servable` by `name`
- See also: `Servable`
"""
const Servables{T} = Vector{T} where {T <: Servable}

string(s::Servable) = s.name::String

string(s::Servables) = join([string(serv) for serv in s])

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
"""
function write! end

function write!(io::IO, servables::Servable ...)
    write(io, join([string(serv) for serv in servables]))
    nothing
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
File(`dir`**::String**)
```
---
```example
# write! candidate
io = IOBuffer()

# make a file
myf = File("myfiles/example")
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
### Consistencies
- properties**::Dict{Symbol, Any}**
##### consistencies
- `name`**::String**
- `string(**::AbstractComponent**)`
- `properties**::Dict{Symbol, <:Any}**`
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
    function Component{T}(name::String = "-", properties ...; args ...) where {T <: Any}
        properties = Dict{Symbol, Any}([Symbol(prop[1]) => string(prop[2]) for prop in properties])
        (push!(properties, Symbol(prop[1]) => string(prop[2])) for prop in args)
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

function copy(c::Component{<:Any})
    comp = Component(name, tag, copy(c.properties))
    comp
end

"""

"""
abstract type StyleComponent <: AbstractComponent end

"""
```julia
copy(c::AbstractComponent) -> ::AbstractComponent
```
------------------
Copies c.
#### example
```
c = p("myp")
t = copy!(c)
```
"""
function copy(c::StyleComponent)
end


"""
```julia
Style <: StyleComponent
```
- name::String
- f::Function
- properties::Dict{Any, Any}
- extras::Vector{Servable}

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
```julia
style(name::String, stylepairs::Pair{String, <:Any}) -> Style
```
A `Style` can be written using `write!`, and converted to a `String` using the `string` 
function.
------------------

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

string(comp::Style) = begin
    properties = comp.properties
    name = comp.name
    extras = join([string(comp) for comp in properties[:extras]])
    delete!(properties, :extras)
    "$(extras) <style id=$name>$name {$(join(["$(p[1]):$(p[2])" for p in properties]));}</style>"
end

"""
"""
abstract type AbstractAnimation <: StyleComponent end

"""

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
    props::String = join(["$(p[1]):$(p[2])" for p in properties], ";")
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
