{
  description = "NixOS hosts for The Pale Heart";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    hermes-agent.url = "github:NousResearch/hermes-agent";
  };

  outputs = { nixpkgs, disko, hermes-agent, ... }: {
    nixosConfigurations.failsafe = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        hermes-agent.nixosModules.default
        ./hosts/failsafe/disko.nix
        ./hosts/failsafe/configuration.nix
      ];
    };
  };
}
