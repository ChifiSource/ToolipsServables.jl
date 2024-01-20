<div align="center">
  
<img src="https://github.com/ChifiSource/image_dump/blob/main/toolips/toolipsservables.png?raw=true" width="300"></img>

</div>

###### high-level and versatile `Component` templating
This package provides a versatile `Component` templating interface primarily intended to fill the role of HTML and CSS templating for [Toolips](https://github.com/ChifiSource/Toolips.jl).
```julia
using ToolipsServables

newstyle = Style("div.exampleclass", "color" => "green", "background-color" => "black", "font-size" => 13pt)

newdiv = div("newdiv", align = "center", class = "exampleclass")

s = write!("", newstyle, newdiv)

comps = ToolipsServables.htmlcomponent(s)
```
##### map
