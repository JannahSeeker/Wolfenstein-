#include "../RaycasterGL/RaycasterEngine.h"
#include <iostream>

const int SCREEN_WIDTH = 800;
const int SCREEN_HEIGHT = 600;

int main(void) {
    std::cout << "Host EXE: Attempting to initialize Renderer DLL..." << std::endl;

    // 1. Initialize the Rendering DLL
    // This should create the window and setup Raylib internally in the DLL.
    if (!InitRenderer(SCREEN_WIDTH, SCREEN_HEIGHT, "Basic Renderer DLL Test")) {
        // Use std::cerr for errors
        std::cerr << "Host EXE: ERROR - Failed to initialize Renderer DLL!" << std::endl;
        return -1; // Indicate failure
    }

    std::cout << "Host EXE: Renderer DLL Initialized Successfully." << std::endl;
    std::cout << "Host EXE: Entering main rendering loop..." << std::endl;

    // --- Optional: Load a test resource via DLL if needed ---
    // TextureID testTexture = LoadTextureFromPath("path/to/your/texture.png");
    // if (testTexture == 0) {
    //     std::cerr << "Host EXE: Warning - Failed to load test texture." << std::endl;
    // }

    // 2. Main Loop
    // Keep running as long as the DLL's window shouldn't close
    while (!Renderer_WindowShouldClose()) { // Use the renamed function!

        // 3. Signal start of drawing to the DLL
        BeginFrame(); // DLL should clear the background (e.g., to BLACK)

        { // Scope for drawing commands (optional, just for clarity)

            // 4. Call DLL functions to draw things:

            // Draw some simple text
            DrawScreenText("Hello from Renderer DLL!", 20, 20, 20, GREEN); // Assumes GREEN defined via raylib.h

            // Draw a rectangle in the middle
            int rectWidth = 200;
            int rectHeight = 100;
            DrawScreenRectangle(
                (SCREEN_WIDTH - rectWidth) / 2,
                (SCREEN_HEIGHT - rectHeight) / 2,
                rectWidth,
                rectHeight,
                BLUE
            );

            // Draw a line across the screen
            DrawScreenLine(0, SCREEN_HEIGHT / 2, SCREEN_WIDTH, SCREEN_HEIGHT / 2, RED);

            // Example using a loaded texture (if you uncommented loading)
            // if (testTexture != 0) {
            //     // Define source (full texture) and destination rectangles
            //     Rectangle source = {0.0f, 0.0f, 32.0f, 32.0f}; // Replace 32x32 with actual texture size
            //     Rectangle dest = {50.0f, 50.0f, 64.0f, 64.0f}; // Draw at 50,50 with size 64x64
            //     DrawSprite(testTexture, source, dest, Vector2{0,0}, 0.0f, WHITE);
            // }

        } // End of drawing commands

        // 5. Signal end of drawing to the DLL
        EndFrame(); // DLL should swap buffers and display the frame
    }

    std::cout << "Host EXE: Window closed or exit requested." << std::endl;
    std::cout << "Host EXE: Shutting down Renderer DLL..." << std::endl;

    // --- Optional: Unload resources ---
    // if (testTexture != 0) {
    //     UnloadTextureByID(testTexture);
    // }

    // 6. Shutdown the Rendering DLL
    ShutdownRenderer(); // DLL should clean up Raylib resources and close window

    std::cout << "Host EXE: Renderer DLL Shutdown complete. Exiting." << std::endl;

    return 0; // Indicate successful execution
}