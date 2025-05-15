{
  lib,
  buildNpmPackage,
}:
buildNpmPackage (finalAttrs: {
  pname = "frontend-ng";
  version = "43";

  src = ./.;

  npmDepsHash = "sha256-bgMlGVGBiIdrR13rTXZUNnGtKa4VIqbJRN54rti67os=";

  installPhase = ''
    mkdir $out
    cp -r dist $out/
  '';
})
