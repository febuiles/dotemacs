;; don't use tabs
(setq-default indent-tabs-mode nil)

;; nice fonts in OS X
(setq mac-allow-anti-aliasing t)

; interpret and use ansi color codes in shell output windows
(ansi-color-for-comint-mode-on)

;; use cmd as meta in Carbon Emacs
(setq mac-command-modifier 'meta)

;; hide all the chrome.
(setq inhibit-startup-message t)
(menu-bar-mode nil)
(tool-bar-mode nil)
(scroll-bar-mode nil)

(setq user-mail-address "federico.builes@gmail.com")
(setq user-full-name "Federico Builes")

;; personal preferences
(mouse-wheel-mode t)
(line-number-mode 1)
(column-number-mode 1)
(global-font-lock-mode t)
(show-paren-mode 1)
(prefer-coding-system 'utf-8)
(setq case-fold-search t
      search-highlight t
      query-replace-highlight t
      default-fill-column 100
      c-tab-always-indent "other"
      browse-url-browser-function 'browse-default-macosx-browser
      make-backup-files nil
      ispell-dictionary "english"
      markdown-command "Markdown.pl | SmartyPants.pl"
      standard-indent 4
      css-indent-offset 2
      transient-mark-mode t
      visible-bell t
      show-paren-delay 0)

;; nice parentheses
(setq-default show-trailing-whitespace t)

(show-paren-mode t)
(setq show-paren-style 'expression)

;; use y/n instead of yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; default window sizes
(set-frame-height (selected-frame) 37)
(set-frame-width (selected-frame) 120)
(set-frame-position (selected-frame) 50 40)

(server-start)

;; use a nice font by default
(set-default-font "-apple-inconsolata-medium-r-normal--0-0-0-0-m-0-iso10646-1")
(set-face-attribute 'default (selected-frame) :height 180)

;; add ~/.emacs.d to the load path
(add-to-list 'load-path "~/.emacs.d")

;; add all the directories in .emacs.d/vendor/ to the path
(let* ((files (directory-files "~/.emacs.d/vendor" t "[^\.+]")))
  (mapcar (lambda (d) (add-to-list 'load-path d)) files))

;; include ELPA if it exists
(if (file-exists-p "~/.emacs.d/elpa/package.el")
    (load (expand-file-name "~/.emacs.d/elpa/package.el")))

;; load everything else
(load "requires")
(load "bindings")
(load "personal")
(load "modes")
(load "hooks")

(load-file "~/.emacs.d/vendor/twilight/twilight.el")
(color-theme-initialize)
(color-theme-twilight)

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(haskell-font-lock-symbols t)
 '(js2-basic-offset 4))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
