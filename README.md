# Leaflet

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://supergrobi.github.io/Leaflet.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://supergrobi.github.io/Leaflet.jl/dev)
[![CI](https://github.com/SuperGrobi/Leaflet.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/SuperGrobi/Leaflet.jl/actions/workflows/CI.yml)

LeafletJS maps for Julia.

This package integrates with JSServe.jl to render leaflet maps to backends able to deal with html.

All [GeoInterface.jl](https://github.com/JuliaGeo/GeoInterface.jl) compatible geometries can be displayed as layers.

A basic (non-working) example, where we use GADM to download a country boundary shapefile,
and plot them over the CARTO `:dark_nolabels` base layers.

```julia
using Leaflet, Electron, GADM, JSServe
JSServe.use_electron_display()
layers = Leaflet.Layer.([GADM.get("CHN").geom[1], GADM.get("JPN").geom[1]]; color=:orange); 
provider = Providers.CartoDB()
m = Leaflet.Map(; layers, provider, zoom=3, height=1000, center=[30.0, 120.0]);
display(m)
```
![](docs/img/example-fs8.png)
