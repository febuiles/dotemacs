;; git
(require 'vc-git)
 (when (featurep 'vc-git) (add-to-list 'vc-handled-backends 'git))
(require 'git)
(require 'git-blame)

(require 'ri)
(require 'ruby-electric)
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
(require 'autotest)
(require 'wrap-region)
(wrap-region-global-mode t)

(require 'textmate)
(textmate-mode)
(require 'coffee-mode)

(require 'peepopen)
(require 'zencoding-mode)

(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/.emacs.d/vendor/yasnippet/snippets")

(require 'slime)
(slime-setup)

(require 'rvm)
(rvm-use-default)

