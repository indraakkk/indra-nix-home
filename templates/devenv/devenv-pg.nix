{ pkgs, ... }:

{
  env = {
    DATABASE_URL = "postgresql://indra@localhost:__PORT__/__PROJECT__";
  };

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    listen_addresses = "127.0.0.1";
    port = __PORT__;
    initialDatabases = [{ name = "__PROJECT__"; }];
  };
}
