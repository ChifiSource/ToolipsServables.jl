<div align="center">
  
<img src="https://github.com/ChifiSource/image_dump/blob/main/toolips/toolipsservables.png?raw=true" width="300"></img>

</div>

###### high-level and versatile `Component` templating
This package provides a versatile `Component` templating interface primarily intended to fill the role of HTML and CSS templating for [Toolips](https://github.com/ChifiSource/Toolips.jl).
```julia
using Pkg; Pkg.add("ToolipsServables")
# or with the web-framework `Toolips`:
using Pkg; Pkg.add("Toolips")
```
```julia
using ToolipsServables
# using Toolips.Components

newstyle = Style("div.exampleclass", "color" => "green", "background-color" => "black", "font-size" => 13pt)

newdiv = div("newdiv", align = "center", class = "exampleclass")

s = write!("", newstyle, newdiv)

comps = ToolipsServables.htmlcomponent(s)
```
```julia
using ToolipsServables
# using Toolips.Components

# creating components
myd::Component{:div} = div("example", text = "hello world!")

myheading::Component{:h1} = h1("myheading", text = "example")

elements::Vector{<:AbstractComponent} = [p("example", text = e) for e in 1:10]

# composing components
style!(myheading, "color" => "white", "font-size" => 10pt)
push!(myd, myheading)
set_children!(myheading, elements)
# writing components
buff = IOBuffer()
write!(buff, myd)
str = ""
write!(str, myd)
using Toolips
c = Toolips.SpoofConnection()
write!(c, myd)
```
##### map
- [components](#components)
  - [styles](#styles)
  - [composing](#composing)
- [IO](#io)
- [contributing](#contributing-guidelines)
### components
#### styles
#### composing
###### IO
##### contributing guidelines
