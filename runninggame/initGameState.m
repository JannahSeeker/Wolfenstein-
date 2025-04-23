function gs = initGameState()
%INITGAMESTATE  Build and return the master GameState struct.
%
%   gs = initGameState();
%
%   Creates all sub‑structs (player, mapManager, spriteManager, …) and
%   bundles them into one handle‑less struct suitable for passing to the
%   parallel‑loop functions.

% initGameState.m

player         = createPlayerr();
mapManager     = createMapManager();
spriteManager  = createSpriteManager();


%% 11) Master GameState Struct
gameState = struct( ...
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

function player = createPlayerr()
%CREATEPLAYER  Initializes the player struct with default attributes.

player = struct( ...
    'position',    [0, 0, 0], ... %[x,y,z]
    'angle',       0.0, ...
    'health',      100.0, ...
    'maxHealth',   100.0, ...
    'mana',        0.0, ...
    'hasKey',      false, ...
    'speed',       5.0, ... %[cell per sec]
    'animFrame',   0 ...
    );
end


function mapManager = createMapManager()

%% 1) Map Tile Keys
TILE_EMPTY     = 0;
TILE_PLAYER    = 1;
TILE_GHOST     = 2;
TILE_SOLDIER   = 7;
TILE_ELEVATOR  = 3;
TILE_CHEST     = 4;
TILE_WALL      = 5;
TILE_DOOR      = 6;
TILE_KEY       = 8;

%% 2) MapManager Struct
mapHeight   = 20;
mapWidth    = 30;
numFloors   = 3;
map3D       = zeros(mapHeight, mapWidth, numFloors, 'uint8');

% Create wall borders on each floor
for z = 1:numFloors
    map3D(1, :, z) = TILE_WALL;                 % Top edge
    map3D(mapHeight, :, z) = TILE_WALL;         % Bottom edge
    map3D(:, 1, z) = TILE_WALL;                 % Left edge
    map3D(:, mapWidth, z) = TILE_WALL;          % Right edge
end

% Create key manager and place key on the map
keyManager = createKeyManager();
x = keyManager.keyPosition(1);
y = keyManager.keyPosition(2);
z = keyManager.keyPosition(3);
map3D(x, y, z) = TILE_KEY;

% Define elevator and chest locations as N×3 arrays of [x,y,z]
elevators = [  5, 10, 1;    % elevator at (5,10) on floor 1
    15,  8, 2 ];  % elevator at (15,8) on floor 2

chests = [ 10,  4, 1;    % chest at (10,4) on floor 1
    12, 17, 2;    % chest at (12,17) on floor 2
    3, 19, 3 ];  % chest at (3,19) on floor 3

% Place elevators
for i = 1:size(elevators, 1)
    x = elevators(i, 1);
    y = elevators(i, 2);
    z = elevators(i, 3);
    map3D(x, y, z) = TILE_ELEVATOR;
end

% Place chests
for i = 1:size(chests, 1)
    x = chests(i, 1);
    y = chests(i, 2);
    z = chests(i, 3);
    map3D(x, y, z) = TILE_CHEST;
end

% Construct the map manager struct
mapManager = struct( ...
    'map',           map3D, ...
    'height', mapHeight,...
    'width', mapWidth,...
    'currentFloor',  1, ...
    'elevators',     elevators, ...
    'chests',        chests, ...
    'key',           keyManager ...
    );

end

function keyManager = createKeyManager()

% managers/KeyManager.m
keyManager = struct( ...
    'keyPosition', [2, 3,1], ...    % initial spawn [x,y]
    'isHeld',      false, ...
    'animFrame',   0 ...           % added animFrame for key
    );

end
% entities/Sprite.m
% entities/Sprite.m
function sprite = createSprite(pos, type, state, animFrame, aiBrain)
%CREATESPRITE Constructs a single sprite struct.
%
%   sprite = createSprite([x y z], typeID, state, animFrame, aiBrain)

if strcmp(type, "soldier")
    sprite = struct( ...
        'speed', 2.0, ...
        'health', 20, ...
        'maxHealth', 20, ...
        'opacity', 1.0, ...
        'pos',       pos, ...
        'type',      type, ...
        'state',     state, ...
        'animFrame', int32(animFrame), ...
        'aiBrain',   aiBrain ...
        );
else
    sprite = struct( ...
        'speed', 4.0, ...
        'health', 10, ...
        'maxHealth', 10, ...
        'opacity', 0.4, ...
        'pos',       pos, ...
        'type',      type, ...
        'state',     state, ...
        'animFrame', int32(animFrame), ...
        'aiBrain',   aiBrain ...
        );
end

end
% managers/SpriteManager.m
function spriteManager = createSpriteManager()
%CREATESPRITEMANAGER Initializes spriteManager with example enemies

spriteManager = struct();

spriteManager.sprites = [
    createSprite([5, 5, 0], "ghost", 'Idle', 0, 'DirectChaser'),
    createSprite([8, 2, 0], "ghost", 'Idle', 0, 'WallAvoidingGhost')
    ];
end