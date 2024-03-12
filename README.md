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
- [quick start](#toolips-servables)
  - [documentation](#documentation)
  - [files](#files)
  - [components](#components)
  - [IO](#io)
- [contributing](#contributing-guidelines)
### toolips servables
##### documentation
##### files
##### components
The most crucial goal of this package is to provide a parametric HTML templating framework for Julia. This is all facilitated through the `Component`. The `Component` is equivalent to an `HTML` element. For example we have the `HTML` `div` and the `ToolipsServables` `div`:
```julia
using ToolipsServables
container = div("container", contenteditable = true, text = "hello world")
```
```html
<div id="container" contenteditable="true">hello world</div>
```
Components are meant to be written to some output, or transformed into a `String` to be displayed as `HTML`. Using a few simple functions, we are able to compose and style these components to create our page. The main functions for these tasks are `push!`, `style!`
```julia
```
###### IO
It is likely we are somewhat familiar with `ToolipsServables` output at this point. Any type which is binded to `write` is generally writable using `write!`, though this might not always be the case. When writing, a `Servable` will call its typical `string` `Method`. `ToolipsServables` also provides a useful input function for parsing `HTML` into Components -- such as from a file, or request; `htmlcomponent`.
#### contributing guidelines
