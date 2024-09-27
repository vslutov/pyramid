require engine.core
require prefabs.Desert

let PLAYER = request_prefab("prefabs/Player.prefab")
let ROT_SPEED = 0.005
let WALK_SPEED = 5.0
let RUN_SPEED = WALK_SPEED * 2.0
let JUMP_SPEED = 4.0
let JUMP_DELAY = 0.5
let LEG_SIZE = 0.7

struct PlayerInput
    forward: bool = false
    backward: bool = false
    left: bool = false
    right: bool = false
    run: bool = false
    jump: bool = false

    rotY: float = 0.0
    rotX: float = -PI / 2.0

struct PlayerState
    bodyHeight: float = 0.0
    floorHeight: float = 0.0
    onGround: bool = false
    lastJump: float = -JUMP_DELAY

class Player : Component
    camera: NodeId
    playerInput = [[PlayerInput()]]
    playerState = [[PlayerState()]]

    def override on_update() // will be called each frame
        self->input()
        self->rotate()
        self->checkState()
        self->move()
        update_desert(nodeId.localPosition)

    def checkState()
        playerState.onGround = false
        [[RayCast() rayOrigin=nodeId.localPosition, rayDirection=float3(0, -1, 0), maxDistance=LEG_SIZE + playerState.bodyHeight, collisionMask=1U]] |> trace() <| $(hit: RaycastHit)
            playerState.onGround = true
            playerState.floorHeight = nodeId.localPosition.y - hit.distance

    def input()
        for cmd in get_input_command_buffer()
            match cmd
                if [[RawKeyboardInputEvent kind=RawKeyboardInputEventKind KeyDown, buttonIdx=$v(buttonIdx)]]
                    if buttonIdx == VK_UP || buttonIdx == VK_W
                        playerInput.forward = true
                    if buttonIdx == VK_DOWN || buttonIdx == VK_S
                        playerInput.backward = true
                    if buttonIdx == VK_LEFT || buttonIdx == VK_A
                        playerInput.left = true
                    if buttonIdx == VK_RIGHT || buttonIdx == VK_D
                        playerInput.right = true
                    if buttonIdx == VK_RSHIFT || buttonIdx == VK_LSHIFT
                        playerInput.run = true
                    if buttonIdx == VK_SPACE
                        playerInput.jump = true

                if [[RawKeyboardInputEvent kind=RawKeyboardInputEventKind KeyUp, buttonIdx=$v(buttonIdx)]]
                    if buttonIdx == VK_UP || buttonIdx == VK_W
                        playerInput.forward = false
                    if buttonIdx == VK_DOWN || buttonIdx == VK_S
                        playerInput.backward = false
                    if buttonIdx == VK_LEFT || buttonIdx == VK_A
                        playerInput.left = false
                    if buttonIdx == VK_RIGHT || buttonIdx == VK_D
                        playerInput.right = false
                    if buttonIdx == VK_RSHIFT || buttonIdx == VK_LSHIFT
                        playerInput.run = false
                    if buttonIdx == VK_SPACE
                        playerInput.jump = false

                if [[RawMouseInputEvent deltaPosition=$v(deltaPosition)]]
                    playerInput.rotX += ROT_SPEED * deltaPosition.x
                    if playerInput.rotX < -3.0 * PI
                        playerInput.rotX += 2.0 * PI
                    if playerInput.rotX > 3.0 * PI
                        playerInput.rotX -= 2.0 * PI
                    playerInput.rotY += ROT_SPEED * deltaPosition.y
                    playerInput.rotY = clamp(playerInput.rotY, -PI * 0.5, PI * 0.5)

    def rotate()
        nodeId.localRotation = quat4(playerInput.rotX, 0, 0)
        camera.localRotation = quat4(0, 0, playerInput.rotY)

    def move()
        let currentTime = get_time()
        let inJump = currentTime - playerState.lastJump <= JUMP_DELAY

        nodeId |> get_component() <| $(var body: RigidBody)
            body.useGravity = !playerState.onGround
            if playerState.onGround
                var vel_y = max(body.velocity.y, 0.0)

                if playerInput.jump && !inJump
                    vel_y = JUMP_SPEED
                    playerState.lastJump = currentTime

                let localY = max(nodeId.localPosition.y, playerState.floorHeight + playerState.bodyHeight)
                nodeId.localPosition = float3(nodeId.localPosition.x, localY, nodeId.localPosition.z)

                let speed = playerInput.run ? RUN_SPEED : WALK_SPEED
                var speedDir = float3(0, 0, 0)
                if playerInput.forward
                    speedDir = nodeId.localForward
                elif playerInput.backward
                    speedDir = -nodeId.localForward

                if playerInput.right && !playerInput.left
                    speedDir += nodeId.localRight
                if playerInput.left && !playerInput.right
                    speedDir -= nodeId.localRight

                speedDir = speed * normalize(speedDir)

                body.velocity = float3(
                    speedDir.x,
                    vel_y,
                    speedDir.z)

    def override on_initialize() : void // will be called when the component appears on the scene (attached)
        camera = nodeId |> get_child(0)
        nodeId |> get_component() <| $(col: CapsuleCollider)
            playerState.bodyHeight = col.height * 0.5 + LEG_SIZE

    def override on_destroy() : void // will be called when the component is destroyed.
        pass

def init_player(coord: float3)
    let player = instantiate_prefab(PLAYER)
    player.localPosition = coord
    player |> add_component() <| [[Player()]]
