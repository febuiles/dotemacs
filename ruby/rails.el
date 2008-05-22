;;; rails.el --- minor mode for editing RubyOnRails code

;; Copyright (C) 2006 Galinsky Dmitry <dima dot exe at gmail dot com>

;; Keywords: ruby rails languages oop
;; X-URL:    https://opensvn.csie.org/mvision/emacs/.emacs.d/rails.el

;;; License

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

;;; Usage

;; Add to your .emacs file
;;
;; (defun try-complete-abbrev (old)
;;   (if (expand-abbrev) t nil))
;;
;; (setq hippie-expand-try-functions-list
;;       '(try-complete-abbrev
;;         try-complete-file-name
;;         try-expand-dabbrev))
;;
;; (require 'rails)
;;

;;; Commentary:

;; Do not use automatic abbrev expand, be various problem in mmm-mode.
;; Abbrev-expand now bind in <TAB>

;; More howtos, see
;; * http://scott.elitists.net/users/scott/posts/rails-on-emacs
;; * http://www.emacswiki.org/cgi-bin/wiki/RubyMode

;;; Changelog:

;; 2006/02/07 (version 0.2)
;;   * Display color logs using ansi-color

;; 2006/02/06 (version 0.1):
;;   * Cleanup code
;;   * Add menu item "SVN status"
;;   * Add menu item "Search documentation"
;;   * If one action associated multiple view templates,
;;     display popup menu to a choice template
;;   * More TextMate snippets
;;   * Using ri to search documentation
;;   * Apply patch from Maiha Ishimura

;;; Code:

(require 'ansi-color)

(defvar rails-version "0.2")
(defvar rails-ruby-command "ruby")
(defvar rails-webrick-buffer-name "*Webrick*")
(defvar rails-webrick-port "3000")
(defvar rails-webrick-default-env "development")
(defvar rails-webrick-url (concat "http://localhost:" rails-webrick-port))
(defvar rails-templates-list '("rhtml" "rxml" "rjs"))

(defvar rails-minor-mode-menu-bar-map
  (let ((map (make-sparse-keymap)))
    (define-key map [rails] (cons "RubyOnRails" (make-sparse-keymap "RubyOnRails")))
    (define-key map [rails svn-status]
      '(menu-item "SVN status"
                  (lambda()
                    (interactive)
                    (svn-status (rails-root))
                    :enable (rails-root))))
    (define-key map [rails ri] '("Search documentation" . rails-ri-start))
    (define-key map [rails separator] '("--"))
    (define-key map [rails snip] (cons "Snippets" (make-sparse-keymap "abbrev")))
    (define-key map [rails snip sk-ra]  '("render (action)\t(ra)" . rails-snip-ra))
    (define-key map [rails snip sk-ral] '("render (action,layout)\t(ral)" . rails-snip-ral))
    (define-key map [rails snip sk-rf]  '("render (file)\t(rf)" . rails-snip-rf))
    (define-key map [rails snip sk-rfu] '("render (file,use_full_path)\t(rfu)" . rails-snip-rfu))
    (define-key map [rails snip sk-ri]  '("render (inline)\t(ri)" . rails-snip-ri))
    (define-key map [rails snip sk-ril] '("render (inline,locals)\t(ril)" . rails-snip-ril))
    (define-key map [rails snip sk-rit] '("render (inline,type)\t(rit)" . rails-snip-rit))
    (define-key map [rails snip sk-rl]  '("render (layout)\t(rl)" . rails-snip-rl))
    (define-key map [rails snip sk-rn]  '("render (nothing)\t(rn)" . rails-snip-rn))
    (define-key map [rails snip sk-rns] '("render (nothing,status)\t(rns)" . rails-snip-rns))
    (define-key map [rails snip sk-rp]  '("render (partial)\t(rp)" . rails-snip-rp))
    (define-key map [rails snip sk-rpc] '("render (partial,collection)\t(rpc)" . rails-snip-rpc))
    (define-key map [rails snip sk-rpl] '("render (partial,locals)\t(rpl)" . rails-snip-rpl))
    (define-key map [rails snip sk-rpo] '("render (partial,object)\t(rpo)" . rails-snip-rpo))
    (define-key map [rails snip sk-rps] '("render (partial,status)\t(rps)" . rails-snip-rps))
    (define-key map [rails snip sk-rt] '("render (text)\t(rt)" . rails-snip-rt))
    (define-key map [rails snip sk-rtl] '("render (text,layout)\t(rtl)" . rails-snip-rtl))
    (define-key map [rails snip sk-rtlt] '("render (text,layout => true)\t(rtlt)" . rails-snip-rtlt))
    (define-key map [rails snip sk-rcea] '("render_component (action)\t(rcea)" . rails-snip-rcea))
    (define-key map [rails snip sk-rcec] '("render_component (controller)\t(rcec)" . rails-snip-rcec))
    (define-key map [rails snip sk-rceca] '("render_component (controller, action)\t(rceca)" . rails-snip-rceca))
    (define-key map [rails snip sk-rea] '("redirect_to (action)\t(rea)" . rails-snip-rea))
    (define-key map [rails snip sk-reai] '("redirect_to (action, id)\t(reai)" . rails-snip-reai))
    (define-key map [rails snip sk-rec] '("redirect_to (controller)\t(rec)" . rails-snip-rec))
    (define-key map [rails snip sk-reca] '("redirect_to (controller, action)\t(reca)" . rails-snip-reca))
    (define-key map [rails snip sk-recai] '("redirect_to (controller, action, id)\t(recai)" . rails-snip-recai))
    (define-key map [rails snip sk-flash] '("flash[...]\t(flash)" . rails-snip-flash))
    (define-key map [rails snip sk-logi] '("logger.info\t(logi)" . rails-snip-logi))
    (define-key map [rails snip sk-params] '("params[...]\t(params)" . rails-snip-params))
    (define-key map [rails snip sk-params] '("session[...]\t(session)" . rails-snip-session))

    (define-key map [rails snip separator] '("--"))
    (define-key map [rails snip sk-erb-ft] '("form_tag\t(ft)" . rails-erb-snip-ft))
    (define-key map [rails snip sk-erb-lia] '("link_to (action)\t(lia)" . rails-erb-snip-lia))
    (define-key map [rails snip sk-erb-liai] '("link_to (action, id)\t(liai)" . rails-erb-snip-liai))
    (define-key map [rails snip sk-erb-lic] '("link_to (controller)\t(lic)" . rails-erb-snip-lic))
    (define-key map [rails snip sk-erb-lica] '("link_to (controller, action)\t(lica)" . rails-erb-snip-lica))
    (define-key map [rails snip sk-erb-licai] '("link_to (controller, action, id)\t(licai)" . rails-erb-snip-licai))
    (define-key map [rails snip sk-erb-ft] '("form_tag\t(ft)" . rails-erb-snip-ft))
    (define-key map [rails snip sk-erb-block] '("<% ... %>\t(%)" . rails-erb-snip-block))
    (define-key map [rails snip sk-erb-echo-block] '("<%= ... %>\t(%%)" . rails-erb-snip-echo-block))

    (define-key map [rails log] (cons "Open log" (make-sparse-keymap "Open log")))
    (define-key map [rails log dev]
      '("test.log" . (lambda() (interactive) (rails-open-log "test"))))
    (define-key map [rails log pro]
      '("production.log" . (lambda() (interactive) (rails-open-log "production"))))
    (define-key map [rails log test]
      '("development.log" . (lambda() (interactive) (rails-open-log "development"))))

    (define-key map [rails config] (cons "Configuration" (make-sparse-keymap "Configuration")))
    (define-key map [rails config routes]
      '("routes.rb" .
        (lambda()
          (interactive)
          (let ((root (rails-root)))
            (if root (find-file (concat root "config/routes.rb")))))))
    (define-key map [rails config environment]
      '("environment.rb" .
        (lambda()
          (interactive)
          (let ((root (rails-root)))
            (if root (find-file (concat root "config/environment.rb")))))))
    (define-key map [rails config database]
      '("database.yml" .
        (lambda()
          (interactive)
          (let ((root (rails-root)))
            (if root (find-file (concat root "config/database.yml")))))))
    (define-key map [rails config boot]
      '("boot.rb" .
        (lambda()
          (interactive)
          (let ((root (rails-root)))
            (if root (find-file (concat root "config/boot.rb")))))))

    (define-key map [rails config env] (cons "environments" (make-sparse-keymap "environments")))
    (define-key map [rails config env test]
      '("test.rb" .
        (lambda()
          (interactive)
          (let ((root (rails-root)))
            (if root (find-file (concat root "config/environments/test.rb")))))))
    (define-key map [rails config env production]
      '("production.rb" .
        (lambda()
          (interactive)
          (let ((root (rails-root)))
            (if root (find-file (concat root "config/environments/production.rb")))))))
    (define-key map [rails config env development]
      '("development.rb" .
        (lambda()
          (interactive)
          (let ((root (rails-root)))
            (if root (find-file (concat root "config/environments/development.rb")))))))

    (define-key map [rails webrick] (cons "WEBrick" (make-sparse-keymap "WEBrick")))

    (define-key map [rails switch-va] '("Switch Action/View" . rails-switch-view-action))

    (if map map))
  "RubyOnRails menubar")

(define-skeleton rails-snip-ra ""
  > "render :action => \"" (skeleton-read "action? " "action") "\"")

(define-skeleton rails-snip-ral ""
  > "render :action => \"" (skeleton-read "action? " "action")
  > "\", :layout => \"" (skeleton-read "layout? " "layoutname") "\"")

(define-skeleton rails-snip-rf ""
  > "render :file => \"" (skeleton-read "filepath? ") "\"")

(define-skeleton rails-snip-rfu ""
  > "render :file => \"" (skeleton-read "filepath? ")
  > "\", :use_full_path => " (skeleton-read "use_full_path? " "false"))

(define-skeleton rails-snip-ri ""
  > "render :inline => \"" (skeleton-read "inline? " "<%= 'hello' %>")  "\"")

(define-skeleton rails-snip-ril ""
  > "render :inline => \"" (skeleton-read "inline? " "<%= 'hello' %>")
  > "\", :locals => { :" (skeleton-read "name? " "name")
  > " => \"" (skeleton-read "value? ") "\" }" _ )

(define-skeleton rails-snip-rit ""
  > "render :inline => \"" (skeleton-read "inline? " "{<%= 'hello' %>}")
  > "\", :type => " (skeleton-read "type? " ":rxml"))

(define-skeleton rails-snip-rl ""
  > "render :layout => \"" (skeleton-read "layout? ") "\"")

(define-skeleton rails-snip-rn ""
  > "render :nothing => " (skeleton-read "nothing? " "true"))

(define-skeleton rails-snip-rns ""
  > "render :nothing => " (skeleton-read "nothing? " "true")
  > ", :status => "(skeleton-read "status? " "401" ))

(define-skeleton rails-snip-rp ""
  > "render :partial => \"" (skeleton-read "partial? " "item") "\"")

(define-skeleton rails-snip-rpc ""
  > "render :partial => \"" (skeleton-read "partial? " "item")
  > "\", :collection => " (skeleton-read "collection? " "items"))

(define-skeleton rails-snip-rpl ""
  > "render :partial => \"" (skeleton-read "partial? " "item")
  > "\", :locals => { :" (skeleton-read "name? " "name")
  > " => \"" (skeleton-read "value? ") "\"" _ " }")

(define-skeleton rails-snip-rpo ""
  > "render :partial => \"" (skeleton-read "partial? " "item")
  > "\", :object => " (skeleton-read "object? " "object"))

(define-skeleton rails-snip-rps ""
  > "render :partial => \"" (skeleton-read "partial? " "item")
  > "\", :status => " (skeleton-read "status? " "500"))

(define-skeleton rails-snip-rt ""
  > "render :text => \"" (skeleton-read "text? ") "\"")

(define-skeleton rails-snip-rtl ""
  > "render :text => \"" (skeleton-read "text? ")
  > "\", :layout => \"" (skeleton-read "layout? ") "\"")

(define-skeleton rails-snip-rtlt ""
  > "render :text => \"" (skeleton-read "text? ")
  > "\", :layout => " (skeleton-read "layout? " "true"))

(define-skeleton rails-snip-rts ""
  > "render :text => \"" (skeleton-read "text? ")
  > "\", :status => " (skeleton-read "status? " "401"))

(define-skeleton rails-snip-rcea ""
  > "render_component :action => \"" (skeleton-read "action? " "index") "\"")

(define-skeleton rails-snip-rcec ""
  > "render_component :controller => \"" (skeleton-read "controller? " "items") "\"")

(define-skeleton rails-snip-rceca ""
  > "render_component :controller => \"" (skeleton-read "controller? " "items")
  > "\", :action => \"" (skeleton-read "action? " "index") "\"")

(define-skeleton rails-snip-rea ""
  > "redirect_to :action => \"" (skeleton-read "action? " "index") "\"")

(define-skeleton rails-snip-reai ""
  > "redirect_to :action => \"" (skeleton-read "action? " "show")
  > "\", :id => " (skeleton-read "id? " "@item"))

(define-skeleton rails-snip-rec ""
  > "redirect_to :controller => \"" (skeleton-read "controller? " "items") "\"")

(define-skeleton rails-snip-reca ""
  > "redirect_to :controller => \"" (skeleton-read "controller? " "items")
  > "\", :action => \"" (skeleton-read "action? " "list") "\"")

(define-skeleton rails-snip-recai ""
  > "redirect_to :controller => \"" (skeleton-read "controller? " "items")
  > "\", :action => \"" (skeleton-read "action? " "show")
  > "\", :id => " (skeleton-read "id? " "@item"))

(define-skeleton rails-snip-flash ""
  > "flash[:" (skeleton-read "type? " "notice")
  > "] = \"" (skeleton-read "message? ") "\"")

(define-skeleton rails-snip-logi ""
  > "logger.info \"" (skeleton-read "message? ") "\"")

(define-skeleton rails-snip-params ""
  > "params[:" (skeleton-read "key? " "id") "]")

(define-skeleton rails-snip-session ""
  > "session[:" (skeleton-read "key? " "user") "]")

(define-skeleton rails-snip-erb-ft ""
  > "<%= form_tag :action => \"" (skeleton-read "action? " "update") "\" %>")

(define-skeleton rails-snip-erb-lia ""
  > "<%= link_to \"" (skeleton-read "title? ")
  > "\", :action => \"" (skeleton-read "action? " "index") "\" %>")

(define-skeleton rails-snip-erb-liai ""
  > "<%= link_to \"" (skeleton-read "title? ")
  > "\", :action => \"" (skeleton-read "action? " "edit")
  > "\", :id => " (skeleton-read "id? " "@item") " %>")

(define-skeleton rails-snip-erb-lic ""
  > "<%= link_to \"" (skeleton-read "title? ")
  > "\", :controller => \"" (skeleton-read "controller? " "items") "\" %>")

(define-skeleton rails-snip-erb-lica ""
  > "<%= link_to \"" (skeleton-read "title? ")
  > "\", :controller => \"" (skeleton-read "controller? " "items")
  > "\", :action => \"" (skeleton-read "action? " "index") "\" %>")

(define-skeleton rails-snip-erb-licai ""
  > "<%= link_to \"" (skeleton-read "title? ")
  > "\", :controller => \"" (skeleton-read "controller? " "items")
  > "\", :action => \"" (skeleton-read "action? " "edit")
  > "\", :id => " (skeleton-read "id? " "@item") " %>")

(define-skeleton rails-snip-erb-block ""
  > "<% " _ "  %>")

(define-skeleton rails-snip-erb-echo-block ""
  > "<%= " _ "  %>")

(defun rails-abbrev-init ()
  "Initialize ruby abbrev table"
  (define-abbrev ruby-mode-abbrev-table "ra"  "" 'rails-snip-ra)
  (define-abbrev ruby-mode-abbrev-table "ral" "" 'rails-snip-ral)
  (define-abbrev ruby-mode-abbrev-table "rf"  "" 'rails-snip-rf)
  (define-abbrev ruby-mode-abbrev-table "rfu" "" 'rails-snip-rfu)
  (define-abbrev ruby-mode-abbrev-table "ri"  "" 'rails-snip-ri)
  (define-abbrev ruby-mode-abbrev-table "ril" "" 'rails-snip-ril)
  (define-abbrev ruby-mode-abbrev-table "rit" "" 'rails-snip-rit)
  (define-abbrev ruby-mode-abbrev-table "rl"  "" 'rails-snip-rl)
  (define-abbrev ruby-mode-abbrev-table "rn"  "" 'rails-snip-rn)
  (define-abbrev ruby-mode-abbrev-table "rns"  "" 'rails-snip-rns)
  (define-abbrev ruby-mode-abbrev-table "rp"  "" 'rails-snip-rp)
  (define-abbrev ruby-mode-abbrev-table "rpc"  "" 'rails-snip-rpc)
  (define-abbrev ruby-mode-abbrev-table "rpl"  "" 'rails-snip-rpl)
  (define-abbrev ruby-mode-abbrev-table "rpo"  "" 'rails-snip-rpo)
  (define-abbrev ruby-mode-abbrev-table "rps"  "" 'rails-snip-rps)
  (define-abbrev ruby-mode-abbrev-table "rt"  "" 'rails-snip-rt)
  (define-abbrev ruby-mode-abbrev-table "rtl"  "" 'rails-snip-rtl)
  (define-abbrev ruby-mode-abbrev-table "rtlt"  "" 'rails-snip-rtlt)
  (define-abbrev ruby-mode-abbrev-table "rts"  "" 'rails-snip-rts)
  (define-abbrev ruby-mode-abbrev-table "rcea"  "" 'rails-snip-rcea)
  (define-abbrev ruby-mode-abbrev-table "rcec"  "" 'rails-snip-rcec)
  (define-abbrev ruby-mode-abbrev-table "rceca"  "" 'rails-snip-rceca)
  (define-abbrev ruby-mode-abbrev-table "rea"  "" 'rails-snip-rea)
  (define-abbrev ruby-mode-abbrev-table "reai"  "" 'rails-snip-reai)
  (define-abbrev ruby-mode-abbrev-table "rec"  "" 'rails-snip-rec)
  (define-abbrev ruby-mode-abbrev-table "reca"  "" 'rails-snip-reca)
  (define-abbrev ruby-mode-abbrev-table "recai"  "" 'rails-snip-recai)
  (define-abbrev ruby-mode-abbrev-table "flash"  "" 'rails-snip-flash)
  (define-abbrev ruby-mode-abbrev-table "logi"  "" 'rails-snip-logi)
  (define-abbrev ruby-mode-abbrev-table "session"  "" 'rails-snip-session)
  (define-abbrev ruby-mode-abbrev-table "params"  "" 'rails-snip-params))

(defun rails-erb-abbrev-init()
  (define-abbrev html-mode-abbrev-table "ft"  "" 'rails-snip-erb-ft)
  (define-abbrev html-mode-abbrev-table "lia"  "" 'rails-snip-erb-lia)
  (define-abbrev html-mode-abbrev-table "liai"  "" 'rails-snip-erb-liai)
  (define-abbrev html-mode-abbrev-table "lic"  "" 'rails-snip-erb-lic)
  (define-abbrev html-mode-abbrev-table "lica"  "" 'rails-snip-erb-lica)
  (define-abbrev html-mode-abbrev-table "licai"  "" 'rails-snip-erb-licai)
  (define-abbrev html-mode-abbrev-table "%"  "" 'rails-snip-erb-block)
  (define-abbrev html-mode-abbrev-table "%%"  "" 'rails-snip-erb-echo-block))

(defun ruby-indent-or-complete ()
  "Complete if point is at end of a word, otherwise indent line."
  (interactive)
  (if (looking-at "\\>")
      (hippie-expand nil)
    (ruby-indent-command)))


(defun ruby-newline-and-indent ()
  (interactive)
  (newline)
  (ruby-indent-command))


(defun rails-switch-to-view()
  (save-excursion
    (let (action path files)
      (search-backward-regexp "^[ ]*def \\([a-z_]+\\)")
      (setq action (match-string 1))
      (search-backward-regexp "^[ ]*class \\([a-zA-Z0-9_]+\\(::\\([a-zA-Z0-9_]+\\)\\)?\\)Controller[ ]+<")
      (setq path (rails-inflector-underscore (match-string 1)))
      (setq path (concat "app/views/" path "/"))

      (setq files (directory-files
                   (concat (rails-root) path)
                   nil
                   (concat "^" action (rails-make-template-regex))))

      (if (= 1 (list-length files))
          (progn
            (find-file (concat (rails-root) path (car files)))
            (message (concat path action))))

      (if (< 1 (list-length files))
         (let (items tmp file pos)
           (setq tmp files)
           (setq items (list))
           (while (car tmp)
             (add-to-list 'items (cons (car tmp) (car tmp)))
             (setq tmp (cdr tmp)))

           (setq pos (car (cddr (posn-at-point))))

           (setq file
                 (x-popup-menu
                  (list '(400 200) (selected-window))
                  (list "Please select.." (cons "Please select.." items ))))
           (if file
               (progn
                 (find-file (concat (rails-root) path file))
                 (message (concat path action)))
             )
           )
       )

      (if (> 1 (list-length files))
          (message (concat path action " not found")))
      )
    )
  )


(defun rails-switch-to-action()
  (let (file path action root)
    (setq file buffer-file-name)
    (string-match "views/\\([^/]+\\)/\\([^/\.]+\\)\\(/\\([^/\.]+\\)\\)?" file)
    (if (match-beginning 4)
        (progn
          (setq path
                (concat (substring file (match-beginning 1) (match-end 1))
                        "/"
                        (substring file (match-beginning 2) (match-end 2)) ))
          (setq path (concat path "_controller.rb"))
          (setq action (substring file (match-beginning 4) (match-end 4))))
      (progn
        (setq path (concat
                    (substring file (match-beginning 1) (match-end 1))
                    "_controller.rb" ))
        (setq action (substring file (match-beginning 2) (match-end 2))))
      )
    (setq root (rails-root))
    (setq path (concat "app/controllers/" path))
    (if (file-exists-p (concat root path))
        (progn
          (find-file (concat root path))
          (goto-char (point-min))
          (message (concat path "#" action))
          (if (search-forward-regexp (concat "^[ ]*def[ ]*" action))
              (recenter))))
    )
  )


(defun rails-switch-view-action()
  (interactive)
  (if (string-match "\\.rb$" buffer-file-name)
      (rails-switch-to-view)
    (rails-switch-to-action)))


(defun rails-inflector-underscore (camel-cased-word)
  (let* ((case-fold-search nil)
         (path (replace-regexp-in-string "::" "/" camel-cased-word))
         (path (replace-regexp-in-string "\\([A-Z]+\\)\\([A-Z][a-z]\\)" "\\1_\\2" path))
         (path (replace-regexp-in-string "\\([a-z\\d]\\)\\([A-Z]\\)" "\\1_\\2" path)))
    (downcase path)))


(defun rails-make-template-regex ()
  "Return regex to match rails view templates"
  (let (reg tmp it)
    (setq reg "\\.\\(")
    (setq tmp rails-templates-list)
    (while (setq it (car tmp))
      (progn
        (setq reg (concat reg it))
        (setq tmp (cdr tmp))
        (if (car tmp)
            (setq reg (concat reg "\\|"))
          (setq reg (concat reg "\\)$")))))
    (if reg reg)))


(defun rails-root ()
  "Return RAILS_ROOT"
  (let (curdir max found)
    (setq curdir default-directory)
    (setq max 10)
    (setq found nil)
    (while (and (not found) (> max 0))
      (progn
        (if (file-exists-p (concat curdir "config/environment.rb"))
            (progn
              (setq found t))
          (progn
            (setq curdir (concat curdir "../"))
            (setq max (- max 1))))))
    (if found curdir)))


;; replace in autorevert.el
(defun auto-revert-tail-handler ()
  (let ((size (nth 7 (file-attributes buffer-file-name)))
        (modified (buffer-modified-p))
        buffer-read-only    ; ignore
        (file buffer-file-name)
        buffer-file-name)   ; ignore that file has changed
    (when (> size auto-revert-tail-pos)
      (undo-boundary)
      (save-restriction
        (widen)
        (save-excursion
          (let ((cur-point (point-max)))
            (goto-char (point-max))
            (insert-file-contents file nil auto-revert-tail-pos size)
            (ansi-color-apply-on-region cur-point (point-max)))))
      (undo-boundary)
      (setq auto-revert-tail-pos size)
      (set-buffer-modified-p nil)))
  (set-visited-file-modtime))


(defun rails-open-log (env)
  (let ((root (rails-root)))
    (if root
        (progn
          (if (file-exists-p (concat root "/log/" env ".log"))
              (progn
                (find-file (concat root "/log/" env ".log"))
                (set-buffer-file-coding-system 'utf-8)
                (ansi-color-apply-on-region (point-min) (point-max))
                (set-buffer-modified-p nil)
                (rails-minor-mode t)
                (goto-char (point-max))
                (setq auto-revert-interval 1)
                (setq auto-window-vscroll t)
                (auto-revert-tail-mode t)))))))

(defun rails-webrick-sentinel (proc msg)
  (if (memq (process-status proc) '(exit signal))
        (message "WEBrick stopped")))


(defun rails-webrick-open-browser()
  (interactive)
  (browse-url rails-webrick-url))


(defun rails-webrick-open-buffer()
  (interactive)
  (switch-to-buffer rails-webrick-buffer-name))


(defun rails-webrick-process-status()
  (let (st)
    (setq st (get-buffer-process rails-webrick-buffer-name))
    (if st t nil)))

(defun rails-webrick-process-stop()
  (interactive)
  (let (proc)
    (setq proc (get-buffer-process rails-webrick-buffer-name))
    (if proc
        (kill-process proc))))


(defun rails-webrick-process(env)
  (let (proc dir root)
    (setq proc (get-buffer-process rails-webrick-buffer-name))
    (unless proc
      (progn
        (setq root (rails-root))
        (if root
            (progn
              (setq dir default-directory)
              (setq default-directory root)
              (setq proc
                     (apply 'start-process-shell-command
                      rails-ruby-command
                      rails-webrick-buffer-name
                      rails-ruby-command
                      (list (concat root "script/server")
                            (concat " -e " env)
                            (concat " -p " rails-webrick-port))))
              (set-process-filter proc 'rails-webrick-filter)
              (set-process-sentinel proc 'rails-webrick-sentinel)
              (setq default-directory dir)
              (message (concat "Webrick(" env  ") started with port " rails-webrick-port)))
          (progn
            (message "RAILS_ROOT not found")))))))


(defun rails-webrick-filter (process line)
  (let ((buffer (current-buffer)))
    (switch-to-buffer rails-webrick-buffer-name)
    (goto-char(point-min))
    (insert line)
    (switch-to-buffer buffer)))


(defun rails-ri-start (func)
  ""
  (interactive "Mname? ")
  (if func
      (let ((buf (buffer-name)))
        (unless (string= buf "*ri*")
          (switch-to-buffer-other-window "*ri*"))
        (setq buffer-read-only nil)
        (kill-region (point-min) (point-max))
        (message (concat "Please wait..."))
        (call-process "ri" nil "*ri*" t func)
        (setq buffer-read-only t)
        (local-set-key (kbd "<return>") 'rails-ri-at-point)
        (goto-char (point-min)))))


(defun rails-ri-at-point ()
  (interactive)
  (rails-ri-start (thing-at-point 'symbol)))


(define-minor-mode rails-minor-mode
  "RubyOnRails"
  nil
  " RoR"
  (list
   (cons [menu-bar] rails-minor-mode-menu-bar-map)
   '("\C-t" . rails-switch-view-action))
  (rails-abbrev-init)

  (local-set-key (kbd "<f1>") 'rails-ri-at-point)
  (local-set-key (kbd "C-<f1>") 'rails-ri-start)

  ;; WEBrick
  (define-key rails-minor-mode-menu-bar-map [rails webrick buffer]
    '(menu-item "Show buffer"
                rails-webrick-open-buffer
                :enable (rails-webrick-process-status)))
  (define-key rails-minor-mode-menu-bar-map [rails webrick url]
    '(menu-item "Open browser"
                rails-webrick-open-browser
                :enable (rails-webrick-process-status)))
  (define-key rails-minor-mode-menu-bar-map [rails webrick stop]
    '(menu-item "Stop"
                rails-webrick-process-stop
                :enable (rails-webrick-process-status)))
  (define-key rails-minor-mode-menu-bar-map [rails webrick test]
    '(menu-item "Start test"
                (lambda() (interactive)
                  (rails-webrick-process "test"))
                :enable (not (rails-webrick-process-status))))
  (define-key rails-minor-mode-menu-bar-map [rails webrick production]
    '(menu-item "Start production"
                (lambda() (interactive)
                  (rails-webrick-process "production"))
                :enable (not (rails-webrick-process-status))))
  (define-key rails-minor-mode-menu-bar-map [rails webrick development]
    '(menu-item "Start development"
                (lambda() (interactive)
                  (rails-webrick-process "development"))
                :enable (not (rails-webrick-process-status)))))


(add-hook 'ruby-mode-hook
          (lambda()
            (rails-minor-mode t)
            (local-set-key (kbd "<tab>") 'ruby-indent-or-complete)
            (local-set-key (kbd "<return>") 'ruby-newline-and-indent)
            (local-set-key (kbd "<del>") 'backward-delete-char-untabify)))


(add-hook 'speedbar-mode-hook
          (lambda()
            (speedbar-add-supported-extension "\\.rb")))

(add-hook 'find-file-hooks
          (lambda()
            (if (and (string-match (rails-make-template-regex) buffer-file-name)
                     (rails-root))
                (progn
                  (rails-minor-mode)
                  (rails-erb-abbrev-init)))))
(provide 'rails)