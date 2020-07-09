local prefix = "LLM.Sv.Detection.Anti_Crash.Bad_Props_Detector.";

local function BadProps_FindInEntityRadius( ent )
    local radius = ent:BoundingRadius();
    local objects = ents.FindInSphere( ent:GetPos(), radius / 3 );

    local i = 0;
    for _, e in pairs( objects ) do
        if ( IsValid( e ) and e:GetClass() == "prop_physics" 
            and ( e:BoundingRadius() / 2 ) >= radius / 2 
        ) then
            i = i + 1;
        end;
    end;
    if ( i >= 4 ) then
        return false;
    end;

    return true;
end;

hook.Add( "PlayerSpawnedProp", prefix .. "PlayerSpawnedProp", function( ply, model, ent )
    
    do
        if ( llm.sv.ent_object.phys_object.EnableMotion == nil ) then

            llm.sv.ent_object.phys_object.EnableMotion = 
                llm.sv.ent_object.phys_object.EnableMotion or 
                    getmetatable( ent:GetPhysicsObject() ).EnableMotion;

        end;
    end;

    local physObj = ent:GetPhysicsObject();
    local physMeta = getmetatable( physObj );

    physMeta.EnableMotion = function( self, BooleanValue )

        if ( BooleanValue ) then

            if ( GetConVar( "llm_badprops_detector" ):GetInt() >= 1 ) then

                local ent = self:GetEntity();
                if ( not BadProps_FindInEntityRadius( ent ) ) then return; end;
                
            end;

        end;

        llm.sv.ent_object.phys_object.EnableMotion( self, BooleanValue );

    end;

end );