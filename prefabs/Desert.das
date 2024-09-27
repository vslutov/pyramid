require engine.core

var private oldCenter = int2(0, 0)
var private desert: NodeId
var private meshId: MeshId
var private collisionId: CollisionId

let private SIZE = 100.0
let private FREQ = 24
let private PLANE_FREQ = 2*FREQ + 1
let private COLLISION_FREQ = FREQ + 1

def private current_phase()
    return 0.05 * get_time()

def private create_plane_mesh(n : int; size: float) : MeshData

    var vertices : array<Vertex>
    var triangles : array<uint3>

    vertices |> reserve(n * n)
    for i in range(n)
        for j in range(n)

            let u = float(i) / float(n - 1)
            let v = float(j) / float(n - 1)
            vertices |> push(Vertex(position=float3(u - 0.5f, 0f, v - 0.5f) * size, normal=float3(0, 1, 0), tex_coord=3.0*float2(u, v)))


    triangles |> reserve((n - 1) * (n - 1) * 2)
    for i in range(n - 1)
        for j in range(n - 1)
            let a = i * n + j
            let b = i * n + j + 1
            let c = (i + 1) * n + j
            let d = (i + 1) * n + j + 1
            if (i + j) % 2 == 0
                triangles |> push(uint3(a, b, d))
                triangles |> push(uint3(a, d, c))
            else
                triangles |> push(uint3(a, b, c))
                triangles |> push(uint3(b, d, c))

    return <- MeshData(vertices<-vertices, triangles<-triangles)


let private originalMesh <- create_plane_mesh(PLANE_FREQ, 3.0 * SIZE)
var private animatedMesh := originalMesh
let private originalCollision <- create_plane_mesh(COLLISION_FREQ, 3.0 * SIZE)
var private animatedCollision := originalCollision

def private GerstnerWave(wave : float4; p : float3; var tangent, binormal : float3&; phase : float) : float3

    let steepness = wave.z
    let wavelength = wave.w
    let k = 2f * PI / wavelength
    let c = sqrt(9.8 / k)
    let d = normalize(wave.xy)
    let f = k * (dot(d, p.xz) - c * phase)
    let a = steepness / k

    var sin_f, cos_f : float
    sincos(f, sin_f, cos_f)

    tangent += float3(
        -d.x * d.x * (steepness * sin_f),
        d.x * (steepness * cos_f),
        -d.x * d.y * (steepness * sin_f)
    )
    binormal += float3(
        -d.x * d.y * (steepness * sin_f),
        d.y * (steepness * cos_f),
        -d.y * d.y * (steepness * sin_f)
    )
    return float3(
        d.x * (a * cos_f),
        a * sin_f,
        d.y * (a * cos_f)
    )

def private animate_vertex(var vertex : Vertex; wave_a, wave_b, wave_c : float4; phase : float; shift: float3) : void
    let gridPoint = vertex.position + shift
    var tangent = float3(1, 0, 0)
    var binormal = float3(0, 0, 1)
    var p = gridPoint
    p += GerstnerWave(wave_a, gridPoint, tangent, binormal, phase)
    p += GerstnerWave(wave_b, gridPoint, tangent, binormal, phase)
    p += GerstnerWave(wave_c, gridPoint, tangent, binormal, phase)
    let normal = normalize(cross(binormal, tangent))
    vertex.position = p - shift
    vertex.normal = normal

def private animate_mesh(mesh_src : MeshData; var mesh_dst : MeshData; phase : float; shift: float3) : void
    let wave_a = float4(1, 1, 0.25, 60)
    let wave_b = float4(1, 0.6, 0.25, 31)
    let wave_c = float4(1, 1.3, 0.25, 18)
    for vertex_src, vertex_dst in mesh_src.vertices, mesh_dst.vertices
        vertex_dst = vertex_src
        animate_vertex(vertex_dst, wave_a, wave_b, wave_c, phase, shift)


def init_desert()
    meshId = create_mesh(animatedMesh)
    collisionId = create_mesh_collision(animatedCollision)
    let shift = update_desert_mesh()

    desert = create_node([[NodeData() name="Desert"]])
    desert.localPosition = shift
    desert |> add_component() <| [[Mesh()
        meshId=meshId,
        materialId=request_material("materials/Sand/Sand.material"),
    ]]
    desert |> add_component() <| [[MeshCollider() collisionId=collisionId]]
    desert |> add_component() <| [[RigidBody() motionType=MotionType Static]]

def private update_desert_mesh()
    let shift = SIZE * float3(oldCenter.x, 0, oldCenter.y)
    animate_mesh(originalMesh, animatedMesh, current_phase(), shift)
    animate_mesh(originalCollision, animatedCollision, current_phase(), shift)
    update_mesh(meshId, animatedMesh)
    update_mesh_collision(collisionId, animatedCollision)
    return shift

def private close(a, b: int2; dist: int)
    let d = abs(a - b)
    return max(d.x, d.y) <= dist

def update_desert(origin: float3)
    var ori = (origin / SIZE).xz
    ori += 0.1 * (float2(oldCenter) - ori)
    let newCenter = int2(roundi(ori.x), roundi(ori.y))
    oldCenter = newCenter
    desert.localPosition = update_desert_mesh()

