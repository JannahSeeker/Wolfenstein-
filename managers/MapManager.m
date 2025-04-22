% managers/MapManager.m
function mapManager = createMapManager()

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
end