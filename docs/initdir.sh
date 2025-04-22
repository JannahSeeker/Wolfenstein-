#!/bin/bash

# setup_project.sh
# Run this from your Wolfenstein+ root directory

# Define folders
folders=(
  "managers"
  "entities"
  "entities/ai"
  "assets"
  "assets/textures"
  "assets/sounds"
  "assets/maps"
  "docs"
  "tests"
)

# Define files
files=(
  "managers/AssetManager.m"
  "managers/AudioManager.m"
  "managers/CollisionDetector.m"
  "managers/HUDManager.m"
  "managers/InputManager.m"
  "managers/KeyManager.m"
  "managers/MapManager.m"
  "managers/RenderEngine.m"
  "managers/SpriteManager.m"
  "entities/Player.m"
  "entities/Sprite.m"
  "entities/ai/DirectChaser.m"
  "entities/ai/WallAvoidingGhost.m"
  "entities/ai/PredictiveGhost.m"
  "docs/GameDesignDoc.pdf"
  "docs/README.md"
  "tests/testCollision.m"
  "tests/testSpriteAI.m"
)

# Create directories
echo "Creating directories..."
for dir in "${folders[@]}"; do
  mkdir -p "$dir"
done

# Create files with placeholders
echo "Creating files..."
for file in "${files[@]}"; do
  if [[ $file == *.pdf ]]; then
    touch "$file"
  else
    echo "% $file" > "$file"
  fi
done

echo "Setup complete."