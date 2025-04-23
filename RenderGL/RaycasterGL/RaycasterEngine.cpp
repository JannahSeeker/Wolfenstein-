// rendering_engine.cpp
#define RENDERINGENGINE_EXPORTS // Define this before including the header in the implementation file

#include "RaycasterEngine.h"
#include "raylib.h"
#include <map>
#include <string>
#include <vector> // Needed if using texture loading approach below

// --- Global State (Managed within the DLL) ---
int g_screenWidth = 0;
int g_screenHeight = 0;

// Texture management: Map an ID provided to the EXE to the Raylib Texture object
std::map<TextureID, Texture2D> g_textureMap;
TextureID g_nextTextureID = 1; // Start IDs from 1 (0 can signify invalid/none)

// --- Exported Function Implementations ---

bool InitRenderer(int screenWidth, int screenHeight, const char* windowTitle) {
    g_screenWidth = screenWidth;
    g_screenHeight = screenHeight;
    InitWindow(g_screenWidth, g_screenHeight, windowTitle);
    if (!IsWindowReady()) {
        return false;
    }
    // SetTargetFPS(60); // FPS can be controlled here or in the EXE loop logic
    g_textureMap.clear();
    g_nextTextureID = 1;
    return true;
}

void ShutdownRenderer() {
    // Unload all textures managed by the DLL
    for (auto const& [id, texture] : g_textureMap) {
        UnloadTexture(texture);
    }
    g_textureMap.clear();
    CloseWindow();
}

bool Renderer_WindowShouldClose() {
    return ::WindowShouldClose(); // Use Raylib's function directly
}

void BeginFrame() {
    BeginDrawing();
    ClearBackground(BLACK); // Default clear color, could be configurable
}

void EndFrame() {
    EndDrawing();
}

TextureID LoadTextureFromPath(const char* filePath) {
    Texture2D texture = LoadTexture(filePath);
    if (texture.id <= 0) { // Check if loading failed (texture.id will be > 0 on success)
        TraceLog(LOG_WARNING, "RENDER DLL: Failed to load texture: %s", filePath);
        return 0; // Return 0 (invalid ID) on failure
    }

    TextureID currentId = g_nextTextureID++;
    g_textureMap[currentId] = texture;
    TraceLog(LOG_INFO, "RENDER DLL: Loaded texture '%s' with ID %u", filePath, currentId);
    return currentId;
}

void UnloadTextureByID(TextureID textureId) {
    auto it = g_textureMap.find(textureId);
    if (it != g_textureMap.end()) {
        UnloadTexture(it->second); // Unload Raylib texture
        g_textureMap.erase(it);    // Remove from map
        TraceLog(LOG_INFO, "RENDER DLL: Unloaded texture with ID %u", textureId);
    }
    else {
        TraceLog(LOG_WARNING, "RENDER DLL: Attempted to unload non-existent texture ID %u", textureId);
    }
}

void DrawWallSlice(int screenX, int drawStartY, int drawEndY, Color color) {
    // Ensure coordinates are within bounds (optional, but good practice)
    // if (screenX < 0 || screenX >= g_screenWidth) return;
    // drawStartY = Clamp(drawStartY, 0, g_screenHeight - 1);
    // drawEndY = Clamp(drawEndY, 0, g_screenHeight - 1);
    // if (drawStartY >= drawEndY) return;

    DrawLine(screenX, drawStartY, screenX, drawEndY, color);
    // Or DrawRectangle(screenX, drawStartY, 1, drawEndY - drawStartY + 1, color);
}

void DrawTexturedWallSlice(int screenX, int drawStartY, int drawEndY, float drawWidth,
    TextureID textureId, float texCoordX, Color tint) {
    auto it = g_textureMap.find(textureId);
    if (it == g_textureMap.end()) {
        // Draw error color or do nothing if texture ID is invalid
        DrawRectangle(screenX, drawStartY, (int)drawWidth, drawEndY - drawStartY, MAGENTA);
        return;
    }

    Texture2D texture = it->second;

    // Calculate the source rectangle within the texture
    // texCoordX is the normalized X coordinate (0..1)
    // We need to map this to the actual pixel column in the texture
    int texX = (int)(texCoordX * texture.width);
    if (texX < 0) texX = 0;
    if (texX >= texture.width) texX = texture.width - 1;

    Rectangle sourceRec = { (float)texX, 0.0f, 1.0f, (float)texture.height };

    // Calculate the destination rectangle on the screen
    Rectangle destRec = { (float)screenX, (float)drawStartY, drawWidth, (float)(drawEndY - drawStartY) };

    // Use DrawTexturePro for precise control over source/dest rectangles
    DrawTexturePro(texture, sourceRec, destRec, Vector2{ 0, 0 }, 0.0f, tint);
}


void DrawSprite(TextureID textureId, Rectangle sourceRec, Rectangle destRec, Vector2 origin, float rotation, Color tint) {
    auto it = g_textureMap.find(textureId);
    if (it != g_textureMap.end()) {
        DrawTexturePro(it->second, sourceRec, destRec, origin, rotation, tint);
    }
    else {
        // Draw error color if texture ID is invalid
        DrawRectangleRec(destRec, MAGENTA);
    }
}

void DrawScreenRectangle(int posX, int posY, int width, int height, Color color) {
    DrawRectangle(posX, posY, width, height, color);
}

void DrawScreenLine(int startPosX, int startPosY, int endPosX, int endPosY, Color color) {
    DrawLine(startPosX, startPosY, endPosX, endPosY, color);
}

void DrawScreenText(const char* text, int posX, int posY, int fontSize, Color color) {
    DrawText(text, posX, posY, fontSize, color);
}

int GetRendererScreenWidth() {
    return g_screenWidth;
}

int GetRendererScreenHeight() {
    return g_screenHeight;
}