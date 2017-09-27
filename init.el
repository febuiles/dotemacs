(package-initialize)

;; don't use tabs

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(setq-default indent-tabs-mode nil)

;; nice fonts in OS X
(setq mac-allow-anti-aliasing t)

;; interpret and use ansi color codes in shell output windows
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(setq shell-file-name "/bin/bash")

;; use cmd as meta in Carbon Emacs
(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'option)

;; hide all the chrome.
(setq inhibit-startup-message t)
(menu-bar-mode 1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq ns-use-native-fullscreen nil)

(setq user-mail-address "federico@mheroin.com")
(setq user-full-name "Federico Builes")

;; personal preferences
(mouse-wheel-mode t)
(line-number-mode 1)
(column-number-mode 1)
(global-font-lock-mode t)
(show-paren-mode 1)
(prefer-coding-system 'utf-8)
(setq case-fold-search t
      display-time-day-and-date t
      display-time-24hr-format t
      search-highlight t
      query-replace-highlight t
      default-fill-column 100
      c-tab-always-indent "other"
      browse-url-browser-function 'browse-default-macosx-browser
      make-backup-files nil
      markdown-command "Markdown.pl | SmartyPants.pl"
      standard-indent 4
      css-indent-offset 2
      transient-mark-mode t
      visible-bell nil
      show-paren-delay 0
      ns-pop-up-frames nil)

;; hour/day in mode line
(display-time)

;; see if you're working with assholes.
(setq-default show-trailing-whitespace t)

(show-paren-mode t)
(setq show-paren-style 'expression)

;; use y/n instead of yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; default window sizes
(set-frame-height (selected-frame) 37)
(set-frame-width (selected-frame) 120)
(set-frame-position (selected-frame) 50 40)
(setq split-height-threshold nil)
(setq split-width-threshold 80)

(server-start)

(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'exec-path "/usr/local/bin")

;; add all the directories in .emacs.d/vendor/ to the path
(let* ((files (directory-files "~/.emacs.d/vendor" t "[^\.+]")))
  (mapcar (lambda (d) (add-to-list 'load-path d)) files))

;; load everything else
(load "requires")
(load "bindings")
(load "personal")
(load "modes")
(load "hooks")
(load "rails")
(load "auto-insert")
(load "platform")

(load-file "~/.emacs.d/vendor/tomorrow-night/color-theme-tomorrow.el")
(color-theme-initialize)
(color-theme-tomorrow-night)

(setenv "PATH" (concat "/usr/local/bin:" (getenv "PATH")))

(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mumamo-background-chunk-major ((((class color) (min-colors 88) (background dark)) nil)))
 '(mumamo-background-chunk-submode1 ((((class color) (min-colors 88) (background dark)) nil)))
 '(mumamo-background-chunk-submode2 ((((class color) (min-colors 88) (background dark)) nil)))
 '(mumamo-background-chunk-submode3 ((((class color) (min-colors 88) (background dark)) nil))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(haskell-program-name "ghci \"+.\"")
 '(package-selected-packages
   (quote
    (dumb-jump gist dash-at-point minitest ag flx-ido grizzl projectile)))
 '(rspec-use-rake-when-possible nil)
 '(rspec-use-rvm nil)
 '(ruby-electric-keywords-alist
   (quote
    (("begin" . reindent)
     ("case" . reindent)
     ("class" . end)
     ("def" . end)
     ("do" . reindent)
     ("else" . reindent)
     ("elsif" . reindent)
     ("end" . reindent)
     ("ensure" . reindent)
     ("for" . reindent)
     ("if" . end)
     ("module" . end)
     ("rescue" . reindent)
     ("unless" . reindent)
     ("until" . reindent)
     ("when" . reindent)
     ("while" . reindent))))
 '(toggle-mapping-style (quote rspec)))

(add-hook 'after-init-hook #'projectile-global-mode)
(setq projectile-completion-system 'ido)
(put 'upcase-region 'disabled nil)
