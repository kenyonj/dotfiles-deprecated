" Default colors
set background=dark
colorscheme base16-solarized

" Show currentline as red
hi CursorLineNr ctermfg=1

" Tomorrow-Night bg fix
if has("gui_running")
  hi Normal ctermbg=none
endif