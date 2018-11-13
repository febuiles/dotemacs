;; global bindings
(global-set-key "\M-g" 'goto-line)
(global-set-key "\M-4" 'query-replace)
(global-set-key [f3] 'shell)
(global-set-key [f4] 'vc-print-log)
(global-set-key [f5] 'compile)
(global-set-key [f6] 'toggle-frame-fullscreen)
(global-set-key [f8] 'lyrics)
(global-set-key [f10] 'fill-paragraph)
(global-set-key [(control -)] 'font-smaller)
(global-set-key [(control \+)] 'font-larger)

;; Dash
(global-set-key (kbd "C-.") 'dash-at-point)

;; Jumping
(global-set-key [(meta t)] 'projectile-find-file)
(global-set-key [(meta shift t)] 'dumb-jump-go)

;; Git
(global-set-key [(control x)(control g)] 'git-status)

;; C-1 opens a temporary buffer 'foo'
(global-set-key [(control \1)]
  (lambda () (interactive) (switch-to-buffer "foo")))

;; Use regexp search by default
(global-set-key "\C-s" 'isearch-forward-regexp)
(global-set-key "\C-r" 'isearch-backward-regexp)
(global-set-key "\C-\M-s" 'isearch-forward)
(global-set-key "\C-\M-r" 'isearch-backward)
(global-set-key (kbd "C-x C-t") 'org-todo)

;; Ag
(global-set-key (kbd "C-c C-g") 'ag)

;; Compilation
(global-set-key "\M-`" 'next-error)

;; rspec
(global-set-key [f2] 'projectile-toggle-between-implementation-and-test)
(define-key ruby-mode-map (kbd "C-c C-d") 'rspec-verify)
(define-key ruby-mode-map (kbd "C-c .") 'rspec-verify-single)

(define-key ruby-mode-map (kbd "C-c C-l") 'rinari-find-controller)
(define-key ruby-mode-map (kbd "C-c C-m") 'rinari-find-model)
(define-key ruby-mode-map (kbd "C-c C-t") 'rinari-find-test)

(define-key ruby-mode-map (kbd "C-c C-r") 'ruby-send-region)

;; Shift+direction
(windmove-default-keybindings)

;; Spelling
(global-set-key "\C-c\C-w" 'ispell-word)
(global-set-key "\C-c\C-d" 'word-definition)

;; Align
(global-set-key "\C-x\C-a" 'align-regexp)

;; Occur
(define-key isearch-mode-map (kbd "C-o") 'isearch-occur)

;; Global
(global-set-key [(control tab)] 'indent-region)
