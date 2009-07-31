(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode)))
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'c++-mode-hook 'turn-on-auto-fill)
(add-hook 'c-mode-hook 'turn-on-auto-fill)
(add-hook 'ruby-mode-hook 'turn-on-auto-fill)
(add-hook 'html-mode-hook 'turn-off-auto-fill)

;; Use C-c k to kill emacs client sessions.
(add-hook 'server-switch-hook
	  (lambda ()
	    (local-set-key (kbd "C-c k") 'server-edit)))

;; load ruby-inf
(autoload 'inf-ruby "vendor/ruby/inf-ruby" "Run an inferior Ruby process" t)
(autoload 'inf-ruby-keys "vendor/ruby/inf-ruby" "" t)
(eval-after-load 'ruby-mode
  '(add-hook 'ruby-mode-hook 'inf-ruby-keys))


;; Pre-save hooks (Stack Overflow ftw! http://stackoverflow.com/questions/1214407/how-to-write-a-global-save-hook-for-emacs)
(defun unix-newline ()
  (set-buffer-file-coding-system 'undecided-unix))

(add-hook 'before-save-hook 'unix-newline)
(add-hook 'before-save-hook 'delete-trailing-whitespace)




