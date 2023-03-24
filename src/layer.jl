"""
    Layer(data; kw...)

Wrapper for a point/polygon layer to be passed to leaflet, holding 
any GeoInterface.jl compatale geometry data, and settings for displaying 
it in the Leaflet map.

A `Layer` or `Vector` of `Layer` is used for the `layers` keyword of [`Map`](@ref).

# Arguments

- `data`: An object conforming to the GeoInterface.jl interface
    or a `Vector` of these objects.

# Keyword arguments

- `color = "blue"`: shape color. Can use web color names or RGB strings.
- `color_map = "nothing"`: color map.
- `opacity = 0.5`: alpha transparency.
- `fill_opacity = 0.5`: alpha transparency of fill. By default the same as `opacity`.
- `marker_size = 3.0`: size of markers.
- `border_width = 2.0`: width of shape borders.
"""
struct Layer{T}
    data::T
    options::Dict{Symbol, Any}
end
function Layer(
    data;
    color_map = "nothing",
    color = :blue,
    opacity = 0.5,
    fill_opacity = opacity,
    marker_size = 3.0,
    border_width = 2.0,
)
color_to_use="#"
if isa(color,Symbol)
    color_to_use*=Colors.hex(Colors.parse(Colors.Colorant,color))
elseif isa(color,Colors.RGB)
    color_to_use*=Colors.hex(color)
elseif isa(color,Colors.RGBA)
    color_to_use*=Colors.hex(color)[3:end]
else
    color_to_use=color
end
    options = Dict(
        :color_map => string(color_map), 
        :color => color_to_use, 
        :opacity => opacity,
        :fill_opacity => fill_opacity,
        :marker_size => marker_size, 
        :border_width => border_width,
    )
    Layer(data, options)
end
