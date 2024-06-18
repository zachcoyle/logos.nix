{
  description = "logos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    erosanix = {
      url = "github:emmanuelrosa/erosanix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    logoslinuxinstaller = {
      url = "github:FaithLife-Community/LogosLinuxInstaller";
      flake = false;
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devshell.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        inherit (inputs.erosanix.lib.${system}) mkWindowsAppNoCC copyDesktopIcons copyDesktopItems makeDesktopIcon;
        wine = pkgs.wineWowPackages.waylandFull;
      in {
        packages.default = mkWindowsAppNoCC rec {
          pname = "logos";
          # TODO: https://bugs.winehq.org/show_bug.cgi?id=53354
          # version = "34.1.0.0009";
          version = "29.1.0.0022";
          name = "${pname}-${version}";
          src = pkgs.fetchurl {
            url = "https://downloads.logoscdn.com/LBS10/Installer/${version}/LogosSetup.exe";
            # hash = "sha256-fuCY5OeCxyssy2G162x3YJKyOpnDTGfGF17ZI369f5A=";
            hash = "sha256-SJ807Q+aCFU2S3jjNEF/2briLfhxxVA6aLAledNPrJc=";
          };
          inherit wine;
          dontUnpack = true;
          enableMonoBootPrompt = false;
          wineArch = "win64";
          persistRegistry = true;

          nativeBuildInputs = [
            copyDesktopIcons
          ];

          fileMap = {"$HOME/.config/Logos" = "drive_c/users/$USER/AppData/Roaming/Logos";};

          winAppInstall = ''
            $WINE start /unix ${src} /S
            wineserver -w
          '';

          winAppRun = ''
            $WINE start /unix "$WINEPREFIX/drive_c/users/$USER/AppData/Local/Logos/Logos.exe" "$ARGS"
          '';

          installPhase = ''
            runHook preInstall
            ln -s $out/bin/.launcher $out/bin/${pname}
            runHook postInstall
          '';

          desktopItems = [
            (pkgs.makeDesktopItem {
              name = "Logos";
              exec = pname;
              icon = pname;
              desktopName = "Logos Bible Software";
              categories = ["Education"];
            })
          ];

          desktopIcon = makeDesktopIcon {
            name = pname;
            icoIndex = 2;
            src = "${inputs.logoslinuxinstaller}/img/logos4-128-icon.png";
          };
        };

        devshells.default = {
          name = "logos";
          packages = with pkgs; [just];
        };
      };
    };
}
