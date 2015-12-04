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

;; WC for emacs
;; taken from http://www.emacswiki.org/emacs/WordCount
(defun count-words (start end)
  "Print number of words in the region."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (goto-char (point-min))
      (print (count-matches "\\sw+")))))


;; Run fast spec files before going for the typical Rails specs.
(defun fast-spec-file(file)
  (gsub (gsub  file "app/" "spec/fast/") ".rb" "_spec.rb"))

(defun run-spec()
  "Runs the specs for the buffer where this is called.
The spec lookup works like this:
1. For foo.rb it'll look for spec/fast/[models|controllers|...]/foo_spec.rb
2. If (1) fails it will run `rspec-verify-single`."
  (interactive)
  (let* ((file-name (buffer-file-name))
        (fast-spec (fast-spec-file file-name)))
    (if
        (file-exists-p fast-spec) (rspec-run-single-file fast-spec)
       (rspec-verify))))

(defun get-current-test-name ()
  (save-excursion
    (let ((pos)
          (test-name))
      (re-search-backward "test \"\\([^\"]+\\)\" do")
      (setq test-name (buffer-substring-no-properties (match-beginning 1) (match-end 1)))
      (concat "test_" (replace-regexp-in-string " " "_" test-name)))))

;; Equivalent to `run-spec` for Minitest. TODO: Merge.
(defun ruby-run-test-at-point ()
  (interactive)
  (compile (format "ruby -Ilib:test -I../. %s -n %s" (expand-file-name (buffer-file-name)) (get-current-test-name))))

(defun gsub (string search-string replace &optional regexp-flag)
  "Replaces the occurences of `search-string` in `string` with `replace`."
  (with-temp-buffer
    (insert string)
    (goto-char (point-min))
    (let ((search-function (if regexp-flag 're-search-forward 'search-forward)))
      (while (funcall search-function search-string nil t)
        (replace-match replace))
      (buffer-string))))

;; Lyrics
(defun lyrics()
  "Prints the lyrics for the current song"
  (interactive)
  (let ((song (shell-command-to-string "/usr/local/bin/lyrics")))
    (if (equal song "")
        (message "No lyrics - Opening browser.")
      (switch-to-buffer (create-file-buffer "Lyrics"))
      (insert song)
      (goto-line 0))))

;; look for the current word in the dictionary
(defun word-definition()
  (interactive)
  (shell-command-to-string (concat "open dict:///" (current-word))))

;; got too used to using git-blame-mode (don't!)
(defalias 'git-blame-mode 'vc-annotate )

;; fast-load ~/.alias
(defun alias ()
  (interactive)
  (find-file "~/.alias"))

;; By Xah Lee: http://ergoemacs.org/emacs/emacs_CSS_colors.html
(defun xah-syntax-color-hex ()
"Syntax color hex color spec such as 「#ff1100」 in current buffer."
 (interactive)
 (font-lock-add-keywords
  nil
  '(("#[abcdef[:digit:]]\\{6\\}"
     (0 (put-text-property
         (match-beginning 0)
         (match-end 0)
         'face (list :background (match-string-no-properties 0)))))))
 (font-lock-fontify-buffer))

(add-hook 'fundamental-mode 'xah-syntax-color-hex)
