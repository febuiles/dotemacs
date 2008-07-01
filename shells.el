; make completion buffers disappear after 5 seconds.
(add-hook 'completion-setup-hook
  (lambda () (run-at-time 5 nil
    (lambda () (delete-windows-on "*Completions*")))))

; interpret and use ansi color codes in shell output windows
(ansi-color-for-comint-mode-on)