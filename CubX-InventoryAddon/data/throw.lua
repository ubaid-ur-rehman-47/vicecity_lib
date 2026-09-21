--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

CubXThrowConfig = {
    handBone = 57005,

    force = 15.0,

    gravity = 9.81,

    trajectory = {
        enabled = true,
        points = 20,
        step = 0.08,
        color = { 32, 201, 151 },
        alpha = 255,

        landingMarker = {
            enabled = true,
            type = 28,
            scale = 0.1,
            color = { 32, 201, 151 },
            alpha = 180,
        },
    },

    offsets = {
        aim = vec3(0.0, 0.8, 0.5),
        throw = vec3(0.0, 1.0, 0.5),
    },

    attachOffsets = {
        default = {
            pos = vec3(0.11, 0.0, -0.075),
            rot = vec3(0.0, 0.0, 90.0),
        },

        models = {
        },
    },

    physics = {
        alignRotation      = true,
        inheritPedVelocity = true,
        spinForce          = 1.5,
        activatePhysics    = true,
    },

    cancelControl = 73,

    landing = {
        timeout = 200,
        velocityThreshold = 0.3,
        detectPlayerHit = true,
    },

    hit = {
        ragdollDuration = 3000,
        velocityDivisor = 6.0,
    },

    pickup = {
        enabled = true,
        dict = 'pickup_object',
        clip = 'pickup_low',
        flag = 48,
        duration = 2000,
        serverCallDelay = 500,
    },

    dropInteraction = {
        type = 'text3d',
        label = 'Pick up item',
        icon = 'fas fa-hand',

        target = {
            distance = 2.0,
            radius = 0.4,
        },

        text3d = {
            message = '[E] Pick up',
            scale = 0.35,
            font = 4,
            color = { 255, 255, 255 },
            alpha = 255,
            maxDistance = 3.0,
            zOffset = 0.3,
            key = 38,
        },

        textui = {
            message = '[E] Pick up',
            position = 'right-center',
            icon = 'fa-solid fa-hand',
            maxDistance = 1.5,
            key = 38,
        },
    },
}
