require engine.core
require prefabs.Desert
require prefabs.Player

let APPEAR_TXT = request_sound("sounds/appear_txt.ogg")
let TRIGGER = request_prefab("prefabs/Trigger.prefab")

[async] def sleep(delay: float): void
    var t = 0.0
    while t < delay
        t += get_delta_time()
        await_next_frame()

var private txt: NodeId
def private clear_text()
    if txt |> valid()
        txt |> remove_node()

def private set_text(text: string; fontSize: float = 64.0)
    clear_text()
    txt = create_node([[NodeData() name="txt"]])
    txt |> add_component([[UIText() fontSize=fontSize, pivot=float2(0.5, 0.8), text=text, color=float4(0, 0, 0, 1)]])

[async] def trigger(trigger: NodeId): void
    var found = false
    let q = [[BoxQuery() position=trigger.localPosition, half_extents=0.5*trigger.localScale, rotation=trigger.localRotation, collisionMask=2U]]
    while !found
        await_next_frame()
        q |> overlap <| $(hit)
            if hit |> length() > 0
                found = true

[async] def start_script(): void
    /*await <| sleep(3.0)
    set_text("Pyramid", 256.0)
    request_sound("sounds/title_appear.ogg") |> play_sound()
    await <| sleep(5.0)
    set_text("Recommended to play in headphones")
    await <| sleep(3.0)
    set_text("Task: find the pyramid")
    APPEAR_TXT |> play_sound()
    await <| sleep(3.0)*/
    set_text("W to move forward")
    allowW = true
    APPEAR_TXT |> play_sound()

    let first_waypoint = TRIGGER |> instantiate_prefab()
    first_waypoint.localPosition = float3(60, 3, -24)
    await <| trigger(first_waypoint)
    first_waypoint |> remove_node()
    moveSand  = true
    allowMove = true
    set_text("Task: enter to the pyramid")
    APPEAR_TXT |> play_sound()
    await <| sleep(3.0)
    set_text("Mouse to look, WASD to move")
    await <| sleep(5.0)
    clear_text()
