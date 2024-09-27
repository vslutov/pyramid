require engine.core
require prefabs.Player
require prefabs.Pyramid
require prefabs.Desert
require engine.runtime.das_profiler

let FLOOR = request_prefab("assets/Floor.prefab")

[export] def on_initialize()
    set_mouse_cursor_locked(true)

    create_render_settings()
    let sun = create_node([[NodeData() rotation=quat4(float3(-PI * 0.25f, 0f, PI / 3f))]])
    sun |> add_component([[DirectionLight()]])

    //let floor = instantiate_prefab(FLOOR)
    init_desert()
    init_player(float3(20, 5, 0))

    create_pyramid(float3(0, -3, 0), 15)

[export]
def on_update()
    pass