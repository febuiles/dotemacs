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

; make completion buffers disappear after 8 seconds.
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

;; Johnson JS2 functions stolen from http://ozmm.org/posts/johnson.html
(defun js2-execute-buffer ()
  (interactive)
  (shell-command (concat "johnson " (buffer-file-name))))

(defun js2-execute-line ()
  (interactive)
  (save-excursion
    (call-process-region (point-at-bol)
                         (point-at-eol)
                         "johnson"
                         nil
                         (get-buffer-create "*johnson-line*"))
    (with-current-buffer (get-buffer "*johnson-line*")
      (search-backward "\n\n" nil t)
      (replace-match "" nil t)
      (message (buffer-string))
      (kill-buffer nil))))


;; === Fix the "copy-paste from MS Word" issue on Mac OS X ===
;; prohibit pasting of TIFFs
(defun x-selection-value (type)
 (let ((data-types '(public.file-url
                      public.utf16-plain-text
                      com.apple.traditional-mac-plain-text))
   text)
   (while (and (null text) data-types)
     (setq text (condition-case nil
            (x-get-selection type (car data-types))
          (error nil)))
     (setq data-types (cdr data-types)))
   (if text
   (remove-text-properties 0 (length text) '(foreign-selection nil)
text))
   text))

;; Alex Schroeder [http://www.emacswiki.org/cgi-bin/wiki/OccurBuffer]
(defun isearch-occur ()
  "*Invoke `occur' from within isearch."
  (interactive)
  (let ((case-fold-search isearch-case-fold-search))
    (occur (if isearch-regexp isearch-string (regexp-quote isearch-string)))))