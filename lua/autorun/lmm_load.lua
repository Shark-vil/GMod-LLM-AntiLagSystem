MsgN("[LLM] Lua Lover Manager -> Load...");

CreateConVar( "llm_ping_detector_maxplayers", 3, FCVAR_ARCHIVE, "How many players do you need to activate server lag checking using player ping? ( Recommendation - 3. Disable detector - 0 )" );
CreateConVar( "llm_badprops_detector", 1, FCVAR_ARCHIVE, "Prevents server crashes from unfreezing objects with a rough collision. ( Enable detector - 1, Disable detector - 0 )" );
CreateConVar( "llm_critical_collision_detector", 1, FCVAR_ARCHIVE, "Prevents server crashes from perpetual collisions. ( Enable detector - 1, Disable detector - 0 )" );
CreateConVar( "llm_frame_rate_lags_detector", 1, FCVAR_ARCHIVE, "Prevents server crashes while drastically reducing frames per second. ( Enable detector - 1, Disable detector - 0 )" );
CreateConVar( "llm_frame_rate_lags_max_methods", 3, FCVAR_ARCHIVE, "How many methods to prevent server crashes can be used? ( 1 to 3 )" );

llm = llm or {
    isLoad = false,
    cl = {},
    sh = {
        gLog = function( text )
            local LogText = "[LLM] " .. tostring( text );

            if ( Discord ~= nil and Discord.Backend ~= nil and Discord.Backend.API ~= nil ) then
                Discord.Backend.API:Send(
                    Discord.OOP:New('Message'):SetChannel('Relay'):SetEmbed({
                        color = 0xe74c3c,
                        description = LogText,
                    }):ToAPI()
                )
            end

            for _, ply in pairs( player.GetHumans() ) do
                ply:SendLua( [[chat.AddText(Color(255, 255, 0),"[LLM] ",Color(255, 255, 255),"]] .. tostring( text ) .. [[")]] );
            end;
        end,
    },
    sv = {
        DataFindPingAverage = {},
        BadProps = {},
        FrameRateLags = false,
        PingLags = false,
        ent_object = {
            phys_object = {},
        },
    },
};

local function AddLuaFile( filePath, type )
    if ( type == nil) then
        MsgN( "[LLM] Load script -> " .. filePath .. " (sv)" );
    else
        MsgN( "[LLM] Load script -> " .. filePath .. "(" .. type .. ")" );
    end;

    if ( SERVER and type ~= nil and ( type == "sh" or type == "cl" ) ) then
        AddCSLuaFile( filePath );
    elseif ( CLIENT and type == nil ) then 
        return;
    end;
    include( filePath ); 
end;

-- ( SERVER
    -- Helpers
    AddLuaFile( "lmm/sv/detection/lags/player_ping.lua" );
    AddLuaFile( "lmm/sv/lib/fixed_lags.lua" );
    -- Scripts
    AddLuaFile( "lmm/sv/detection/lags/detector.lua" );
    AddLuaFile( "lmm/sv/detection/anti_crash/bad_props_detector.lua" );
    AddLuaFile( "lmm/sv/detection/lags/frame_rate_lags.lua" );
    AddLuaFile( "lmm/sv/detection/lags/anti_multiple_collisions.lua" );
-- )

-- ( SHARED
    -- Helpers
    -- Scripts
-- )

-- ( CLIENT
    -- Helpers
    -- Scripts
-- )

llm.isLoad = true;

MsgN("[LLM] Lua Lover Manager -> Is loaded!");