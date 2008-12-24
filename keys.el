(global-set-key [(meta g)] 'goto-line) 
(global-set-key [(meta 4)] 'query-replace)
(global-set-key [(control x)(control g)] 'git-status)
(global-set-key [f3] 'shell)
(global-set-key [f2] 'fill-paragraph)
(global-set-key [f4] 'vc-print-log)
(global-set-key [f5] 'compile)
(global-set-key [f6] 'kill-buffer)
(global-set-key [f7] 'vm)
(global-set-key [f8] 'add-change-log-entry-other-window)
(global-set-key [(meta -)] 'font-smaller) 
(global-set-key [(meta \+)] 'font-larger)
(global-set-key [(control \1)]
  (lambda () (interactive) (switch-to-buffer "foo")))

(define-key ruby-mode-map (kbd "C-c C-l") 'rinari-find-controller)
(define-key ruby-mode-map (kbd "C-c C-m") 'rinari-find-model)
(define-key ruby-mode-map (kbd "C-c C-t") 'rinari-find-test)

(define-key ruby-mode-map (kbd "C-c C-s") 'inf-ruby)
(define-key ruby-mode-map (kbd "C-c C-r") 'ruby-send-region)


















