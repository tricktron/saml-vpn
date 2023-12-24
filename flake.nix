{
    description               = "learn-go-with-tests";
    inputs.nixpkgs.url        = "github:NixOS/nixpkgs/nixos-unstable";
    inputs.nix-github-actions =
    {
        url                    = "github:nix-community/nix-github-actions";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = { self, nixpkgs, nix-github-actions, ... }:
    let 
        supportedSystems = 
        [ 
            "x86_64-darwin" 
            "aarch64-darwin"
            "x86_64-linux" 
        ];
        forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
        devShells = forAllSystems
        (system:
        let
            pkgs = nixpkgs.legacyPackages.${system};
        in
        {
            default = pkgs.mkShell 
            {
                buildInputs = with pkgs; 
                [
                    go
                ];
            };
        });

        packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in
        {
            default = pkgs.buildGoModule
            {
                nativeBuildInputs  = with pkgs; [ golangci-lint ];
                pname        = "saml-vpn";
                version      = "1.0.0";
                src          = ./.;
                vendorSha256 = null;
                preCheck     = 
                ''
                    HOME=$TMPDIR
                    golangci-lint run --enable-all
                '';
                checkFlags = "-short";
            };
        });

        githubActions = 
        let githubRunnerSystems = 
            nixpkgs.lib.lists.remove "aarch64-darwin" supportedSystems;
        in
            nix-github-actions.lib.mkGithubMatrix
        {
            checks = nixpkgs.lib.getAttrs githubRunnerSystems self.packages;
        };
    };
}
