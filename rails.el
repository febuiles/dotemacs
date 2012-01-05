;; stolen from Jim Weirich
(defun find-rails-root (&optional dir)
  (or dir (setq dir default-directory))
  (if (file-exists-p (concat dir "config/environment.rb"))
      dir
    (if (equal dir  "/")
	nil
      (find-rails-root (expand-file-name (concat dir "../"))))))

(defun routes ()
  (interactive)
  (find-file (concat (find-rails-root) "/config/routes.rb")))

(defun schema ()
  (interactive)
  (find-file (concat (find-rails-root) "/db/schema.rb")))