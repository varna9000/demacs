;; j3100.el: Toshiba J-3100 cursor key and function key mapping
;;
;; Edition History:
;; 1.1 91/11/21 Manabu Higashida Creation.
;;     91/11/22 HIRANO Satoshi Modified.
;; 1.2 91/12/12 Toshihiko SHIMOKAWA
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

(defun j3100-assign-special-key ()
; (send-string-to-terminal "\e[0;3;0p")		; Null -> NULL
; (send-string-to-terminal "\e[0;15;0;15p")	; Shift-Tab

  (send-string-to-terminal "\e[0;59;\"\eO;\"p")	; F1  -> \eO;
  (send-string-to-terminal "\e[0;60;\"\eO<\"p")	; F2  -> \eO<
  (send-string-to-terminal "\e[0;61;\"\eO=\"p")	; F3  -> \eO=
  (send-string-to-terminal "\e[0;62;\"\eO>\"p")	; F4  -> \eO>
  (send-string-to-terminal "\e[0;63;\"\eO?\"p")	; F5  -> \eO?
  (send-string-to-terminal "\e[0;64;\"\eO@\"p")	; F6  -> \eO@
  (send-string-to-terminal "\e[0;65;\"\eOA\"p")	; F7  -> \eOA
  (send-string-to-terminal "\e[0;66;\"\eOB\"p")	; F8  -> \eOB
  (send-string-to-terminal "\e[0;67;\"\eOC\"p")	; F9  -> \eOC
  (send-string-to-terminal "\e[0;68;\"\eOD\"p")	; F10 -> \eOD

  (send-string-to-terminal "\e[0;71;\"\e<\"p")	; Home       -> M-<
  (send-string-to-terminal "\e[0;72;\"\"p")	; UpArrow    -> C-p
  (send-string-to-terminal "\e[0;73;\"\ev\"p")	; PgUp       -> M-v
  (send-string-to-terminal "\e[0;75;\"\"p")	; LeftArrow  -> C-b
  (send-string-to-terminal "\e[0;77;\"\"p")	; RightArrow -> C-f
  (send-string-to-terminal "\e[0;79;\"\e>\"p")	; End        -> M->
  (send-string-to-terminal "\e[0;80;\"\"p")	; DownArrow  -> C-n
  (send-string-to-terminal "\e[0;81;\"\"p")	; PgDn       -> C-v
  (send-string-to-terminal "\e[0;82;\"\eOR\"p")	; Ins
  (send-string-to-terminal "\e[0;83;\"\"p")	; Del        -> DEL

  (send-string-to-terminal "\e[0;84;\"\eOT\"p")	; Shift-F1  -> \eOT
  (send-string-to-terminal "\e[0;85;\"\eOU\"p")	; Shift-F2  -> \eOU
  (send-string-to-terminal "\e[0;86;\"\eOV\"p")	; Shift-F3  -> \eOV
  (send-string-to-terminal "\e[0;87;\"\eOW\"p")	; Shift-F4  -> \eOW
  (send-string-to-terminal "\e[0;88;\"\eOX\"p")	; Shift-F5  -> \eOX
  (send-string-to-terminal "\e[0;89;\"\eOY\"p")	; Shift-F6  -> \eOY
  (send-string-to-terminal "\e[0;90;\"\eOZ\"p")	; Shift-F7  -> \eOZ
  (send-string-to-terminal "\e[0;91;\"\eO[\"p")	; Shift-F8  -> \eO[
  (send-string-to-terminal "\e[0;92;\"\eO\\\"p"); Shift-F9  -> \eO\
  (send-string-to-terminal "\e[0;93;\"\eO]\"p")	; Shift-F10 -> \eO]

  (send-string-to-terminal "\e[0;94;\"\eO^\"p")	; Ctrl-F1  -> \eO^
  (send-string-to-terminal "\e[0;95;\"\eO_\"p")	; Ctrl-F2  -> \eO_
  (send-string-to-terminal "\e[0;96;\"\eO`\"p")	; Ctrl-F3  -> \eO`
  (send-string-to-terminal "\e[0;97;\"\eOa\"p")	; Ctrl-F4  -> \eOa
  (send-string-to-terminal "\e[0;98;\"\eOb\"p")	; Ctrl-F5  -> \eOb
  (send-string-to-terminal "\e[0;99;\"\eOc\"p")	; Ctrl-F6  -> \eOc
  (send-string-to-terminal "\e[0;100;\"\eOd\"p"); Ctrl-F7  -> \eOd
  (send-string-to-terminal "\e[0;101;\"\eOe\"p"); Ctrl-F8  -> \eOe
  (send-string-to-terminal "\e[0;102;\"\eOf\"p"); Ctrl-F9  -> \eOf
  (send-string-to-terminal "\e[0;103;\"\eOg\"p"); Ctrl-F10 -> \eOg
  
; (send-string-to-terminal "\e[0;104;0;104p")	; Alt-F1  -> 
; (send-string-to-terminal "\e[0;105;0;105p")	; Alt-F2  -> 
; (send-string-to-terminal "\e[0;106;0;106p")	; Alt-F3  -> 
; (send-string-to-terminal "\e[0;107;0;107p")	; Alt-F4  -> 
; (send-string-to-terminal "\e[0;108;0;108p")	; Alt-F5  -> 
; (send-string-to-terminal "\e[0;109;0;109p")	; Alt-F6  -> 
; (send-string-to-terminal "\e[0;110;0;110p")	; Alt-F7  -> 
; (send-string-to-terminal "\e[0;111;0;111p")	; Alt-F8  -> 
; (send-string-to-terminal "\e[0;112;0;112p")	; Alt-F9  -> 
; (send-string-to-terminal "\e[0;113;0;113p")	; Alt-F10 -> 

; (send-string-to-terminal "\e[0;114;0;114p")	; Ctrl-PrtSc      ->
; (send-string-to-terminal "\e[0;115;0;115p")	; Ctrl-LeftArrow  ->
; (send-string-to-terminal "\e[0;116;0;116p")	; Ctrl-RightArrow ->
; (send-string-to-terminal "\e[0;117;0;117p")	; Ctrl-End        ->
; (send-string-to-terminal "\e[0;118;0;118p")	; Ctrl-PgDn       ->
; (send-string-to-terminal "\e[0;119;0;119p")	; Ctrl-Home       ->
; (send-string-to-terminal "\e[0;132;0;132p")	; Ctrl-PgUp       ->
  )

(defun j3100-cancel-special-key ()
; (send-string-to-terminal "\e[0;3;0;3p")	; Null
; (send-string-to-terminal "\e[0;15;0;15p")	; Shift-Tab

  (send-string-to-terminal "\e[0;59;0;59p")	; F1
  (send-string-to-terminal "\e[0;60;0;60p")	; F2
  (send-string-to-terminal "\e[0;61;0;61p")	; F3
  (send-string-to-terminal "\e[0;62;0;62p")	; F4
  (send-string-to-terminal "\e[0;63;0;63p")	; F5
  (send-string-to-terminal "\e[0;64;0;64p")	; F6
  (send-string-to-terminal "\e[0;65;0;65p")	; F7
  (send-string-to-terminal "\e[0;66;0;66p")	; F8
  (send-string-to-terminal "\e[0;67;0;67p")	; F9
  (send-string-to-terminal "\e[0;68;0;68p")	; F10

  (send-string-to-terminal "\e[0;71;0;71p")	; Home
  (send-string-to-terminal "\e[0;72;0;72p")	; UpArrow
  (send-string-to-terminal "\e[0;73;0;73p")	; PgUp
  (send-string-to-terminal "\e[0;75;0;75p")	; LeftArrow
  (send-string-to-terminal "\e[0;77;0;77p")	; RightArrow
  (send-string-to-terminal "\e[0;79;0;79p")	; End
  (send-string-to-terminal "\e[0;80;0;80p")	; DownArrow
  (send-string-to-terminal "\e[0;81;0;81p")	; PgDn
  (send-string-to-terminal "\e[0;82;0;82p")	; Ins
  (send-string-to-terminal "\e[0;83;0;83p")	; Del

  (send-string-to-terminal "\e[0;84;0;84p")	; Shift-F1
  (send-string-to-terminal "\e[0;85;0;85p")	; Shift-F2
  (send-string-to-terminal "\e[0;86;0;86p")	; Shift-F3
  (send-string-to-terminal "\e[0;87;0;87p")	; Shift-F4
  (send-string-to-terminal "\e[0;88;0;88p")	; Shift-F5
  (send-string-to-terminal "\e[0;89;0;89p")	; Shift-F6
  (send-string-to-terminal "\e[0;90;0;90p")	; Shift-F7
  (send-string-to-terminal "\e[0;91;0;91p")	; Shift-F8
  (send-string-to-terminal "\e[0;92;0;92p")	; Shift-F9
  (send-string-to-terminal "\e[0;93;0;93p")	; Shift-F10
			                
  (send-string-to-terminal "\e[0;94;0;94p")	; Ctrl-F1
  (send-string-to-terminal "\e[0;95;0;95p")	; Ctrl-F2
  (send-string-to-terminal "\e[0;96;0;96p")	; Ctrl-F3
  (send-string-to-terminal "\e[0;97;0;97p")	; Ctrl-F4
  (send-string-to-terminal "\e[0;98;0;98p")	; Ctrl-F5
  (send-string-to-terminal "\e[0;99;0;99p")	; Ctrl-F6
  (send-string-to-terminal "\e[0;100;0;100p")	; Ctrl-F7
  (send-string-to-terminal "\e[0;101;0;101p")	; Ctrl-F8
  (send-string-to-terminal "\e[0;102;0;102p")	; Ctrl-F9
  (send-string-to-terminal "\e[0;103;0;103p")	; Ctrl-F10
  
; (send-string-to-terminal "\e[0;104;0;104p")	; Alt-F1
; (send-string-to-terminal "\e[0;105;0;105p")	; Alt-F2
; (send-string-to-terminal "\e[0;106;0;106p")	; Alt-F3
; (send-string-to-terminal "\e[0;107;0;107p")	; Alt-F4
; (send-string-to-terminal "\e[0;108;0;108p")	; Alt-F5
; (send-string-to-terminal "\e[0;109;0;109p")	; Alt-F6
; (send-string-to-terminal "\e[0;110;0;110p")	; Alt-F7
; (send-string-to-terminal "\e[0;111;0;111p")	; Alt-F8
; (send-string-to-terminal "\e[0;112;0;112p")	; Alt-F9
; (send-string-to-terminal "\e[0;113;0;113p")	; Alt-F10

; (send-string-to-terminal "\e[0;114;0;114p")	; Ctrl-PrtSc
; (send-string-to-terminal "\e[0;115;0;115p")	; Ctrl-LeftArrow
; (send-string-to-terminal "\e[0;116;0;116p")	; Ctrl-RightArrow
; (send-string-to-terminal "\e[0;117;0;117p")	; Ctrl-End
; (send-string-to-terminal "\e[0;118;0;118p")	; Ctrl-PgDn
; (send-string-to-terminal "\e[0;119;0;119p")	; Ctrl-Home
; (send-string-to-terminal "\e[0;132;0;132p")	; Ctrl-PgUp
  )


(defvar j3100-map (make-keymap)
  "The j3100-map maps the function keys on the TOSHIBA J-3100 keyboard.")

;; function keys

(define-key j3100-map ";" 'help-for-help)		; f.1
(define-key j3100-map "T" 'describe-mode)		; s-f.1
(define-key j3100-map "^" 'describe-key)		; c-f.1

(define-key j3100-map "<" 'other-window)		; f.2
(define-key j3100-map "U" 'switch-to-buffer)		; s-f.2
(define-key j3100-map "_" 'list-buffers)		; c-f.2

(define-key j3100-map "=" 'delete-other-windows)	; f.3
(define-key j3100-map "V" 'delete-window)		; s-f.3
(define-key j3100-map "`" 'scroll-other-window)		; c-f.3

(define-key j3100-map ">" 'split-window-vertically)	; f.4
(define-key j3100-map "W" 'enlarge-window)		; s-f.4
(define-key j3100-map "a" 'shrink-window)		; c-f.4

(define-key j3100-map "?" 'split-window-horizontally)	; f.5
(define-key j3100-map "X" 'enlarge-window-horizontally)	; s-f.5
(define-key j3100-map "b" 'shrink-window-horizontally)	; c-f.5

(define-key j3100-map "@" 'copy-region-as-kill)		; f.6
(define-key j3100-map "Y" 'kill-region)			; s-f.6
(define-key j3100-map "c" 'yank)			; lc-f.6

(define-key j3100-map "A" 'goto-line)			; f.7
(define-key j3100-map "Z" 'isearch-forward)		; s-f.7
(define-key j3100-map "d" 'query-replace)		; c-f.7

(define-key j3100-map "B" 'find-file)			; f.8
(define-key j3100-map "[" 'save-buffer)			; s-f.8
(define-key j3100-map "e" 'write-file)			; c-f.8

(define-key j3100-map "C" 'dired)			; f.9
(define-key j3100-map "\\" 'compile)			; s-f.9
(define-key j3100-map "f" 'repeat-complex-command)	; c-f.9

(define-key j3100-map "D" 'shell-command)		; f.10
(define-key j3100-map "]" 'suspend-emacs)		; s-f.10
(define-key j3100-map "g" 'save-buffers-kill-emacs)	; c-f.10

(define-key j3100-map "R" 'set-mark-command)		; Ins

(define-key esc-map "O" j3100-map)

(defvar j3100-map-hooks nil
  "List of forms to evaluate after setting j3100-map.")

(let ((hooks j3100-map-hooks))
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
     (convert-string-kanji-code
;; You may find funny symbols. Don't worry these are Kanji characters.      
      (format "\e[%d;1f\
 |  F.1  |  F.2  |  F.3  |  F.4  |  F.5  |  F.6  | F.7 |  F.8  | F.9 | F.10   |\n\
 |ƒwƒ‹ƒv |‘‹ˆÚ“® |‘S–Ê‰» |‰¡•ªŠ„ |c•ªŠ„ |ƒRƒs[ |ˆÚ“® |ƒŠ[ƒh |DIR  |ƒRƒ}ƒ“ƒh|\n\
s|ƒ‚[ƒh |‘‹w’è |‘‹•Â½ |‰¡Šg‘å |cŠg‘å |ƒJƒbƒg |’Tõ |ƒZ[ƒu |MAKE |ƒVƒFƒ‹  |\n\
c|Œ®‰ğà |‘‹ˆê—— |‘¼‘‹“® |‰¡k¬ |ck¬ |ƒ„ƒ“ƒN |’uŠ· |ƒ‰ƒCƒg |ŒJ•Ô |I—¹    |\n" (- (screen-height) 3))
      3 1)))
  nil)

(defun erase-system-function-key-label ()
 "Erase system function key label."
 t)

(defun appear-system-function-key-label ()
 "Appear system function key label."
 t)

;;;

(if console-is-with-function-key-label
    (progn
      (global-set-key "\C-l" 'recenter-with-function-key-label)
      (setup-console-with-function-key-label)))

;;;

(j3100-assign-special-key)
(setq meta-flag t)	; enable meta by ATL keys
			; this also can be enabled by termcap switch ':km:'
