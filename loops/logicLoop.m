function gs = initGameState()
    %INITGAMESTATE  Build and return the master GameState struct.
    %
    %   gs = initGameState();
    %
    %   Creates all sub‑structs (player, mapManager, spriteManager, …) and
    %   bundles them into one handle‑less struct suitable for passing to the
    %   parallel‑loop functions.
    
    % initGameState.m
    
    %% 1) Player Struct
    player = struct( ...
        'position',    [0, 0, 0], ...    % [x, y,z]
        'angle',       0.0,   ...     % facing direction (radians)
        'health',      100.0, ...     % starting health
        'mana',        0.0,   ...     % starting mana
        'hasKey',      false, ...     % are they holding the key?
        'speed',       5.0 ...        % movement units per second
    );
    
    %% 2) MapManager Struct
    mapHeight   = 20;
    mapWidth    = 30;
    numFloors   = 3;
    maps3D      = zeros(mapHeight, mapWidth, numFloors, 'uint8');  
    % (Fill each slice maps3D(:,:,f) with your tile IDs)
    
    % Define elevator and chest locations as N×3 arrays of [x,y,z]
    elevators = [  5, 10, 1;    % elevator at (5,10) on floor 1
                  15,  8, 2 ];  % elevator at (15,8) on floor 2
    
    chests    = [ 10,  4, 1;    % chest at (10,4) on floor 1
                  12, 17, 2;    % chest at (12,17) on floor 2
                   3, 19, 3 ];  % chest at (3,19) on floor 3
    
    mapManager = struct( ...
        'maps',         maps3D, ...    
        'currentFloor', 1,    ...       % starting on floor 1
        'elevators',    elevators, ...
        'chests',       chests ...
    );
    
    %% 3) KeyManager Struct
    keyManager = struct( ...
        'keyPosition', [2, 3], ...    % initial spawn [x,y]
        'isHeld',      false ...
    );
    
    %% 4) Sprite & SpriteManager
    Sprite = @(pos,typeID,state,animFrame,aiBrain) struct( ...
        'pos',       pos, ...
        'typeID',    uint16(typeID), ...
        'state',     state, ...
        'animFrame', int32(animFrame), ...
        'aiBrain',   aiBrain ...      % e.g. 'DirectChaser'
    );
    
    % Example sprites array
    sprites = [ ...
        Sprite([5,5,0], 1, 'Idle', 0, 'DirectChaser'), ...
        Sprite([8,2,0], 2, 'Idle', 0, 'WallAvoidingGhost') ...
    ];
    
    spriteManager = struct( ...
        'sprites', sprites ...
    );
    
    %% 5) InputManager Struct
    inputManager = struct( ...
        'joystick',  [0, 0], ...      % [x,y] from readValue()
        'shoot',     false, ...
        'dropKey',   false, ...
        'interact',  false, ...
        'deadzone',  0.1 ...
    );
    
    %% 6) CollisionDetector (stateless placeholder)
    collisionDetector = struct();
    
    %% 7) RenderEngine (stateless wrapper)
    renderEngine = struct();
    
    %% 8) AudioManager (stateless)
    audioManager = struct();
    
    %% 9) HUDManager (stateless)
    hudManager = struct();
    
    %% 10) AssetManager (lookup tables)
    assetManager = struct( ...
        'textureIDs',   uint16([]), ...
        'animationMap', int32([]) ...
    );
    
    %% 11) Master GameState Struct
    gameState = struct( ...
        'player',           player, ...
        'mapManager',       mapManager, ...
        'spriteManager',    spriteManager, ...
        'keyManager',       keyManager, ...
        'inputManager',     inputManager, ...
        'collisionDetector',collisionDetector, ...
        'renderEngine',     renderEngine, ...
        'audioManager',     audioManager, ...
        'hudManager',       hudManager, ...
        'assetManager',     assetManager, ...
        'running',          true,  ...
        'renderPeriod',     1/60,  ...
        'logicPeriod',      1/30,  ...
        'inputPeriod',      1/100  ...
    );
    gs = gameState;
    end
    
    function logicLoop(gs)
    %LOGICLOOP  Core simulation loop: sprite AI, collisions, health & mana.
    %
    %   This worker runs continuously until  gs.running  is set to false.
    %
    %   Major responsibilities each tick
    %   --------------------------------
    %     • Advance all sprite positions using their AI brains
    %     • Resolve sprite↔wall collisions
    %     • Handle player↔sprite contact damage
    %     • Award mana on sprite kill
    %     • Consume health packs on pickup
    %     • Elevator floor transitions
    %     • Win / lose detection (sets  gs.running = false)
    
        dt = gs.logicPeriod;
    
        while gs.running
            currentFloor = gs.mapManager.currentFloor;
            floorGrid    = gs.mapManager.maps(:,:,currentFloor);
    
            %% 1) Update every sprite via its AI brain
            for idx = 1:numel(gs.spriteManager.sprites)
                spr = gs.spriteManager.sprites(idx);
    
                % Dead sprites stay put
                if strcmpi(spr.state,"Dead"),  continue; end
    
                % Request a move direction from brain (unit vector)
                dir = spr.aiBrain.getNextMove( ...
                            gs.player.position, spr.pos, floorGrid);
    
                newPos = spr.pos + [dir 0] * dt;   % move in XY plane
                % Wall collision: if destination not walkable -> stay
                tile = floorGrid( round(newPos(2)), round(newPos(1)) );
                if tile == 0         % 0 = empty
                    spr.pos = newPos;
                end
    
                % Update sprite back into array
                gs.spriteManager.sprites(idx) = spr;
            end
    
            %% 2) Player–sprite collisions & shooting damage
            manaGain = 0;
            for idx = 1:numel(gs.spriteManager.sprites)
                spr = gs.spriteManager.sprites(idx);
                dist = norm(gs.player.position - spr.pos);
                if dist < 0.75
                    % Contact damage
                    gs.player.health = gs.player.health - 10*dt;
                end
    
                % Shooting logic (very simple ray hit in 1.5‑unit range)
                if gs.inputManager.shoot && ~gs.player.hasKey && ...
                   dist < 1.5 && ~strcmpi(spr.state,"Dead")
                    spr.state = "Dead";
                    manaGain  = manaGain + 20;   % reward per kill
                    gs.spriteManager.sprites(idx) = spr;
                end
            end
            gs.player.mana = min(100, gs.player.mana + manaGain);
    
            %% 3) Health pack pickup (tile ID 4)
            pxy  = round(gs.player.position);
            tile = floorGrid(pxy(2),pxy(1));
            if tile == uint8(4)            % health pack tile
                gs.player.health = min(100, gs.player.health + 25);
                gs.mapManager.maps(pxy(2),pxy(1),currentFloor) = 0; % remove pack
            end
    
            %% 4) Elevator detection
            elev = gs.mapManager.elevators;
            if any(all(bsxfun(@eq, round(gs.player.position), elev(:,1:2)),2))
                row = find(all(bsxfun(@eq, round(gs.player.position), elev(:,1:2)),2),1);
                gs.mapManager.currentFloor = elev(row,3);
                gs.player.position(3) = gs.mapManager.currentFloor;
                fprintf("Moved to floor %d\n", gs.mapManager.currentFloor);
            end
    
            %% 5) Win / lose checks
            WIN_TILE   = uint8(5);
            pxy  = round(gs.player.position);
            tile = floorGrid(pxy(2),pxy(1));
            if gs.player.hasKey && tile == WIN_TILE
                fprintf("YOU ESCAPED!  GG\n");
                gs.running = false;
            end
            if gs.player.health <= 0
                fprintf("You died.\n");
                gs.running = false;
            end
    
            pause(dt);
        end
    end