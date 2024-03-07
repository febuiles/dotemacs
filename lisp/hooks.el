;; Generic hooks
(add-hook 'prog-mode-hook '(lambda () (yas/minor-mode)))
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
(add-hook 'ruby-mode-hook (lambda () (rvm-activate-corresponding-ruby)))
(add-hook 'ruby-mode-hook 'minitest-mode)
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'c++-mode-hook 'turn-on-auto-fill)
(add-hook 'c-mode-hook 'turn-on-auto-fill)
(add-hook 'ruby-mode-hook 'turn-on-auto-fill)
(add-hook 'html-mode-hook 'turn-off-auto-fill)

;; Use ZenCoding for all markup modes
(add-hook 'sgml-mode-hook 'zencoding-mode)
(add-hook 'web-mode 'zencoding-mode)

;; electric ruby
(eval-after-load "ruby-mode"
  '(add-hook 'ruby-mode-hook 'ruby-electric-mode))

;; Use C-c k to kill emacs client sessions.
(add-hook 'server-switch-hook
	  (lambda ()
	    (local-set-key (kbd "C-c k") 'server-edit)))

;; Pre-save hooks (Stack Overflow ftw! http://stackoverflow.com/questions/1214407/how-to-write-a-global-save-hook-for-emacs)
(defun unix-newline ()
  (set-buffer-file-coding-system 'undecided-unix))

;; prevent markdown extra spaces from getting erased.
(defun delete-trailing-whitespace-if-needed ()
  (when (not (equal major-mode 'markdown-mode))
    (delete-trailing-whitespace)))

(add-hook 'before-save-hook 'unix-newline)
(add-hook 'before-save-hook 'delete-trailing-whitespace-if-needed)

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

;; zencoding
(add-hook 'shell-mode-hook 'zencoding-mode)

;; ido-mode
(defun ido-keybindings ()
  "Add my keybindings for ido."
  (define-key ido-completion-map (kbd "C-n") 'ido-next-match)
  (define-key ido-completion-map (kbd "C-p") 'ido-prev-match))

(add-hook 'ido-setup-hook 'ido-keybindings)

;; javascript
(add-hook 'js-mode-hook (lambda () (tern-mode t)))
(add-hook 'js-mode-hook (lambda () (tern-mode t)))
(add-hook 'js-mode-hook
          (lambda () (set (make-local-variable 'compile-command) "npm test ")))

;; rust
(add-hook 'rust-mode-hook
          (lambda () (set (make-local-variable 'compile-command) "cargo build")))


;; golang
(add-hook 'go-mode-hook
          (lambda () (set (make-local-variable 'compile-command) "go test")))


(add-hook 'go-mode-hook #'lsp-deferred)

;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

(defun go-bindings-hook ()
  (local-set-key (kbd "M-T") 'lsp-find-definition))
