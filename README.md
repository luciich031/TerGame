# TerGame Launcher (Arch Linux)

A terminal-based game launcher for running .exe files on Arch Linux via Wine.

# setup, requirements and testing

```bash
sudo pacman -S wine wine-mono wine-gecko dxvk-bin vkd3d-proton-bin
chmod +x tergame.sh or test.sh   

# Usage

./tergame.sh add gamename /path/to/game.exe
./tergame.sh list
./tergame.sh run gamename
./tergame.sh /path/to/game.exe   # direct run   


#have fun :))


#ToBeFixed :
tergame fails when the words are separated
