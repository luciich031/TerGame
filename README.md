<img width="535" height="138" alt="image" src="https://github.com/user-attachments/assets/57b7ab2c-2fdc-4f8c-8db5-2b7811f13807" />


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


