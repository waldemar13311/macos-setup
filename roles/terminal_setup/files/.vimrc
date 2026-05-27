" Перенаправляем временные файлы Vim в XDG Cache, чтобы не мусорить
set directory=$HOME/.cache/vim/swap//
set backupdir=$HOME/.cache/vim/backup//
set undodir=$HOME/.cache/vim/undo//

" Настройки отступов
set expandtab
set smarttab

" Используем 2 пробела по умолчанию
set tabstop=2
set softtabstop=2
set shiftwidth=2

" для Python принудительно ставим 4 пробела
autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4

" Включить нумерацию строк
set number

" Включить подцветку синтаксиса
syntax on

filetype plugin indent on

set encoding=utf8
