let
  indent = 2;
in
{
  globals.mapleader = " ";

  opts = {
    number = true;
    relativenumber = true;
    mouse = "a";
    encoding = "utf8";
    termguicolors = true;
    clipboard = "unnamedplus";

    # indentation
    tabstop = indent;
    shiftwidth = indent;
    expandtab = true;
    smarttab = true;
    smartindent = true;

    # ui
    cursorline = true;
    signcolumn = "yes";
    wrap = false;
    laststatus = 2;
    showmode = false;

    # search
    ignorecase = true;
    smartcase = true;
    hlsearch = true;
    incsearch = true;

    # splits
    splitbelow = true;
    splitright = true;

    # misc
    scrolloff = 8;
    sidescrolloff = 8;
    updatetime = 250;
    timeoutlen = 300;
    backup = false;
    swapfile = false;
    undofile = true;
  };
}
