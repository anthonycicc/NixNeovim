{ pkgs, lib, helpers, ... }:

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "vim-startuptime";
  pluginUrl = "https://github.com/dstein64/vim-startuptime";

  inherit (helpers.custom_options)
    strOption
    listOption
    enumOption
    intOption
    boolOption;

  moduleOptions = {
    # add module options here
  };



in mkLuaPlugin {

# Consider the following additional options:
#
# extraDescription ? "" # description added to the enable function
# extraPackages ? [ ]   # non-plugin packages
# extraConfigLua ? "" # lua config added to the init.vim
# extraConfigVim ? ""   # vim config added to the init.vim
# defaultRequire ? true # add default requrie string?
# extraOptions ? {}     # extra vim options like line numbers, etc
# extraNixNeovimConfig ? {} # extra config applied to 'programs.nixneovim'
# isColorscheme ? false # If enabled, plugin will be added to 'nixneovim.colorschemes' instead of 'nixneovim.plugins'

  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    vim-startuptime
  ];

  defaultRequire = false;
}
