(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell
      (replace-regexp-in-string "[[:space:]\n]*$" ""
        (shell-command-to-string "$SHELL -l -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(when (equal system-type 'darwin) (set-exec-path-from-shell-PATH))

(cond ((string= system-type "gnu/linux")
       (set-face-attribute 'default nil :height 155)
       (global-set-key [(control -)] 'font-smaller)
       (global-set-key [(control \+)] 'font-larger)
       (global-set-key [XF86AudioRaiseVolume] 'shell))

      ((string= system-type "darwin")
       (set-exec-path-from-shell-PATH)
       (set-default-font "-unknown-Inconsolata-normal-normal-normal-*-*-*-*-*-m-0-iso10646-1")
       (set-face-attribute 'default nil :height 230)))
