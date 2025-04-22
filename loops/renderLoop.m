function renderLoop(gs)
    %RENDERLOOP  Sends all render + audio info to the C++ MEX each frame.
    %
    %   Expects a MEX function with signature:
    %
    %     frameRGB = mexRenderAndSound( ...
    %                     playerData,          % 1×5  [x y z angle animID]
    %                     spriteArr,           % 1×N  struct array
    %                     objectArr,           % 1×M  struct array (chest, door, key)
    %                     soundIDArr );        % P×1  uint8  sounds to mix
    %
    %   Notes
    %   -----
    %   • `soundIDArr(k)==0`   → no sound for sprite k this frame
    %   • `objAnimIDArr(k)`    → current frame index for sprite k's sheet
    %
    
        dt = gs.renderPeriod;
        soundMap = gs.assetManager.soundIDs;   % struct of name → uint8
        while gs.running
            %% 1) Build player data row  [x y z angle animID]
            p      = gs.player;
            playerData = [p.position, p.angle, p.animFrame];
    
            %% 2) Gather sprite array + sound / anim status
            S  = gs.spriteManager.sprites;
            N  = numel(S);
            soundIDArr  = gs.audioManager.pendingSounds;
            gs.audioManager.pendingSounds = uint8([]);
            animIDArr   = zeros(N,1,'int32');
            for k = 1:N
                animIDArr(k)  = S(k).animFrame;
                tag           = S(k).soundTag;
                soundIDArr(k) = soundMap.(tag);   % numeric ID (0 if silent)
            end

            %% 3) Build object array (doors, chests, key)
            doorTile = uint8(3);
            [yD,xD]  = find(floorGrid==doorTile);
            numDoors = numel(xD);

            objArr   = repmat(struct('pos',[0 0 0],'typeID',uint16(0), ...
                                     'animFrame',int32(0)), numDoors+1+size(gs.mapManager.chests,1),1);

            % fill doors
            for d=1:numDoors
                objArr(d).pos        = [xD(d) yD(d) currentFloor];
                objArr(d).typeID     = uint16(10);     % 10 = door
                objArr(d).animFrame  = 0;
            end
            idx = numDoors;

            % fill chests
            for c = 1:size(gs.mapManager.chests,1)
                idx = idx + 1;
                objArr(idx).pos       = gs.mapManager.chests(c,:);
                objArr(idx).typeID    = uint16(11);    % 11 = chest
                objArr(idx).animFrame = 0;
            end

            % key object
            idx = idx + 1;
            objArr(idx).pos       = gs.keyManager.keyPosition;
            objArr(idx).typeID    = uint16(12);        % 12 = key
            objArr(idx).animFrame = gs.keyManager.animFrame;

            %% 4) Call MEX (we pass the *struct array* directly)
            frameRGB = mexRenderAndSound( ...
                            playerData, S, objArr, soundIDArr );

            %% 5) Optionally send frame back via DataQueue (headless build skips)
    
            pause(dt);
        end
    end