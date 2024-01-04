mutable struct ComponentTemplate{T <: Any}
    ComponentTemplate{T}(name::String, comps::AbstractComponent,
    props::Pair{String, <:Any} ...; args ...) where {T <: Any} = begin
        Component{T}(name, comps ..., props ...; args ...)
    end
end

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

const templating = ComponentTemplate{info}
const div = ComponentTemplate{:div}
const img = ComponentTemplate{:img}
const link = ComponentTemplate{:link}
const meta = ComponentTemplate{:meta}
const input = ComponentTemplate{:input}
const a = ComponentTemplate{:a}
const p = ComponentTemplate{:p}
const h = ComponentTemplate{:h}
const ul = ComponentTemplate{:ul}
const li = ComponentTemplate{:li}
const br = ComponentTemplate{:br}
const i = ComponentTemplate{:i}
const title = ComponentTemplate{:title}
const span = ComponentTemplate{:span}
const iframe = ComponentTemplate{:iframe}
const svg = ComponentTemplate{:svg}

const element = ComponentTemplate{:element}
const label = ComponentTemplate{:label}
const script = ComponentTemplate{:script}
const nav = ComponentTemplate{:nav}
const button = ComponentTemplate{:button}
const form = ComponentTemplate{:form}
const section = ComponentTemplate{:section}
const body = ComponentTemplate{:body}
const header = ComponentTemplate{:header}
const footer = ComponentTemplate{:footer}
const b = ComponentTemplate{:b}
const source = ComponentTemplate{:source}
const audio = ComponentTemplate{:audio}
const video = ComponentTemplate{:video}
const table = ComponentTemplate{:table}
const tr = ComponentTemplate{:tr}
const th = ComponentTemplate{:th}
const td = ComponentTemplate{:td}



ComponentTemplate{:h}(name::String, level::Int64, comps::AbstractComponent,
props::Pair{String, <:Any} ...; args ...) where {T <: Any} = begin
    Component{T}(name, comps ..., props ...; args ...)
end

ComponentTemplate{:h}(level::Int64, name::String, comps::AbstractComponent,
props::Pair{String, <:Any} ...; args ...) where {T <: Any} = begin
    Component{T}(name, comps ..., props ...; args ...)
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