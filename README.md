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

- `C-c f o` Open Collection
- `C-c f c` Open Controller
- `C-c f e` Open Error
- `C-c f h` Open Helper
- `C-c f x` Open Mixin
- `C-c f m` Open Model
- `C-c f n` Open Renderer
- `C-c f r` Open Route
- `C-c f S` Open Service
- `C-c f t` Open Template
- `C-c f i` Open Translation
- `C-c f v` Open View
- `C-c f p` Open Component
- `C-c f w` Open Widget
- `C-c f a` Open Assembler
- `C-c f s` Open Sass
- `C-c f k` Open Spec or target
