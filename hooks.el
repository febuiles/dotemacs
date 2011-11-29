;; Generic hooks
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode)))
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'c++-mode-hook 'turn-on-auto-fill)
(add-hook 'c-mode-hook 'turn-on-auto-fill)
(add-hook 'ruby-mode-hook 'turn-on-auto-fill)
(add-hook 'html-mode-hook 'turn-off-auto-fill)

;; Use ZenCoding for all markup modes
(add-hook 'sgml-mode-hook 'zencoding-mode)

;; Add automatic spelling to Markdown and Text modes.
;;(add-hook 'markdown-mode-hook 'flyspell-mode)
;;(add-hook 'text-mode-hook 'flyspell-mode)

;;(dolist (hook '(rhtml-mode-hook))
;;  (add-hook hook (lambda () (flyspell-mode -1))))

;; Use C-c k to kill emacs client sessions.
(add-hook 'server-switch-hook
	  (lambda ()
	    (local-set-key (kbd "C-c k") 'server-edit)))

;; Load ruby-inf
(autoload 'inf-ruby "vendor/ruby/inf-ruby" "Run an inferior Ruby process" t)
(autoload 'inf-ruby-keys "vendor/ruby/inf-ruby" "" t)
(eval-after-load 'ruby-mode
  '(add-hook 'ruby-mode-hook 'inf-ruby-keys))

;; Pre-save hooks (Stack Overflow ftw! http://stackoverflow.com/questions/1214407/how-to-write-a-global-save-hook-for-emacs)
(defun unix-newline ()
  (set-buffer-file-coding-system 'undecided-unix))
(add-hook 'before-save-hook 'unix-newline)
(add-hook 'before-save-hook 'delete-trailing-whitespace)


;; M-x compile should call "open html" instead of make
(add-hook 'html-mode-hook
  (lambda ()
    (set (make-local-variable 'compile-command) (concat "open " (buffer-name)))))

;; Use `mdify` for Markdown documents compile-command.
(add-hook 'markdown-mode-hook
  (lambda ()
    (set (make-local-variable 'compile-command) (concat "mdify " (buffer-name)))))

;; CoffeeScript mode
(add-hook 'coffee-mode-hook
  '(lambda() (set (make-local-variable 'tab-width) 2)))

;; colors in shells
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)