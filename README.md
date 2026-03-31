# Snake Game (LÖVE 2D)
A version of the classic "Snake" game developed in Lua using the LÖVE framework. This project serves as a demonstration of game development fundamentals, including table manipulation, state management, and data persistence.

<img width="1026" height="658" alt="image" src="https://github.com/user-attachments/assets/1b9e89a5-247c-46fa-abe0-ff6eb41a5709" />

## Key Features
- **Dynamic Gameplay**: Difficulty scales as the score increases (progressive speed).
- **Special Items**: 
  - **Blue Apples**: Speed boost and score multiplier.
  - **Yellow Apples**: Multi-spawn event.
- **Ranking System**: Local data persistence to save and display high scores.
- **Complete Game Loop**: Fully functional menus, pause states, and game over screens.
- **Sound Design**: Dynamic soundtrack and SFX.

## Tech Stack
- **Language**: Lua
- **Framework**: LÖVE 11.x
- **Libraries**:
  - **push**: Virtual resolution handling.
  - **ser**: Table serialization for save files.

## Project Structure
- **main.lua**: Core engine logic, managing the game loop (load, update, draw).
- **player.lua**: Encapsulates snake movement, collision detection, and growth logic.
- **food.lua**: Manages spawning logic for standard and special consumables.
- **assets/**: Directory for fonts and audio resources.
- **libraries/**: Directory for external libraries.

## How to Run
1. Extract the "snakeBuild.zip" file.
2. Run "snake.exe" to play the game.

![20260331-0223-59 4819527](https://github.com/user-attachments/assets/49e653a8-ca08-443f-b6f2-5443ec364072)

## Resources
- **Font**:
  - Upheaval - Brian Kent
- **Sound Fx**:
  - Made on https://sfxr.me/ sfx generator
- **Music**:
  - Made by me (https://www.youtube.com/watch?v=3YM4MK9XZvA)
