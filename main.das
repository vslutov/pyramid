require engine.core
require prefabs.Player
require prefabs.Pyramid
require prefabs.Desert
require engine.runtime.das_profiler

let RENDER_SETTINGS = request_prefab("assets/RenderSettings.prefab")

[export] def on_initialize()
    set_mouse_cursor_locked(true)

    let rs = create_render_settings()
    rs |> get_component() <| $(var sky: Sky)
        sky.materialId = request_material("materials/Skybox/Skybox.material")
    let sun = create_node([[NodeData() rotation=quat4(float3(PI / 6.0, 0, PI / 3.0)), name="sun"]])
    sun |> add_component([[DirectionLight()]])

    init_desert()
    init_player(float3(70, -1, -24))

    create_pyramid(float3(0, -3, 0), 15)

[export]
def on_update()
    pass