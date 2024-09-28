require engine.core
require prefabs.Desert
require prefabs.Player
require prefabs.Pyramid

let APPEAR_TXT = request_sound("sounds/appear_txt.ogg")
let TRIGGER = request_prefab("prefabs/Trigger.prefab")
let BONUS = request_prefab("prefabs/Bonus.prefab")
let GOLD = request_prefab("prefabs/Gold.prefab")
let TITLE = request_sound("sounds/title_appear.ogg")

[async] def sleep(delay: float): void
    var end_time = get_time() + delay
    while get_time() < end_time
        await_next_frame()

var private txt: NodeId
def private clear_text()
    if txt |> valid()
        txt |> remove_node()
    txt = [[NodeId]]

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
    let first_waypoint = TRIGGER |> instantiate_prefab()
    first_waypoint.localPosition = float3(60, 3, -24)
    let second_waypoint = BONUS |> instantiate_prefab()
    second_waypoint.localPosition = float3(0, 0, 0)

    await <| sleep(3.0)
    set_text("Pyramid", 256.0)
    TITLE |> play_sound()
    await <| sleep(5.0)
    set_text("Better to play in headphones")
    await <| sleep(3.0)
    set_text("Task: find the pyramid")
    APPEAR_TXT |> play_sound()
    await <| sleep(3.0)
    set_text("W to move forward")
    allowW = true
    APPEAR_TXT |> play_sound()

    await <| trigger(first_waypoint)
    first_waypoint |> remove_node()
    moveSand  = true
    allowMove = true
    set_text("Mouse to look, WASD to move")
    await <| sleep(5.0)
    clear_text()

    await <| trigger(second_waypoint)
    second_waypoint |> remove_node()
    set_text("You got new shoes: SHIFT to run")
    allowRun = true

    spawn_pyramid(1)
    let third_waypoint = BONUS |> instantiate_prefab()
    third_waypoint.localPosition = float3(0, 1, 100)

    await <| sleep(5.0)
    set_text("Task: find second pyramid")
    APPEAR_TXT |> play_sound()
    await <| sleep(3.0)
    clear_text()

    await <| trigger(third_waypoint)
    third_waypoint |> remove_node()
    set_text("You drunk coffee: SPACE to jump")
    allowJump = true

    spawn_pyramid(2)
    let final_waypoint = GOLD |> instantiate_prefab()
    final_waypoint.localPosition = float3(-60, 29, 190)

    await <| sleep(5.0)
    set_text("Task: find GOLD")
    APPEAR_TXT |> play_sound()
    await <| sleep(3.0)
    clear_text()

    await <| trigger(final_waypoint)
    final_waypoint |> remove_node()
    set_text("VICTORY!", 256.0)
    TITLE |> play_sound()
    allowW = false
    allowRun = false
    allowMove = false
    allowJump = false
    await <| sleep(10.0)
    set_text("Are you still here?")
    allowW = true
    allowRun = true
    allowMove = true
    allowJump = true
    await <| sleep(3.0)
    set_text("Now you can try to find the end of map :P", 32.0)
    await <| sleep(5.0)
    clear_text()
