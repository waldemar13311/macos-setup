" /etc/hosts и подобные файлы: назначаем наш синтаксис (см. syntax/hosts.vim).
" Из коробки vim не имеет синтаксиса для /etc/hosts - он определяет filetype=conf,
" который подсвечивает только комментарии. Цвета в syntax/hosts.vim подобраны
" под bat (Monokai Extended), чтобы cat и vim выглядели одинаково
autocmd BufNewFile,BufRead *hosts setlocal filetype=hosts
