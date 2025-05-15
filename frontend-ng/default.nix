let local-pkgs = import <nixpkgs> { };
in
local-pkgs.callPackage ./package.nix { }
