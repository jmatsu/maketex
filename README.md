maketex
=======

TeX file control script on OSX. (with pLaTeX)

### Features

+ generate pdf file and open it.
+ convert *.png or *.pdf to *.eps, if the files is in figures/. 
+ use suitable options for tex encoding.
+ remove \newblock from bbl file. 

### How to use

#### Ready

+ In your shell)
+ export PATH=$PATH:${path/to/this}

+ In your sublime)
+ PATH=${path/to/this}:${YOUR_PATH}

+ Directory structures)
+ path/to/main.tex/) main.tex figures/ *.sty *.cls
+ figures/) *.png *.pdf *.eps

#### Command
     maketex ${main file(.tex)}
     '.tex' is not required.

#### Caution
     This script couldn't handle relative path to main tex file. 