{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "failsafe";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  virtualisation.docker.enable = true;

  services.hermes-agent = {
    enable = true;
    container.enable = true;
    container.backend = "docker";
    container.hostUsers = [ "root" ];
    container.extraVolumes = [
      "/workspace:/workspace:rw"
    ];
    addToSystemPackages = true;
    environmentFiles = [
      "/var/lib/hermes/env"
    ];
    extraDependencyGroups = [
      "messaging"
    ];
    extraPackages = with pkgs; [
      ansible
      docker
      git
      jq
      kubectl
      kubernetes-helm
      nodejs_22
      opentofu
      pnpm
      ripgrep
    ];
    settings = {
      model.default = "anthropic/claude-sonnet-4";
      toolsets = [ "all" ];
      terminal = {
        backend = "local";
        cwd = "/workspace";
        timeout = 180;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    ansible
    bun
    curl
    direnv
    docker-compose
    fd
    git
    jq
    k9s
    kubectl
    kubernetes-helm
    nodejs_22
    opentofu
    pnpm
    ripgrep
    tmux
    vim
    yarn
  ];

  systemd.tmpfiles.rules = [
    "d /workspace 0750 hermes hermes -"
    "d /var/lib/hermes 0750 hermes hermes -"
    "f /var/lib/hermes/env 0600 hermes hermes -"
  ];

  networking.firewall.allowedTCPPorts = [
    22
  ];

  system.stateVersion = "25.05";
}
