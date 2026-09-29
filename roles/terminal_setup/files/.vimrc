" Цвета в 24-bit (true color). COLORTERM=truecolor выставляют сами терминалы
" с поддержкой 24-bit (iTerm2 >=3.4, VS Code). Terminal.app 24-bit не рисует и
" COLORTERM не задаёт: там guifg-цвета выродились бы в грязную 256-палитру
" (проверено printf-тестом), поэтому гейтимся на COLORTERM - без него vim
" работает через cterm-цвета темы (приближённо, но читаемо).
" ВАЖНО: termguicolors должен быть установлен ДО syntax on и colorscheme -
" если включить подсветку раньше, первый символ экрана отрисовывается со старыми
" атрибутами и не перекрашивается до полного redraw (лечилось toggling'ом set nu)
if $COLORTERM ==# 'truecolor' || $COLORTERM ==# '24bit'
  set termguicolors
endif

" XDG-каталог конфигурации в runtimepath: vim сам ищет в нём только vimrc,
" а ftdetect/, syntax/ и colors/ читает из ~/.vim. Без этой строки наши
" ftdetect/hosts.vim и syntax/hosts.vim просто не подхватятся.
" ВАЖНО: строки rtp и filetype идут в начале - если включить подсветку (syntax on)
" раньше, чем сработает filetype-детект, синтаксис буфера фиксируется неверно
" (проверено: ftdetect перестаёт переключать syntax)
set runtimepath^=$HOME/.config/vim

filetype plugin indent on

" Подсветка /etc/hosts и подобных файлов - см. ftdetect/hosts.vim и syntax/hosts.vim.
" Цвета подобраны под bat (Monokai Extended), чтобы cat и vim выглядели одинаково

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

" Тема unokai - Monokai-подобная схема из комплекта vim 9.2.
" Выбрана под bat (алиас cat): bat по умолчанию использует тему Monokai Extended,
" у unokai та же палитра (fg #f8f8f2, комментарии серо-оливковые, строки жёлтые и т.д.),
" поэтому вывод cat и vim смотрятся единообразно
colorscheme unokai

" Дотюнивание палитры unokai под bat (Monokai Extended): базовые цвета (строки,
" комментарии, keywords, константы, функции) и так совпадают, а вот "ключевые"
" группы разных форматов vim связывает не с теми базовыми категориями, чем bat:
"   ключи yaml/ini/toml   - vim: Identifier/Type (cyan/оранжевый), bat: розовый #f92672
"   заголовки секций ini  - vim: Special (бирюзовый), bat: зелёный #a6e22e
" Переопределяем сами syntax-группы форматов (не базовые!) - ссылки остальных
" групп подтянутся за ними. hi! link должен сработать ПОСЛЕ загрузки syntax-файла,
" поэтому вешаемся на событие Syntax
augroup vimrc_bat_palette
  autocmd!
  " markdown: fenced-блоки с указанием языка (```bash, ```yaml и т.д.) красим вложенным
  " синтаксисом этого языка - как это делает bat. Список языков должен быть задан ДО
  " загрузки syntax/markdown.vim, поэтому переменная задаётся здесь, а не в augroup.
  " Список по необходимости расширяйте: 'python', 'java' и т.д.
  let g:markdown_fenced_languages = ['bash', 'sh', 'yaml', 'python', 'json', 'go', 'sql', 'java', 'toml', 'ini=dosini', 'css', 'html', 'terraform', 'dockerfile']
  autocmd Syntax yaml      hi! link yamlMappingKey Statement
  autocmd Syntax dosini    hi! link dosiniHeader Function | hi! link dosiniLabel Statement
  autocmd Syntax toml      hi! link tomlTable Function | hi! link tomlTableArray Function
  autocmd Syntax toml      hi! link tomlKey Statement | hi! link tomlKeySq Statement | hi! link tomlKeyDq Statement
  autocmd Syntax gitconfig hi! link gitconfigSection Function | hi! link gitconfigVariable Statement
  " cfg (ansible.cfg и т.п.): секции - зелёным. Встроенный CfgParams подсвечивает
  " только '=' (его паттерн '.\{0}=' с me=e-1 даёт нулевую длину и не красит ключи),
  " поэтому добавляем свой паттерн для ключей до '=' и красим как в bat
  autocmd Syntax cfg syn match CfgKey "^\s*[a-zA-Z0-9_.-]\+\s*[=:{]"me=e-1 containedin=ALLBUT,cfgComment
  autocmd Syntax cfg hi! link CfgKey Statement
  autocmd Syntax cfg hi! link CfgSection Function
  " markdown (README.md): заголовки в bat - оранжевый #fd971f; в vim H1/H2 идут в htmlH1 -> Title,
  " у unokai Title без цвета (только bold). Красим в Type (оранжевый).
  " Решётки ###/# - markdownHeadingDelimiter -> Delimiter -> PreProc (#f92672 красный у unokai),
  " в bat они тоже оранжевые - линкуем туда же. ВАЖНО: markdownH1Delimiter связан с
  " HeadingDelimiter через hi def link в markdown.vim, поэтому меняем HeadingDelimiter -
  " все Delimiter-ы заголовков подтянутся
  autocmd Syntax markdown hi! link markdownH1 Type | hi! link markdownH2 Type | hi! link markdownH3 Type
  autocmd Syntax markdown hi! link markdownH4 Type | hi! link markdownH5 Type | hi! link markdownH6 Type
  " Решётки ##/#: unokai раскрашивает H1..H6Delimiter радугой (H1 - красный, H2 - жёлтый...),
  " в bat решётка всегда того же цвета, что и заголовок - оранжевая. Перекрываем все
  " (hi def link в markdown.vim линкует H*Delimiter на HeadingDelimiter, но unokai
  " задаёт для них ЯВНЫЕ цвета, поэтому перекрываем каждую отдельно)
  autocmd Syntax markdown hi! link markdownH1Delimiter Type | hi! link markdownH2Delimiter Type | hi! link markdownH3Delimiter Type
  autocmd Syntax markdown hi! link markdownH4Delimiter Type | hi! link markdownH5Delimiter Type | hi! link markdownH6Delimiter Type
  autocmd Syntax markdown hi! link markdownHeadingDelimiter Type
  " inline-код (`hosts: all`) в bat - красный #ec3533 (vim красит markdownCode серым Comment)
  autocmd Syntax markdown hi markdownCode guifg=#ec3533 ctermfg=203
  " внутри markdown-блоков sh/bash shOption получает дефолтный link из syn include -
  " переопределяем тут же (событие Syntax буфера = markdown, не sh/bash)
  autocmd Syntax markdown hi! link shOption Type
  " json: ключи в bat - оранжевый #fd971f; vim красит jsonKeyword жёлтым (String)
  autocmd Syntax json      hi! link jsonKeyword Type
  " terraform/hcl: слова объявлений (resource, variable, module) в bat - cyan;
  " vim красит hclBlockType оранжевым. Скобки блоков в bat белые
  autocmd Syntax terraform hi! link hclBlockType Identifier
  autocmd Syntax terraform hi! link hclBraces Normal
  " yaml: двоеточие после ключа в bat - белым (в vim - бирюзовый Special)
  autocmd Syntax yaml      hi! link yamlBlockMappingDelimiter Normal
  autocmd Syntax yaml      hi! link yamlFlowMappingDelimiter Normal
  " java: слова class/interface/enum в bat - cyan (vim красит javaClassDecl розовым);
  " аннотации @Override в bat белым (vim - розовым)
  autocmd Syntax java      hi! link javaClassDecl Identifier
  autocmd Syntax java      hi! link javaAnnotation Normal
  " sql: FROM/AS/GROUP BY и пр. в bat розовым (vim - бирюзовый sqlKeyword);
  " функции COUNT/SUM - cyan (vim - зелёный sqlFunction)
  autocmd Syntax sql       hi! link sqlKeyword Statement
  autocmd Syntax sql       hi! link sqlFunction Identifier
  " go: func в bat - cyan (vim - розовый goDeclaration)
  autocmd Syntax go        hi! link goDeclaration Identifier
  " python: встроенные функции (print, len, str) в bat - cyan (vim - зелёный pythonBuiltin)
  autocmd Syntax python    hi! link pythonBuiltin Identifier
  " shell: флаги (--limit, -la) в bat - оранжевый #fd971f (vim - бирюзовый shOption)
  autocmd Syntax sh        hi! link shOption Type
  autocmd Syntax bash      hi! link shOption Type
  " html: скобки <> в bat белые (vim красит htmlTag зелёным); имена тегов уже розовые
  autocmd Syntax html      hi! link htmlTag Normal
  " css: фигурные скобки в bat белые (vim - зелёные)
  autocmd Syntax css       hi! link cssBraces Normal
  " make: команды рецептов в bat белым (vim красит фиолетовым makeCommands); target уже зелёный
  autocmd Syntax make      hi! link makeCommands Normal
  " nginx: блоки (server, location, http) в bat - cyan (vim - розовый);
  " директивы (listen, proxy_pass и пр.) в bat - розовым (vim - оранжевый/зелёный)
  autocmd Syntax nginx     hi! link ngxDirectiveBlock Identifier
  autocmd Syntax nginx     hi! link ngxDirectiveImportant Statement
  autocmd Syntax nginx     hi! link ngxDirective Statement
augroup END

" Форс-перерисовка ПОСЛЕ первого кадра экрана: vim оптимизирует отрисовку и
" иногда не перекрашивает первый символ строки, у которой сменился цвет
" (симптом лечился toggling'ом set nu - это тоже полный redraw).
" redrew в BufWinEnter не помогал: он срабатывает ДО первого кадра.
" Таймер (даже с малой задержкой) исполняется в event-loop уже после отрисовки
" экрана, поэтому redraw! гарантированно перекрашивает всё
autocmd BufWinEnter * call timer_start(10, {-> execute('redraw!')})

set encoding=utf8
