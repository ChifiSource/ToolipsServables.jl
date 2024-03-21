<div align="center">
  
<img src="https://github.com/ChifiSource/image_dump/blob/main/toolips/toolipsservables.png?raw=true" width="300"></img>

</div>

###### high-level and versatile `Component` templating
This package provides a versatile `Component` templating interface primarily intended to fill the role of HTML and CSS templating for [Toolips](https://github.com/ChifiSource/Toolips.jl) **0.3 +**.
```julia
using Pkg; Pkg.add("ToolipsServables")
# or with the web-framework `Toolips`:
using Pkg; Pkg.add("Toolips")
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
### toolips servables
`ToolipsServables` provides an extensible HTML and CSS templating platform centralized on parametric typing and extensibility. This package provides a simple API for creating beautiful websites to write to responses through both files and a *julianized* API.
###### map
- [quick start](#toolips-servables)
  - [documentation](#documentation)
  - [files](#files)
  - [components](#components)
  - [IO](#io)
- [contributing](#contributing-guidelines)
##### documentation
##### files
Alongside an interface for templating HTML files within Julia, `ToolipsServables` also includes a parametric `File` type. With `Toolips`, these types can be interpolated (*or simply served*) very easily!
##### components
The most crucial goal of this package is to provide a parametric HTML templating framework for Julia. This is all facilitated through the `Component`. The `Component` is equivalent to an `HTML` element. For example we have the `HTML` `div` and the `ToolipsServables` `div`:
```julia
using ToolipsServables
container = div("container", contenteditable = true, text = "hello world")
```
```html
<div id="container" contenteditable="true">hello world</div>
```
Components are meant to be written to some output, or transformed into a `String` to be displayed as `HTML`. Using a few simple functions, we are able to compose and style these components to create our page. The main functions for these tasks are `push!`, `style!`, and occassionally `set_children!`. Yes, it really is that simple! Here is a simple page composition:
```julia
mainheader = div("myheader", align = "center")
style!(mainpadding, "background-color" => "darkgray")
push!()
```
Here is a detailed templating example which includes several forms of templating:
```julia
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

# creting styles
post_style = style("div.postbox", "border-radius" => 5px, "border" => "5px solid black")
fadein = keyframes("fadein")
                #  vv (or 0percent)
keyframes!(fadein, from, "opacity" => 0percent)
                #  vv (or 100percent)
keyframes!(fadein, to, "opacity" => 100percent)
style!(post_style, fadein)
# composing a body:
mainbod = body("mainbody")
    # animation
style!(mainbod, fadein)
    # inline styles
style!(mainbod, "padding" => 10percent, "background-color" => "lightblue")
    # generating post divs
posts = ["hello world!", "post example"]
for (e, post) in enumerate(posts)
    comp = div("post$(e)")
    style!(comp, post_style)
    posthead = h4("head$(e)", text = "$(e)")
    postbody = p("body$(e)", text = post)
    style!(postbody, "font-size" => 13pt, "color" => "darkgray")
    push!(comp, posthead, postbody)
    # push! to body:
    push!(mainbod, comp)
end
# components can be written with `write!` or turned to a `String` with `string`
# <:IO, <:Toolips.AbstractConnection, `String`
@info string(mainbod)
result = write!("", post_style, fadein, mainbod)
```
###### IO
It is likely we are somewhat familiar with `ToolipsServables` output at this point. Any type which is binded to `write` is generally writable using `write!`, though this might not always be the case. When writing, a `Servable` will call its typical `string` `Method`. `ToolipsServables` also provides a useful input function for parsing `HTML` into Components -- such as from a file, or request; `htmlcomponent`.
#### contributing guidelines
