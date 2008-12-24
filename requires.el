
;; git
(require 'vm)
(require 'vc-git)
 (when (featurep 'vc-git) (add-to-list 'vc-handled-backends 'git))
(require 'git)
(require 'gitsum)

;; ruby
(require 'ri)
(require 'ruby-electric)
(require 'rinari)
(require 'ruby-compilation)
(autoload 'inf-ruby "vendor/ruby/inf-ruby" "Run an inferior Ruby process" t)
(autoload 'inf-ruby-keys "vendor/ruby/inf-ruby" "" t)
(eval-after-load 'ruby-mode
  '(add-hook 'ruby-mode-hook 'inf-ruby-keys))

;; shiny colors!
(require 'color-theme)
(require 'color-theme-autoloads)
(require 'zenburn)

;; some useful modes
(require 'markdown-mode)
(require 'tumble)
(require 'erlang-start)
(require 'haml-mode)

;; defunkt's stuff
(require 'gist)
(require 'textmate)
(textmate-mode)





