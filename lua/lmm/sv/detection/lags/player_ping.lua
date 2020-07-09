local prefix = "LLM.Sv.Detection.Lags.PlayerPing.";

local Maximum = 50;

llm.sv.GetAveragePlayerPing = function( ply )
    local uid = ply:UniqueID();
    if ( llm.sv.DataFindPingAverage[ uid ] ~= nil ) then
        if ( llm.sv.DataFindPingAverage[ uid ][ "AveragePing" ] ~= nil ) then
            return llm.sv.DataFindPingAverage[ uid ][ "AveragePing" ];
        end;
    end;
    return -1;
end;

llm.sv.GetPingList = function( ply )
    local uid = ply:UniqueID();
    if ( llm.sv.DataFindPingAverage[ uid ] ~= nil ) then
        if ( llm.sv.DataFindPingAverage[ uid ][ "PingList" ] ~= nil ) then
            return llm.sv.DataFindPingAverage[ uid ][ "PingList" ];
        end;
    end;
    return nil;
end;

llm.sv.ResetPing = function()
    for uid, tbl in pairs( llm.sv.DataFindPingAverage ) do
        table.Empty( tbl );
    end
end;

local function FindPingAverage()
    if ( llm.sv.PingLags ) then return; end;

    local players = player.GetAll();

    for i = 1, table.Count( players ) do
        if ( players[ i ].AdvDupe2 ~= nil and players[ i ].AdvDupe2.Pasting ) then return; end;
    end;

    for i = 1, table.Count( players ) do

        local uid = players[ i ]:UniqueID();
        llm.sv.DataFindPingAverage[ uid ] = llm.sv.DataFindPingAverage[ uid ] or {};
        llm.sv.DataFindPingAverage[ uid ][ 'Index' ] = llm.sv.DataFindPingAverage[ uid ][ 'Index' ] or 1;
        llm.sv.DataFindPingAverage[ uid ][ "PingList" ] = llm.sv.DataFindPingAverage[ uid ][ "PingList" ] or {};     
        
        -- if ( table.Count( llm.sv.DataFindPingAverage[ uid ][ "PingList" ] ) >= Maximum ) then
        if ( llm.sv.DataFindPingAverage[ uid ][ 'Index' ] > Maximum ) then

            -- local value = 0;
            -- for j = 1, 10 do
            --     value = value + llm.sv.DataFindPingAverage[ uid ][ "PingList" ][ j ];
            -- end;
            -- llm.sv.DataFindPingAverage[ uid ][ "AveragePing" ] = ( value / Maximum );
            -- table.Empty( llm.sv.DataFindPingAverage[ uid ][ "PingList" ] );

            llm.sv.DataFindPingAverage[ uid ][ 'Index' ] = 1;
        end;

        local Count = table.Count( llm.sv.DataFindPingAverage[ uid ][ "PingList" ] );

        if ( Count >= 10 ) then
            local value = 0;
            for j = 1, Count do
                value = value + llm.sv.DataFindPingAverage[ uid ][ "PingList" ][ j ];
            end;
            llm.sv.DataFindPingAverage[ uid ][ "AveragePing" ] = ( value / Count );
        end;

        -- table.insert( llm.sv.DataFindPingAverage[ uid ][ "PingList" ], 
        --     llm.sv.DataFindPingAverage[ uid ][ 'Index' ], players[ i ]:Ping() );

        llm.sv.DataFindPingAverage[ uid ][ "PingList" ][ llm.sv.DataFindPingAverage[ uid ][ 'Index' ] ] = players[ i ]:Ping();

        llm.sv.DataFindPingAverage[ uid ][ 'Index' ] = llm.sv.DataFindPingAverage[ uid ][ 'Index' ] + 1;
    end;
end;
timer.Create( prefix .. "FindPingAverage", 0.5, 0, FindPingAverage );

llm.sv.RejectionSearch = function( ply )
    -- local min = nil;
    -- local max = nil;
    -- local PingList = llm.sv.GetPingList( ply );

    -- if ( PingList ~= nil ) then
    --     local count = table.Count( PingList );
    --     for i = 1, count do
    --         if ( min == nil ) then
    --             min = PingList[ i ];
    --         elseif ( PingList[ i ] < min ) then
    --             min = PingList[ i ];
    --         end;
    --         if ( max == nil ) then
    --             max = PingList[ i ];
    --         elseif ( PingList[ i ] > max ) then
    --             max = PingList[ i ];
    --         end;
    --     end;

    --     if ( min == nil ) then min = 0; end;
    --     if ( max == nil ) then max = 10; end;

    --     -- return ( max - min / 2 );

    --     local result = ( max - min ) / ( Maximum - ( Maximum / 2 ) );

    --     if ( result == 0 ) then
    --         result = 10;
    --     end;

    --     return result;
    -- else
        return 20;
    -- end;
end;
