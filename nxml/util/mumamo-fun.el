;;; mumamo-fun.el --- Multi major mode functions
;;
;; Author: Lennart Borgman (lennart O borgman A gmail O com)
;; Created: 2008-03-09T01:35:21+0100 Sun
;; Version: 0.5
;; Last-Updated: 2008-03-09T03:09:31+0100 Sun
;; URL:
;; Keywords:
;; Compatibility:
;;
;; Features that might be required by this library:
;;
;;   `cl', `mumamo', `sgml-mode'.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;; Defines some "multi major modes" functions.  See mumamo.el for more
;; information.
;;
;;;; Usage:
;;
;;  See mumamo.el for how to use the multi major mode functions
;;  defined here.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Change log:
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

(eval-when-compile (add-to-list 'load-path default-directory))
(require 'mumamo)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Chunk search routines for XHTML things

(defun mumamo-chunk-attr=(pos min max attr= attr=is-regex attr-regex submode)
  "This should work similar to `mumamo-find-possible-chunk'.
See `mumamo-chunk-style=' for an example of use."
  ;; 1- for the case that pos is at the " before the attribute value.
  (mumamo-condition-case err
      (progn
        (goto-char (1- pos))
        (let ((prev-attr= (if attr=is-regex
                              (re-search-backward attr= min t)
                            (search-backward attr= min t)))
              prev-attr-sure
              next-attr=
              start
              end
              exc-mode
              exc-start-prev
              exc-end-prev
              exc-start-next
              exc-end-next
              )
          ;; make sure if we have find prev-attr= or not
          (while (and prev-attr=
                      (not prev-attr-sure))
            (if (not (search-backward "<" min t))
                (setq prev-attr-sure 'none)
              (if (looking-at attr-regex)
                  (setq prev-attr-sure 'found)
                (setq prev-attr= (if attr=is-regex
                                     (re-search-backward attr= min t)
                                   (search-backward attr= min t))))))
          ;; find prev change and if inside style= the next change
;;;           (when (and prev-attr=
;;;                      (search-backward "<" min t))
;;;             (when (looking-at attr-regex)
          (when (and prev-attr= (eq prev-attr-sure 'found))
              (setq exc-start-prev (match-beginning 1))
              (setq exc-end-prev   (match-end 1))
              (when (<= exc-start-prev pos)
                (if (>= pos exc-end-prev)
                    (setq start exc-end-prev)
                  (setq exc-mode submode)
                  (setq start exc-start-prev)
                  (setq end exc-end-prev))))
            ;;)
          ;; find next change
          (unless end
            (if start
                (goto-char start)
              (goto-char pos)
              (search-backward "<" min t))
            (setq next-attr= (if attr=is-regex
                                 (re-search-forward attr= max t)
                               (search-forward attr= max t)))
            (when (and next-attr=
                       (search-backward "<" min t))
              (when (looking-at attr-regex)
                (setq end (match-beginning 1)))))
          (when start (assert (<= start pos) t))
          (when end   (assert (<= pos end) t))
          (goto-char pos)
          ;;(list start end exc-mode t nil pos)))
          (list start end exc-mode)))
    (error
     (mumamo-display-error 'mumamo-chunk-attr= "%s"
                           (error-message-string err)))))

;;;; xml pi

(defvar mumamo-xml-pi-mode-alist
  '(("php"   . php-mode)
    ("python" . python-mode))
  "Alist used by `mumamo-chunk-xml-pi' to get exception mode." )

(defun mumamo-search-bw-exc-start-xml-pi-1 (pos min lt-chars)
  "Helper for `mumamo-chunk-xml-pi'.
POS is where to start search and MIN is where to stop.

Actual use is in `mumamo-search-bw-exc-start-xml-pi' and
`mumamo-search-bw-exc-start-xml-pi2'.  Those functions are
identical except for the LT-CHARS argument.  The purpose for the
second function was to be able to edit PHP code embedded in
arguments which contains <?.  This string is illegal in XML when
not used for XML instructions.  The parsing routines from
`nxml-mode' gets very confused by that string.  The second
routine used �? as a temporary replacement for <? during editing.

However I did not managed to safely convert between <? and �?
upon reading and saving files so I have withdrawed the visual
support for this from nXhtml where I originally used it.  I keep
the code in case I or someone else would like to work on it
again.  The implementation is in nxthml-strval.el."
  (let ((exc-start (mumamo-chunk-start-bw-str (+ pos 2) min lt-chars))
        spec
        exc-mode
        hit)
    (when exc-start
      (goto-char exc-start)
      (when (and (not (looking-at "xml"))
                 (looking-at (rx (0+ (any "a-z")))))
        (setq exc-start (match-end 0))
        (setq spec (match-string-no-properties 0))
        (setq exc-mode (assoc spec mumamo-xml-pi-mode-alist))
        (when exc-mode (setq exc-mode (cdr exc-mode)))
        (setq hit t)
        )
      (when hit
        (unless exc-mode
          (setq exc-mode 'fundamental-mode))
        (when (<= exc-start pos)
          (cons exc-start exc-mode))))))

(defun mumamo-search-bw-exc-start-xml-pi (pos min)
  "Helper for `mumamo-chunk-xml-pi'.
POS is where to start search and MIN is where to stop."
  (mumamo-search-bw-exc-start-xml-pi-1 pos min "<?"))

(defun mumamo-xml-pi-end-is-xml-end (pos)
  "Return t if the ?> at pos is end of <?xml."
  (when (> 1000 pos)
    (assert (and (= (char-after pos) ??)
                 (= (char-after (1+ pos)) ?>)))
    (save-excursion
      (save-restriction
        (widen)
        (save-match-data
          (when (search-backward "<" (- pos 150) t)
            (when (looking-at (rx line-start "<\?xml" (1+ space)))
              (mumamo-msgfntfy "mumamo-xml-pi-end-is-xml-end %s => t" pos)
              t)))))))

(defun mumamo-search-bw-exc-end-xml-pi (pos min)
  "Helper for `mumamo-chunk-xml-pi'.
POS is where to start search and MIN is where to stop."
  ;; Fix me: merge xml header
  (mumamo-msgfntfy "mumamo-search-bw-exc-end-xml-pi %s %s" pos min)
  (let ((end-pos (mumamo-chunk-end-bw-str pos min "?>")))
    (mumamo-msgfntfy "  end-pos=%s" end-pos)
    (when end-pos
      (unless (or (mumamo-xml-pi-end-is-xml-end end-pos)
;;;                   (progn
;;;                     (save-restriction
;;;                       (widen)
;;;                       (message "not xml-end, end-pos=%s, cb=%s, char-after end-pos - 1=%s, point=%s, point-max=%s, sub=%s"
;;;                                end-pos
;;;                                (current-buffer)
;;;                                (char-after (- end-pos 1))
;;;                                (point)
;;;                                (point-max)
;;;                                (buffer-substring-no-properties (1- end-pos) end-pos)
;;;                                ))
;;;                     nil)
                  (= (save-restriction
                       (widen)
                       (char-after (- end-pos 1)))
                     ?<))
        (mumamo-msgfntfy "  returning end-pos")
        end-pos))))

(defun mumamo-search-fw-exc-end-xml-pi (pos max)
  "Helper for `mumamo-chunk-xml-pi'.
POS is where to start search and MAX is where to stop."
  ;; Fix me: merge xml header
  (let ((end-pos (mumamo-chunk-end-fw-str pos max "?>")))
    (when end-pos
      (unless (mumamo-xml-pi-end-is-xml-end end-pos)
        end-pos))))

(defun mumamo-search-fw-exc-start-xml-pi-1 (pos max lt-chars)
  "Helper for `mumamo-chunk-xml-pi'.
POS is where to start search and MAX is where to stop.

Used in `mumamo-search-fw-exc-start-xml-pi' and
`mumamo-search-fw-exc-start-xml-pi2'.  For an explanation of
LT-CHARS see `mumamo-search-bw-exc-start-xml-pi-1'."
  (goto-char pos)
  (skip-chars-backward "a-zA-Z")
  (let ((end-out (mumamo-chunk-start-fw-str (point) max lt-chars)))
    (when (looking-at "xml")
      (if t ;(= 1 pos)
          (setq end-out (mumamo-chunk-start-fw-str (1+ (point)) max lt-chars))
        (setq end-out nil)))
    (when end-out
      ;; Get end-out:
      (if (looking-at (rx (0+ (any "a-z"))))
          (setq end-out (match-end 0))
        (setq end-out nil)))
    end-out))

(defun mumamo-search-fw-exc-start-xml-pi (pos max)
  "Helper for `mumamo-chunk-xml-pi'.
POS is where to start search and MAX is where to stop."
  (mumamo-search-fw-exc-start-xml-pi-1 pos max "<?"))

(defun mumamo-chunk-xml-pi (pos min max)
  "Find process instruction, <? ... ?>.  Return range and wanted mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-exc-start-xml-pi
                              'mumamo-search-bw-exc-end-xml-pi
                              'mumamo-search-fw-exc-start-xml-pi
                              'mumamo-search-fw-exc-end-xml-pi))

;; (defun mumamo-search-bw-exc-start-xml-pi2 (pos min)
;;   "Helper for `mumamo-chunk-xml-pi2'.
;; POS is where to start search and MIN is where to stop."
;;   (mumamo-search-bw-exc-start-xml-pi-1 pos min "�?"))

;; (defun mumamo-search-bw-exc-end-xml-pi2 (pos min)
;;   "Helper for `mumamo-chunk-xml-pi2'.
;; POS is where to start search and MIN is where to stop."
;;   (mumamo-chunk-end-bw-str pos min "?�"))

;; (defun mumamo-search-fw-exc-end-xml-pi2 (pos max)
;;   "Helper for `mumamo-chunk-xml-pi2'.
;; POS is where to start search and MAX is where to stop."
;;   (mumamo-chunk-end-fw-str pos max "?�"))

;; (defun mumamo-search-fw-exc-start-xml-pi2 (pos max)
;;   "Helper for `mumamo-chunk-xml-pi2'.
;; POS is where to start search and MAX is where to stop."
;;   (mumamo-search-fw-exc-start-xml-pi-1 pos max "�?"))

;; (defun mumamo-chunk-xml-pi2(pos min max)
;;   "Find faked process instruction, <? ... ?>.  Return range and wanted mode.
;; See `mumamo-find-possible-chunk' for POS, MIN and MAX.

;; See `mumamo-search-bw-exc-start-xml-pi-1' for the meaning of 'faked' here."
;;   (mumamo-find-possible-chunk pos min max
;;                               'mumamo-search-bw-exc-start-xml-pi2
;;                               'mumamo-search-bw-exc-end-xml-pi2
;;                               'mumamo-search-fw-exc-start-xml-pi2
;;                               'mumamo-search-fw-exc-end-xml-pi2))

;;;; <style ...>

(defconst mumamo-style-tag-start-regex
  (rx "<style"
      space
      (0+ (not (any ">")))
      "type"
      (0+ space)
      "="
      (0+ space)
      ?\"
      "text/css"
      ?\"
      (0+ (not (any ">")))
      ">"
      ;; FIX-ME: Commented out because of bug in Emacs
      ;;
      ;;(optional (0+ space) "<![CDATA[")
      ))

(defun mumamo-search-bw-exc-start-inlined-style (pos min)
  "Helper for `mumamo-chunk-inlined-style'.
POS is where to start search and MIN is where to stop."
  (goto-char (+ pos 6))
  (let ((marker-start (search-backward "<style" min t))
        exc-mode
        exc-start)
    (when marker-start
      (when (looking-at mumamo-style-tag-start-regex)
        (setq exc-start (match-end 0))
        (goto-char exc-start)
        (when (<= exc-start pos)
          ;;(cons (point) 'css-mode)
          (list (point) 'css-mode '(nxml-mode))
          )
        ))))

(defun mumamo-search-bw-exc-end-inlined-style (pos min)
  "Helper for `mumamo-chunk-inlined-style'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-str pos min "</style>"))

(defun mumamo-search-fw-exc-start-inlined-style (pos max)
  "Helper for `mumamo-chunk-inlined-style'.
POS is where to start search and MAX is where to stop."
  (goto-char (1+ pos))
  (skip-chars-backward "^<")
  ;; Handle <![CDATA[
  (when (and
         (eq ?< (char-before))
         (eq ?! (char-after))
         (not (bobp)))
    (backward-char)
    (skip-chars-backward "^<"))
  (unless (bobp)
    (backward-char 1))
  (let ((exc-start (search-forward "<style" max t))
        exc-mode)
    (when exc-start
      (goto-char (- exc-start 6))
      (when (looking-at mumamo-style-tag-start-regex)
        (goto-char (match-end 0))
        (point)
        ))))

(defun mumamo-search-fw-exc-end-inlined-style (pos max)
  "Helper for `mumamo-chunk-inlined-style'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-str pos max "</style>"))

(defun mumamo-chunk-inlined-style (pos min max)
  "Find <style>...</style>.  Return range and 'css-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-exc-start-inlined-style
                              'mumamo-search-bw-exc-end-inlined-style
                              'mumamo-search-fw-exc-start-inlined-style
                              'mumamo-search-fw-exc-end-inlined-style))

;;;; <script ...>

(defconst mumamo-script-tag-start-regex
  (rx "<script"
      space
      (0+ (not (any ">")))
      "type"
      (0+ space)
      "="
      (0+ space)
      ?\"
      ;;(or "text" "application")
      ;;"/"
      ;;(or "javascript" "ecmascript")
      "text/javascript"
      ?\"
      (0+ (not (any ">")))
      ">"
      ;; FIX-ME: Commented out because of bug in Emacs
      ;;
      ;;(optional (0+ space) "<![CDATA[" )
      ))

(defun mumamo-search-bw-exc-start-inlined-script (pos min)
  "Helper for `mumamo-chunk-inlined-script'.
POS is where to start search and MIN is where to stop."
  (goto-char (+ pos 7))
  (let ((marker-start (search-backward "<script" min t))
        exc-mode
        exc-start)
    (when marker-start
      (when (looking-at mumamo-script-tag-start-regex)
        (setq exc-start (match-end 0))
        (goto-char exc-start)
        (when (<= exc-start pos)
          ;;(cons (point) 'javascript-mode)
          (list (point) 'javascript-mode '(nxml-mode))
          )
        ))))

(defun mumamo-search-bw-exc-end-inlined-script (pos min)
  "Helper for `mumamo-chunk-inlined-script'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-str pos min "</script>"))

(defun mumamo-search-fw-exc-start-inlined-script (pos max)
  "Helper for `mumamo-chunk-inlined-script'.
POS is where to start search and MAX is where to stop."
  (goto-char (1+ pos))
  (skip-chars-backward "^<")
  ;; Handle <![CDATA[
  (when (and
         (eq ?< (char-before))
         (eq ?! (char-after))
         (not (bobp)))
    (backward-char)
    (skip-chars-backward "^<"))
  (unless (bobp)
    (backward-char 1))
  (let ((exc-start (search-forward "<script" max t))
        exc-mode)
    (when exc-start
      (goto-char (- exc-start 7))
      (when (looking-at mumamo-script-tag-start-regex)
        (goto-char (match-end 0))
        (point)
        ))))

(defun mumamo-search-fw-exc-end-inlined-script (pos max)
  "Helper for `mumamo-chunk-inlined-script'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-str pos max "</script>"))

(defun mumamo-chunk-inlined-script (pos min max)
  "Find <script>...</script>.  Return range and 'javascript-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-exc-start-inlined-script
                              'mumamo-search-bw-exc-end-inlined-script
                              'mumamo-search-fw-exc-start-inlined-script
                              'mumamo-search-fw-exc-end-inlined-script))

;;;; on[a-z]+=\"javascript:"

(defconst mumamo-onjs=start-regex
  (rx "<"
      (0+ (not (any ">")))
      space
      "on"
      (1+ (any "a-za-z"))
      "="
      (0+ space)
      ?\"
      (submatch
       "javascript:"
       (0+
        (not (any "\""))))
      ))

(defun mumamo-chunk-onjs=(pos min max)
  "Find javascript on...=\"...\".  Return range and 'javascript-mode."
  (mumamo-chunk-attr= pos min max "on[a-z]+=" t mumamo-onjs=start-regex
                      'javascript-mode))

;;;; style=

(defconst mumamo-style=start-regex
  (rx "<"
      (0+ (not (any ">")))
      space
      "style="
      (0+ space)
      ?\"
      (submatch
       (0+
        (not (any "\""))))
      ))

(defun mumamo-chunk-style=(pos min max)
  "Find style=\"...\".  Return range and 'css-mode."
  (mumamo-chunk-attr= pos min max "style=" nil mumamo-style=start-regex
                      'css-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; HTML w html-mode

;;;###autoload
(define-mumamo-multi-major-mode html-mumamo
  "Turn on multiple major modes for (X)HTML with main mode `html-mode'.
This covers inlined style and javascript and PHP."
  ("HTML Family" html-mode
   (mumamo-chunk-xml-pi
    mumamo-chunk-inlined-style
    mumamo-chunk-inlined-script
    mumamo-chunk-style=
    mumamo-chunk-onjs=
    )))
(define-mumamo-multi-major-mode xml-pi-only-mumamo
  "Test"
  ("HTML Family" html-mode
   (mumamo-chunk-xml-pi
    )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; XHTML w nxml-mode

;;;###autoload
(define-mumamo-multi-major-mode nxml-mumamo
  "Turn on multiple major modes for (X)HTML with main mode `nxml-mode'.
This covers inlined style and javascript and PHP."
    ("nXml Family" nxml-mode
     (mumamo-chunk-xml-pi
      mumamo-chunk-inlined-style
      mumamo-chunk-inlined-script
      mumamo-chunk-style=
      mumamo-chunk-onjs=
      )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Embperl

(defun mumamo-chunk-embperl-<- (pos min max)
  "Find [- ... -], return range and `perl-mode'.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-quick-static-chunk pos min max "[-" "-]" nil 'perl-mode t))

(defun mumamo-chunk-embperl-<+ (pos min max)
  "Find [+ ... +], return range and `perl-mode'.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-quick-static-chunk pos min max "[+" "+]" nil 'perl-mode nil))

(defun mumamo-chunk-embperl-<! (pos min max)
  "Find [! ... !], return range and `perl-mode'.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-quick-static-chunk pos min max "[!" "!]" nil 'perl-mode t))

(defun mumamo-chunk-embperl-<$ (pos min max)
  "Find [$ ... $], return range and `perl-mode'.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  ;; This is a bit tricky since [$var] etc must be avoided.
  (let* ((begin-mark "[$")
         (end-mark "$]")
         (good-chars '(32 ;space
                       10 ;line feed
                       9  ;tab
                       ))
         (search-bw-exc-start (lambda (pos min)
                                (let ((not-found t)
                                      (next-char nil)
                                      (exc-start (mumamo-chunk-start-bw-str
                                                  pos min begin-mark))
                                      (here (point)))
                                  (while (and not-found
                                              exc-start)
                                    (setq next-char (char-after (+ (point) 2)))
                                    (if (memq next-char good-chars)
                                        (setq not-found nil)
                                      (setq exc-start
                                            (search-backward begin-mark
                                                             min t))))
                                  (when (and exc-start
                                             (<= exc-start pos))
                                    (cons exc-start 'perl-mode)))))
         (search-bw-exc-end (lambda (pos min)
                              (mumamo-chunk-end-bw-str pos min end-mark)))
         (search-fw-exc-start (lambda (pos max)
                                (let ((not-found t)
                                      (next-char nil)
                                      (exc-start (mumamo-chunk-start-fw-str
                                                  pos max begin-mark))
                                      (here (point)))
                                  (while (and not-found
                                              exc-start)
                                    (setq next-char (char-after))
                                    (if (memq next-char good-chars)
                                        (setq not-found nil)
                                      (setq exc-start
                                            (search-forward begin-mark
                                                            max t))))
                                  exc-start)))
         (search-fw-exc-end (lambda (pos max)
                              (mumamo-chunk-end-fw-str pos max end-mark)))
         )
    (mumamo-find-possible-chunk pos min max
                                search-bw-exc-start
                                search-bw-exc-end
                                search-fw-exc-start
                                search-fw-exc-end)))

;;;###autoload
(define-mumamo-multi-major-mode embperl-html-mumamo
  "Turn on multiple major modes for Embperl files with main mode `html-mode'.
This also covers inlined style and javascript."
    ("Embperl HTML Family" html-mode
     (mumamo-chunk-embperl-<-
      mumamo-chunk-embperl-<+
      mumamo-chunk-embperl-<!
      mumamo-chunk-embperl-<$
      mumamo-chunk-inlined-style
      mumamo-chunk-inlined-script
      mumamo-chunk-style=
      mumamo-chunk-onjs=
     )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; django

(defun mumamo-chunk-django4(pos min max)
  "Find {% comment %}.  Return range and `django-mode'.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-exc-start-django4
                              'mumamo-search-bw-exc-end-django4
                              'mumamo-search-fw-exc-start-django4
                              'mumamo-search-fw-exc-end-django4))

(defun mumamo-chunk-django3(pos min max)
  "Find {# ... #}.  Return range and `django-mode'.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-exc-start-django3
                              'mumamo-search-bw-exc-end-django3
                              'mumamo-search-fw-exc-start-django3
                              'mumamo-search-fw-exc-end-django3))

(defun mumamo-chunk-django2(pos min max)
  "Find {{ ... }}.  Return range and `django-mode'.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-exc-start-django2
                              'mumamo-search-bw-exc-end-django2
                              'mumamo-search-fw-exc-start-django2
                              'mumamo-search-fw-exc-end-django2))

(defun mumamo-chunk-django (pos min max)
  "Find {% ... %}.  Return range and `django-mode'.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-exc-start-django
                              'mumamo-search-bw-exc-end-django
                              'mumamo-search-fw-exc-start-django
                              'mumamo-search-fw-exc-end-django))

(defun mumamo-search-bw-exc-start-django (pos min)
  "Helper for `mumamo-chunk-django'.
POS is where to start search and MIN is where to stop."
  (let ((exc-start (mumamo-chunk-start-bw-str-inc pos min "{%")))
    (and exc-start
         (<= exc-start pos)
         (cons exc-start 'django-mode))))

(defun mumamo-search-bw-exc-start-django2(pos min)
  "Helper for `mumamo-chunk-django2'.
POS is where to start search and MIN is where to stop."
  (let ((exc-start (mumamo-chunk-start-bw-str-inc pos min "{{")))
    (and exc-start
         (<= exc-start pos)
         (cons exc-start 'django-mode))))

(defun mumamo-search-bw-exc-start-django3(pos min)
  "Helper for `mumamo-chunk-django3'.
POS is where to start search and MIN is where to stop."
  (let ((exc-start (mumamo-chunk-start-bw-str-inc pos min "{#")))
    (and exc-start
         (<= exc-start pos)
         (cons exc-start 'django-mode))))

(defun mumamo-search-bw-exc-start-django4(pos min)
  "Helper for `mumamo-chunk-django4'.
POS is where to start search and MIN is where to stop."
  (let ((exc-start (mumamo-chunk-start-bw-str-inc pos min
                                                       "{% comment %}")))
    (and exc-start
         (<= exc-start pos)
         (cons exc-start 'django-mode))))

(defun mumamo-search-bw-exc-end-django (pos min)
  "Helper for `mumamo-chunk-django'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-str-inc pos min "%}"))

(defun mumamo-search-bw-exc-end-django2(pos min)
  "Helper for `mumamo-chunk-django2'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-str-inc pos min "}}"))

(defun mumamo-search-bw-exc-end-django3(pos min)
  "Helper for `mumamo-chunk-django3'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-str-inc pos min "#}"))

(defun mumamo-search-bw-exc-end-django4(pos min)
  "Helper for `mumamo-chunk-django4'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-str-inc pos min "{% endcomment %}"))

(defun mumamo-search-fw-exc-start-django (pos max)
  "Helper for `mumamo-chunk-django'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-start-fw-str-inc pos max "{%"))

(defun mumamo-search-fw-exc-start-django2(pos max)
  "Helper for `mumamo-chunk-django2'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-start-fw-str-inc pos max "{{"))

(defun mumamo-search-fw-exc-start-django3(pos max)
  "Helper for `mumamo-chunk-django3'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-start-fw-str-inc pos max "{#"))

(defun mumamo-search-fw-exc-start-django4(pos max)
  "Helper for `mumamo-chunk-django4'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-start-fw-str-inc pos max "{% comment %}"))

(defun mumamo-search-fw-exc-end-django (pos max)
  "Helper for `mumamo-chunk-django'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-str-inc pos max "%}"))

(defun mumamo-search-fw-exc-end-django2(pos max)
  "Helper for `mumamo-chunk-django2'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-str-inc pos max "}}"))

(defun mumamo-search-fw-exc-end-django3(pos max)
  "Helper for `mumamo-chunk-django3'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-str-inc pos max "#}"))

(defun mumamo-search-fw-exc-end-django4(pos max)
  "Helper for `mumamo-chunk-django4'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-str-inc pos max "{% endcomment %}"))

;;;###autoload
(define-mumamo-multi-major-mode django-html-mumamo
  "Turn on multiple major modes for Django with main mode `html-mode'.
This also covers inlined style and javascript."
  ("Django HTML Family" html-mode
   (mumamo-chunk-django4
    mumamo-chunk-django
    mumamo-chunk-django2
    mumamo-chunk-django3
    mumamo-chunk-inlined-style
    mumamo-chunk-inlined-script
    mumamo-chunk-style=
    mumamo-chunk-onjs=
    )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Genshi / kid

;; {% python ... %}
(defun mumamo-chunk-genshi%(pos min max)
  "Find {% python ... %}.  Return range and `genshi-mode'.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-quick-static-chunk pos min max "{% python" "%}" nil 'python-mode t))

;; ${expr}
(defun mumamo-chunk-genshi$(pos min max)
  "Find ${ ... }, return range and `python-mode'.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-quick-static-chunk pos min max "${" "}" nil 'python-mode t))

;;;###autoload
(define-mumamo-multi-major-mode genshi-html-mumamo
  "Turn on multiple major modes for Genshi with main mode `html-mode'.
This also covers inlined style and javascript."
  ("Genshi HTML Family" html-mode
   (
    mumamo-chunk-genshi%
    mumamo-chunk-genshi$
    mumamo-chunk-xml-pi
    mumamo-chunk-inlined-style
    mumamo-chunk-inlined-script
    mumamo-chunk-style=
    mumamo-chunk-onjs=
    )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; MJT

;; ${expr}
(defun mumamo-chunk-mjt$(pos min max)
  "Find ${ ... }, return range and `javascript-mode'.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-quick-static-chunk pos min max "${" "}" nil 'javascript-mode t))

;;;###autoload
(define-mumamo-multi-major-mode mjt-html-mumamo
  "Turn on multiple major modes for MJT with main mode `html-mode'.
This also covers inlined style and javascript."
  ("MJT HTML Family" html-mode
   (
    mumamo-chunk-mjt$
    mumamo-chunk-xml-pi
    mumamo-chunk-inlined-style
    mumamo-chunk-inlined-script
    mumamo-chunk-style=
    mumamo-chunk-onjs=
    )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; smarty

(defun mumamo-chunk-smarty (pos min max)
  "Find { ... }.  Return range and 'smarty-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-exc-start-smarty
                              'mumamo-search-bw-exc-end-smarty
                              'mumamo-search-fw-exc-start-smarty
                              'mumamo-search-fw-exc-end-smarty))

(defun mumamo-search-bw-exc-start-smarty (pos min)
  "Helper for `mumamo-chunk-smarty'.
POS is where to start search and MIN is where to stop."
  (let ((exc-start (mumamo-chunk-start-bw-str-inc pos min "{")))
    (when (and exc-start
               (<= exc-start pos))
      (cons exc-start 'smarty-mode))))

(defun mumamo-search-bw-exc-end-smarty (pos min)
  "Helper for `mumamo-chunk-smarty'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-str-inc pos min "}"))

(defun mumamo-search-fw-exc-start-smarty (pos max)
  "Helper for `mumamo-chunk-smarty'.
POS is where to start search and MAX is where to stop."
  (let ((end-out (mumamo-chunk-start-fw-str-inc pos max "{")))
    end-out))

(defun mumamo-search-fw-exc-end-smarty (pos max)
  "Helper for `mumamo-chunk-smarty'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-str-inc pos max "}"))

;;;###autoload
(define-mumamo-multi-major-mode smarty-html-mumamo
  "Turn on multiple major modes for Smarty with main mode `html-mode'.
This also covers inlined style and javascript."
  ("Smarty HTML Family" html-mode
   (mumamo-chunk-xml-pi
    mumamo-chunk-smarty
    mumamo-chunk-style=
    mumamo-chunk-onjs=
    )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; jsp

(defun mumamo-chunk-jsp (pos min max)
  "Find <% ... %>.  Return range and 'java-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-exc-start-jsp
                              'mumamo-search-bw-exc-end-jsp
                              'mumamo-search-fw-exc-start-jsp
                              'mumamo-search-fw-exc-end-jsp))

(defun mumamo-search-bw-exc-start-jsp (pos min)
  "Helper for `mumamo-chunk-jsp'.
POS is where to start search and MIN is where to stop."
  (let ((exc-start (mumamo-chunk-start-bw-str pos min "<%")))
    (when (and exc-start
               (<= exc-start pos))
      (cons exc-start 'java-mode))))

(defun mumamo-search-bw-exc-end-jsp (pos min)
  "Helper for `mumamo-chunk-jsp'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-str pos min "%>"))

(defun mumamo-search-fw-exc-start-jsp (pos max)
  "Helper for `mumamo-chunk-jsp'.
POS is where to start search and MAX is where to stop."
  (let ((end-out (mumamo-chunk-start-fw-str pos max "<%")))
    end-out))

(defun mumamo-search-fw-exc-end-jsp (pos max)
  "Helper for `mumamo-chunk-jsp'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-str pos max "%>"))

;;;###autoload
(define-mumamo-multi-major-mode jsp-html-mumamo
  "Turn on multiple major modes for JSP with main mode `html-mode'.
This also covers inlined style and javascript."
    ("JSP HTML Family" html-mode
     (mumamo-chunk-jsp
      mumamo-chunk-inlined-style
      mumamo-chunk-inlined-script
      mumamo-chunk-style=
      mumamo-chunk-onjs=
      )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; eruby

(defun mumamo-chunk-eruby (pos min max)
  "Find <% ... %>.  Return range and 'ruby-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-quick-static-chunk pos min max "<%" "%>" t 'ruby-mode t))
;;;   (mumamo-find-possible-chunk pos min max
;;;                               'mumamo-search-bw-exc-start-ruby
;;;                               'mumamo-search-bw-exc-end-jsp
;;;                               'mumamo-search-fw-exc-start-jsp
;;;                               'mumamo-search-fw-exc-end-jsp))

(defun mumamo-search-bw-exc-start-ruby (pos min)
  "Helper for `mumamo-chunk-ruby'.
POS is where to start search and MIN is where to stop."
  (let ((exc-start (mumamo-chunk-start-bw-str pos min "<%")))
    (when (and exc-start
               (<= exc-start pos))
      (cons exc-start 'ruby-mode))))

;;;###autoload
(define-mumamo-multi-major-mode eruby-mumamo
  "Turn on multiple major mode for eRuby with unspecified main mode.
Current major-mode will be used as the main major mode."
  ("eRuby Family" nil
   (mumamo-chunk-eruby
    )))

;;;###autoload
(define-mumamo-multi-major-mode eruby-html-mumamo
  "Turn on multiple major modes for eRuby with main mode `html-mode'.
This also covers inlined style and javascript."
  ("eRuby Html Family" html-mode
   (mumamo-chunk-eruby
    mumamo-chunk-inlined-style
    mumamo-chunk-inlined-script
    mumamo-chunk-style=
    mumamo-chunk-onjs=
    )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Perl here doc

(defcustom mumamo-perl-here-doc-modes
  '(
    ("_HTML_" html-mode)
    )
  "Matches for perl here doc modes.
The entries in this list have the form

  (REGEXP MAJOR-MODE)

where REGEXP is a regular expression that should match the perl
here document marker and MAJOR-MODE is the major mode to use in
the perl here document.

The entries are tried from the beginning until the first match."
  :type '(repeat
          (list
           regexp
           (function :tag "Major mode")))
  :group 'mumamo)

(defun mumamo-perl-here-doc-mode (marker)
  "Get major mode associated with MARKER."
  (let ((mode (catch 'mode
                (dolist (rec mumamo-perl-here-doc-modes)
                  (let ((regexp (nth 0 rec))
                        (mode   (nth 1 rec)))
                    (when (string-match regexp marker)
                      (throw 'mode mode)))))))
    (if mode
        mode
      'fundamental-mode)))

(defun mumamo-chunk-perl-here-doc (pos min max)
  "This should work similar to `mumamo-find-possible-chunk'.
POS, MIN and MAX have the same meaning as there."
  (mumamo-condition-case err
      (let ((old-point (point)))
        (goto-char pos)
        ;; Adjust for beeing inside an <<...;
        ;;(beginning-of-line)
        ;;(when (looking-at (rx (1+ (not (any "<")))
        ;;                      "<<"
        ;;                      (submatch (1+ (not (any "^;")))) ";" line-end)
        (end-of-line)
        (beginning-of-line)
        (let ((prev-<< (search-backward "<<" min t))
              next-<<
              here-doc-end-mark-end
              here-doc-end-mark-start
              here-doc-start-mark-start
              here-doc-start-mark-end
              here-doc-mark
              start
              end
              exc-mode
              )
          ;; find prev change and end of that perl here doc
          (when prev-<<
            (when (looking-at (concat "<<[[:space:]]*\\([^\n;]*\\);"))
              (setq here-doc-start-mark-start (match-beginning 0))
              (setq here-doc-start-mark-end   (match-end 0))
              (setq here-doc-mark  (buffer-substring-no-properties
                                    (match-beginning 1)
                                    (match-end 1)))
              (end-of-line)
              (setq here-doc-end-mark-end (search-forward here-doc-mark max t))
              (when (and here-doc-end-mark-end
                         (eolp))
                (beginning-of-line)
                (if (looking-at here-doc-mark)
                    (setq here-doc-end-mark-start (point))
                  (setq here-doc-end-mark-end nil)))
              (if (and here-doc-end-mark-start
                       (<= here-doc-end-mark-start pos))
                  (progn
                    (setq start here-doc-end-mark-start)
                    )
                (setq exc-mode (mumamo-perl-here-doc-mode here-doc-mark))
                (setq start (1+ here-doc-start-mark-end))
                (when here-doc-end-mark-start
                  (setq end here-doc-end-mark-start))
                )))
          (unless end
            (goto-char pos)
            (beginning-of-line)
            (setq next-<< (search-forward "<<" max t))
            (when next-<<
              (when (looking-at (concat "[[:space:]]*\\([^\n;]*\\);"))
                (setq end (1+ (match-end 0))))))
          (when start (assert (<= start pos) t))
          (when end   (assert (<= pos end) t))
          (goto-char old-point)
          (list start end exc-mode t nil pos)))
    (error (mumamo-display-error 'mumamo-chunk-perl-here-doc
                                 "%s" (error-message-string err)))))

(defun mumamo-chunk-perl-here-html (pos min max)
  "Find perl here docs, still a little bit EXPERIMENTAL.
See `mumamo-perl-here-doc-modes' for how to customize the choice
of major mode in the perl here document.

See `mumamo-find-possible-chunk' for POS, MIN
and MAX.

* Note: This used to be slow, but after fixing a bug in perl here
  doc chunk dividing it seems to work ok."
  (mumamo-msgfntfy "mumamo-chunk-perl-here-html start")
  (let ((r (mumamo-chunk-perl-here-doc pos min max)))
    (mumamo-msgfntfy "  perl-here stop")
    r))

;;;###autoload
(define-mumamo-multi-major-mode perl-mumamo
  "Turn on multiple major modes for Perl Here Document."
  ("Perl Here Doc" perl-mode
   (mumamo-chunk-perl-here-html
    )))

;;;###autoload
(define-mumamo-multi-major-mode cperl-mumamo
  "Turn on multiple major modes for Perl Here Document."
  ("Perl Here Doc" cperl-mode
   (mumamo-chunk-perl-here-html
    )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Tex meta

(defun mumamo-search-bw-textext-start (pos min)
  "Helper for `mumamo-chunk-textext'.
POS is where to start search and MIN is where to stop."
  (let ((exc-start (mumamo-chunk-start-bw-str pos min "textext(\""))
        (exc-mode 'plain-tex-mode))
    (when exc-start
      (when (<= exc-start pos)
        (cons exc-start exc-mode)))))

(defconst mumamo-textext-end-regex
  (rx "textext("
      (0+
       (0+ (not (any "\"()")))
       ?\"
       (0+ (not (any "\"")))
       ?\"
       )
      (0+ (not (any "\"()")))
      ")"))

(defun mumamo-textext-test-is-end (pos)
  "Helper for `mumamo-chunk-textext'.
Return POS if POS is at the end of textext chunk."
  (when pos
    (let ((here (point))
          hit)
      (goto-char (+ 2 pos))
      (when (looking-back mumamo-textext-end-regex)
        (setq hit t))
      (goto-char here)
      (when hit pos))))

(defun mumamo-search-bw-textext-end (pos min)
  "Helper for `mumamo-chunk-textext'.
POS is where to start search and MIN is where to stop."
  (let ((end (mumamo-chunk-end-bw-str pos min "\")"))
        res)
    (while (and end
                (not (setq res (mumamo-textext-test-is-end end))))
      (setq end (mumamo-chunk-end-bw-str (1- end) min "\")")))
    res))

(defun mumamo-search-fw-textext-start (pos max)
  "Helper for `mumamo-chunk-textext'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-start-fw-str pos max "textext(\""))

(defun mumamo-search-fw-textext-end (pos max)
  "Helper for `mumamo-chunk-textext'.
POS is where to start search and MAX is where to stop."
  (let ((end (mumamo-chunk-end-fw-str pos max "\")")))
    (mumamo-textext-test-is-end end)))

(defun mumamo-chunk-textext (pos min max)
  "Find textext or TEX chunks.  Return range and 'plain-tex-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-textext-start
                              'mumamo-search-bw-textext-end
                              'mumamo-search-fw-textext-start
                              'mumamo-search-fw-textext-end))

(defun mumamo-search-bw-verbatimtex-start (pos min)
  "Helper for `mumamo-chunk-verbatimtextext'.
POS is where to start search and MIN is where to stop."
  (let ((exc-start (mumamo-chunk-start-bw-str pos min "\nverbatimtex"))
        (exc-mode 'plain-tex-mode))
    (when exc-start
      (when (<= exc-start pos)
        (cons exc-start exc-mode)))))

(defun mumamo-search-bw-verbatimtex-end (pos min)
  "Helper for `mumamo-chunk-verbatimtextext'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-str pos min "\netex"))

(defun mumamo-search-fw-verbatimtex-start (pos max)
  "Helper for `mumamo-chunk-verbatimtextext'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-start-fw-str pos max "\nverbatimtex"))

(defun mumamo-search-fw-verbatimtex-end (pos max)
  "Helper for `mumamo-chunk-verbatimtextext'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-str pos max "\netex"))

(defun mumamo-chunk-verbatimtex (pos min max)
  "Find verbatimtex - etex chunks.  Return range and 'plain-tex-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-verbatimtex-start
                              'mumamo-search-bw-verbatimtex-end
                              'mumamo-search-fw-verbatimtex-start
                              'mumamo-search-fw-verbatimtex-end))

(defun mumamo-search-bw-btex-start (pos min)
  "Helper for `mumamo-chunk-btex'.
POS is where to start search and MIN is where to stop."
  (let ((exc-start (mumamo-chunk-start-bw-str pos min "\nverbatimtex"))
        (exc-mode 'plain-tex-mode))
    (when exc-start
      (when (<= exc-start pos)
        (cons exc-start exc-mode)))))

(defun mumamo-search-bw-btex-end (pos min)
  "Helper for `mumamo-chunk-btex'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-str pos min "\netex"))

(defun mumamo-search-fw-btex-start (pos max)
  "Helper for `mumamo-chunk-btex'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-start-fw-str pos max "\nverbatimtex"))

(defun mumamo-search-fw-btex-end (pos max)
  "Helper for `mumamo-chunk-btex'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-str pos max "\netex"))

(defun mumamo-chunk-btex (pos min max)
  "Find btex - etex chunks.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-btex-start
                              'mumamo-search-bw-btex-end
                              'mumamo-search-fw-btex-start
                              'mumamo-search-fw-btex-end))

;;;###autoload
(define-mumamo-multi-major-mode metapost-mumamo
  "Turn on multiple major modes for MetaPost."
  ("MetaPost TeX Family" metapost-mode
   (mumamo-chunk-textext
    mumamo-chunk-verbatimtex
    )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; OpenLaszlo

(defconst mumamo-lzx-method-tag-start-regex
  (rx "<method"
      (optional
       space
       (0+ (not (any ">"))))
      ">"
      ;; FIX-ME: Commented out because of bug in Emacs
      ;;
      ;;(optional (0+ space) "<![CDATA[" )
      ))

(defun mumamo-search-bw-exc-start-inlined-lzx-method (pos min)
  "Helper for `mumamo-chunk-inlined-lzx-method'.
POS is where to start search and MIN is where to stop."
  (goto-char (+ pos 7))
  (let ((marker-start (search-backward "<method" min t))
        exc-mode
        exc-start)
    (when marker-start
      (when (looking-at mumamo-lzx-method-tag-start-regex)
        (setq exc-start (match-end 0))
        (goto-char exc-start)
        (when (<= exc-start pos)
          (cons (point) 'javascript-mode))
        ))))

(defun mumamo-search-bw-exc-end-inlined-lzx-method (pos min)
  "Helper for `mumamo-chunk-inlined-lzx-method'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-str pos min "</method>"))

(defun mumamo-search-fw-exc-start-inlined-lzx-method (pos max)
  "Helper for `mumamo-chunk-inlined-lzx-method'.
POS is where to start search and MAX is where to stop."
  (goto-char (1+ pos))
  (skip-chars-backward "^<")
  ;; Handle <![CDATA[
  (when (and
         (eq ?< (char-before))
         (eq ?! (char-after))
         (not (bobp)))
    (backward-char)
    (skip-chars-backward "^<"))
  (unless (bobp)
    (backward-char 1))
  (let ((exc-start (search-forward "<method" max t))
        exc-mode)
    (when exc-start
      (goto-char (- exc-start 7))
      (when (looking-at mumamo-lzx-method-tag-start-regex)
        (goto-char (match-end 0))
        (point)
        ))))

(defun mumamo-search-fw-exc-end-inlined-lzx-method (pos max)
  "Helper for `mumamo-chunk-inlined-lzx-method'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-str pos max "</method>"))

(defun mumamo-chunk-inlined-lzx-method (pos min max)
  "Find <method>...</method>.  Return range and 'javascript-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-exc-start-inlined-lzx-method
                              'mumamo-search-bw-exc-end-inlined-lzx-method
                              'mumamo-search-fw-exc-start-inlined-lzx-method
                              'mumamo-search-fw-exc-end-inlined-lzx-method))

(defconst mumamo-lzx-handler-tag-start-regex
  (rx "<handler"
      (optional
       space
       (0+ (not (any ">"))))
      ">"
      ;; FIX-ME: Commented out because of bug in Emacs
      ;;
      ;;(optional (0+ space) "<![CDATA[" )
      ))

(defun mumamo-search-bw-exc-start-inlined-lzx-handler (pos min)
  "Helper for `mumamo-chunk-inlined-lzx-handler'.
POS is where to start search and MIN is where to stop."
  (goto-char (+ pos 8))
  (let ((marker-start (search-backward "<handler" min t))
        exc-mode
        exc-start)
    (when marker-start
      (when (looking-at mumamo-lzx-handler-tag-start-regex)
        (setq exc-start (match-end 0))
        (goto-char exc-start)
        (when (<= exc-start pos)
          (cons (point) 'javascript-mode))
        ))))

(defun mumamo-search-bw-exc-end-inlined-lzx-handler (pos min)
  "Helper for `mumamo-chunk-inlined-lzx-handler'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-str pos min "</handler>"))

(defun mumamo-search-fw-exc-start-inlined-lzx-handler (pos max)
  "Helper for `mumamo-chunk-inlined-lzx-handler'.
POS is where to start search and MAX is where to stop."
  (goto-char (1+ pos))
  (skip-chars-backward "^<")
  ;; Handle <![CDATA[
  (when (and
         (eq ?< (char-before))
         (eq ?! (char-after))
         (not (bobp)))
    (backward-char)
    (skip-chars-backward "^<"))
  (unless (bobp)
    (backward-char 1))
  (let ((exc-start (search-forward "<handler" max t))
        exc-mode)
    (when exc-start
      (goto-char (- exc-start 8))
      (when (looking-at mumamo-lzx-handler-tag-start-regex)
        (goto-char (match-end 0))
        (point)
        ))))

(defun mumamo-search-fw-exc-end-inlined-lzx-handler (pos max)
  "Helper for `mumamo-chunk-inlined-lzx-handler'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-str pos max "</handler>"))

(defun mumamo-chunk-inlined-lzx-handler (pos min max)
  "Find <handler>...</handler>.  Return range and 'javascript-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-exc-start-inlined-lzx-handler
                              'mumamo-search-bw-exc-end-inlined-lzx-handler
                              'mumamo-search-fw-exc-start-inlined-lzx-handler
                              'mumamo-search-fw-exc-end-inlined-lzx-handler))


;;;###autoload
(define-mumamo-multi-major-mode laszlo-nxml-mumamo
  "Turn on multiple major modes for OpenLaszlo."
  ("OpenLaszlo Family" nxml-mode
   (mumamo-chunk-inlined-script
    mumamo-chunk-inlined-lzx-method
    mumamo-chunk-inlined-lzx-handler
    )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; csound

(defun mumamo-search-bw-exc-start-csound-orc (pos min)
  "Helper for `mumamo-chunk-csound-orc'.
POS is where to start search and MIN is where to stop."
  (let ((exc-start (mumamo-chunk-start-bw-str pos min "<csinstruments>")))
    (and exc-start
         (<= exc-start pos)
         (cons exc-start 'csound-orc-mode))))

(defun mumamo-search-bw-exc-end-csound-orc (pos min)
  "Helper for `mumamo-chunk-csound-orc'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-str pos min "</csinstruments>"))

(defun mumamo-search-fw-exc-start-csound-orc (pos max)
  "Helper for `mumamo-chunk-csound-orc'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-start-fw-str pos max "<csinstruments>"))

(defun mumamo-search-fw-exc-end-csound-orc (pos max)
  "Helper for `mumamo-chunk-csound-orc'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-str pos max "</csinstruments>"))

(defun mumamo-chunk-csound-orc (pos min max)
  "Find <csinstruments>...</...>.  Return range and 'csound-orc-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-exc-start-csound-orc
                              'mumamo-search-bw-exc-end-csound-orc
                              'mumamo-search-fw-exc-start-csound-orc
                              'mumamo-search-fw-exc-end-csound-orc))

(defun mumamo-search-bw-exc-start-csound-sco (pos min)
  "Helper for `mumamo-chunk-csound-sco'.
POS is where to start search and MIN is where to stop."
  (let ((exc-start (mumamo-chunk-start-bw-str pos min "<csscore>")))
    (and exc-start
         (<= exc-start pos)
         (cons exc-start 'csound-sco-mode))))

(defun mumamo-search-bw-exc-end-csound-sco (pos min)
  "Helper for `mumamo-chunk-csound-sco'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-str pos min "</csscore>"))

(defun mumamo-search-fw-exc-start-csound-sco (pos max)
  "Helper for `mumamo-chunk-csound-sco'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-start-fw-str pos max "<csscore>"))

(defun mumamo-search-fw-exc-end-csound-sco (pos max)
  "Helper for `mumamo-chunk-csound-sco'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-str pos max "</csscore>"))

(defun mumamo-chunk-csound-sco (pos min max)
  "Found <csscore>...</csscore>.  Return range and 'csound-sco-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-exc-start-csound-sco
                              'mumamo-search-bw-exc-end-csound-sco
                              'mumamo-search-fw-exc-start-csound-sco
                              'mumamo-search-fw-exc-end-csound-sco))

;;;###autoload
(define-mumamo-multi-major-mode csound-sgml-mumamo
  "Turn on mutiple major modes for CSound orc/sco Modes."
  ("CSound orc/sco Modes" sgml-mode
   (mumamo-chunk-csound-sco
    mumamo-chunk-csound-orc
    )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; noweb

(defcustom mumamo-noweb2-mode-from-ext
  '(
    ("php" . php-mode)
    ("c" . c-mode)
    )
  "File extension regexp to major mode mapping."
  :type '(repeat
          (cons regexp major-mode-function))
  :group 'mumamo)

(defvar mumamo-noweb2-found-mode-from-ext nil
  "Major modes determined from file names.  Internal use.")

(defun mumamo-noweb2-chunk-start-fw (pos max)
  "Helper for `mumamo-noweb2-chunk'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-start-fw-re pos max "^<<\\(.*?\\)>>="))

(defun mumamo-noweb2-chunk-start-bw (pos min)
  "Helper for `mumamo-noweb2-chunk'.
POS is where to start search and MIN is where to stop."
  (let ((exc-start (mumamo-chunk-start-bw-re pos min "^<<\\(.*?\\)>>="))
        (exc-mode 'text-mode))
    (when exc-start
      (let* ((file-name (match-string 1))
             (file-ext  (when file-name (file-name-extension file-name))))
        (when file-ext
          (setq exc-mode (catch 'major
                           (dolist (rec mumamo-noweb2-mode-from-ext)
                             (when (string-match (car rec) file-ext)
                               (throw 'major (cdr rec))))
                           nil))
          (unless exc-mode
            (setq exc-mode
                  (cdr (assoc file-ext mumamo-noweb2-found-mode-from-ext)))
            (unless exc-mode
              ;; Get the major mode from file name
              (with-temp-buffer
                (setq buffer-file-name file-name)
                (condition-case err
                    (normal-mode)
                  (error (message "error (normal-mode): %s"
                                  (error-message-string err))))
                (setq exc-mode (or major-mode
                                   'text-mode))
                (add-to-list 'mumamo-noweb2-found-mode-from-ext
                             (cons file-ext exc-mode)))
              ))))
      (cons exc-start exc-mode))))

(defun mumamo-noweb2-chunk-end-fw (pos max)
  "Helper for `mumamo-noweb2-chunk'.
POS is where to start search and MAX is where to stop."
  (mumamo-chunk-end-fw-re pos max "^@"))

(defun mumamo-noweb2-chunk-end-bw (pos min)
  "Helper for `mumamo-noweb2-chunk'.
POS is where to start search and MIN is where to stop."
  (mumamo-chunk-end-bw-re pos min "^@"))

(defun mumamo-noweb2-code-chunk (pos min max)
  "Find noweb chunks.  Return range and found mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (save-match-data
    (mumamo-find-possible-chunk pos min max
                                'mumamo-noweb2-chunk-start-bw
                                'mumamo-noweb2-chunk-end-bw
                                'mumamo-noweb2-chunk-start-fw
                                'mumamo-noweb2-chunk-end-fw)))


;;;###autoload
(define-mumamo-multi-major-mode noweb2-mumamo
  "Multi major mode for noweb files."
  ("noweb Family" latex-mode
   (mumamo-noweb2-code-chunk)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Asp

(defun mumamo-chunk-asp (pos min max)
  "Find <% ... %>.  Return range and 'asp-js-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-search-bw-exc-start-asp
                              'mumamo-search-bw-exc-end-jsp
                              'mumamo-search-fw-exc-start-jsp
                              'mumamo-search-fw-exc-end-jsp))

(defconst mumamo-asp-lang-marker
  (rx "<%@"
      (0+ space)
      "language"
      (0+ space)
      "="
      (0+ space)
      "\""
      (submatch (1+ (not (any "\""))))
      "\""
      (0+ space)))

(defun mumamo-search-bw-exc-start-asp (pos min)
  "Helper function for `mumamo-chunk-asp'.
POS is where to start search and MIN is where to stop."
  (let ((exc-start (mumamo-chunk-start-bw-str pos min "<%")))
    (when (and exc-start
               (<= exc-start pos))
      (let ((here (point))
            (mode 'asp-vb-mode)
            lang)
        (when (re-search-backward mumamo-asp-lang-marker nil t)
          (setq lang (downcase (match-string-no-properties 1)))
          (lwarn 't :warning "lang=%s" lang)
          (cond
           ((string= lang "javascript")
            (setq mode 'asp-js-mode))
           )
          )
        (cons exc-start mode)))))


;;;; asp <script ...>

(defconst mumamo-asp-script-tag-start-regex
  (rx "<script"
      space
      (0+ (not (any ">")))
      "language"
      (0+ space)
      "="
      (0+ space)
      ?\"
      ;;(or "text" "application")
      ;;"/"
      ;;(or "javascript" "ecmascript")
      ;; "text/javascript"
      (or "javascript" "vbscript")
      ?\"
      (0+ (not (any ">")))
      ">"
      ;; FIX-ME: Commented out because of bug in Emacs
      ;;
      ;;(optional (0+ space) "<![CDATA[" )
      ))

(defun mumamo-asp-search-bw-exc-start-inlined-script (pos min)
  "Helper function for `mumamo-asp-chunk-inlined-script'.
POS is where to start search and MIN is where to stop."
  (goto-char (+ pos 7))
  (let ((marker-start (search-backward "<script" min t))
        (exc-mode 'asp-vb-mode)
        exc-start
        lang)
    (when marker-start
      (when (looking-at mumamo-script-tag-start-regex)
        (setq lang (downcase (match-string-no-properties 1)))
        (cond
         ((string= lang "javascript")
          (setq exc-mode 'asp-js-mode))
         )
        (setq exc-start (match-end 0))
        (goto-char exc-start)
        (when (<= exc-start pos)
          (cons (point) exc-mode))
        ))))

(defun mumamo-asp-chunk-inlined-script (pos min max)
  "Find <script language=...  runat=...>...</script>.  Return 'asp-js-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-find-possible-chunk pos min max
                              'mumamo-asp-search-bw-exc-start-inlined-script
                              'mumamo-search-bw-exc-end-inlined-script
                              'mumamo-search-fw-exc-start-inlined-script
                              'mumamo-search-fw-exc-end-inlined-script))

;;;###autoload
(define-mumamo-multi-major-mode asp-html-mumamo
  "Turn on multiple major modes for ASP with main mode `html-mode'.
This also covers inlined style and javascript."
  ("ASP Html Family" html-mode
   (mumamo-chunk-asp
    mumamo-asp-chunk-inlined-script
    mumamo-chunk-inlined-script
    mumamo-chunk-style=
    mumamo-chunk-onjs=
    )))



(provide 'mumamo-fun)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; mumamo-fun.el ends here
