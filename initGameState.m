function gs = initGameState()
%INITGAMESTATE  Build and return the master GameState struct.
%
%   gs = initGameState();
%
%   Creates all sub‑structs (player, mapManager, spriteManager, …) and
%   bundles them into one handle‑less struct suitable for passing to the
%   parallel‑loop functions.

% initGameState.m

player         = createPlayer();
mapManager     = createMapManager();
spriteManager  = createSpriteManager();
arduinoManager = createArduinoManager();


%% 11) Master GameState Struct
gameState = struct( ...
    'arduinoManager', arduinoManager,...
    'player',           player, ...
    'mapManager',       mapManager, ...
    'spriteManager',    spriteManager, ...
    'running',          true,  ...
    'renderPeriod',     1/60,  ...
    'logicPeriod',      1/30,  ...
    'inputPeriod',      1/100  ...
    );
gs = gameState;
end