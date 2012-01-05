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

(require 'zencoding-mode)

;; Snippets
(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/.emacs.d/vendor/yasnippet/snippets")

(require 'autotest)

(require 'slime)
(slime-setup)

(require 'yaml-mode)

(require 'rvm)
(rvm-use-default)

;; mark whitespace
(require 'whitespace)
(global-whitespace-mode t)