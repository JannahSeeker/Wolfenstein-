% managers/SpriteManager.m
function spriteManager = createSpriteManager()
%CREATESPRITEMANAGER Initializes spriteManager with example enemies

spriteManager = struct();

spriteManager.sprites = [
    createSprite([5, 5, 0], "ghost", 'Idle', 0, 'DirectChaser'),
    createSprite([8, 2, 0], "ghost", 'Idle', 0, 'WallAvoidingGhost')
    ];
end