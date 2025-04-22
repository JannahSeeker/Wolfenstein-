function inputLoop(gs)
%INPUTLOOP  Background task that polls the Arduino joystick & buttons.
%
%   This function is launched exactly once as a parfeval worker and then
%   runs an internal while‑loop until  gs.running  becomes false or the
%   future is cancelled.
%
%   Responsibilities
%   ---------------
%     • Read analog stick via  readValue()  → [x y] in range ‑1..1
%     • Apply dead‑zone filtering
%     • Store joystick vector in  gs.inputManager.joystick
%     • Read two buttons (shoot / dropKey) via  readDigitalPin()
%     • Sleep for  gs.inputPeriod  seconds between polls
%
%   Assumptions
%   -----------
%     • If  gs.inputManager.ard  exists, it is a valid  arduino  object.
%     • Button pins are wired on D2 (shoot) and D3 (dropKey).
%     • If  readValue()  or digital pins are unavailable, the code
%       quietly falls back to zeros / false.
%
%   NOTE:  Because  gs  is a plain struct captured by the worker when this
%   function starts, changes made here are reflected immediately in the
%   calling workspace (copy‑by‑reference before the workers launch).

    % Cache period locally for speed
    dt = gs.inputPeriod;

    % Determine whether we have an Arduino handle
    haveArduino = isfield(gs.inputManager,'ard') && ...
                  ~isempty(gs.inputManager.ard);

    while gs.running
        %% 1) Poll hardware
        try
            joy = readValue();               % [x y] ∈ [-1 1]
            btns = readButtonState();        % struct with .shoot .interact
        catch
            joy  = [0 0];
            btns = struct('shoot',false,'interact',false);
        end

        %% 2) Dead‑zone & normalise
        dz = gs.inputManager.deadzone;
        joy(abs(joy) < dz) = 0;
        gs.inputManager.joystick = joy;
        gs.inputManager.shoot    = btns.shoot;
        gs.inputManager.interact = btns.interact;

        %% 3) Move player in the X‑Y plane
        if any(joy)
            dir   = joy / max(1,norm(joy));        % unit vector
            speed = gs.player.speed * dt;
            newPos = gs.player.position(1:2) + dir * speed;

            % Simple wall collision guard (stay inside bounds)
            H = size(gs.mapManager.maps,1);
            W = size(gs.mapManager.maps,2);
            newPos = max([1 1], min([W H], newPos));

            gs.player.position(1:2) = newPos;
        end

        %% 4) Interaction key (pickup key / open chest / door)
        if btns.interact
            playerXYZ = round(gs.player.position);
            floorIdx  = gs.mapManager.currentFloor;

            % --- Pickup key from chest ---------------------------------
            chestList = gs.mapManager.chests;
            for k = 1:size(chestList,1)
                if all(playerXYZ == chestList(k,:))
                    if gs.player.mana >= 100 && ~gs.keyManager.isHeld
                        gs.player.hasKey   = true;
                        gs.keyManager.isHeld = true;
                        fprintf("Key picked up!\n");
                    end
                end
            end

            % --- Open door if mana full (placeholder) ------------------
            tileID = gs.mapManager.maps(playerXYZ(2),playerXYZ(1),floorIdx);
            DOOR_TILE = uint8(3);  % define your door id
            if tileID == DOOR_TILE && gs.player.mana >= 100
                gs.mapManager.maps(playerXYZ(2),playerXYZ(1),floorIdx) = 0; % set to empty
                gs.player.mana = 0;  % consume mana
                fprintf("Door opened.\n");
            end
        end

        pause(dt);   % throttle
    end
end
