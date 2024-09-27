require engine.core

let STATIC_BLOCK = request_prefab("assets/StaticBlock.prefab")
let RANDOM_ROTATION = 0.1
let RANDOM_SHIFT = 0.1

def private random_float3(s: float)
    return float3(random_range(-s, s), random_range(-s, s), random_range(-s, s))

def private create_cube(parent: NodeId; center: float3)
    let cube = instantiate_prefab(STATIC_BLOCK, parent)
    cube.localPosition = center + random_float3(RANDOM_SHIFT)
    cube.localRotation = quat4(random_float3(RANDOM_ROTATION))

def create_pyramid(center: float3; size: int)
    let pyramid = create_node([[NodeData() position=center, name="Pyramid"]])

    for i in range(0, size)
        let layer_size = size - i
        for j in range(-i, i)
            let diff = float3(float(j) * 1.05, 0.95 * float(layer_size), i)
            create_cube(pyramid, diff)
            create_cube(pyramid, float3(-diff.x, diff.y, -diff.z))
            create_cube(pyramid, float3(diff.z, diff.y, -diff.x))
            create_cube(pyramid, float3(-diff.z, diff.y, diff.x))

    return pyramid


