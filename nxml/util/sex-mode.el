;;; sex-mode.el --- Shell EXecute mode / Send to EXterna program
;;
;; Author: Lennart Borgman (lennart O borgman A gmail O com)
;; Created: 2008-06-01T18:41:50+0200 Sun
;; Version: 0.2
;; Last-Updated: 2008-06-02T12:40:58+0200 Mon
;; URL:
;; Keywords:
;; Compatibility:
;;
;; Features that might be required by this library:
;;
;;   None
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;; Open urls belonging to other programs with those programs.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Change log:
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

(defcustom sex-open-alist
  '(
    "\\.pdf\\'"
    "\\.doc\\'"
    )
  "Alist of file name patterns to handle.
Adding to this list will cause those patterns to be added to to
`auto-mode-alist' and `file-name-handler-alist' when `sex-mode'
is on.

This means that opening those files will create a dummy buffer in
Emacs in `sex-file-mode' and an external program is called to
handle the file."
  :type '(repeat regexp)
  :group 'sex)

;; (setq sex-keep-dummy-buffer nil)
;; (setq sex-keep-dummy-buffer 'visible)
;; (setq sex-keep-dummy-buffer 'burried)
(defcustom sex-keep-dummy-buffer 'visible
  "Keep dummy buffer after opening file.
See `sex-open-alist'."
  :type '(choice (const :tag "Visible" 'visible)
                 (const :tag "Burried" 'burried)
                 (const :tag "Do not keep it" nil))
  :group 'sex)

(defun sex-browse-url (url)
  "Ask a web browser to open URL."
  (condition-case err
      (list (browse-url url) "Opened URL in web browser")
    (error (list nil (error-message-string err)))))

(defun sex-url-insert-file-contents (url &optional visit beg end replace)
  (sex-generic-insert-file-contents
   'sex-browse-url
   (concat "This dummy buffer is used just for opening a URL.\n"
           "To open the URL again click here:\n\n  ")
   (concat "Tried to open URL in web browser, "
           "but it failed with message\n\n  ")
   url visit beg end replace))

(defun sex-file-insert-file-contents (url &optional visit beg end replace)
  (sex-generic-insert-file-contents
   'sex-handle-by-external
   (concat "This dummy buffer is used just for opening a file.\n"
           "The file itself was sent to system for opening.\n\n"
           "To open the file again click here:\n\n  ")
   (concat "Tried to send file"
           " to system but it failed with message\n\n  ")
   url visit beg end replace))

(defun sex-write-file-function ()
  (set-buffer-modified-p nil)
  (error "Can't write this to file, it is just a dummy buffer"))

(defun sex-generic-insert-file-contents (insert-fun
                                         success-header
                                         fail-header
                                         url &optional visit beg end replace)
  (let ((window-config (current-window-configuration)))
    (unless (= 0 (buffer-size))
      (error "Buffer must be empty"))
    (set (make-local-variable 'write-file-functions) '(sex-write-file-function))
    (let* ((name url)
           ;;(result (sex-browse-url name))
           (result (funcall insert-fun name))
           (success (nth 0 result))
           (msg     (nth 1 result)))
      (setq buffer-file-name name)
      (if success
          (progn
            (insert success-header)
            (sex-setup-restore-window-config))
        (insert (propertize "Error: " 'face 'font-lock-warning-face)
                fail-header msg
                "\n\nTo try again click here:\n\n  "))
      (save-excursion
        (insert-text-button
         buffer-file-name
         'action (lambda (button)
                   (sex-browse-url buffer-file-name)))))))

(defun sex-file-handler (operation &rest args)
  "Handler for `insert-file-contents'."
  (cond ((eq operation 'insert-file-contents)
         (apply 'sex-file-insert-file-contents args))
        ;; Handle any operation we don't know about.
        (t (let ((inhibit-file-name-handlers
                  (cons 'sex-file-handler
                        (and (eq inhibit-file-name-operation operation)
                             inhibit-file-name-handlers)))
                 (inhibit-file-name-operation operation))
             (apply operation args)))))

(defun sex-setup-restore-window-config ()
  (when (not (eq sex-keep-dummy-buffer 'visible))
    (run-with-idle-timer 0 nil
                         'sex-restore-window-config
                         (selected-frame)
                         window-config
                         (unless sex-keep-dummy-buffer
                           (current-buffer)))))

(defun sex-restore-window-config (frame win-config buffer)
  (with-selected-frame frame
    (set-window-configuration win-config))
  (when buffer (kill-buffer buffer)))

(defun sex-handle-by-external (&optional file)
  "Give file FILE to external program.
Return a list:

  (SUCCESS MESSAGE)

where SUCCESS is non-nil if operation succeeded and MESSAGE is an
informational message."
  (unless file (setq file buffer-file-name))
  (cond ((fboundp 'w32-shell-execute)
         (condition-case err
             (progn
               (w32-shell-execute "open" (convert-standard-filename file))
               (list t "Sent file to system"))
           (error
            (list nil (error-message-string err)))))
        (t
         (error "Don't know how to handle the file on your OS yet."))))

(define-derived-mode sex-file-mode nil
  "External"
  "Mode for files opened in external programs."
  (set-keymap-parent (current-local-map) button-buffer-map)
  (set-buffer-modified-p nil)
  (setq buffer-read-only t))


(defvar sex-old-url-insert-file-contents nil)
(defvar sex-old-url-handler-mode nil)

(define-minor-mode sex-mode
  "Open certain files in external programs using shell execute."
  nil
  :group 'sex
  :global t
  ;; fix-me: better list handling
  (if sex-mode
      (progn
        (dolist (patt sex-open-alist)
          (add-to-list 'auto-mode-alist (cons patt 'sex-file-mode))
          (add-to-list 'file-name-handler-alist (cons patt 'sex-file-handler) t))
        (require 'url-handlers)
        (setq sex-old-url-insert-file-contents (get 'insert-file-contents 'url-file-handlers))
        (put 'insert-file-contents 'url-file-handlers 'sex-url-insert-file-contents)
        (setq sex-old-url-handler-mode url-handler-mode)
        (unless url-handler-mode (url-handler-mode 1)))
    ;; Remove from the lists:
    (dolist (patt sex-open-alist)
      (setq auto-mode-alist
            (delete (cons patt 'sex-file-mode) auto-mode-alist))
      (setq file-name-handler-alist
            (delete (cons patt 'sex-file-handler)
                    file-name-handler-alist)))
        (put 'insert-file-contents 'url-file-handlers sex-old-url-insert-file-contents)
        (unless sex-old-url-handler-mode (url-handler-mode 0))))

(provide 'sex-mode)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sex-mode.el ends here
