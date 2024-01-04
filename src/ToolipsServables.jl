module ToolipsServables
import Base: write
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
mutable struct Component{tag} <: AbstractComponent
    name::String
    properties::Dict{Symbol, Any}
    tag::String
    function Component{T}(tag::String, name::String = "-", properties::Dict{Symbol, Any} = Dict{Symbol, Any}()) where {T <: Any}
        propkeys = keys(properties)
        if ~(:children in propkeys || :text in propkeys || :extras in propkeys)
            push!(propkeys, :children => Vector{AbstractComponent}(), :extras => Vector{AbstractComponent}())
        end
        new{T}(name, properties, tag)
    end
    Component(tag::String, name::String, properties::Pair{String, <:Any} ...; args::Any ...) = begin
        properties = Dict{Symbol, Any}(vcat([Symbol() => string() for prop in properties], [Symbol(prop[1]) => string(prop[2]) for prop in args]))
    end
end

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

end # module ToolipsServables
