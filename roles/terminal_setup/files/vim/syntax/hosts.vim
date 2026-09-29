" Vim syntax file
" Language:   /etc/hosts
" Назначение: подсветка hosts-файла, аналогичная bat (тема Monokai Extended).
" Из коробки vim не имеет синтаксиса для /etc/hosts: он детектит filetype=conf,
" который красит только комментарии. Этот файл добавляет подсветку IP-адресов,
" имен хостов и lo/loopback-маркеров.
" Подключение: через autocmd в .vimrc (см. ftplugin-строку ниже) или вручную :set syntax=hosts
" Цвета совпадают с unokai/Monokai Extended: IP - cyan #66d9ef, имена - жёлтый #e6db74

" Не перезагружаемся, если синтаксис уже активен
if exists("b:current_syntax")
  finish
endif

" Комментарии: строки целиком начинающиеся с # (красит их и "хвостовые" комментарии)
syn match hostsComment "^#.*$" contains=hostsTodo
syn keyword hostsTodo contained TODO FIXME XXX NOTE

" Имена хостов: всё остальное в строке (включая FQDN и алиасы).
" ВАЖНО: объявлен ДО hostsIP - в vim при совпадении в одной позиции выигрывает
" объявленный позже, и hostsIP за счёт этого побеждает hostsHost на IP-адресах
syn match hostsHost "\v<([a-zA-Z0-9_-]+\.)*[a-zA-Z0-9_-]+>" contains=hostsSpecial

" IP-адрес: IPv4 (упрощённо - 4 октета) и IPv6 (упрощённо - группы с двоеточиями).
" Нюанс: в double-quoted строке vim-скрипта надо писать \v<..., а не \v\<... -
" во втором случае граница слова не срабатывает (проверено на практике)
syn match hostsIP "\v<(\d{1,3}\.){3}\d{1,3}>"
syn match hostsIP "\v\x{1,4}:(\x{1,4}::?){1,7}\x{0,4}"

" Спец-имена loopback
syn keyword hostsSpecial contained localhost broadcasthost localhost.localdomain

" Подключаем общие вещи из conf.vim (строки, TODO и т.п.) - как это делают
" системные syntax-файлы вроде hostsaccess.vim
runtime! syntax/conf.vim
unlet b:current_syntax

" Привязка групп к цветам: аналог hi def link, но с явными цветами Monokai Extended,
" чтобы совпасть с bat (и не зависеть от темы: bat красит hosts своими цветами всегда)
if !exists("g:loaded_hosts_syntax_colors")
  hi def hostsIP        guifg=#66d9ef ctermfg=81
  hi def hostsHost      guifg=#e6db74 ctermfg=185
  hi def hostsSpecial   guifg=#fd971f ctermfg=208
endif

let b:current_syntax = "hosts"
" vim: ts=8 sw=2
