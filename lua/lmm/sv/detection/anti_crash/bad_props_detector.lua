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

local PhysObj = FindMetaTable( "PhysObj" );
local OriginalEnableMotion = PhysObj.EnableMotion;

function PhysObj:EnableMotion( BooleanValue )

    if ( BooleanValue ) then

        if ( GetConVar( "llm_badprops_detector" ):GetInt() >= 1 ) then

            local ent = self:GetEntity();
            if ( IsValid( ent ) and not BadProps_FindInEntityRadius( ent ) ) then
                return; 
            end;
            
        end;

    end;

    OriginalEnableMotion( self, BooleanValue );

end;