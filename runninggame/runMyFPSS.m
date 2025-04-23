function runMyFPSS()
    %RUNMYFPSS  Head‑less launcher that runs each loop on its own background
    %           worker (parfeval) and prints minimal status to the console.
    %
    %   Stops when the user presses ENTER or when gameState.running == false.
    
        %% 1) Build all state
        gs = initGameState();
 
    
        %% 3) Launch background tasks
        render2dLoop(gs);

        input2Loop(gs);
        % fInput  = parfeval(@input2Loop,  0, gs);   % 0 outputs
        % fLogic  = parfeval(@logicLoop,  0, gs);
        % fRender = parfeval(@render2dLoop, 0, gs);   % renderLoop can discard frames
    

        fprintf("Shutdown complete.\n");
    end