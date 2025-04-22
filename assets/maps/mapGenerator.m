function map = generateGameMap(rows, cols, numRooms)
    %GENERATEGAMEMAP Create a room-and-corridor style ASCII map
    %   rows, cols: size of map
    %   numRooms: number of rooms to generate
    
        WALL = 9;
        PATH = 0;
        map = repmat(WALL, rows, cols);
    
        rooms = [];
    
        for i = 1:numRooms
            % Random room size
            w = randi([5, 10]);
            h = randi([4, 8]);
    
            % Random room position
            x = randi([2, cols - w - 1]);
            y = randi([2, rows - h - 1]);
    
            % Add to room list
            rooms(end+1,:) = [x, y, w, h];
    
            % Carve room
            map(y:y+h-1, x:x+w-1) = PATH;
        end
    
        % Connect rooms with L-shaped corridors
        for i = 2:numRooms
            x1 = rooms(i-1,1) + floor(rooms(i-1,3)/2);
            y1 = rooms(i-1,2) + floor(rooms(i-1,4)/2);
            x2 = rooms(i,1) + floor(rooms(i,3)/2);
            y2 = rooms(i,2) + floor(rooms(i,4)/2);
    
            if rand < 0.5
                map(min(y1,y2):max(y1,y2), x1) = PATH; % vertical
                map(y2, min(x1,x2):max(x1,x2)) = PATH; % horizontal
            else
                map(y1, min(x1,x2):max(x1,x2)) = PATH;
                map(min(y1,y2):max(y1,y2), x2) = PATH;
            end
        end
    end