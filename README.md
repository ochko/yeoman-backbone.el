### Install

Clone this repo:

```shell
$ cd ~/.emacs.d/vendor
$ git clone git://github.com/ochko/yeoman-backbone.el
```

In your emacs config:

```elisp
(add-to-list 'load-path "~/.emacs.d/vendor/yeoman-backbone.el")
(require 'yeoman-backbone)
```
### Usage

- yeoman-bb-open-...

   Opens desired source files

- yeoman-bb-open-spec-or-target

   Opens spec file if current buffer is sourse, otherwise source file
   of current spec. It assumes your specs are in same directory structure
   as app dir and has .spec.js extension.

It expects following directory structure by default, but you can customize
through `yeoman-backbone-jump-schema'.

```
   [-] app
    |-[-] scripts
    |  |-[+] controllers
    |  |-[+] helpers
    |  |-[+] models
    |  |-[+] routes
    |  |-[+] templates
    |  |-[-] views
    |  |  |-[-] components
    |  |  |  |-[+] widgets
   [-] test
    |-[-] specs
    |  |-[+] controllers
    |  |-[+] helpers
    |  |-[+] models
    |  |-[+] routes
    |  |-[+] views
    |  |  |-[-] components
    |  |  |  |-[+] assemblers
    |  |  |  |-[+] widgets
```

### Key bindings

`C-c y o` Open Collection
`C-c y c` Open Controller
`C-c y e` Open Error
`C-c y h` Open Helper
`C-c y x` Open Mixin
`C-c y m` Open Model
`C-c y n` Open Renderer
`C-c y r` Open Route
`C-c y S` Open Service
`C-c y t` Open Template
`C-c y i` Open Translation
`C-c y v` Open View
`C-c y p` Open Component
`C-c y w` Open Widget
`C-c y a` Open Assembler
`C-c y s` Open Sass
`C-c y k` Open Spec or target
