(setq load-path (cons "~/.emacs.d/" load-path))
(load "paths")
(load "requires")
(load "hooks")
(load "fonts")
(load "keys")
(load "gitsum")
(load "color-theme")
(load "color-theme-autoloads")
(load "color-theme-library")
(load "temp_files")
(load "nxml")
(load "gist")
(load "haskell-site-file")
(load "textmate")
(textmate-mode)
(load "markdown")
(load "modes")
(load "haml-mode")
(load "syntax")
(load "tumble")

(autoload 'inf-ruby "vendor/ruby/inf-ruby" "Run an inferior Ruby process" t)
(autoload 'inf-ruby-keys "vendor/ruby/inf-ruby" "" t)
(eval-after-load 'ruby-mode
  '(add-hook 'ruby-mode-hook 'inf-ruby-keys))
