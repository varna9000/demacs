;; ibmpc.el: IBM PC cursor key and function key mapping
;;
;; Edition History:
;; 1.1 91/11/20 Halca.HIRANO creation
;; 1.2 91/11/28 Manabu Higashida
;; 1.3 91/12/12 Toshihiko SHIMOKAWA
;;
 
;; Copyright (C) 1991 Free Software Foundation, Inc.

;; This file is part of GNU Emacs.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY.  No author or distributor
;; accepts responsibility to anyone for the consequences of using it
;; or for whether it serves any particular purpose or works at all,
;; unless he says so in writing.  Refer to the GNU Emacs General Public
;; License for full details.

;; Everyone is granted permission to copy, modify and redistribute
;; GNU Emacs, but only under the conditions described in the
;; GNU Emacs General Public License.   A copy of this license is
;; supposed to have been given to you along with GNU Emacs so you
;; can know your rights and responsibilities.  It should be in a
;; file named COPYING.  Among other things, the copyright notice
;; and this notice must be preserved on all copies.

;;

(defun ibmpc-assign-special-key ()
  (send-string-to-terminal "\e[0;71;\"\e<\"p")	; Home       -> M-<
  (send-string-to-terminal "\e[0;72;\"\"p")	; UpArrow    -> C-p
  (send-string-to-terminal "\e[0;73;\"\ev\"p")	; PgUp       -> M-v
  (send-string-to-terminal "\e[0;75;\"\"p")	; LeftArrow  -> C-b
  (send-string-to-terminal "\e[0;77;\"\"p")	; RightArrow -> C-f
  (send-string-to-terminal "\e[0;79;\"\e>\"p")	; End        -> M->
  (send-string-to-terminal "\e[0;80;\"\"p")	; DownArrow  -> C-n
  (send-string-to-terminal "\e[0;81;\"\"p")	; PgDn       -> C-v
; (send-string-to-terminal "\e[0;82;0;82p")	; Ins
  (send-string-to-terminal "\e[0;83;\"\"p")	; Del        -> DEL
  )

(defun ibmpc-cancel-special-key ()
  (send-string-to-terminal "\e[0;71;0;71p")	; Home
  (send-string-to-terminal "\e[0;72;0;72p")	; UpArrow
  (send-string-to-terminal "\e[0;73;0;73p")	; PgUp
  (send-string-to-terminal "\e[0;75;0;75p")	; LeftArrow
  (send-string-to-terminal "\e[0;77;0;77p")	; RightArrow
  (send-string-to-terminal "\e[0;79;0;79p")	; End
  (send-string-to-terminal "\e[0;80;0;80p")	; DownArrow
  (send-string-to-terminal "\e[0;81;0;81p")	; PgDn
; (send-string-to-terminal "\e[0;82;0;82p")	; Ins
  (send-string-to-terminal "\e[0;83;0;83p")	; Del
  )

;;

(defvar ibmpc-map (make-keymap)
  "The ibmpc-map maps the function keys on the IBMPC keyboard.")

;; function keys

(define-key ibmpc-map ";" 'help-for-help) 		; f1
(define-key ibmpc-map "T" 'describe-mode)		; shift-f1
(define-key ibmpc-map "^" 'describe-key)		; ctrl-f1

(define-key ibmpc-map "<" 'other-window)		; f2
(define-key ibmpc-map "U" 'switch-to-buffer)		; shift-f2
(define-key ibmpc-map "_" 'list-buffers)		; ctrl-f2

(define-key ibmpc-map "=" 'delete-other-windows)	; f3
(define-key ibmpc-map "V" 'delete-window)		; s-f3
(define-key ibmpc-map "`" 'scroll-other-window)		; c-f3

(define-key ibmpc-map ">" 'split-window-vertically)	; f4
(define-key ibmpc-map "W" 'enlarge-window)		; s-f4
(define-key ibmpc-map "a" 'shrink-window)		; c-f4

(define-key ibmpc-map "?" 'split-window-horizontally)	; f5
(define-key ibmpc-map "X" 'enlarge-window-horizontally) ; s-f5
(define-key ibmpc-map "b" 'shrink-window-horizontally)	; c-f5

(define-key ibmpc-map "@" 'copy-region-as-kill)		; f6
(define-key ibmpc-map "Y" 'kill-region)			; s-f6
(define-key ibmpc-map "c" 'yank)			; c-f6

(define-key ibmpc-map "A" 'goto-line)			; f7
(define-key ibmpc-map "Z" 'isearch-forward)		; s-f7
(define-key ibmpc-map "d" 'query-replace)		; c-f7

(define-key ibmpc-map "B" 'find-file)			; f8
(define-key ibmpc-map "[" 'save-buffer)			; s-f8
(define-key ibmpc-map "e" 'write-file)			; c-f8

(define-key ibmpc-map "C" 'dired)			; f9
(define-key ibmpc-map "\\" 'compile)			; s-f9
(define-key ibmpc-map "e" 'repeat-complex-command)	; c-f9

(define-key ibmpc-map "D" 'shell-command)		; f10
(define-key ibmpc-map "]" 'suspend-emacs)		; s-f10
(define-key ibmpc-map "g" 'save-buffers-kill-emacs)	; c-f10

;; cursor key

(define-key ibmpc-map "R" 'set-mark-command)		; insert
(define-key ibmpc-map "\C-@" 'set-mark-command)		; original ^@

(define-key global-map "\C-@" ibmpc-map)

(defvar ibmpc-map-hooks nil
 "List of forms to evaluate after setting ibmpc-map.")

(let ((hooks ibmpc-map-hooks))
  (while hooks
    (eval (car hooks))
    (setq hooks (cdr hooks))))

;;
;; function key label support functions
;;
(defvar console-is-with-function-key-label nil
 "If value is t, the console consists of emacs windows and function key label.")

(defun redraw-display-with-function-key-label ()
  (redraw-display)
  (put-function-key-label))

(defun recenter-with-function-key-label (&optional arg) "\
  recenter and display function key label."
  (interactive)
  (recenter arg)
  (put-function-key-label))

(defun setup-console-with-function-key-label ()
  (delete-other-windows)
  (enlarge-window 100)
  (shrink-window 4)
  (message "")
  (redraw-display-with-function-key-label)
  (send-string-to-terminal "\e[1;1f"))
  
(defun put-function-key-label ()
  (save-excursion
    (message "")
    (send-string-to-terminal
      (format "\e[%d;1f\
 | F.1 |  F.2  |  F.3  |  F.4   |  F.5   | F.6 |  F.7  | F.8  | F.9  | F.10   |\n\
 |help | nextW | delOW |splitWH |splitWV |copy | goto  | read |dired |command |\n\
s|mode |switchW| delW  |largeWH |largeWV |kill |search | save | make |suspend |\n\
c|key  |buffers|scrlOW |shrnkWH |shrnkWV |yank |replace|write |repeat| quit   |" (- (screen-height) 3))))
  nil)

(defun erase-system-function-key-label ()
 "Erase system function key label."
 t)

(defun appear-system-function-key-label ()
 "Appear system function key label."
 t)




(if console-is-with-function-key-label
    (progn
      (global-set-key "\C-l" 'recenter-with-function-key-label)
      (setup-console-with-function-key-label)))

(ibmpc-assign-special-key)
;(setq meta-flag t)		; enable meta by ATL keys
				; this can be enabled by termcap switch ':km:'
