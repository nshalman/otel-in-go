with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    nodePackages.prettier
  ];
}
