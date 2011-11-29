;; git
(require 'vc-git)
 (when (featurep 'vc-git) (add-to-list 'vc-handled-backends 'git))
(require 'git)
(require 'git-blame)

;; ruby
(require 'ri)
(require 'ruby-electric)
(require 'ruby-compilation)
(require 'rhtml-mode)
(require 'rspec-mode)

;; shiny colors!
(require 'color-theme)
(require 'color-theme-autoloads)

;; some useful modes
(require 'markdown-mode)
(require 'haml-mode)
(require 'sass-mode)
(require 'haskell-site-file)
(require 'toggle)
(require 'espresso)

;; defunkt's stuff
(require 'gist)
(require 'textmate)
(textmate-mode)
(require 'coffee-mode)
(require 'peepopen)

;; ZenCoding
(require 'zencoding-mode)

;; Yasnippet
(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/.emacs.d/vendor/yasnippet/snippets")

;; autotest
(require 'autotest)

;; slime
(require 'slime)
(slime-setup)

;; yaml
(require 'yaml-mode)

;; rvm
(require 'rvm)
(rvm-use-default)