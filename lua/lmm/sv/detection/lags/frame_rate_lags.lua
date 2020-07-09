local prefix = "LLM.Sv.Detection.Lags.Frame_Rate_Lags.";
-- local SavingFrameTime = 0;
local constraint_ent_list = {};

-- local currcount = 0;
local SavingDeltaTime = 9999;

local LagCount = 0;
local LagResetTime = 0;

local function isLagDetector()

    local NormalizateTime = SysTime() - CurTime();

    if ( ( SavingDeltaTime + 1 ) < NormalizateTime ) then
        SavingDeltaTime = NormalizateTime;
        return true;
    end;
    
    SavingDeltaTime = NormalizateTime;

    return false;

end;

timer.Create( prefix .. "FindLags", 1, 0, function()

    if ( GetConVar( "llm_frame_rate_lags_detector" ):GetInt() <= 0 ) then return; end;

    if ( isLagDetector() ) then

        LagResetTime = CurTime() + 1;
        LagCount = LagCount + 1;

        if ( LagCount > 1 ) then
            llm.sh.gLog( "Frame rate lags detection! Recheck ... ( " .. tostring( LagCount ) .. " )" );
        end;

        llm.sv.FrameRateLags = true;

        local cvar = GetConVar( "llm_frame_rate_lags_max_methods" ):GetInt();

        if ( LagCount == 5 and cvar >= 1 ) then

            llm.sh.gLog( "Frame rate lags: Correction Method - 1" );
            llm.FixedLags.Method_1();

            SavingDeltaTime = 9999;

        elseif ( LagCount == 10 and cvar >= 2 ) then
        
            llm.sh.gLog( "Frame rate lags: Correction Method - 2" );
            llm.FixedLags.Method_2();

            SavingDeltaTime = 9999;

        elseif ( LagCount == 15 and cvar >= 3 ) then

            llm.sh.gLog( "Frame rate lags: Correction Method - 3" );
            llm.FixedLags.Method_3();

            if ( cvar <= 3 ) then
                llm.sv.FrameRateLags = false;
            end

            SavingDeltaTime = 9999;
            LagCount = 0;

        elseif ( LagCount == 15 and cvar >= 4 ) then

            llm.sh.gLog( "Frame rate lags: Correction Method - 4" );
            llm.FixedLags.Method_4();

            llm.sv.FrameRateLags = false;
            SavingDeltaTime = 9999;
            LagCount = 0;

        end;

    elseif ( LagCount ~= 0 and LagResetTime < CurTime() ) then

        LagCount = LagCount - 1;

        if ( LagCount == 0 ) then
            llm.sv.FrameRateLags = false;
            SavingDeltaTime = 9999;
            LagCount = 0;
        end;
        
    end;

end );