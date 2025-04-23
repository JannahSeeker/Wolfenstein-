#ifndef RENDERING_ENGINE_H
#define RENDERING_ENGINE_H

#include "raylib.h" 

typedef unsigned int TextureID; 
bool InitRenderer(int screenWidth, int screenHeight, const char* windowTitle);
void ShutdownRenderer();

bool Renderer_WindowShouldClose();
void BeginFrame();
void EndFrame();          
TextureID LoadTextureFromPath(const char* filePath);
void UnloadTextureByID(TextureID textureId);
    
    
void DrawWallSlice(int screenX, int drawStartY, int drawEndY, Color color);
void DrawTexturedWallSlice(int screenX, int drawStartY, int drawEndY, float drawWidth, TextureID textureId, float texCoordX, Color tint);
void DrawSprite(TextureID textureId, Rectangle sourceRec, Rectangle destRec, Vector2 origin, float rotation, Color tint);
void DrawScreenRectangle(int posX, int posY, int width, int height, Color color);
void DrawScreenLine(int startPosX, int startPosY, int endPosX, int endPosY, Color color);
void DrawScreenText(const char* text, int posX, int posY, int fontSize, Color color);

int GetRendererScreenWidth();
int GetRendererScreenHeight();

#endif

/*

% --- Configuration: Verify Paths for DYNAMIC CRT libs ---
rendererHeaderPath = 'C:\Users\SNO\source\repos\RaycasterGL\RaycasterGL';
% *** UPDATE to dynamic Raylib path from vcpkg ***
raylibHeaderPath   = 'C:\vcpkg-master\installed\x64-windows-static\include\'; % <--- CHANGE HERE
% *** UPDATE to Release build of your lib ***
rendererLibFile    = 'C:\Users\SNO\source\repos\RaycasterGL\x64\Release\RaycasterGL.lib'; % <--- Use Release build
% *** UPDATE to dynamic Raylib path from vcpkg ***
raylibLibFile      = 'C:\vcpkg-master\installed\x64-windows-static\lib\raylib.lib'; % <--- CHANGE HERE
% *** Find glfw3.lib (likely same directory as raylib.lib) ***
glfwLibFile        = 'C:\vcpkg-master\installed\x64-windows-static\lib\glfw3.lib'; % <--- ADD THIS (Verify name/path)

% --- Extract Library Directories ---
if ~isfile(rendererLibFile), error('Renderer library file not found: %s', rendererLibFile); end
if ~isfile(raylibLibFile), error('Raylib library file not found: %s', raylibLibFile); end
if ~isfile(glfwLibFile), error('GLFW library file not found: %s', glfwLibFile); end

[rendererLibDir, ~, ~] = fileparts(rendererLibFile);
[raylibLibDir, ~, ~] = fileparts(raylibLibFile); % raylib and glfw likely share dir
[glfwLibDir, ~, ~] = fileparts(glfwLibFile);

% --- Check if header paths exist ---
if ~isfolder(rendererHeaderPath), error('Renderer header path not found: %s', rendererHeaderPath); end
if ~isfolder(raylibHeaderPath), error('Raylib header path not found: %s', raylibHeaderPath); end

% --- Construct arguments ---
% Include paths (using -I path format, as Name-Value caused issues before)
includeArgRenderer = ['-I' rendererHeaderPath];
includeArgRaylib   = ['-I' raylibHeaderPath];
% Library Paths (using -L path format)
libPathArgRenderer = ['-L' rendererLibDir];
libPathArgRaylib   = ['-L' raylibLibDir]; % Only need one if raylib & glfw share dir
% libPathArgGlfw     = ['-L' glfwLibDir]; % Redundant if same as raylib

% --- Run the MEX command (Release build, linking GLFW) ---
disp('Attempting MEX compilation (Release, dynamic CRT, linking GLFW)...');
try
    mex('renderMex.cpp', ...
        '-v', ...                % Verbose
        '-g', ...                % Keep debug symbols for MEX file itself
        'COMPFLAGS="$COMPFLAGS /MD /O2 /DNDEBUG"', ... % Ensure Release flags for compilation
        'LINKFLAGS="$LINKFLAGS"', ... % Add '/LTCG' here if needed after turning off /GL
        includeArgRenderer, ...
        includeArgRaylib, ...
        libPathArgRenderer, ...
        libPathArgRaylib, ...     % Path for both raylib and glfw
        rendererLibFile, ...      % Your engine lib (Release, /MD)
        raylibLibFile, ...        % Raylib lib (dynamic CRT, /MD)
        glfwLibFile, ...          % GLFW lib (dynamic CRT, /MD) <-- ADDED
        'winmm.lib', ...
        'gdi32.lib', ...
        'opengl32.lib', ...
        'shell32.lib', ...
        'user32.lib', ...         % Add explicitly just in case
        'kernel32.lib' ...        % Add explicitly just in case
       );
    disp('------------------------------------');
    disp('MEX compilation successful!');
    disp('------------------------------------');
catch ME
    disp('------------------------------------');
    disp('ERROR during MEX compilation:');
    disp(ME.message);
    if ~isempty(ME.cause)
        disp('Cause:');
        try causeStr = getReport(ME.cause{1}, 'basic'); disp(causeStr); catch; disp(ME.cause{1}); end
    end
    disp('Stack Trace:');
    disp(ME.getReport('basic'));
    disp('------------------------------------');
end

*/