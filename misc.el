(server-start)
(display-time)
(line-number-mode 1)
(column-number-mode 1)
(color-theme-andreas)
(menu-bar-mode)
(tool-bar-mode nil)
(scroll-bar-mode)
(global-font-lock-mode t)
(show-paren-mode 1)

(set-frame-height (selected-frame) 37)
(set-frame-width (selected-frame) 120)
(set-frame-position (selected-frame) 50 40)
(setq rinari-tags-file-name "TAGS")

(defun linux-c-mode ()
  "C mode with adjusted defaults for use with the Linux kernel."
  (interactive)
  (c-mode)
  (setq c-indent-level 4)
  (setq c-brace-imaginary-offset 0)
  (setq c-brace-offset -4)
  (setq c-argdecl-indent 4)
  (setq c-label-offset -4)
  (setq c-continued-statement-offset 4)
  (setq indent-tabs-mode nil)
  (setq tab-width 8))




