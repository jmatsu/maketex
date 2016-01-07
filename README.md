maketex
=======

TeX file control script for OSX. (with pLaTeX)

### Features

+ generate pdf file and open it.
+ convert *.png or *.pdf to *.eps, if the files is in figures/. 
+ use suitable options for tex encoding.
+ remove \newblock from bbl file. 

### How to use

#### Ready

In your shell)
  
  export PATH=$PATH:${path/to/this}
  or
  cp -a ./maketex /your/PATH/
  cp -a ./geneps /your/PATH/

In your sublime)

  PATH=${path/to/this}:${YOUR_PATH}

### Assumed Directory structures)

+ path/to/main.tex/ 
  - main.tex
  - figures/
    *  *.png *.pdf *.eps
  - *.sty
  - *.cls

#### Command

     maketex ${main file(.tex)}

#### Caution
     This script couldn't handle relative path to main tex file. 