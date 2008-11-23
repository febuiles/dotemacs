(global-set-key [(meta g)] 'goto-line) 
(global-set-key [(meta 4)] 'query-replace)
(global-set-key [(control x)(control g)] 'git-status)
(global-set-key [f3] 'shell)
(global-set-key [f2] 'fill-paragraph)
(global-set-key [f4] 'vc-print-log)
(global-set-key [f5] 'compile)
(global-set-key [f6] 'kill-buffer)
(global-set-key [f8] 'add-change-log-entry-other-window)
(global-set-key [(meta -)] 'font-smaller) 
(global-set-key [(meta \+)] 'font-larger)
(global-set-key [(control \1)]
  (lambda () (interactive) (switch-to-buffer "foo")))
(global-set-key [(control c)(control l)] 'rinari-find-controller)
(global-set-key [(control c)(control m)] 'rinari-find-model)
(global-set-key [(control c)(control t)] 'rinari-find-test)


















