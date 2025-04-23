function input2Loop(gs)
% INPUT2LOOP: Continuously checks for key input to move or rotate the player.
disp('Input loop started');

% Ensure there's a figure to receive input
fig = figure('KeyPressFcn', @keyDown, 'Name', 'Wolfenstein+', 'NumberTitle', 'off');
movegui(fig, 'center');

while gs.running
    pause(gs.inputPeriod); % small delay to prevent overwhelming input polling
end

    function keyDown(~, event)
        pos = gs.player.position;
        x = pos(1); y = pos(2); z = pos(3);

        switch event.Key
            case {'w', 'uparrow'}
                if x > 1, x = x - 1; end
            case {'s', 'downarrow'}
                if x < gs.mapManager.height, x = x + 1; end
            case {'a', 'leftarrow'}
                if y > 1
                    y = y - 1;
                else
                    % Optional: handle left tilt
                    gs.player.facing = mod(gs.player.facing - 1, 4);
                end
            case {'d', 'rightarrow'}
                if y < gs.mapManager.width
                    y = y + 1;
                else
                    % Optional: handle right tilt
                    gs.player.facing = mod(gs.player.facing + 1, 4);
                end
        end

        % Apply movement
        gs.player.position = [x, y, z];
    end
end