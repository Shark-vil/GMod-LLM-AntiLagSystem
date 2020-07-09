local prefix = "LLM.Sv.Detection.Lags.Anti_Multiple_Collisions.";

hook.Add( "EntityTakeDamage", prefix .. "Critical_Collisions", function( ent, dmginfo )

    if ( GetConVar( "llm_critical_collision_detector" ):GetInt() <= 0 ) then return; end;
    
    if (    not IsValid(ent)   )    then return; end;
    if (    ent:IsPlayer()     )    then return; end;
    if (    ent:IsNPC()        )    then return; end;
    if (    ent:IsVehicle()    )    then return; end;

    if ( ent:GetClass() == 'prop_physics' and dmginfo:GetDamageType() == DMG_CRUSH ) then
        
        local constrs = constraint.GetAllConstrainedEntities( ent );

        if ( table.HasValue( constrs, dmginfo:GetAttacker() ) 
            and not llm.sv.FrameRateLags and not llm.sv.PingLags
        ) then return; end;

        ent.LLM_SearchCritColl_Infringement   = ent.LLM_SearchCritColl_Infringement or 0;
        ent.LLM_SearchCritColl_CoolDown       = ent.LLM_SearchCritColl_CoolDown     or 0;

        if ( ent.LLM_SearchCritColl_CoolDown + 1 < CurTime() ) then
            ent.LLM_SearchCritColl_Infringement = 0;
        end

        if ( ent.LLM_SearchCritColl_Infringement == 5 ) then

            local phy = ent:GetPhysicsObject();

            MsgN( "[LLM]: An endless collision of props has been prevented." );
            
            if ( IsValid( phy ) ) then

                if ( DPP ~= nil ) then
                    DPP.SetGhosted( ent, true );
                    local owner = DPP.GetOwner( ent );
                    if ( IsValid( owner ) and owner:IsPlayer() ) then
                        DPP.Notify( owner, "Your props are blocked due to countless clashes." );
                    end;
                elseif ( FPP ~= nil ) then
                    FPP.AntiSpam.GhostFreeze( ent, phy );
                    if ( IsValid( ent.FPPOwner ) ) then
                        FPP.Notify( ent.FPPOwner, "Your props are blocked due to countless clashes.", true );
                    end;
                else
                    phy:EnableMotion( false );
                end;
                
            end;

            ent.LLM_SearchCritColl_Infringement   = 0;

        else

            ent.LLM_SearchCritColl_Infringement   = ent.LLM_SearchCritColl_Infringement + 1;
            ent.LLM_SearchCritColl_CoolDown       = CurTime();

        end;

    end;

end );