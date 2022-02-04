syntax enable  
set number
set nowrap
set termguicolors
set encoding=UTF-8
set cursorline
set showtabline=2
set noshowmode
set laststatus=0 

call plug#begin()

Plug 'arcticicestudio/nord-vim'
Plug 'vim-airline/vim-airline'
Plug 'ryanoasis/vim-devicons'
Plug 'mhinz/vim-startify'
Plug 'preservim/nerdtree'

call plug#end()

"Plugin Nord config
let g:nord_cursor_line_number_background = 1
let g:nord_uniform_status_lines = 1
let g:nord_bold_vertical_split_line = 1
let g:nord_uniform_diff_background = 1
let g:nord_italic = 1
let g:nord_italic_comments = 1
let g:nord_underline = 1

"Theme
colorscheme nord

"Plugin Airline
let g:airline_theme='nord'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''
let g:airline_powerline_fonts = 1
let g:airline_left_sep = ''
let g:airline_right_sep = ''

"Plugin startify
let g:startify_custom_header = [
			\' ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
			\' ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
			\' ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
			\' ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
			\' ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
			\' ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
            \]
