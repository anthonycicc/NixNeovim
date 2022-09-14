{ pkgs, lib, config, ... }:

with lib;

let

  helpers = import ./helpers.nix { inherit lib config; };

  # names inserted here must match the name of the package in pkgs.vimExtraPlugins
  plugs = with pkgs.vimExtraPlugins; [
    "nvim-comment-frame"
    "vim-printer"
    "vim-easy-align"
    "plantuml-syntax"
    "gruvbox"
    "nest-nvim"
    "plenary-nvim"
    "nvim-ts-context-commentstring"
    "telescope-nvim"
    "indent-blankline-nvim"
    "asyncrun-vim"
    "ltex-extra-nvim"
    "firenvim"
    { name = "LuaSnip"; setup = false; }
    { name = "lsp-signature-nvim"; setup = false; }
  ];

in with helpers; {
  imports = lib.forEach plugs
    (p:
    let
      name = if isString p then p else p.name;
      setup =
        if isString p then 
          ""
        else 
          if isString p.setup then
            p.setup
          else if p.setup then
            "require('${name}').setup()"
          else "";
    in mkLuaPlugin {
        name = name;
        description = "Autogenerated module for ${name}";
        extraPlugins = [ pkgs.vimExtraPlugins.${name} ];
        extraConfigLua = setup;
      }
    );
}
