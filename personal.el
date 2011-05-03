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

;; align-regexp expressions for Ruby, upgraded to 1.9 from http://d.hatena.ne.jp/rubikitch/20080227/1204051280
(require 'align)
(add-to-list 'align-rules-list
             '(ruby-comma-delimiter
               (regexp . ",\\(\\s-*\\)[^# \t\n]")
               (repeat . t)
               (modes  . '(ruby-mode))))
(add-to-list 'align-rules-list
             '(ruby-hash-literal
               (regexp . "\\(\\s-*\\)\\(=>\\|:\\)\\s-*[^# \t\n]")
               (repeat . t)
               (modes  . '(ruby-mode))))
(add-to-list 'align-rules-list
             '(ruby-assignment-literal
               (regexp . "\\(\\s-*\\)=\\s-*[^# \t\n]")
               (repeat . t)
               (modes  . '(ruby-mode))))
(add-to-list 'align-rules-list
             '(ruby-xmpfilter-mark
               (regexp . "\\(\\s-*\\)#\\s-+=> [^#\t\n]")
               (repeat . nil)
               (modes  . '(ruby-mode))))

;; mkdir
(defalias 'mkdir 'make-directory)

;; --------------------------------------------------------
;; nice little alternative visual bell by Miles Bader <miles /at/ gnu.org>
(defcustom echo-area-bell-string ""
  "Message displayed in mode-line by `echo-area-bell' function."
  :group 'user)
(defcustom echo-area-bell-delay 0.1
  "Number of seconds `echo-area-bell' displays its message."
  :group 'user)
;; internal variables
(defvar echo-area-bell-cached-string nil)
(defvar echo-area-bell-propertized-string nil)
(defun echo-area-bell ()
  "Briefly display a highlighted message in the echo-area.
    The string displayed is the value of `echo-area-bell-string',
    with a gray! background; the background highlighting extends to the
    right margin.  The string is displayed for `echo-area-bell-delay'
    seconds.
    This function is intended to be used as a value of `ring-bell-function'."
  (unless (equal echo-area-bell-string echo-area-bell-cached-string)
    (setq echo-area-bell-propertized-string
          (propertize
           (concat
            (propertize
             "x"
             'display
             `(space :align-to (- right ,(+ 2 (length echo-area-bell-string)))))
            echo-area-bell-string)
           'face '(:background "#BBBBBB")))
    (setq echo-area-bell-cached-string echo-area-bell-string))
  (message echo-area-bell-propertized-string)
  (sit-for echo-area-bell-delay)
  (message ""))
(setq ring-bell-function 'echo-area-bell)