function keyManager = createKeyManager()

% managers/KeyManager.m
keyManager = struct( ...
    'keyPosition', [2, 3,1], ...    % initial spawn [x,y]
    'isHeld',      false, ...
    'animFrame',   0 ...           % added animFrame for key
    );

end