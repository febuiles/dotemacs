;; stolen from Jim Weirich
(defun routes ()
  (interactive)
  (find-file (concat (find-rails-root) "/config/routes.rb")))

(defun schema ()
  (interactive)
  (find-file (concat (find-rails-root) "/db/schema.rb")))