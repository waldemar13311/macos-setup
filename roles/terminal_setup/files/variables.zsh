# --- Переменные ---

# Оформление выделенной строки fzf. Общая настройка для fzf_options.zsh и
# zoxide_options.zsh - менять в одном месте:
#   --highlight-line        - закрашивать строку на всю ширину экрана
#   --color=... - оформление выделенной строки:
#     bg+ (238)         - фон (светло-серый)
#     fg+ (regular:253) - текст выделенной строки (почти белый)
#     hl+ (regular:197) - подсветка совпадений запроса в выделенной строке;
#     hl - та же подсветка в обычных строках - не переопределяем, остаётся
#     дефолтная.
#     query (regular:-1) - вводимый текст: -1 = дефолтный цвет терминала.
#     ВАЖНО: "regular:" обязателен перед цветом - указание одного цвета НЕ
#     сбрасывает атрибуты дефолтной схемы fzf (fg+, hl, hl+ и вводимый текст
#     query по умолчанию жирные), атрибут надо снимать явно
export FZF_HIGHLIGHT_LINE_OPTS='--highlight-line --color=bg+:238,fg+:regular:253,hl+:regular:197,query:regular:-1'

# Консольный редактор по умолчанию
export EDITOR="vim"

# Жирное выделение совпадений в grep: 01 - жирный, 91 - ярко-красный (bright red,
# заметнее обычного красного 31 и не зависит от настроек bold в терминале).
# Две переменные: GREP_COLORS - GNU grep (Ubuntu), GREP_COLOR - BSD grep (macOS)
export GREP_COLORS='ms=01;91'
export GREP_COLOR='01;91'

# LS_COLORS: системный дефолт macOS красит каталоги жирным (di=1;36), а эти
# цвета наследуют все инструменты, читающие LS_COLORS: fd, GNU ls, eza (как
# база под EZA_COLORS ниже - eza приоритетнее) и листинг автодополнения zsh
# (list-colors в .zshrc, иначе там жирный синий из GNU-дефолта). Жирность
# зарезервирована за grep, поэтому переопределяем только di на бирюзовый
# (96 = тот же цвет 36 без жирного), остальное не трогаем
export LS_COLORS='di=96:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# JQ_COLORS: jq по умолчанию красит массивы (1;39) и объекты/ключи (1;34)
# жирным. Порядок: null:false:true:числа:строки:массивы:объекты:ключи (в jq 1.7+
# ключи объектов красятся отдельным 8-м слотом, поэтому слотов 8, а не 7).
# 1 -> 0 (обычное начертание), цвета не трогаем
export JQ_COLORS='0;90:0;39:0;39:0;39:0;92:0;39:0;34:0;34'

# eza: без жирного начертания, но с родными цветами. Единого тумблера нет -
# перечисляем все ключи, у которых в дефолтной схеме eza стоит жирность (01),
# и задаём тот же цвет без неё (цвет 3X -> яркий 9X):
#   LS_COLORS выше уже красит каталоги в ярко-голубой (бирюзовый, di=96) -
#   здесь их не переопределяем; ex - исполняемые (1;32 -> 92),
#   uu/gu - свой пользователь/группа (жирный жёлтый 1;33 -> 93),
#   ur/uw/ux/ue - биты прав пользователя (r 1;33 -> 93, w 1;31 -> 91,
#   x у исполняемых файлов 1;4;32 -> 4;92, у каталогов 1;32 -> 92),
#   df - major ID устройства в размере (1;32 -> 92; minor ID ds в дефолте
#   обычный 32), mp - mount point (1;4;34 -> 4;94),
#   xx - пунктуация: дефисы "-" в колонке прав и стрелка "->" симлинка
#   (жирный серый 1;90 -> 90).
# un/gn/uR - чужие и root-пользователь/группа - в дефолтной схеме бесцветны,
# не переопределяем.
# Ключи с glob'ами (*.py, Dockerfile и т.д.) - дефолтная схема eza красит
# жирным исходники кода (01;33 -> 93), сертификаты/ключи (01;32 -> 92),
# видео (01;35 -> 95), аудио (01;36 -> 96) и спец-имена файлов
# (01;4;33 -> 4;93, жёлтый с подчёркиванием: Dockerfile, Makefile, README,
# pyproject.toml, Cargo.toml, package.json, ...). Список получен
# тестированием: создавались файлы каждого типа и проверялся ANSI-вывод eza.
# ВАЖНО: матчинг чувствителен к регистру (*.py не ловит TEST.PY), поэтому
# расширения указаны в обоих регистрах. *.md/*.toml не переопределяем - в
# дефолтной теме они бесцветны, а жёлтыми с подчёркиванием были только
# точные имена README.md и pyproject.toml (возвращены в группе имён ниже).
# Цвета - яркая половина ANSI-палитры (90-97: жёлтый=93, зелёный=92, ...)
# вместо обычных 30-37: раньше яркость компенсировала жирность, которую мы
# везде убрали. Подчёркивание (4) у спец-имён сохранено.
# EZA_COLORS переопределяет только перечисленные ключи, остальная схема
# не трогает. Коды ANSI: 01 - жирный, 4 - подчёркивание, просто цвет -
# обычное начертание
export EZA_COLORS='ex=92:uu=93:gu=93:ur=93:uw=91:ux=4;92:ue=92:df=92:mp=4;94:xx=90'
export EZA_COLORS="${EZA_COLORS}:*.c=93:*.C=93:*.cc=93:*.CC=93:*.clj=93:*.CLJ=93:*.cpp=93:*.CPP=93"
export EZA_COLORS="${EZA_COLORS}:*.cs=93:*.CS=93:*.css=93:*.CSS=93:*.dart=93:*.DART=93:*.elm=93:*.ELM=93"
export EZA_COLORS="${EZA_COLORS}:*.erl=93:*.ERL=93:*.ex=93:*.EX=93:*.exs=93:*.EXS=93:*.f=93:*.F=93"
export EZA_COLORS="${EZA_COLORS}:*.f90=93:*.F90=93:*.fs=93:*.FS=93:*.go=93:*.GO=93:*.gradle=93:*.GRADLE=93"
export EZA_COLORS="${EZA_COLORS}:*.groovy=93:*.GROOVY=93:*.awk=93:*.AWK=93:*.h=93:*.H=93:*.hpp=93:*.HPP=93"
export EZA_COLORS="${EZA_COLORS}:*.hs=93:*.HS=93:*.ipynb=93:*.IPYNB=93"
export EZA_COLORS="${EZA_COLORS}:*.java=93:*.JAVA=93:*.jl=93:*.JL=93:*.js=93:*.JS=93:*.jsx=93:*.JSX=93"
export EZA_COLORS="${EZA_COLORS}:*.kt=93:*.KT=93:*.lua=93:*.LUA=93:*.m=93:*.M=93:*.ml=93:*.ML=93"
export EZA_COLORS="${EZA_COLORS}:*.pas=93:*.PAS=93:*.php=93:*.PHP=93:*.pl=93:*.PL=93:*.pp=93:*.PP=93"
export EZA_COLORS="${EZA_COLORS}:*.ps1=93:*.PS1=93:*.py=93:*.PY=93:*.r=93:*.R=93:*.rb=93:*.RB=93"
export EZA_COLORS="${EZA_COLORS}:*.rs=93:*.RS=93:*.scm=93:*.SCM=93:*.scss=93:*.SCSS=93:*.sql=93:*.SQL=93"
export EZA_COLORS="${EZA_COLORS}:*.swift=93:*.SWIFT=93:*.tex=93:*.TEX=93:*.ts=93:*.TS=93:*.v=93:*.V=93"
export EZA_COLORS="${EZA_COLORS}:*.vb=93:*.VB=93:*.zig=93:*.ZIG=93:*.cer=92:*.CER=92:*.crt=92:*.CRT=92"
export EZA_COLORS="${EZA_COLORS}:*.p12=92:*.P12=92:*.pem=92:*.PEM=92:*.pfx=92:*.PFX=92:*.pub=92:*.PUB=92"
export EZA_COLORS="${EZA_COLORS}:*.avi=95:*.AVI=95:*.mkv=95:*.MKV=95:*.mov=95:*.MOV=95:*.mp4=95:*.MP4=95"
export EZA_COLORS="${EZA_COLORS}:*.webm=95:*.WEBM=95:*.wmv=95:*.WMV=95:*.flac=96:*.FLAC=96:*.wav=96:*.WAV=96"
export EZA_COLORS="${EZA_COLORS}:Dockerfile=4;93:Makefile=4;93:makefile=4;93:GNUmakefile=4;93:CMakeLists.txt=4;93:Containerfile=4;93:Gemfile=4;93:Justfile=4;93"
export EZA_COLORS="${EZA_COLORS}:Procfile=4;93:Rakefile=4;93:README=4;93:README.md=4;93:Cargo.toml=4;93:package.json=4;93:pyproject.toml=4;93:Brewfile=4;93"
export EZA_COLORS="${EZA_COLORS}:PKGBUILD=4;93:Vagrantfile=4;93:BUILD=4;93:BUILD.bazel=4;93:WORKSPACE=4;93:meson.build=4;93:mix.exs=4;93:configure=4;93"
# ssh-ключи: точные имена, в дефолтной теме жирный зелёный (01;32 -> 92);
# их *.pub-пары ловятся glob'ом *.pub выше
export EZA_COLORS="${EZA_COLORS}:id_rsa=92:id_ed25519=92:id_ecdsa=92:id_dsa=92"
# исходники кода (D, Scala, Lisp, Shader и т.д.): было 01;33
export EZA_COLORS="${EZA_COLORS}:*.AS=93:*.ASA=93:*.C++=93:*.C++M=93:*.CABAL=93:*.CCM=93:*.CP=93:*.CPPM=93"
export EZA_COLORS="${EZA_COLORS}:*.CR=93:*.CSX=93:*.CU=93:*.CXX=93:*.CXXM=93:*.CYPHER=93:*.D=93:*.DI=93"
export EZA_COLORS="${EZA_COLORS}:*.DPR=93:*.EL=93:*.FCMACRO=93:*.FCSCRIPT=93:*.FNL=93:*.FOR=93:*.FSH=93:*.FSI=93"
export EZA_COLORS="${EZA_COLORS}:*.FSX=93:*.GD=93:*.GVY=93:*.H++=93:*.HC=93:*.HH=93:*.HTC=93:*.HXX=93"
export EZA_COLORS="${EZA_COLORS}:*.INC=93:*.INL=93:*.INO=93:*.IXX=93:*.KTS=93:*.KUSTO=93:*.LESS=93:*.LHS=93"
export EZA_COLORS="${EZA_COLORS}:*.LISP=93:*.LTX=93:*.MALLOY=93:*.MATLAB=93:*.MLI=93:*.MN=93:*.NB=93:*.P=93"
export EZA_COLORS="${EZA_COLORS}:*.PM=93:*.POD=93:*.PRQL=93:*.PSD1=93:*.PSM1=93:*.PURS=93:*.RQ=93:*.SASS=93"
export EZA_COLORS="${EZA_COLORS}:*.SCAD=93:*.SCALA=93:*.SLD=93:*.SS=93:*.TCL=93:*.VSH=93:*.as=93:*.asa=93"
export EZA_COLORS="${EZA_COLORS}:*.c++=93:*.c++m=93:*.cabal=93:*.ccm=93:*.cp=93:*.cppm=93:*.cr=93:*.csx=93"
export EZA_COLORS="${EZA_COLORS}:*.cu=93:*.cxx=93:*.cxxm=93:*.cypher=93:*.d=93:*.di=93:*.dpr=93:*.el=93"
export EZA_COLORS="${EZA_COLORS}:*.fcmacro=93:*.fcscript=93:*.fnl=93:*.for=93:*.fsh=93:*.fsi=93:*.fsx=93:*.gd=93"
export EZA_COLORS="${EZA_COLORS}:*.gvy=93:*.h++=93:*.hc=93:*.hh=93:*.htc=93:*.hxx=93:*.inc=93:*.inl=93"
export EZA_COLORS="${EZA_COLORS}:*.ino=93:*.ixx=93:*.kts=93:*.kusto=93:*.less=93:*.lhs=93:*.lisp=93:*.ltx=93"
export EZA_COLORS="${EZA_COLORS}:*.malloy=93:*.matlab=93:*.mli=93:*.mn=93:*.nb=93:*.p=93:*.pm=93:*.pod=93"
export EZA_COLORS="${EZA_COLORS}:*.prql=93:*.psd1=93:*.psm1=93:*.purs=93:*.rq=93:*.sass=93:*.scad=93:*.scala=93"
export EZA_COLORS="${EZA_COLORS}:*.sld=93:*.ss=93:*.tcl=93:*.vsh=93"

# сертификаты/ключи и контрольные суммы: было 01;32
export EZA_COLORS="${EZA_COLORS}:*.AGE=92:*.ASC=92:*.CSR=92:*.GPG=92:*.KBX=92:*.MD5=92:*.PGP=92:*.SHA1=92"
export EZA_COLORS="${EZA_COLORS}:*.SHA224=92:*.SHA256=92:*.SHA384=92:*.SHA512=92:*.SIG=92:*.SIGNATURE=92:*.age=92:*.asc=92"
export EZA_COLORS="${EZA_COLORS}:*.csr=92:*.gpg=92:*.kbx=92:*.md5=92:*.pgp=92:*.sha1=92:*.sha224=92:*.sha256=92"
export EZA_COLORS="${EZA_COLORS}:*.sha384=92:*.sha512=92:*.sig=92:*.signature=92:id_ecdsa_sk=92:id_ed25519_sk=92"

# видео: было 01;35
export EZA_COLORS="${EZA_COLORS}:*.FLV=95:*.H264=95:*.HEICS=95:*.M2TS=95:*.M2V=95:*.M4V=95:*.MPEG=95:*.MPG=95"
export EZA_COLORS="${EZA_COLORS}:*.OGM=95:*.OGV=95:*.VIDEO=95:*.VOB=95:*.flv=95:*.h264=95:*.heics=95:*.m2ts=95"
export EZA_COLORS="${EZA_COLORS}:*.m2v=95:*.m4v=95:*.mpeg=95:*.mpg=95:*.ogm=95:*.ogv=95:*.video=95:*.vob=95"

# аудио (lossless): было 01;36
export EZA_COLORS="${EZA_COLORS}:*.AIF=96:*.AIFC=96:*.AIFF=96:*.ALAC=96:*.APE=96:*.PCM=96:*.WV=96:*.aif=96"
export EZA_COLORS="${EZA_COLORS}:*.aifc=96:*.aiff=96:*.alac=96:*.ape=96:*.pcm=96:*.wv=96"

# build-файлы: было 01;4;33
export EZA_COLORS="${EZA_COLORS}:*.NINJA=4;93:*.ninja=4;93:Earthfile=4;93:Gruntfile.coffee=4;93:Pipfile=4;93:Podfile=4;93:SConstruct=4;93:bsconfig.json=4;93"
export EZA_COLORS="${EZA_COLORS}:build.sbt=4;93:build.xml=4;93:composer.json=4;93:flake.nix=4;93:jsconfig.json=4;93:pom.xml=4;93:tsconfig.json=4;93:webpack.config.cjs=4;93"

# Исполняемые файлы пользователя
export PATH="$HOME/.local/bin:$PATH"
# curl из homebrew, так как стандартный mac-овский не удобный
# /opt/homebrew - на Apple Silicon,
# /usr/local - на Intel Mac
if [[ -d "/opt/homebrew/opt/curl/bin" ]]; then
    export PATH="/opt/homebrew/opt/curl/bin:$PATH"
elif [[ -d "/usr/local/opt/curl/bin" ]]; then
    export PATH="/usr/local/opt/curl/bin:$PATH"
fi

# Зеркала для tenv
export TENV_TERRAFORM_REMOTE="https://hashicorp-releases.yandexcloud.net"
export TENV_OPENTOFU_REMOTE="https://github.com/opentofu/opentofu/releases/download"

setopt NOBEEP               # Убрать звуки терминала
setopt NUMERIC_GLOB_SORT    # Умная сортировка файлов с цифрами (file10 после file9, не после file1)
