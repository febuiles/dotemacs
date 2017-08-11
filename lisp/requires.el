(require 'vc-git)
(when (featurep 'vc-git) (add-to-list 'vc-handled-backends 'git))
(require 'git)

(require 'ri)
(require 'ruby-compilation)
(require 'ruby-electric)
(require 'rhtml-mode)
(require 'rspec-mode)

(require 'color-theme)
(require 'color-theme-autoloads)

(require 'markdown-mode)
(require 'haml-mode)
(require 'sass-mode)
(require 'haskell-site-file)
(require 'toggle)
(require 'espresso)
(require 'yaml-mode)
(require 'php-mode)
(require 'go-mode)
(require 'autotest)
(require 'wrap-region)
(wrap-region-global-mode t)

(add-to-list 'load-path "~/dev/tern/emacs/")
(autoload 'tern-mode "tern.el" nil t)

(require 'coffee-mode)

(require 'zencoding-mode)

(require 'yasnippet)
(yas/load-directory "~/.emacs.d/vendor/yasnippet/snippets")
(yas/global-mode 1)

(require 'rvm)
(rvm-use-default)

(require 'dirtrack)
(setq-default dirtrack-list '("\\s-\\(\033\\[[0-9]+m\\)\\([^\033\\(]+\\)" 2 1))

(require 'ido)
(ido-mode)
