------------------------------------------------------------
-- Atonement Alert
--
-- Tracks ONLY Atonement on the player.
--
-- Atonement spell ID: 194384
--
-- WoW Midnight 12.1
------------------------------------------------------------

local ADDON_NAME = ...

local ATONEMENT_ID = 194384

------------------------------------------------------------
-- Configuration
------------------------------------------------------------

local BUTTON_SIZE = 72

local DEFAULT_X = 0
local DEFAULT_Y = -220

------------------------------------------------------------
-- Sound Configuration
------------------------------------------------------------

local SOUND_FILE =
    "Interface\\AddOns\\AtonementAlert\\Sounds\\AtonementWarning.ogg"

------------------------------------------------------------
-- Database
------------------------------------------------------------

local db

------------------------------------------------------------
-- Aura sound registration ID
------------------------------------------------------------

local AtonementAuraSoundID = nil

------------------------------------------------------------
-- Main movable frame
--
-- IMPORTANT:
--
-- This is a normal Frame.
--
-- The AuraContainer lives INSIDE this frame.
--
-- We move/save THIS frame instead of the AuraContainer.
------------------------------------------------------------

local mover = CreateFrame(
    "Frame",
    "AtonementAlertMover",
    UIParent
)

mover:SetSize(
    BUTTON_SIZE,
    BUTTON_SIZE
)

mover:SetClampedToScreen(true)

mover:SetMovable(true)

mover:EnableMouse(true)

------------------------------------------------------------
-- AuraContainer
------------------------------------------------------------

local container = CreateFrame(
    "AuraContainer",
    "AtonementAlertContainer",
    mover,
    "CustomAuraContainerTemplate"
)

container:SetSize(
    BUTTON_SIZE,
    BUTTON_SIZE
)

container:SetPoint(
    "CENTER",
    mover,
    "CENTER",
    0,
    0
)

container:SetUnit(
    "player"
)

------------------------------------------------------------
-- Duration Formatter
------------------------------------------------------------

local durationFormatter

if C_StringUtil
    and C_StringUtil.CreateSecondsFormatter then

    durationFormatter =
        C_StringUtil.CreateSecondsFormatter()

    if durationFormatter.SetDefaultAbbreviation then

        durationFormatter:SetDefaultAbbreviation(
            Enum.SecondsFormatterAbbreviation.OneLetter
        )

    end

    if durationFormatter.SetStripIntervalWhitespace then

        durationFormatter:SetStripIntervalWhitespace(
            Enum.SecondsFormatterIntervalWhitespace.Strip
        )

    end

end

------------------------------------------------------------
-- Atonement Color / Flash Curve
------------------------------------------------------------

local AtonementColorCurve

if C_CurveUtil
    and C_CurveUtil.CreateColorCurve then

    AtonementColorCurve =
        C_CurveUtil.CreateColorCurve()

    AtonementColorCurve:SetType(
        Enum.LuaCurveType.Step
    )

    --------------------------------------------------------
    -- Normal
    --------------------------------------------------------

    AtonementColorCurve:AddPoint(
        10,
        CreateColor(
            1.0,
            1.0,
            1.0,
            1.0
        )
    )

    --------------------------------------------------------
    -- Yellow
    --------------------------------------------------------

    AtonementColorCurve:AddPoint(
        5,
        CreateColor(
            1.0,
            1.0,
            0.0,
            1.0
        )
    )

    --------------------------------------------------------
    -- Flashing starts at 3 seconds
    --------------------------------------------------------

    AtonementColorCurve:AddPoint(
        3.0,
        CreateColor(
            1.0,
            1.0,
            0.0,
            1.0
        )
    )

    AtonementColorCurve:AddPoint(
        2.75,
        CreateColor(
            1.0,
            0.05,
            0.05,
            1.0
        )
    )

    AtonementColorCurve:AddPoint(
        2.50,
        CreateColor(
            1.0,
            1.0,
            1.0,
            1.0
        )
    )

    AtonementColorCurve:AddPoint(
        2.25,
        CreateColor(
            1.0,
            0.05,
            0.05,
            1.0
        )
    )

    AtonementColorCurve:AddPoint(
        2.00,
        CreateColor(
            1.0,
            1.0,
            1.0,
            1.0
        )
    )

    AtonementColorCurve:AddPoint(
        1.75,
        CreateColor(
            1.0,
            0.05,
            0.05,
            1.0
        )
    )

    AtonementColorCurve:AddPoint(
        1.50,
        CreateColor(
            1.0,
            1.0,
            1.0,
            1.0
        )
    )

    AtonementColorCurve:AddPoint(
        1.25,
        CreateColor(
            1.0,
            0.05,
            0.05,
            1.0
        )
    )

    AtonementColorCurve:AddPoint(
        1.00,
        CreateColor(
            1.0,
            1.0,
            1.0,
            1.0
        )
    )

    AtonementColorCurve:AddPoint(
        0.75,
        CreateColor(
            1.0,
            0.05,
            0.05,
            1.0
        )
    )

    AtonementColorCurve:AddPoint(
        0.50,
        CreateColor(
            1.0,
            1.0,
            1.0,
            1.0
        )
    )

    AtonementColorCurve:AddPoint(
        0.25,
        CreateColor(
            1.0,
            0.05,
            0.05,
            1.0
        )
    )

    AtonementColorCurve:AddPoint(
        0,
        CreateColor(
            1.0,
            0.0,
            0.0,
            1.0
        )
    )

end

------------------------------------------------------------
-- Atonement AuraButton initializer
------------------------------------------------------------

local function InitializeAtonementButton(button)

    button:SetSize(
        BUTTON_SIZE,
        BUTTON_SIZE
    )

    --------------------------------------------------------
    -- Icon
    --------------------------------------------------------

    local icon = button:CreateTexture(
        nil,
        "ARTWORK"
    )

    icon:SetAllPoints(button)

    icon:SetTexCoord(
        0.07,
        0.93,
        0.07,
        0.93
    )

    button.AtonementIcon = icon

    button:SetIcon(
        icon
    )

    --------------------------------------------------------
    -- Countdown
    --------------------------------------------------------

    local durationText =
        button:CreateFontString(
            nil,
            "OVERLAY"
        )

    durationText:SetPoint(
        "CENTER",
        button,
        "CENTER",
        0,
        0
    )

    durationText:SetFont(
        STANDARD_TEXT_FONT,
        36,
        "OUTLINE"
    )

    durationText:SetShadowColor(
        0,
        0,
        0,
        1
    )

    durationText:SetShadowOffset(
        2,
        -2
    )

    durationText:SetTextColor(
        1,
        1,
        1,
        1
    )

    button.AtonementDurationText =
        durationText

    --------------------------------------------------------
    -- Duration options
    --------------------------------------------------------

    local durationOptions = {}

    if durationFormatter then

        durationOptions.textFormatter =
            durationFormatter

    end

    if AtonementColorCurve then

        durationOptions.textColor = {

            curve = AtonementColorCurve,

            property =
                Enum.DurationTextBindingProperty
                    .RemainingDuration,

        }

    end

    --------------------------------------------------------
    -- Set duration text
    --------------------------------------------------------

    local success, errorMessage =
        pcall(
            button.SetDurationText,
            button,
            durationText,
            durationOptions
        )

    --------------------------------------------------------
    -- Fallback
    --------------------------------------------------------

    if not success then

        local fallbackSuccess =
            pcall(
                button.SetDurationText,
                button,
                durationText
            )

        if not fallbackSuccess then

            print(
                "|cffff3333Atonement Alert:|r " ..
                "SetDurationText failed."
            )

            print(
                tostring(errorMessage)
            )

        end

    end

    --------------------------------------------------------
    -- Disable clicking
    --------------------------------------------------------

    pcall(
        button.SetMouseClickEnabled,
        button,
        false
    )

end

------------------------------------------------------------
-- Add Atonement AuraGroup
------------------------------------------------------------

local success, errorMessage =
    pcall(
        container.AddAuraGroup,
        container,
        "Atonement",
        "HELPFUL",
        {
            maxFrameCount = 1,

            candidateFilters = {

                includeSpellIDs = {
                    [ATONEMENT_ID] = true,
                },

            },

            initializeFrame =
                InitializeAtonementButton,
        }
    )

if not success then

    print(
        "|cffff3333Atonement Alert ERROR:|r " ..
        tostring(errorMessage)
    )

end

------------------------------------------------------------
-- Restore Position
------------------------------------------------------------

local function RestorePosition()

    if not db then
        return
    end

    mover:ClearAllPoints()

    mover:SetPoint(
        db.point or "CENTER",
        UIParent,
        db.relativePoint or "CENTER",
        tonumber(db.x) or DEFAULT_X,
        tonumber(db.y) or DEFAULT_Y
    )

end

------------------------------------------------------------
-- Save Position
------------------------------------------------------------

local function SavePosition()

    if not db then
        return false
    end

    local point,
          relativeTo,
          relativePoint,
          x,
          y =
        mover:GetPoint(1)

    if not point then
        return false
    end

    --------------------------------------------------------
    -- IMPORTANT:
    --
    -- Save the position of the ordinary mover frame.
    -- The AuraContainer is NOT involved here.
    --------------------------------------------------------

    db.point =
        point

    db.relativePoint =
        relativePoint or "CENTER"

    db.x =
        tonumber(x) or 0

    db.y =
        tonumber(y) or 0

    return true

end

------------------------------------------------------------
-- Initialize Database
------------------------------------------------------------

local function InitializeDatabase()

    --------------------------------------------------------
    -- SavedVariables are guaranteed to be available here.
    --------------------------------------------------------

    if not AtonementAlertDB then

        AtonementAlertDB = {}

    end

    db =
        AtonementAlertDB

    --------------------------------------------------------
    -- Position defaults
    --------------------------------------------------------

    if db.point == nil then

        db.point = "CENTER"

    end

    if db.relativePoint == nil then

        db.relativePoint = "CENTER"

    end

    if db.x == nil then

        db.x = DEFAULT_X

    end

    if db.y == nil then

        db.y = DEFAULT_Y

    end

    --------------------------------------------------------
    -- Lock state
    --------------------------------------------------------

    if db.locked == nil then

        db.locked = true

    end

    --------------------------------------------------------
    -- Sound
    --------------------------------------------------------

    if db.soundEnabled == nil then

        db.soundEnabled = true

    end

end

------------------------------------------------------------
-- Unlock
------------------------------------------------------------

local function UnlockMover()

    if not db then
        return
    end

    db.locked = false

    mover:EnableMouse(true)

    mover:SetMovable(true)

    mover:RegisterForDrag(
        "LeftButton"
    )

    mover:SetScript(
        "OnDragStart",
        function(self)

            if InCombatLockdown() then

                return

            end

            self:StartMoving()

        end
    )

    mover:SetScript(
        "OnDragStop",
        function(self)

            self:StopMovingOrSizing()

            SavePosition()

            print(
                "|cff33ccffAtonement Alert:|r " ..
                "position saved."
            )

        end
    )

    print(
        "|cff33ccffAtonement Alert:|r unlocked."
    )

    print(
        "Drag the Atonement tracker to move it."
    )

end

------------------------------------------------------------
-- Lock
------------------------------------------------------------

local function LockMover(savePosition)

    if not db then
        return
    end

    db.locked = true

    --------------------------------------------------------
    -- Save before disabling movement when explicitly
    -- requested.
    --------------------------------------------------------

    if savePosition then

        SavePosition()

    end

    mover:StopMovingOrSizing()

    mover:EnableMouse(false)

    mover:SetMovable(false)

    mover:RegisterForDrag()

    mover:SetScript(
        "OnDragStart",
        nil
    )

    mover:SetScript(
        "OnDragStop",
        nil
    )

    print(
        "|cff33ccffAtonement Alert:|r locked."
    )

end

------------------------------------------------------------
-- Set Locked State
------------------------------------------------------------

local function SetLocked(locked, savePosition)

    if locked then

        LockMover(
            savePosition
        )

    else

        UnlockMover()

    end

end

------------------------------------------------------------
-- Reset Position
------------------------------------------------------------

local function ResetPosition()

    if not db then
        return
    end

    db.point =
        "CENTER"

    db.relativePoint =
        "CENTER"

    db.x =
        DEFAULT_X

    db.y =
        DEFAULT_Y

    RestorePosition()

    print(
        "|cff33ccffAtonement Alert:|r " ..
        "position reset."
    )

end

------------------------------------------------------------
-- Register Atonement expiration sound
------------------------------------------------------------

local function RegisterAtonementSound()

    if AtonementAuraSoundID then

        return true

    end

    if not db
        or not db.soundEnabled then

        return false

    end

    if not C_UnitAuras
        or not C_UnitAuras.AddAuraSound then

        print(
            "|cffff3333Atonement Alert:|r " ..
            "C_UnitAuras.AddAuraSound is unavailable."
        )

        return false

    end

    --------------------------------------------------------
    -- Current 12.1 API:
    --
    -- Added                  = 0
    -- ApplicationsIncreased  = 1
    -- Removed                = 2
    --------------------------------------------------------

    local trigger

    if Enum
        and Enum.UnitAuraSoundTrigger
        and Enum.UnitAuraSoundTrigger.Removed then

        trigger =
            Enum.UnitAuraSoundTrigger.Removed

    else

        trigger = 2

    end

    --------------------------------------------------------
    -- Register
    --------------------------------------------------------

    local success, result =
        pcall(
            C_UnitAuras.AddAuraSound,
            trigger,
            {
                unitToken = "player",

                spellID = ATONEMENT_ID,

                soundFileName = SOUND_FILE,

                outputChannel = "SFX",
            }
        )

    if success and result then

        AtonementAuraSoundID =
            result

        return true

    end

    if not success then

        print(
            "|cffff3333Atonement Alert:|r " ..
            "Could not register expiration sound."
        )

        print(
            tostring(result)
        )

    else

        print(
            "|cffff3333Atonement Alert:|r " ..
            "Expiration sound registration returned nil."
        )

    end

    return false

end

------------------------------------------------------------
-- Remove Atonement expiration sound
------------------------------------------------------------

local function UnregisterAtonementSound()

    if not AtonementAuraSoundID then

        return true

    end

    if not C_UnitAuras
        or not C_UnitAuras.RemoveAuraSound then

        print(
            "|cffff3333Atonement Alert:|r " ..
            "RemoveAuraSound is unavailable."
        )

        return false

    end

    local success, result =
        pcall(
            C_UnitAuras.RemoveAuraSound,
            AtonementAuraSoundID
        )

    if success then

        AtonementAuraSoundID =
            nil

        return true

    end

    print(
        "|cffff3333Atonement Alert:|r " ..
        "Could not remove expiration sound."
    )

    print(
        tostring(result)
    )

    return false

end

------------------------------------------------------------
-- Toggle Sound
------------------------------------------------------------

local function SetSoundEnabled(enabled)

    enabled =
        enabled and true or false

    db.soundEnabled =
        enabled

    if enabled then

        local registered =
            RegisterAtonementSound()

        if registered then

            print(
                "|cff33ccffAtonement Alert:|r " ..
                "expiration sound |cff00ff00ON|r."
            )

        else

            print(
                "|cff33ccffAtonement Alert:|r " ..
                "sound is enabled, but registration failed."
            )

        end

    else

        UnregisterAtonementSound()

        print(
            "|cff33ccffAtonement Alert:|r " ..
            "expiration sound |cffff3333OFF|r."
        )

    end

end

------------------------------------------------------------
-- Test Sound
------------------------------------------------------------

local function TestSound()

    if not db.soundEnabled then

        print(
            "|cff33ccffAtonement Alert:|r " ..
            "sound is currently OFF."
        )

        print(
            "Use |cffffffff/aat sound on|r first."
        )

        return

    end

    if not PlaySoundFile then

        print(
            "|cffff3333Atonement Alert:|r " ..
            "PlaySoundFile is unavailable."
        )

        return

    end

    local success, handle =
        pcall(
            PlaySoundFile,
            SOUND_FILE,
            "SFX"
        )

    if success and handle then

        print(
            "|cff33ccffAtonement Alert:|r " ..
            "test sound played."
        )

    elseif success then

        print(
            "|cff33ccffAtonement Alert:|r " ..
            "test sound requested."
        )

    else

        print(
            "|cffff3333Atonement Alert:|r " ..
            "could not play test sound."
        )

        print(
            tostring(handle)
        )

    end

end

------------------------------------------------------------
-- Sound Status
------------------------------------------------------------

local function PrintSoundStatus()

    print(
        "|cff33ccffAtonement Alert sound status:|r"
    )

    print(
        "Enabled: " ..
        tostring(db.soundEnabled)
    )

    print(
        "Registered: " ..
        tostring(
            AtonementAuraSoundID ~= nil
        )
    )

    print(
        "Sound file:"
    )

    print(
        "  " .. SOUND_FILE
    )

    print(
        "Channel: SFX"
    )

end

------------------------------------------------------------
-- Slash Commands
------------------------------------------------------------

SLASH_ATONEMENTALERT1 =
    "/aat"

SLASH_ATONEMENTALERT2 =
    "/atonementalert"

SlashCmdList["ATONEMENTALERT"] =
    function(message)

        message =
            strtrim(
                string.lower(
                    message or ""
                )
            )

        ----------------------------------------------------
        -- UNLOCK
        ----------------------------------------------------

        if message == "unlock"
            or message == "move" then

            UnlockMover()

            return

        end

        ----------------------------------------------------
        -- LOCK
        ----------------------------------------------------

        if message == "lock" then

            LockMover(true)

            return

        end

        ----------------------------------------------------
        -- RESET
        ----------------------------------------------------

        if message == "reset" then

            ResetPosition()

            return

        end

        ----------------------------------------------------
        -- STATUS
        ----------------------------------------------------

        if message == "status" then

            print(
                "|cff33ccffAtonement Alert:|r " ..
                "loaded successfully."
            )

            print(
                "Locked: " ..
                tostring(db.locked)
            )

            print(
                "Saved position: " ..
                tostring(db.point) ..
                " / " ..
                tostring(db.relativePoint) ..
                " / " ..
                tostring(db.x) ..
                ", " ..
                tostring(db.y)
            )

            print(
                "Tracking spell ID: " ..
                tostring(ATONEMENT_ID)
            )

            print(
                "Duration formatter: " ..
                tostring(
                    durationFormatter ~= nil
                )
            )

            print(
                "Color curve: " ..
                tostring(
                    AtonementColorCurve ~= nil
                )
            )

            print(
                "Expiration sound enabled: " ..
                tostring(db.soundEnabled)
            )

            print(
                "Expiration sound registered: " ..
                tostring(
                    AtonementAuraSoundID ~= nil
                )
            )

            return

        end

        ----------------------------------------------------
        -- SOUND ON
        ----------------------------------------------------

        if message == "sound on" then

            SetSoundEnabled(true)

            return

        end

        ----------------------------------------------------
        -- SOUND OFF
        ----------------------------------------------------

        if message == "sound off" then

            SetSoundEnabled(false)

            return

        end

        ----------------------------------------------------
        -- SOUND TEST
        ----------------------------------------------------

        if message == "sound test" then

            TestSound()

            return

        end

        ----------------------------------------------------
        -- SOUND STATUS
        ----------------------------------------------------

        if message == "sound status" then

            PrintSoundStatus()

            return

        end

        ----------------------------------------------------
        -- SOUND HELP
        ----------------------------------------------------

        if message == "sound"
            or message == "sound help" then

            print(
                "|cff33ccffAtonement Alert sound commands:|r"
            )

            print(
                "/aat sound on - enable expiration sound"
            )

            print(
                "/aat sound off - disable expiration sound"
            )

            print(
                "/aat sound test - play the warning sound"
            )

            print(
                "/aat sound status - show sound status"
            )

            return

        end

        ----------------------------------------------------
        -- HELP
        ----------------------------------------------------

        print(
            "|cff33ccffAtonement Alert commands:|r"
        )

        print(
            "/aat unlock - enable dragging"
        )

        print(
            "/aat lock - lock the tracker"
        )

        print(
            "/aat reset - reset position"
        )

        print(
            "/aat status - show addon status"
        )

        print(
            "/aat sound - show sound commands"
        )

    end

------------------------------------------------------------
-- Addon Event Handler
------------------------------------------------------------

local eventFrame =
    CreateFrame("Frame")

eventFrame:RegisterEvent(
    "ADDON_LOADED"
)

eventFrame:RegisterEvent(
    "PLAYER_LOGOUT"
)

eventFrame:SetScript(
    "OnEvent",
    function(self, event, addonName)

        ----------------------------------------------------
        -- ADDON_LOADED
        ----------------------------------------------------

        if event == "ADDON_LOADED" then

            if addonName ~= ADDON_NAME then

                return

            end

            ------------------------------------------------
            -- IMPORTANT:
            --
            -- SavedVariables are now guaranteed to have
            -- been loaded.
            ------------------------------------------------

            InitializeDatabase()

            ------------------------------------------------
            -- Restore the saved mover position.
            ------------------------------------------------

            RestorePosition()

            ------------------------------------------------
            -- Apply saved lock state.
            --
            -- false means:
            -- "do NOT save during initialization"
            ------------------------------------------------

            SetLocked(
                db.locked,
                false
            )

            ------------------------------------------------
            -- Register sound.
            ------------------------------------------------

            if db.soundEnabled then

                RegisterAtonementSound()

            end

            print(
                "|cff33ccffAtonement Alert:|r loaded."
            )

            return

        end

        ----------------------------------------------------
        -- PLAYER_LOGOUT
        ----------------------------------------------------

        if event == "PLAYER_LOGOUT" then

            ------------------------------------------------
            -- Final save before WoW writes SavedVariables.
            ------------------------------------------------

            SavePosition()

            return

        end

    end
)