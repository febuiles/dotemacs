;; personal.el - random bits of elisp

(defun increase-font-size ()
  (set-face-attribute 'default (selected-frame) :height (+ (face-attribute 'default :height) 10)))

(defun decrease-font-size ()
  (set-face-attribute 'default (selected-frame) :height (- (face-attribute 'default :height) 10)))

(defun font-larger ()
  "Increases font size."
  (interactive)
  (increase-font-size))

(defun font-smaller ()
  "Decreases font size."
  (interactive)
  (decrease-font-size))

;; don't clutter the workspace with a bunch of backups
(defvar user-temporary-file-directory
  (concat temporary-file-directory user-login-name "/"))
(make-directory user-temporary-file-directory t)
(setq backup-by-copying t)
(setq backup-directory-alist
      `(("." . ,user-temporary-file-directory)))
(setq auto-save-list-file-prefix
      (concat user-temporary-file-directory ".auto-saves-"))
(setq auto-save-file-name-transforms
      `((".*" ,user-temporary-file-directory t)))
(setq auto-save-default nil)

; make completion buffers disappear after 5 seconds.
(add-hook 'completion-setup-hook
  (lambda () (run-at-time 8 nil
    (lambda () (delete-windows-on "*Completions*")))))

;; HAML stuff
(defun haml-replace-region (begin end)
  "Replaces the current block of Haml code with the HTML equivalent"
  (interactive "r")
  (shell-command-on-region begin end "haml" "haml-output" t))

(defun haml-output-region (begin end)
  "Returns the HTML output for the current block of Haml code"
  (interactive "r")
  (shell-command-on-region begin end "haml" "haml-output" nil))

;; set the default OS X browser
(defun browse-default-macosx-browser (url &optional new-window)
  (interactive (browse-url-interactive-arg "URL: "))
  (let ((url
	 (if (aref (url-generic-parse-url url) 0)
	     url
	   (concat "http://" url))))
    (start-process (concat "open " url) nil "open" url)))
