# Overwatch Tracer 1v1: Ecopoint Antarctica

> **🎮 Workshop Code: `4MNDC`**

A 6-player rotation Tracer 1v1 workshop code set on the Ecopoint: Antarctica map.

## 🎮 Game Features
* **Map & Hero:** Ecopoint: Antarctica (Tracer only).
* **Game Rule (Winner Stays On):** The winner of the 1v1 duel remains in the arena to face the next challenger. The loser is moved to the back of the queue.
* **Custom Boundaries:** Utilizes invisible walls and kill zones to restrict the map to a specific arena size.
* **Real-time Stats UI:** Displays the current queue, individual win rates (W/L), current win streak, and the lobby's highest win streak in real-time.

---

## 🛠 Development Workflow

This project is written and compiled using Visual Studio Code and the [OverPy](https://github.com/Zezombye/overpy) extension. Follow the workflow below to edit and apply the code to your game.

### Prerequisites
* [Visual Studio Code](https://code.visualstudio.com/)
* VS Code Extension: [OverPy](https://marketplace.visualstudio.com/items?itemName=Zezombye.overpy)

### How to Edit and Apply
The conversion between Overwatch Workshop code and OverPy code is done through the following steps:

1. **Copy Settings:** Go to your Overwatch Custom Game Lobby -> **Settings** -> Click **Copy Settings**.
2. **Decompile:** In VS Code, open the Command Palette (`Ctrl`+`Shift`+`P` or `Cmd`+`Shift`+`P`) and run `OverPy: Decompile`. This converts the workshop code in your clipboard into OverPy code.
3. **Edit Code:** Freely modify the decompiled `.opy` source code.
4. **Compile:** Open the Command Palette again and run `OverPy: Compile`. The modified code will be compiled back into the Overwatch Workshop format and copied to your clipboard.
5. **Import Settings:** Go back to your Overwatch Custom Game Lobby -> **Settings** -> Click **Import Settings** to apply the changes.
