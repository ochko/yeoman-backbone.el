;;; yeoman-backbone.el Navigate yeoman backbone in Emacs

;; Copyright (c) 2014 Lkhagva Ochirkhuyag <ochkoo@gmail.com>

;; Author: Lkhagva Ochirkhuyag <ochkoo@gmail.com>
;; URL: https://github.com/ochko/mac-app-binding.el
;; Keywords: mac applescript
;; Created: 24 Dec 2013
;; Version: 1.0.0
;; Package-Requires: ((org))

;; This file is NOT part of GNU Emacs.

;;; Commentary:

;; Inspired by rinari, rspec-mode and ember-mode yeoman-backbone helps you
;; navigate directory structure quickly.
;;
;; 1) yeoman-bb-open-...
;;
;;    Opens desired source files
;;
;; 2) yeoman-bb-open-spec-or-target
;;
;;    Opens spec file if current buffer is sourse, otherwise source file
;;    of current spec. It assumes your specs are in same directory structure
;;    as app dir and has .spec.js extension.
;;
;; It expects following directory structure by default, but you can customize
;; through `yeoman-backbone-jump-schema'.
;;
;;    [-] app
;;     |-[-] scripts
;;     |  |-[+] controllers
;;     |  |-[+] helpers
;;     |  |-[+] models
;;     |  |-[+] routes
;;     |  |-[+] templates
;;     |  |-[-] views
;;     |  |  |-[-] components
;;     |  |  |  |-[+] widgets
;;    [-] test
;;     |-[-] specs
;;     |  |-[+] controllers
;;     |  |-[+] helpers
;;     |  |-[+] models
;;     |  |-[+] routes
;;     |  |-[+] views
;;     |  |  |-[-] components
;;     |  |  |  |-[+] assemblers
;;     |  |  |  |-[+] widgets

;;; Install

;; $ cd ~/.emacs.d/vendor
;; $ git clone git://github.com/ochko/yeoman-backbone.el
;;
;; In your emacs config:
;;
;; (add-to-list 'load-path "~/.emacs.d/vendor/yeoman-backbone.el")
;; (require 'yeoman-backbone)

;;; Code:
(require 'cl)

(defgroup yeoman-backbone nil
  "yeoman-bb-mode customizations."
  :prefix "yeoman-backbone-")

;;;;;;;;;;;;;;;;;;;;
;;; General Settings
(defcustom yeoman-project-root
  nil
  "Yeoman project root directory."
  :group 'yeoman-backbone)

(defcustom yeoman-project-root-anchor
  "Gruntfile.js"
  "Filename used for detecting project root directory."
  :group 'yeoman-backbone)

(defcustom yeoman-backbone-jump-schema
  '(
    ("collection"  . "app/scripts/collections/\\1.js")
    ("controller"  . "app/scripts/controllers/\\1Controller.js")
    ("error"       . "app/scripts/errors/\\1.js")
    ("helper"      . "app/scripts/helpers/\\1.js")
    ("mixin"       . "app/scripts/mixins/\\1.js")
    ("model"       . "app/scripts/models/\\1.js")
    ("renderer"    . "app/scripts/renderers/\\1Renderer.js")
    ("route"       . "app/scripts/routes/\\1.js")
    ("service"     . "app/scripts/services/\\1.js")
    ("template"    . "app/scripts/templates/\\1.js")
    ("translation" . "app/scripts/translations/\\1.js")
    ("view"        . "app/scripts/views/\\1View.js")
    ("component"   . "app/scripts/views/components/\\1.js")
    ("widget"      . "app/scripts/views/components/widgets/\\1Control.js")
    ("assembler"   . "app/scripts/views/components/assemblers/\\1Control.js")
    ("sass"        . "app/styles/sass/\\1.scss")
    )
  "Project directory structure used for finding files."
  :type '(repeat (string . string))
  :group 'yeoman-backbone)

;;;;;;;;;;;;
;;;; plurals

(defcustom yeoman-irregular-nouns
  '(("child" . "children") ("woman" . "women") ("man" . "men") ("mouse" . "mice") ("goose" . "geese"))
  "Contain irregular pluralizations which yeoman-bb-mode considers."
  :type '(alist :key-type string :value-type string)
  :group 'yeoman-backbone)

(defun yeoman--pluralize-noun (noun)
  "Pluralizes NOUN."
  (save-match-data
    (cond ((find noun yeoman-irregular-nouns :key #'car :test #'string=)
           (cdr (find noun yeoman-irregular-nouns :key #'car :test #'string=)))
          ((string-match-p "[yo]$" noun)
           (message "Don't know how to translate %s" noun)
           noun)
          ((or (string-match "ch$" noun)
               (string-match "[xs]$" noun))
           (concat noun "es"))
          ((string-match "^\\(.*\\)fe?$" noun)
           (concat (match-string 1 noun) "ves"))
          (t (concat noun "s")))))

(defun yeoman--singularize-noun (noun)
  "Singularizes NOUN."
  (save-match-data
    (cond ((find noun yeoman-irregular-nouns :key #'cdr :test #'string=)
           (car (find noun yeoman-irregular-nouns :key #'cdr :test #'string=)))
          ((string-match "^\\(.*ch\\)es$" noun)
           (match-string 1 noun))
          ((string-match "^\\(.*[xs]\\)es$" noun)
           (match-string 1 noun))
          ((string-match "^\\(.*\\)ves$" noun)
           (concat (match-string 1 noun) "f")) ;; this is just a wild guess, it might as well be fe
          ((string-match "^\\(.*\\)s$" noun)
           (match-string 1 noun))
          (t noun))))

;;;;;;;;;;;;;;
;;; Navigation

(defun yeoman--current-project-root ()
  "Returns the root folder of the current yeoman-bb project."
  (or yeoman-project-root
      (locate-dominating-file (or load-file-name buffer-file-name default-directory)
                              yeoman-project-root-anchor)))

(defun yeoman-bb--target-file-list (kind base)
  (let ((pattern (cdr (assoc kind yeoman-backbone-jump-schema))))
    (list (replace-regexp-in-string "\\\\1" base pattern)
          (replace-regexp-in-string "\\\\1" (yeoman--pluralize-noun base) pattern)
          (replace-regexp-in-string "\\\\1" (yeoman--singularize-noun base) pattern))
    ))

(defun yeoman-bb--current-file-base ()
  (let ((basename nil)
        (relative-path (file-relative-name (or load-file-name buffer-file-name)
                                           (yeoman--current-project-root))))
    (block finding-type
      (loop for (type . pattern) in yeoman-backbone-jump-schema
            if (string-match (replace-regexp-in-string "\\\\1" "\\\\(.*?\\\\)" pattern)  relative-path)
            do
            (setf basename (match-string 1 relative-path))
            (return-from finding-type basename))
      )
    basename))

(defun yeoman-bb--find-file-in-dir (dir)
  "if `ido-mode' is turned on use ido speedups finding the file"
  (if (or (equal ido-mode 'file) (equal ido-mode 'both))
      (ido-find-file-in-dir dir)
    (let ((default-directory dir)) (call-interactively 'find-file))))

(defun yeoman-bb--open-file-by-type (kind)
  (let ((yo-bb-root (yeoman--current-project-root))
        (file-list (yeoman-bb--target-file-list kind (yeoman-bb--current-file-base))))
    (block found-file
      (loop for relative-file in file-list
            for absolute-file = (concat yo-bb-root relative-file)
            if (file-exists-p absolute-file)
            do
            (find-file absolute-file)
            (return-from found-file absolute-file))
      (yeoman-bb--find-file-in-dir (file-name-directory (car file-list))))))

(defun yeoman-bb--open-mirror-file (list)
  (let ((yo-bb-root (yeoman--current-project-root))
        (relative-file (file-relative-name (or load-file-name buffer-file-name)
                                           (yeoman--current-project-root))))

    (dolist (element list)
      (let ((regexp (first element))
            (replacement (second element)))
        (setf relative-file (replace-regexp-in-string regexp replacement relative-file))))

    (let ((absolute-file (concat yo-bb-root relative-file)))
      (if (file-exists-p absolute-file)
          (find-file absolute-file)
        (yeoman-bb--find-file-in-dir (file-name-directory absolute-file))))))

;;;;;;;;;
;;; Specs

(defun yeoman-bb-open-spec ()
  (interactive)
  (setq patterns '(("app/scripts" "test/specs")
                   ("js$"         "spec.js")))
  (yeoman-bb--open-mirror-file patterns))

(defun yeoman-bb-open-from-spec ()
  (interactive)
  (setq patterns '(("test/specs" "app/scripts")
                   ("spec.js$"   "js" )))
  (yeoman-bb--open-mirror-file patterns))

(defun yeoman-bb-open-spec-or-target ()
  (interactive)
  (let ((name (or load-file-name buffer-file-name)))
    (if (string-match "\\.spec\\.js$" name)
        (yeoman-bb-open-from-spec)
      (yeoman-bb-open-spec))))

;;;;;;;;;;;;;;;
;;; Interactive

(defun yeoman-bb-open-collection ()
  (interactive)
  (yeoman-bb--open-file-by-type "collection"))

(defun yeoman-bb-open-controller ()
  (interactive)
  (yeoman-bb--open-file-by-type "controller"))

(defun yeoman-bb-open-error ()
  (interactive)
  (yeoman-bb--open-file-by-type "error"))

(defun yeoman-bb-open-helper ()
  (interactive)
  (yeoman-bb--open-file-by-type "helper"))

(defun yeoman-bb-open-mixin ()
  (interactive)
  (yeoman-bb--open-file-by-type "mixin"))

(defun yeoman-bb-open-model ()
  (interactive)
  (yeoman-bb--open-file-by-type "model"))

(defun yeoman-bb-open-renderer ()
  (interactive)
  (yeoman-bb--open-file-by-type "renderer"))

(defun yeoman-bb-open-route ()
  (interactive)
  (yeoman-bb--open-file-by-type "route"))

(defun yeoman-bb-open-service ()
  (interactive)
  (yeoman-bb--open-file-by-type "service"))

(defun yeoman-bb-open-template ()
  (interactive)
  (yeoman-bb-open-file-by-kind "template"))

(defun yeoman-bb-open-translation ()
  (interactive)
  (yeoman-bb-open-file-by-kind "translation"))

(defun yeoman-bb-open-view ()
  (interactive)
  (yeoman-bb--open-file-by-type "view"))

(defun yeoman-bb-open-component ()
  (interactive)
  (yeoman-bb--open-file-by-type "component"))

(defun yeoman-bb-open-widget ()
  (interactive)
  (yeoman-bb--open-file-by-type "widget"))

(defun yeoman-bb-open-assembler ()
  (interactive)
  (yeoman-bb--open-file-by-type "assembler"))

(defun yeoman-bb-open-sass ()
  (interactive)
  (yeoman-bb--open-file-by-type "sass"))

;;;;;;;;;;;;;;;
;;; Keybindings

(defvar yeoman-backbone-keymap (make-sparse-keymap)
  "Keymap for yeoman-backbone.")

(define-key yeoman-backbone-keymap (kbd "C-c y o") #'yeoman-bb-open-collection)
(define-key yeoman-backbone-keymap (kbd "C-c y c") #'yeoman-bb-open-controller)
(define-key yeoman-backbone-keymap (kbd "C-c y e") #'yeoman-bb-open-error)
(define-key yeoman-backbone-keymap (kbd "C-c y h") #'yeoman-bb-open-helper)
(define-key yeoman-backbone-keymap (kbd "C-c y x") #'yeoman-bb-open-mixin)
(define-key yeoman-backbone-keymap (kbd "C-c y m") #'yeoman-bb-open-model)
(define-key yeoman-backbone-keymap (kbd "C-c y n") #'yeoman-bb-open-renderer)
(define-key yeoman-backbone-keymap (kbd "C-c y r") #'yeoman-bb-open-route)
(define-key yeoman-backbone-keymap (kbd "C-c y S") #'yeoman-bb-open-service)
(define-key yeoman-backbone-keymap (kbd "C-c y t") #'yeoman-bb-open-template)
(define-key yeoman-backbone-keymap (kbd "C-c y i") #'yeoman-bb-open-translation)
(define-key yeoman-backbone-keymap (kbd "C-c y v") #'yeoman-bb-open-view)
(define-key yeoman-backbone-keymap (kbd "C-c y p") #'yeoman-bb-open-component)
(define-key yeoman-backbone-keymap (kbd "C-c y w") #'yeoman-bb-open-widget)
(define-key yeoman-backbone-keymap (kbd "C-c y a") #'yeoman-bb-open-assembler)
(define-key yeoman-backbone-keymap (kbd "C-c y s") #'yeoman-bb-open-sass)
(define-key yeoman-backbone-keymap (kbd "C-c y k") #'yeoman-bb-open-spec-or-target)

(define-minor-mode yeoman-backbone
  "Mode for navigating around yeoman-backbone applications"
  nil " Yo" yeoman-backbone-keymap
  :global t)

(provide 'yeoman-backbone)
