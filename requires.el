;; git
(require 'vc-git)
 (when (featurep 'vc-git) (add-to-list 'vc-handled-backends 'git))
(require 'git)
(require 'gitsum)

;; ruby
(require 'ri)
(require 'ruby-electric)
;;(require 'rinari)
(require 'ruby-compilation)

;; shiny colors!
(require 'color-theme)
(require 'color-theme-autoloads)
(require 'zenburn)

;; some useful modes
(require 'markdown-mode)
(require 'haml-mode)
(require 'tumble)
(require 'lyricwiki)

(require 'haskell-site-file)


;; defunkt's stuff
(require 'gist)
(require 'textmate)
(textmate-mode)

;; ZenCoding
(require 'zencoding-mode)

;; Yasnippet
(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/.emacs.d/vendor/yasnippet/snippets")









