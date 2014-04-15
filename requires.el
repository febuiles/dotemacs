;; git
(require 'vc-git)
(when (featurep 'vc-git) (add-to-list 'vc-handled-backends 'git))
(require 'git)
(require 'git-blame)

(require 'ri)
;;(require 'ruby-electric)
(require 'ruby-compilation)
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

(require 'coffee-mode)

(require 'zencoding-mode)

(require 'yasnippet)
(yas/load-directory "~/.emacs.d/vendor/yasnippet/snippets")

(require 'rvm)
(rvm-use-default)

(require 'textmate)
(require 'peepopen)
(textmate-mode)
