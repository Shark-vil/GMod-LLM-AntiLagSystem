local prefix = "LLM.Sv.Detection.Lags.Detector.";

local DetectedIncreasedPing = 0;
local ChalkUpResetTime = 0;
local ChalkUp = true;
local IncreasedPing = 0;

timer.Create( prefix .. "PingLags_Detector", 1, 0, function()
    local cvar = GetConVar( "llm_ping_detector_maxplayers" ):GetInt();

    if ( cvar <= 0 ) then return; end;
    if ( ChalkUpResetTime > CurTime() ) then return; end;

    local Players = player.GetHumans();
    local PlayersCount = table.Count( Players );

    if ( PlayersCount < cvar ) then
        return;
    end;

    if ( ChalkUp ) then
        for i = 1, PlayersCount do
            if ( IsValid( Players[ i ] ) ) then
                
                if ( Players[ i ].AdvDupe2 ~= nil and Players[ i ].AdvDupe2.Pasting ) then 
                    llm.sv.ResetPing();
                    return;
                end;

                local ping = llm.sv.GetAveragePlayerPing( Players[ i ] );

                -- MsgN( tostring( Players[ i ]:Name() ) .. " : Rejection ping (" .. tostring( llm.sv.RejectionSearch( Players[ i ] ) ) .. ") Average ping (" .. tostring( ping ) .. ") Result ping (" .. tostring( ( ping + llm.sv.RejectionSearch( Players[ i ] ) ) ) .. ") - Select ping (" .. tostring( Players[ i ]:Ping() ) .. ")" );

                if ( ping ~= -1 ) then
                    -- MsgN( tostring( Players[ i ]:Name() ) .. " : Select ping (" .. tostring( Players[ i ]:Ping() ) .. ") - Normal ping (" .. tostring( ( ping + llm.sv.RejectionSearch( Players[ i ] ) ) ) .. ")" );
                    if ( Players[ i ]:Ping() > ( ping + llm.sv.RejectionSearch( Players[ i ] ) ) ) then
                        IncreasedPing = IncreasedPing + 1;
                    end;
                end;
            end;
        end;
    end;

    if ( ( IncreasedPing * ( 100 / PlayersCount ) ) > 90 ) then

        llm.sv.PingLags = true;
        DetectedIncreasedPing = DetectedIncreasedPing + 1;
        ChalkUp = false;

        MsgN( "[LLM] Bad ping detextion -> Repeated analysis... ( " .. tostring( DetectedIncreasedPing ) .. " )" );
        
        -- local Maximum = 10;
        -- local playerCount = player.GetCount();

        -- if ( playerCount > 2 ) then
        --     Maximum = 8;
        -- elseif ( playerCount > 4 ) then
        --     Maximum = 6;
        -- elseif ( playerCount > 6 ) then
        --     Maximum = 4;
        -- end;
        
        -- if ( DetectedIncreasedPing > Maximum ) then

        local div = math.floor( PlayersCount / 1.2 );

        if ( PlayersCount > 0 and div > 0 and DetectedIncreasedPing > div ) then

            MsgN( "[LLM] Bad ping detextion -> Fixed..." );
            
            llm.FixedLags.Method_2();

            DetectedIncreasedPing = 0;
            IncreasedPing = 0;
            ChalkUp = true;
            ChalkUpResetTime = CurTime() + 10;

        end;

    else
        
        llm.sv.PingLags = false;

    end;

    if ( IncreasedPing ~= 0 ) then

        for i = 1, PlayersCount do
            if ( IsValid( Players[ i ] ) ) then

                local ping = llm.sv.GetAveragePlayerPing( Players[ i ] );
                if ( ping ~= -1 ) then
                    if ( Players[ i ]:Ping() <= ( ping + llm.sv.RejectionSearch( Players[ i ] ) ) ) then
                        IncreasedPing = IncreasedPing - 1;
                        if ( DetectedIncreasedPing ~= 0 ) then
                            DetectedIncreasedPing = DetectedIncreasedPing - 1;
                        end; 
                    end;
                end;

            end; 
        end;

    elseif ( IncreasedPing == 0 ) then
        ChalkUp = true;
        DetectedIncreasedPing = 0;
    end;

end );