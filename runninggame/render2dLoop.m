function render2dLoop(gs)
disp('Render loop (graphical) started');
dt = gs.renderPeriod;

% Set up figure for both rendering and input handling
figureHandle = figure('Name', 'Game View', 'NumberTitle', 'off', 'KeyPressFcn', @keyDown);
axis equal tight
colormap([1 1 1;     % 0 - Empty (white)
    0 0 0;     % 1 - Player (black)
    1 0 0;     % 2 - Ghost (red)
    0 0 1;     % 3 - Elevator (blue)
    1 1 0;     % 4 - Chest (yellow)
    0.5 0.5 0.5; % 5 - Wall (gray)
    0 1 1;     % 6 - Door (cyan)
    0.5 0 0;   % 7 - Soldier (brown)
    0 1 0]);   % 8 - Key (green)

movegui(figureHandle, 'center');  % Move the figure to center
figure(figureHandle);  % Ensure the figure has focus

while gs.running && ishandle(figureHandle)
    % Render the map
    map = gs.mapManager.map;
    z = gs.mapManager.currentFloor;
    playerPos = gs.player.position;

    % Copy floor z of the map
    floorMap = map(:, :, z);

    % Set player position on the map
    if all(playerPos(3) == z)
        floorMap(playerPos(1), playerPos(2)) = 1;  % Player tile index
    end

    % Display the floor map
    imagesc(floorMap);
    title(sprintf('=== FLOOR %d ===', z));
    drawnow;  % Update the display

    % Small pause to allow the system to process key events
    getInput(gs);
    pause(0.05);  % Reduced pause time
end

if ishandle(figureHandle)
    close(figureHandle);  % Close the figure when done
end
disp('Render loop (graphical) ran');

% Key press handler
    function getInput(gs)
        % GETINPUT Polls an HTTP joystick server and updates the player's position

        try
            % Send GET request to the joystick server
            keyStates = webread('http://localhost:5555/keypress');

            % Read booleans for WASD keys
            w = keyStates.w;
            a = keyStates.a;
            s = keyStates.s;
            d = keyStates.d;

            % Current player position
            pos = gs.player.position;
            x = pos(1); y = pos(2); z = pos(3);

            % Apply movement based on key states
            if w && x > 1
                x = x - 1;
            end
            if s && x < gs.mapManager.height
                x = x + 1;
            end
            if a
                if y > 1
                    y = y - 1;
                else
                    gs.player.facing = mod(gs.player.facing - 1, 4);  % Turn left
                end
            end
            if d
                if y < gs.mapManager.width
                    y = y + 1;
                else
                    gs.player.facing = mod(gs.player.facing + 1, 4);  % Turn right
                end
            end

            % Update position
            gs.player.position = [x, y, z];

        catch ME
            disp('[getInput] Error reading from joystick server:');
            disp(ME.message);
        end
    end
end