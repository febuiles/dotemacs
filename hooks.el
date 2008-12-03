(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode)))
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'c++-mode-hook 'turn-on-auto-fill)
(add-hook 'c-mode-hook 'turn-on-auto-fill)
(add-hook 'ruby-mode-hook 'turn-on-auto-fill)
;; Use C-c k to kill emacs client sessions.
(add-hook 'server-switch-hook 
	  (lambda ()
	    (local-set-key (kbd "C-c k") 'server-edit)))








