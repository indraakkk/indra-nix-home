{ pkgs, ... }:

{
  env = {
    DATABASE_URL = "mysql://root@localhost:__PORT__/__PROJECT__";
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings.mysqld.port = __PORT__;
    initialDatabases = [{ name = "__PROJECT__"; }];
  };
}
