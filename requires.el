(require 'cc-mode)
(require 'erlang-start)

;; Git
(require 'vm)
(require 'vc-git)
 (when (featurep 'vc-git) (add-to-list 'vc-handled-backends 'git))
(require 'git)

;; Ruby
(require 'ri)
(require 'ruby-electric)
(require 'rinari)
(require 'ruby-compilation)



