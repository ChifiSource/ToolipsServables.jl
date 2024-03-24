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
Alongside an interface for templating HTML files within Julia, `ToolipsServables` also includes a parametric `File` type. Files will convert into a read `String` of themselves when `string` is used on them. 
```julia
f = File("my.txt")

string(f)

    "hello world!"
```
With `Toolips`, these types can be interpolated (*or simply served*) very easily!
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
mainbody = body("bod")
style!(mainbody, "padding" => 25perc)
mainheader = div("myheader", align = "center")
style!(mainpadding, "background-color" => "darkgray")

message1 = h3("m", text = "you made it!")
message2 = h6("messag", text = "welcome to my HTML website!")
push!(mainheader, message1, message2)
push!(mainbody, mainheader)


touch("example.html"); open("example.html", "w") do o::IO
    write!(o, mainbody)
end
```
Along with regular HTML element components, `ToolipsServables` also includes `KeyFrames` for creating `@keyframe` CSS animations and `Style` for creating style classes with CSS. To apply a `Style` or `Animation`, we simply use `style!` `Style` will simply take style pairs similar to `style!`, whereas `KeyFrames` must be mutated with `keyframes!`.
```julia
exampleclass = style("div.myclass", "color" => "blue", "font-weight" => "bold")
comp = div("examplediv", text = "sample")
style!(comp, exampleclass)

fadein = keyframes("fadein")
keyframes!(fadein, 0percent, "opacity" => 0percent, "transform" => scale(1.1))
keyframes!(fadein, 50percent, "opacity" => 100percent, "transform" => scale(1))

style!(exampleclass, fadein)
# or
# style!(comp, fadein)

# make sure to write the CSS!
write!("", fadein, exampleclass, comp)
```
Here is a **detailed** templating example which includes several forms of templating:
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
Finally, `ToolipsServables` also provides parsing for these components via `htmlcomponent`.
```julia
comp = "<div id=\\"sample\\">hello</div>"

htmlcomponent(comp)["sample"]["text"]

"hello"
```
#### contributing guidelines
There are several ways to contribute to the ParametricProcesses package.

- submitting [issues](https://github.com/ChifiSource/ToolipsServables.jl/issues)
- creating packages which use `ToolipsServables`
- forking and pull-requesting your changes to this code
- trying other [chifi](https://github.com/ChifiSource) projects.
- contributing to other [chifi](https:://github.com/ChifiSource) projects (gives more attention here).

We are not super picky on contributions, as the goal of chifi is to get more people involved in computing. However, if you want your code merged there are definitely a few things to be aware of before contributing to this package.

- If there is no issue for what you want to do, create an issue.
- If you have multiple issues, submit multiple issues rather than typing each issue into one issue.
- Make sure the issue you are solving or feature you want to implement is still feasible on Unstable -- this is the top-level development branch which represents the latest unstable changes.
- Please format your documentation using the technique presented in the rest of the file.
- Make sure Pkg.test("ToolipsServables") works with your version of ToolipsServables before making a pull-request.
