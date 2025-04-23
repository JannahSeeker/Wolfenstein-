function runMyFPS()
    %RUNMYFPS  Head‑less launcher that runs each loop on its own background
    %          worker (parfeval) and prints minimal status to the console.
    %
    %   Stops when the user presses ENTER or when gameState.running == false.
    
        %% 1) Build all state

        gs = initGameState();
    
        %% 2) Ensure a parallel pool (threads profile)
        pool = gcp("nocreate");
        if isempty(pool)
            pool = parpool("threads");   %#ok<NASGU>
        end
    
        %% 3) Launch background tasks
        fInput  = parfeval(@input2Loop,  0, gs);   % 0 outputs
        % fLogic  = parfeval(@logicLoop,  0, gs);
        fRender = parfeval(@render2dLoop, 0, gs);   % renderLoop can discard frames
    
        fprintf("Game running in background threads – press ENTER to stop...\n");
    
        %% 4) Wait for user interrupt or gameState.running flag
        stopRequested = false;
        h = listener(gs,'running','PostSet',@(~,~)checkStop()); %#ok<LNVEN>
    
        % Non‑blocking keyboard wait
        try
            pause on
            while ~stopRequested && gs.running
                pause(0.2);
                if ~isempty(get(groot,'CurrentCharacter')) || ~isempty(get(groot,'CurrentKey'))
                    stopRequested = true;
                end
            end
        catch
            % If the user closed MATLAB command window
        end
    
        %% 5) Clean shutdown
        cancel([fInput, fLogic, fRender]);
        delete(h);
    
        fprintf("Shutdown complete.\n");
    
        % ----------------------------------------------------------
        function checkStop()
            % If some part of the game sets gs.running = false, exit
            if ~gs.running
                stopRequested = true;
            end
        end
    end