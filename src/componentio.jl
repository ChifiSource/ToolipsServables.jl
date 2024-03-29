function html_properties(s::AbstractString)
    propvec::Vector{SubString} = split(s, " ")
    properties::Dict{Symbol, Any} = Dict{Symbol, Any}(begin
        ppair::Vector{SubString} = split(segment, "=")
        if length(ppair) < 2
            Symbol(ppair[1]) => string(ppair[1])
        else
            Symbol(ppair[1]) => replace(string(ppair[2]), "\"" => "")
        end
    end for segment in propvec)
    properties::Dict{Symbol, Any}
end

"""
```julia
htmlcomponent(s::String, args ...) -> ::Vector{<:AbstractComponent}

htmlcomponent(s::String, names_only::Bool = true) -> ::Vector{Component{<:Any}}
htmlcomponent(s::String, readonly::Vector{String}) -> ::Vector{Component{<:Any}}
```
Reads components from an HTML `String`. Providing `names_only` as `false` will 
read elements without an `id` as well. Not doing so of course speeds up parsing of 
by excluding unneeded (unnamed in this case) elements. A `Vector{String}` of names 
may also be provided.
---
```example
comp = "<div id=\\"sample\\">hello</div>"

htmlcomponent(comp)["sample"]["text"]

"hello"
```
"""
function htmlcomponent(s::String, names_only::Bool = true)
    stop::Int64 = 1
    laststop::Int64 = 1
    comps::Vector{Component{<:Any}} = Vector{Component{<:Any}}()
    while true
        laststop = stop
        argfinish = findnext(">", s, stop)
        tagstart = findnext("<", s, stop)
        tagend = findnext(" ", s, stop)
        tagbefore = minimum(tagstart) > maximum(argfinish)
        if isnothing(argfinish) || isnothing(tagend) || isnothing(tagstart) || tagbefore
            break
        end
        tag::String = s[minimum(tagstart) + 1:minimum(tagend) - 1]
        finisher = findnext("</$tag>", s, maximum(argfinish) + 1)
        stop = maximum(argfinish) + 1
        if contains(tag, "/")
            continue
        end
        name::String = "component-$stop"
        idstart = findfirst("id=\"", s[minimum(tagstart):minimum(argfinish)])
        if isnothing(finisher)
            continue
        end
        if (isnothing(idstart) && names_only)
            continue
        end
        argstring::String = s[minimum(tagend) + 1:minimum(argfinish) - 1]
        properties::Dict{Symbol, Any} = html_properties(argstring)
        if :id in keys(properties)
            name = properties[:id]
            delete!(properties, :id)
        end
        text::String = ""
        try
            text = s[minimum(argfinish) + 1:minimum(finisher) - 1]
        catch
            text = s[minimum(argfinish) + 1:minimum(finisher) - 2]
        end
        push!(properties, :text => text)
        props = Dict{Symbol, Any}(Symbol(k[1]) => k[2] for k in properties)
        push!(comps, Component{Symbol(tag)}(name, tag, props))
    end
    return(comps)
end

function htmlcomponent(s::String, readonly::Vector{String})
    if readonly[1] == "none"
        return Vector{Servable}()
    end
    Vector{AbstractComponent}(filter!(x -> ~(isnothing(x)), [begin
        element_sect = findfirst(" id=\"$compname\"", s)
        if ~(isnothing(element_sect))
            starttag = findprev("<", s, element_sect[1])[1]
            ndtag = findnext(" ", s, element_sect[1])[1]
            argfinish = findnext(">", s, ndtag)[1] + 1
            tg = s[starttag + 1:ndtag - 1]
            finisher = findnext("</$tg", s, argfinish)
            fulltxt = s[argfinish:finisher[1] - 1]
            properties = html_properties(s[ndtag:argfinish - 2])
            name::String = ""
            if "id" in keys(properties)
                name = properties["id"]
                delete!(properties, "id")
            end
            push!(properties, :text => replace(fulltxt, "<br>" => "\n", "<div>" => "", 
            "&#36;" => "\$", "&#37;" => "%", "&#38;" => "&", "&nbsp;" => " ", "&#60;" => "<", "	&lt;" => "<", 
            "&#62;" => ">", "&gt;" => ">", "<br" => "\n", "&bsol;" => "\\", "&#63;" => "?"))
            Component{Symbol(tg)}(compname, tg, properties)
        else
        end
    end for compname in readonly]))::Vector{AbstractComponent}
end

componenthtml(comps::Vector{<:AbstractComponent}) = join([string(comp) for comp in comps])

md_string(comp::Component{<:Any}) = comp[:text]
md_string(comp::Component{:h1}) = "# $(comp[:text])\n"
md_string(comp::Component{:h2}) = "## $(comp[:text])\n"
md_string(comp::Component{:h3}) = "### $(comp[:text])\n"
md_string(comp::Component{:h4}) = "#### $(comp[:text])\n"
md_string(comp::Component{:h5}) = "##### $(comp[:text])\n"
md_string(comp::Component{:h6}) = "###### $(comp[:text])\n"
md_string(comp::Component{:hr}) = "---\n"
md_string(comp::Component{:code}) = begin
    "```\n$(comp[:text])\n```"
end
md_string(comp::Component{:b}) = "**\n$(comp[:text])\n**"
md_string(comp::Component{:i}) = "*\n$(comp[:text])\n*"
md_string(comp::Component{:a}) = begin
    if :href in keys(comp.properties)
        "[$(comp[:text])]($(comp[:href]))"
    else
        comp[:text]
    end
end

function componentmd(comps::Vector{<:AbstractComponent})
    [md_string(comp) for comp in comps]
end
