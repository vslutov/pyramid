require engine.core


[export] def on_initialize()
    let cubeMesh = request_cube_mesh()
    let planeMesh = request_plane_mesh()

    let cube = create_node([[NodeData() name="cube", position=float3(0, 1, 0), rotation=quat4(float3(PI * 0.3f, 0f, 0f))]])
    cube |> add_component() <| [[Mesh() meshId=cubeMesh]]
    let plane = create_node([[NodeData() name="plane", scale=float3(10, 1, 10)]])
    plane |> add_component() <| [[Mesh() meshId=planeMesh]]

    let camera = create_node([[NodeData() position=float3(0, 5, -5), rotation=quat4(float3(0f, 0f, PI / 4f))]])
    camera |> add_component([[Camera()]])

    let sun = create_node([[NodeData() rotation=quat4(float3(-PI * 0.25f, 0f, PI / 3f))]])
    sun |> add_component([[DirectionLight()]])

    let renderSettings = create_render_settings()

[export]
def on_update()
    pass