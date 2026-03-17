let
  indra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICqBeoTWu6J3g/hn4ub43c6mp43LVNwMfVHARmc0KNpF";
in
{
  "openclaw-gateway-token.age".publicKeys = [ indra ];
  "telegram-bot-token.age".publicKeys = [ indra ];
  "anthropic-setup-token.age".publicKeys = [ indra ];
  "whatsapp-allow-from.age".publicKeys = [ indra ];
  "telegram-allow-from.age".publicKeys = [ indra ];
}
