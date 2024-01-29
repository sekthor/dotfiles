# dotfiles

## neovim

config only works with neovim `0.9.x`.

install neovim the tar.gz way.

```sh
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
tar xzvf nvim-linux64.tar.gz
sudo cp -r nvim-linux64 /usr/local/bin
sudo ln -s /usr/local/bin/nvim-linux64/bin/nvim /usr/local/bin/nvim
sudo ln -s /usr/local/bin/nvim-linux64/bin/nvim /usr/local/bin/vim
```

```sh
export VIMRUNTIME=/usr/local/bin/nvim-linux64/share/nvim/runtime
```

use the dotfiles


```sh
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
cp -r ./.config/nvim ~/.config
vim ~/.config/nvim/lua/sekthor/packer.lua
# :so
# :PackerSync
```
