;; gist.el --- Emacs integration for gist.github.com
;; Copyright (C) 2008  Christian Neukirchen <purl.org/net/chneukirchen>
;; Copyright (C) 2008  Chris Wanstrath <chris@ozmm.org>
;; Copyright (C) 2008  Will Farrington <wcfarrington@gmail.com>
;; Licensed under the same terms as Emacs.

;; Version: 0.3.1
;; 26aug2008  +wfarr+
;; 25aug2008  +defunkt+
;; 21jul2008  +chris+

;; Ideas: fork

(defvar github-username "febuiles")
(defvar github-api-key "1948a85f5274af72019dd0964d15044f")

(defvar gist-supported-modes-alist '((action-script-mode . "as")
                                     (c-mode . "c")
                                     (c++-mode . "cpp")
                                     (common-lisp-mode . "el")
                                     (css-mode . "css")
                                     (diff-mode . "diff")
                                     (emacs-lisp-mode . "el")
                                     (erlang-mode . "erl")
                                     (haskell-mode . "hs")
                                     (html-mode . "html")
                                     (io-mode . "io")
                                     (java-mode . "java")
                                     (javascript-mode . "js")
                                     (jde-mode . "java")
                                     (js2-mode . "js")
                                     (lua-mode . "lua")
                                     (ocaml-mode . "ml")
                                     (objective-c-mode . "m")
                                     (perl-mode "pl")
                                     (php-mode . "php")
                                     (python-mode . "sc")
                                     (ruby-mode . "rbx")
                                     (text-mode . "txt")
                                     (sql-mode . "sql")
                                     (scheme-mode . "scm")
                                     (smalltalk-mode . "st")
                                     (sh-mode . "sh")
                                     (tcl-mode . "tcl")
                                     (tex-mode . "tex")
                                     (xml-mode . "xml")))

;;;###autoload
(defun gist-region (begin end &optional private)
  "Post the current region as a new paste at gist.github.com
Copies the URL into the kill ring."
  (interactive "r")
  (let* ((file (or (buffer-file-name) (buffer-name)))
         (name (file-name-nondirectory file))
         (ext (or (cdr (assoc major-mode gist-supported-modes-alist))
                  (file-name-extension file)
                  "txt"))
         (output (generate-new-buffer " *gist*"))
         (login (github-auth-string))
         (do-private (if private "-F private=1" "")))
    (shell-command-on-region
     begin end
     (format (concat "curl -sS "
                     "%s "
                     "-F 'file_ext[gistfile1]=.%s' "
                     "-F 'file_name[gistfile1]=%s' "
                     "-F 'file_contents[gistfile1]=<-' "
                     "%s "
                     "http://gist.github.com/gists") login ext name do-private)
     output)
    (with-current-buffer output
      (re-search-backward "href=\"\\(.*\\)\"")
      (message "Paste created: %s" (match-string 1))
      (kill-new (match-string 1)))
   (kill-buffer output)))

;;;###autoload
(defun gist-region-private (begin end)
  "Post the current region as a new private paste at gist.github.com
Copies the URL into the kill ring."
  (interactive "r")
  (gist-region begin end t))

(defun github-raw-auth-string (user token)
  "Given a username and API token, returns a curl-friendly string."
  (if (and (> (length user) 0) (> (length token) 0))
      (format "-F 'login=%s' -F 'token=%s'" user token)))

(defun github-config (key)
  "Returns a GitHub specific value from the global Git config."
  (let ((strip (lambda (string)
                 (if (> (length string) 0)
                     (substring string 0 (- (length string) 1))))))
  (funcall strip (shell-command-to-string
                  (concat "git config --global github." key)))))

(defun github-set-config (key value)
  "Sets a GitHub specific value to the global Git config."
  (shell-command-to-string (format "git config --global github.%s %s" key value)))

(defun github-auth-string ()
  "Returns a curl-friendly GitHub auth string.
Searches for a GitHub username and token in the global git config.
If nothing is found, prompts for the info then sets it to the git config."
  (interactive)

  (let* ((user (github-config "user"))
         (token (github-config "token"))
         (auth-string (github-raw-auth-string user token)))

    (if (> (length auth-string) 0)
        auth-string

      (cond
       ((not user)
        (setq user (read-string "GitHub username: "))
        (github-set-config "user" user)))

      (cond
       ((not token)
        (setq token (read-string "GitHub API token: "))
        (github-set-config "token" token)))

      (github-raw-auth-string user token))))

;;;###autoload
(defun gist-buffer ()
  "Post the current buffer as a new paste at gist.github.com.
Copies the URL into the kill ring."
  (interactive)
  (gist-region (point-min) (point-max)))

;;;###autoload
(defun gist-buffer-private ()
  "Post the current buffer as a new private paste at gist.github.com.
Copies the URL into the kill ring."
  (interactive)
  (gist-region-private (point-min) (point-max)))

;;;###autoload
(defun gist-region-or-buffer ()
  "Post either the current region, or if mark is not set, the current buffer as a new paste at gist.github.com
Copies the URL into the kill ring."
  (interactive)
  (condition-case nil
      (gist-region (point) (mark))
      (mark-inactive (gist-buffer))))

;;;###autoload
(defun gist-region-or-buffer-private ()
  "Post either the current region, or if mark is not set, the current buffer as a new private paste at gist.github.com
Copies the URL into the kill ring."
  (interactive)
  (condition-case nil
      (gist-region-private (point) (mark))
      (mark-inactive (gist-buffer-private))))

(defvar gist-fetch-url "http://gist.github.com/%d.txt"
  "Raw Gist content URL format")

;;;###autoload
(defun gist-fetch (id)
  "Fetches a Gist and inserts it into a new buffer
If the Gist already exists in a buffer, switches to it"
  (interactive "nGist ID: ")

  (let* ((gist-buffer-name (format "*gist %d*" id))
         (gist-buffer (get-buffer gist-buffer-name)))
    (if (bufferp gist-buffer)
      (switch-to-buffer-other-window gist-buffer)
      (progn
        (message "Fetching Gist %d..." id)
        (setq gist-buffer
              (url-retrieve-synchronously (format gist-fetch-url id)))
        (with-current-buffer gist-buffer
          (rename-buffer gist-buffer-name t)
          (beginning-of-buffer)
          (search-forward-regexp "\n\n")
          (delete-region (point-min) (point))
          (set-buffer-modified-p nil))
        (switch-to-buffer-other-window gist-buffer)))))

(provide 'gist)
;;; gist.el ends here.