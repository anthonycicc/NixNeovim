{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.plugins.lualine;
  helpers = import ../helpers.nix { inherit lib config; };
  separators = mkOption {
    type = types.nullOr (types.submodule {
      options = {
        left = mkOption {
          default = " ";
          type = types.str;
          description = "left separator";
        };
        right = mkOption {
          default = " ";
          type = types.str;
          description = "right separator";
        };
      };
    });
    default = null;
  };
  component_options = defaultName:
    mkOption {
      type = types.nullOr (types.listOf (types.oneOf [
        types.str
        (types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "component name";
              default = defaultName;
            };
            icons_enabled = mkOption {
              type = types.enum [ "True" "False" ];
              default = "True";
              description = "displays icons in alongside component";
            };
            icon = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "displays icon in front of the component";
            };
            separator = separators;
            extraConfig = mkOption {
              type = types.attrs;
              default = { };
              description = "extra options for the component";
            };
          };
        })
      ]));
      default = null;
    };
in {
  options = {
    plugins.lualine = {
      enable = mkEnableOption "Enable lualine";

      theme = mkOption {
        default = config.colorscheme;
        type = types.nullOr types.str;
        description = "The theme to use for lualine-nvim.";
      };

      sectionSeparators = separators;
      componentSeparators = separators;

      disabledFiletypes = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        example = ''[ "lua" ]'';
        description = "filetypes to disable lualine on";
      };

      alwaysDivideMiddle = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description =
          "When true, left_sections (a,b,c) can't take over entire statusline";
      };

      sections = mkOption {
        type = types.nullOr (types.submodule ({ ... }: {
          options = {
            lualine_a = sections_option "mode";
            lualine_b = sections_option "branch";
            lualine_c = sections_option "filename";

            lualine_x = sections_option "encoding";
            lualine_y = sections_option "progress";
            lualine_z = sections_option "location";
          };
        }));

        default = null;
      };

      tabline = mkOption {
        type = types.nullOr (types.submodule ({ ... }: {
          options = {
            lualine_a = sections_option "";
            lualine_b = sections_option "";
            lualine_c = sections_option "";

            lualine_x = sections_option "";
            lualine_y = sections_option "";
            lualine_z = sections_option "";
          };
        }));
        default = null;
      };
      extensions = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        example = ''[ "fzf" ]'';
        description = "list of enabled extensions";
      };
    };
  };
  config =
    let
      processComponent = x: (if isAttrs x then processTableComponent else id) x;
      processTableComponent = { name, icons_enabled, icon, separator, extraConfig }: mergeAttrs
        {
          "@" = name;
          inherit icons_enabled icon separator;
        }
        extraConfig;
      processSections = sections: mapAttrs (_: mapNullable (map processComponent)) sections;
      setupOptions = {
        options = {
          theme = cfg.theme;
          section_separators = cfg.sectionSeparators;
          component_separators = cfg.componentSeparators;
          disabled_filetypes = cfg.disabledFiletypes;
          always_divide_middle = cfg.alwaysDivideMiddle;
        };

        sections = mapNullable processSections cfg.sections;
        tabline = mapNullable processSections cfg.tabline;
        extensions = cfg.extensions;
      };
    in
    mkIf cfg.enable {
      extraPlugins = [ pkgs.vimPlugins.lualine-nvim ];
      extraPackages = [ pkgs.git ];
      extraConfigLua =
        ''require("lualine").setup(${helpers.toLuaObject setupOptions})'';
    };
}
