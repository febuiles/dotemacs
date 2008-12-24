(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(case-fold-search t)
 '(markdown-command "Markdown.pl | SmartyPants.pl")
 '(mouse-wheel-mode t nil (mwheel))
 '(show-paren-mode t nil (paren))
 '(standard-indent 4)
 '(transient-mark-mode t)
 '(visible-bell t))

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

;; this is me
(setq user-mail-address "federico.builes@gmail.com")
(setq user-full-name "Federico Builes")

;; personal preferences
(setq search-highlight t)
(setq query-replace-highlight t)
(setq default-fill-column 77)
(setq c-tab-always-indent "other") 
(setq browse-url-browser-function 'browse-default-macosx-brower)
(setq make-backup-files nil) 
(setq ispell-dictionary "spanish")
(line-number-mode 1)
(column-number-mode 1)
(global-font-lock-mode t)
(show-paren-mode 1)
(prefer-coding-system 'utf-8)

;; use y/n instead of yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; default window sizes
(set-frame-height (selected-frame) 37)
(set-frame-width (selected-frame) 120)
(set-frame-position (selected-frame) 50 40)

(server-start)

;; load everything else
(load "~/.emacs.d/loads.el")

;; nice color theme stolen from emacs-starter-kit
(color-theme-zenburn)
(require 'zenburn)

