using JSServe
using Observables
using JSServe: Asset
JSServe.browser_display()

leafletjs = JSServe.ES6Module("https://esm.sh/v111/leaflet@1.9.3/es2022/leaflet.js")
leafletcss = Asset("https://unpkg.com/leaflet@1.9.3/dist/leaflet.css")

struct LeafletMap
    center::Observable{NTuple{2,Float64}}  # center of leaflet map in (lat, lng).
    zoom::Observable{Int}  # zoom level of leaflet map.
    size::NTuple{2,String}  # size of container on the page in (width, height), expects anything the height and width css properties can handle.
    _message::Observable{Any}  # general endpoint to notify javascript events against.
    _js_leafmap::Observable{Any}  # holds reference to the javascript map object
    function LeafletMap(center::NTuple{2,Float64}, zoom::Int, size)
        leaflet_map = new(
            Observable(center),
            Observable(zoom),
            size,
            Observable{Any}(nothing),
            Observable{Any}(nothing)
        )
        return leaflet_map
    end
end

set_zoom!(map::LeafletMap, new_level::Int) = map.zoom[] = new_level
set_center!(map::LeafletMap, new_center::NTuple{2,Float64}) = map.center[] = new_center

function JSServe.jsrender(session::Session, map::LeafletMap)
    map_div = DOM.div(id="map"; style="width: $(map.size[1]); height: $(map.size[2]);")

    # update state change coming from the julia side on the javascript side.
    #onjs(session, map.zoom, js"""e=>leaf_map.setZoom(e)""")
    #onjs(session, map.center, js"""e=>leaf_map.setView(e)""")

    # when an update gets triggered from the javascript side, parse what we get sent
    # and silently change the appropriate variables on the julia side.
    on(map._message) do m
        if m["event"] == "zoom"
            map.zoom.val = m["payload"]
        elseif m["event"] == "move"
            payload = m["payload"]
            map.center.val = (payload["lat"], payload["lng"])
        end
        @show m
        map._message.val = nothing
    end

    return JSServe.jsrender(session, DOM.div(
        leafletcss,
        leafletjs,
        map_div,
        js"""
        const leaf_map = L.map('map').setView($((map.center[])), $(map.zoom[]));
        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    maxZoom: 19,
                    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                }).addTo(leaf_map);

        // register zoom and move events and notify map._message with a special object
        leaf_map.on("zoom", e=>{
            $(map._message).notify({event:"zoom", payload:e.target.getZoom()});
            console.log(e.target.getZoom());
        });
        leaf_map.on("move", e=>{
            const position = e.target.getCenter();
            $(map._message).notify({event:"move", payload:position});
            console.log(position);
        })

        // register zoom and move events coming from julia
        $(map.zoom).on(e=>leaf_map.setZoom(e))
        $(map.center).on(e=>leaf_map.setView(e))

        // this should give me a reference to the javascript object in julia (but doesn't...)
        //`map._js_leafmap[]` = leaf_map

        // attach map to window for debugging...
        window.leaf_map = leaf_map;
        """
    ))
end

lmap = LeafletMap((51.505, -0.09), 13, ("100vw", "100vh"))

a = App() do
    return lmap
end

set_zoom!(lmap, 10)
set_center!(lmap, (51.0, 0.67))