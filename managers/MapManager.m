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