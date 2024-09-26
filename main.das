require engine.core
require prefabs.player

let floorPF = request_prefab("prefabs/floor.prefab")

[export] def on_initialize()
    set_mouse_cursor_locked(true)

    create_render_settings()
    let sun = create_node([[NodeData() rotation=quat4(float3(-PI * 0.25f, 0f, PI / 3f))]])
    sun |> add_component([[DirectionLight()]])

    let floor = instantiate_prefab(floorPF)
    init_player(float3(0, 10, 0))

[export]
def on_update()
    pass