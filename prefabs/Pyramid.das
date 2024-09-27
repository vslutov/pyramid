require engine.core

let STATIC_BLOCK = request_prefab("assets/StaticBlock.prefab")
let RANDOM_ROTATION = 0.1
let RANDOM_SHIFT = 0.1
let SPLIT = 0.9

def private random_float3(s: float)
    return float3(random_range(-s, s), random_range(-s, s), random_range(-s, s))

def private create_cube(parent: NodeId; center: float3)
    let cube = instantiate_prefab(STATIC_BLOCK, parent)
    cube.localPosition = center + random_float3(RANDOM_SHIFT)
    cube.localRotation = quat4(random_float3(RANDOM_ROTATION))

def private add_tri(var vertices : array<Vertex>; var triangles : array<uint3>; a, b, c: float3)
    let s = vertices |> length()
    let n = normalize(cross(b - a, c - a))
    vertices |> push(Vertex(position=a, normal=n, tex_coord=float2(0, 0)))
    vertices |> push(Vertex(position=b, normal=n, tex_coord=float2(distance(a, b), 0)))
    vertices |> push(Vertex(position=c, normal=n, tex_coord=float2(distance(a, b) * 0.5, distance((a + b)*0.5, c))))

    triangles |> push(uint3(s, s + 1, s + 2))

def private add_gate(var vertices : array<Vertex>; var triangles : array<uint3>; a, b, c: float3)
    let ac = lerp(a, c, SPLIT)
    let ah = lerp(a, b, SPLIT * 0.5)
    let ac0 = float3(ac.x, ac.y, 0)
    let ah0 = float3(ah.x, ah.y, 0)
    let bc = lerp(b, c, SPLIT)
    let bh = lerp(a, b, 1.0 - SPLIT * 0.5)
    let bc0 = float3(bc.x, bc.y, 0)
    let bh0 = float3(bh.x, bh.y, 0)
    add_tri(vertices, triangles, ac, bc, c)
    add_tri(vertices, triangles, a, ah, ac)
    add_tri(vertices, triangles, ah, ah0, ac0)
    add_tri(vertices, triangles, ac0, ac, ah)
    add_tri(vertices, triangles, bh, b, bc)
    add_tri(vertices, triangles, bh0, bh, bc0)
    add_tri(vertices, triangles, bc, bc0, bh)


def private create_pyro_mesh(size: int; parent: NodeId)
    var vertices : array<Vertex>
    vertices |> reserve(4 * 8)
    var triangles : array<uint3>
    vertices |> reserve(8)


    let a = float3(-float(size) * .5, 0, float(size) * .5)
    let b = float3(float(size) * .5, 0, float(size) * .5)
    let c = float3(0, float(size) - 2.0, 0)
    add_gate(vertices, triangles, a, b, c)
    add_tri(vertices, triangles, b, -a, c)
    add_gate(vertices, triangles, -a, -b, c)
    add_tri(vertices, triangles, -b, a, c)

    let md <- MeshData(vertices<-vertices, triangles<-triangles)
    let meshId = create_mesh(md)
    let pyro = create_node([[NodeData() name="PyroTriange", parent=parent]])
    pyro |> add_component() <| [[Mesh()
        meshId=meshId,
        materialId=request_material("materials/StaticBlock/StaticBlock.material"),
    ]]
    return pyro


def create_pyramid(center: float3; size: int)
    let pyramid = create_node([[NodeData() position=center, name="Pyramid"]])
    create_pyro_mesh(size, pyramid)
    let wall = float(size) * (1.0 - SPLIT) - 1.0

    for i in range(0, size + 1)
        let layer_height = size - i
        for j in range(1, i)
            let diff = float3(float(j) * 1.05 - 0.5025 * float(i), 0.95 * float(layer_height), 0.5 * float(i))
            let perc = 2.0 * float(j) / float(i)
            if float(layer_height) >= 0.7 * float(size) || perc < SPLIT || perc > 2.0 - SPLIT
                create_cube(pyramid, diff)
                create_cube(pyramid, float3(-diff.x, diff.y, -diff.z))
            create_cube(pyramid, float3(-diff.z, diff.y, diff.x))
            create_cube(pyramid, float3(diff.z, diff.y, -diff.x))
            create_cube(pyramid, float3(wall, diff.y, diff.x))
            create_cube(pyramid, float3(-wall, diff.y, diff.x))
            if i == 4
                create_cube(pyramid, float3(0.5, diff.y, diff.x))
                create_cube(pyramid, float3(-0.5, diff.y, diff.x))




