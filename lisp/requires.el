(require 'ansi-color)
(require 'fzf)

(require 'vc-git)
(when (featurep 'vc-git) (add-to-list 'vc-handled-backends 'git))
(require 'github-browse-file)

(require 'color-theme)
(require 'color-theme-autoloads)

(require 'markdown-mode)
(require 'haskell-site-file)
(require 'yaml-mode)
(require 'autotest)
(require 'wrap-region)
(wrap-region-global-mode t)

(autoload 'tern-mode "tern.el" nil t)
(setq tern-command '("tern" "--no-port-file"))

(require 'yasnippet)
(yas-load-directory "~/.emacs.d/vendor/yasnippet/snippets")
(yas-global-mode 1)

(require 'ruby-electric)
(require 'rvm)
(rvm-use-default)

(require 'dirtrack)
(setq-default dirtrack-list '("\\s-\\(\033\\[[0-9]+m\\)\\([^\033\\(]+\\)" 2 1))

(setq vc-handled-backends '(Git))

(require 'lsp-mode)
