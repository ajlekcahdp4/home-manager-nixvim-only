{
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    inputs.stylix.homeManagerModules.stylix
    inputs.nixvim.homeManagerModules.nixvim
  ];

  stylix = {
    autoEnable = true;
    image = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/2y/wallhaven-2y2wg6.png";
      sha256 = "sha256-nFoNfk7Y/CGKWtscOE5GOxshI5eFmppWvhxHzOJ6mCA=";
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    targets = {
      nixvim.enable = true;
      nixvim.transparent_bg.main = true;
      nixvim.transparent_bg.sign_column = true;
    };
  };

  programs.nixvim = {
    enable = true;
    enableMan = true;
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        showBufferEnd = true;
        dimInactive = {
          enabled = true;
          percentage = 0.15;
          shade = "dark";
        };
        styles = {
          comments = ["italic"];
        };
        transparentBackground = true;
      };
    };

    vimAlias = true;

    opts = {
      number = true;
      shiftwidth = 2;
      expandtab = true;
      smartcase = true;
      tabstop = 2;
      smartindent = true;
      cursorline = true;
      colorcolumn = "80";
    };
    plugins.luasnip.enable = true;
    plugins.lsp = {
      enable = true;
      servers = {
        clangd = {
          enable = true;
          autostart = true;
          package = pkgs.clang-tools_18;
        };
        nixd = {
          enable = true;
          autostart = true;
        };
      };
      keymaps.lspBuf = {
        gD = "references";
        gd = "definition";
        gi = "implementation";
        gt = "type_definition";
      };
    };
    plugins.cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        snippet.expand = ''
          function(args)
            require('luasnip').lsp_expand(args.body)
          end
        '';
        sources = [{name = "nvim_lsp";}];
      };
    };
    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>fg" = "live_grep";
        "<leader>ff" = "find_files";
        "<leader>fh" = "help_tags";
        "<leader>fb" = "buffers";
      };
    };
    plugins.airline = {
      enable = true;
    };
    extraConfigVim = ''
      let g:airline#extensions#tabline#enabled = 1
      let g:airline_powerline_fonts = 1
      set mouse=""
    '';
    extraConfigLua = ''
      local cmp = require'cmp'
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
         ['<C-b>'] = cmp.mapping.scroll_docs(-4),
         ['<C-f>'] = cmp.mapping.scroll_docs(4),
         ['<C-Space>'] = cmp.mapping.complete(),
         ['<C-e>'] = cmp.mapping.abort(),
         ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        })
      })
    '';
  };

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
