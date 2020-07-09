local prefix = "LLM.Sv.Lib.FixedLags.";

local constraint_ent_list = {};
llm.FixedLags = {};

local function ReconstructList()
    local new_list = {};
    local new_index = 1;

    for _, v in pairs( constraint_ent_list ) do
        if ( v ~= nil ) then
            new_list[ new_index ] = v;
            new_index = new_index + 1;
        end;
    end;

    constraint_ent_list = new_list;
end;

local function IsValidObject( ent )
    if ( ent ~= nil and IsValid( ent ) ) then
        local phy = ent:GetPhysicsObject();
        if ( IsValid( phy ) and not ent:IsPlayer() --[[and ent:GetClass() == "prop_physics"]] ) then
            return true;
        end
    end
    return false;
end

local FixedLag_1_Theard;
llm.FixedLags.Method_1 = function()

    local index = table.Count( constraint_ent_list );

    if ( not FixedLag_1_Theard or not coroutine.resume( FixedLag_1_Theard ) ) then

        FixedLag_1_Theard = coroutine.create( function( index ) 
            while ( index > 0 ) do
                local select_list = constraint_ent_list[ index ];
        
                if ( select_list ~= nil ) then
        
                    local Count = table.Count( select_list );
        
                    if ( Count > 100 ) then
        
                        for _, ent in pairs( select_list ) do
                            if ( IsValidObject( ent ) ) then
                                local phys = ent:GetPhysicsObject();
                                if ( phys:IsMotionEnabled() ) then
                                    phys:EnableMotion( false );
                                end;
                            end;
                        end;
        
                        constraint_ent_list[ index ] = nil;
                    end;
        
                end;
        
                index = index - 1;
            end;
        end );

        coroutine.resume( FixedLag_1_Theard, index );

    end;

    ReconstructList();

end;

llm.FixedLags.Method_2 = function()

    local Objects = ents.GetAll();
    local ObjectsCount = table.Count( Objects );

    llm.sh.gLog( "Find " .. tostring( ObjectsCount ) .. " objects in map" );

    if ( ObjectsCount == 0 ) then return; end;

    llm.sh.gLog( "Run lags analysis..." );

    local mes1 = true;
    local mes2 = true;
    local mes3 = true;

    for i = 0, ObjectsCount do

        local SelectObject = Objects[ i ];
        
        if ( IsValidObject( SelectObject ) ) then

            local objectsInRadius = ents.FindInSphere( SelectObject:WorldSpaceCenter(), 
                SelectObject:BoundingRadius() );
            local objectsInRadiusCount = table.Count( objectsInRadius );

            if ( objectsInRadiusCount >= 50 ) then

                if ( mes1 ) then
                    llm.sh.gLog( "[1] Found " .. tostring( objectsInRadiusCount ) .. 
                        " entities in object radius. Deep Scan..." );
                    mes1 = false;
                end;

                do

                    local ignore_ent = {};
                    local find_constraints_ents = constraint.FindConstraints( 
                            SelectObject, "NoCollide" );
                    
                    for _, ent in pairs( objectsInRadius ) do

                        for _, c_ent in pairs( find_constraints_ents ) do
                    
                            if ( ent ~= SelectObject and ent == c_ent ) then
                                table.insert( ignore_ent, ent );
                            end;

                        end;

                    end;

                    local result_count = objectsInRadiusCount - table.Count( ignore_ent );

                    if ( mes2 ) then
                        llm.sh.gLog( "[2] Found " .. tostring( result_count ) .. " entities in object radius." );
                        mes2 = false;
                    end;

                    if ( result_count >= 50 ) then

                        for _, ent in pairs( objectsInRadius ) do

                            --local class = ent:GetClass();

                            if ( not table.HasValue( ignore_ent, ent ) and IsValidObject( ent ) ) then

                                local phys = ent:GetPhysicsObject();
                                if ( IsValid( phys ) and phys:IsMotionEnabled() ) then
                                    phys:EnableMotion( false ); 
                                end;

                            end;

                        end;

                        if ( mes3 ) then
                            llm.sh.gLog( "Freeze all objects at point -> " .. tostring( SelectObject:GetPos() ) );
                            mes3 = false;
                        end;

                    end;

                end;

            end;

        end;
        
    end;

end;

llm.FixedLags.Method_3 = function()

    local objects = ents.GetAll();

    for i = 1, table.Count( objects ) do
        local ent = objects[ i ];

        if ( IsValidObject( ent ) ) then
            local phys = ent:GetPhysicsObject();
            if ( phys:IsMotionEnabled() ) then
                phys:EnableMotion( false );
            end;
        end
    end;

end;

llm.FixedLags.Method_4 = function()

    local objects = ents.GetAll();

    for i = 1, table.Count( objects ) do
        local ent = objects[ i ];
        local phys = ent:GetPhysicsObject();
        if ( IsValidObject( ent ) ) then
            ent:Remove();
        end
    end;

end;

hook.Add( "CanPlayerUnfreeze", prefix .. "CanPlayerUnfreeze", function( ply, ent, phys )
    if ( IsValid( phys ) and not phys:IsMotionEnabled() ) then

        local index = table.Count( constraint_ent_list ) + 1;
        constraint_ent_list[ index ] = constraint.GetAllConstrainedEntities( ent );

        local function _RemoveListValue( _index )
            if ( llm.sv.FrameRateLags ) then
                timer.Simple( 10, function() _RemoveListValue( index ); end );
                return;
            end;

            if ( IsValid( phys ) and phys:IsMotionEnabled() ) then
                constraint_ent_list[ _index ] = nil;
                ReconstructList();
            end;
        end;

        timer.Simple( 10, function()
            _RemoveListValue( index );
        end );
    end;
end );