run:
    nix build -L .
    ./result/bin/logos

clean:
    -rm result
    -rm -rf ~/.cache/mkWindowsApp
    -rm -rf ~/.config/mkWindowsApp
