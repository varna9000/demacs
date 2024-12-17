;; DIRED commands for Emacs.  $Revision: 4.53 $
;; Copyright (C) 1985, 1986, 1990 Free Software Foundation, Inc.

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 1, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;; Enhanced from 18.55 dired by Sebastian Kremer.
;; Send bug reports to <sk@thp.uni-koeln.de>.

(provide 'dired)

(defconst dired-version (substring "$Revision: 4.53 $" 11 -2)
  "The revision number of dired (as string).  The complete RCS id is:

  $Id: dired.el,v 4.53 90/12/21 12:09:56 sk Exp $

Don't forget to mention this when reporting bugs.")

;; compatibility package when using Emacs 18.55
(require 'emacs-19)

;; can now contain even `F', but still not `i'.
;In loaddefs.el
;(defvar dired-listing-switches "-al"
;  "Switches passed to ls for dired. MUST contain the `l' option.
;CANNOT contain the `F' option.")

;;; patched by Manabu Higashida for demacs-1.1 91/10/28
(defvar dired-chmod-program
  "chmod"
  "Pathname of chmod command.")

(defvar dired-chgrp-program
  "chgrp"
  "Pathname of chgrp command.")
;;; end of patch

(defvar dired-chown-program
  (if (memq system-type '(hpux usg-unix-v)) "/bin/chown" "/etc/chown")
  "Pathname of chown command.")

(defvar dired-ls-program "ls"
  ;; GNU ls has no way to suppress the group, so one might prefer /bin/ls.
  "*Absolute or relative name of the ls program used by dired.")

(defvar dired-ls-F-marks-symlinks nil
  "*Set this to t if dired-ls-program with -lF marks the symbolic link
itself with a trailing @ (usually the case under Ultrix).

Example: if `ln -s foo bar; ls -F bar' gives `bar -> foo', set it to
nil (the default), if it gives `bar@ -> foo', set it to t.

Dired checks if there is really a @ appended.  Thus, if you have a
marking ls program on one host and a non-marking on another host, and
don't care about symbolic links which really contain a trailing @, you
can always set this variable to t.")

(defvar dired-directory nil
  "The directory name or shell wildcard passed as argument to ls.
Local to each dired buffer.")

(defvar dired-actual-switches nil
  "The actual (buffer-local) value of dired-listing-switches.")

;; This makes matches rather slow - perhaps -is should be forbidden.
;; If you don't use -is, you can set this to "".
(defvar dired-re-inode-size ;;"\\(\\s *[0-9]*\\s *[0-9]* \\)?"
  "\\s *[0-9]*\\s *[0-9]* ?" ; this seems to be slightly faster
  ;;"Regexp for optional initial inode and file size as produced
  ;;by ls' -i and -s flags."
)

;; These regexps must be tested at beginning-of-line, but are also
;; used to search for next matches, so omitting "^" won't do.
;; Replacing "^" by "\n" might be faster, but fails on the first line,
;; thus excluding the possibility to mark subdir lines.

(defconst dired-re-mark "^[^ \n]")
;; "Regexp matching a marked line.
;; Important: the match ends just after the marker."
;; "\n[^ \n]" 
(defconst dired-re-maybe-mark "^. ")
;;; patched by Manabu Higashida for demacs-1.1 91/10/28 
;;; original lines are
;(defconst dired-re-dir (concat dired-re-maybe-mark dired-re-inode-size "d"))
;(defconst dired-re-sym (concat dired-re-maybe-mark dired-re-inode-size "l"))
;;; and new lines are
(defconst dired-re-dir (concat dired-re-maybe-mark dired-re-inode-size "d[-r]"))
(defconst dired-re-sym (concat dired-re-maybe-mark dired-re-inode-size "l[-r]"))
;;; end of patch
(defconst dired-re-exe
  (mapconcat (function
	      (lambda (x)
		(concat dired-re-maybe-mark dired-re-inode-size x)))
	     '("-[-r][-w][xs][-r][-w].[-r][-w]." 
	       "-[-r][-w].[-r][-w][xs][-r][-w]."
	       "-[-r][-w].[-r][-w].[-r][-w][xst]")
	     "\\|"))
(defconst dired-re-dot "^.* \\.\\.?$")

;;; Customizable variables:

;; Might use {,} for bash or csh:
(defvar dired-mark-prefix "" "*Prepended to marked files.")
(defvar dired-mark-postfix "" "*Appended to marked files.")
(defvar dired-mark-separator " " "*Separates marked files.")

;; User might like the shorter "! on %s: " and "& on %s: " to save screen space:
(defvar dired-background-prompt "Background shell command on %s: "
  "*Format string for \\[dired-mark-background-shell-command] prompt.")

(defvar dired-shell-prompt "Shell command on %s: "
  "*Format string for \\[dired-mark-shell-command] prompt.")

(defvar shell-maximum-command-length 10000
  ;; 10K is a reasonable length to give the user a chance for second
  ;; thoughts.
  ;; SunOS 4.1 csh(1) mentions
  ;; 	1048576 as system limit on argument lists (that's a meg!)
  ;;	max. 1706 arguments to a command using file name expansion
  ;; 	1024 as maximum word length
  ;; Assuming 10 chars per filename, about 17000 should be OK.
  "*If non-nil, maximum number of bytes a dired shell command can have
before the user is asked for confirmation.")

(defvar dired-print-command "print %s"
  "Format string for shell command to print files in dired.
Can actually be used for any special purpose shell command to be run
by \\[dired-mark-print].")

(defvar dired-trivial-filenames "^\\.\\.?$\\|^#"
  "*Regexp of files to skip when moving point to the first file of a
new directory listing.
Nil means move to the subdir line, t means move to first file.")

(defvar dired-basename-regexp "\\(.+\\)\\.\\(.+\\)$")

;; user might prefer 'y-or-n-p or even 'identity, in effect disabling
;; all confirmation upon deletion. 
(or (fboundp 'dired-yes)
    (fset 'dired-yes 'yes-or-no-p))

;;; Hook variables

(defvar dired-load-hook nil
  "Run after loading dired.
You can customize key bindings or load extensions with this.")

(defvar dired-mode-hook nil
  "Run in each new dired buffer.")

(defvar dired-readin-hook nil
  "After each listing of a file or directory, this hook is run
with the buffer narrowed to the listing.")

;; An example filter to squeeze spaces:
;(setq dired-readin-hook
;      '(lambda () (goto-char (point-min))
;	 (while (re-search-forward " +" nil t) (replace-match " "))))
;
;  See dired-extra.el for an example on how to use it for sorting on
;  file size.   It also supports use of several different markers
;  (other than `D' and `*') in parallel and a minibuffer history for
;  shell commands.  Email if you want to try it.  It is about 20K.

;;; Global internal variables

;; next two used by function dired-mark-prompt
(defvar dired-mark-count 0
  "Count of marked files as determined by the last dired-mark-get-files.")
(defvar dired-mark-files nil
  "List of marked files as determined by the last dired-mark-get-files.")

(defvar dired-flagging-regexp nil
  "Last regexp used in flagging files.")

;;; Macros must be defined before they are used - for the byte compiler.

(defmacro dired-count-up ()
  ;; Increment variable dired-mark-count.
  '(setq dired-mark-count (1+ dired-mark-count)))

(defun dired-plural-s ()
  (if (= 1 dired-mark-count) "" "s"))

(defmacro dired-mark-if (predicate msg)
  (` (let ((buffer-read-only nil))
       (save-excursion
	 (setq dired-mark-count 0)
	 (message "0 %ss..." (, msg))
	 (goto-char (point-min))
	 (while (not (eobp))
	   (if (, predicate)
	       (progn
		 (delete-char 1)
		 (insert dired-marker-char)
		 (setq dired-mark-count (1+ dired-mark-count))))
	   (forward-line 1))
	 (message "%s %s%s %s%s."
		  dired-mark-count
		  (, msg)
		  (dired-plural-s)
		  (if (eq dired-marker-char ?\ ) "un" "")
		  (if (eq dired-marker-char ?D) "flagged" "marked"))))))

(defmacro dired-mark-map (body arg)
;  "Macro: Perform BODY with point on each marked line and
;mark it again (so BODY can call dired-redisplay without losing markers).
;If no file was marked, execute BODY on the current line.
;If ARG is non-nil, use current file instead."
  ;; BODY should not be too long as it is expanded three times.
  (` (let (buffer-read-only found)
       (if arg
	   (, body)
	 (let (opoint (regexp (dired-marker-regexp)))
	   (save-excursion
	     (goto-char (point-min))
	     (while (re-search-forward regexp nil t)
	       ;; If body contains dired-redisplay, the deletion (and
	       ;; new insertion) of the line confuses save-excursion.
	       (setq opoint (point))	; column 1 stays, however
	       (, body)
	       (goto-char opoint)
	       (setq found t))))
	 (or found (, body))))))

;; The following functions are redefinable for VMS or ange-ftp
;; - or for customization.

(defun dired-ls (file &optional switches wildcard full-directory-p)
;  "Insert ls output of FILE, optionally formatted with SWITCHES.
;Optional third arg WILDCARD means treat FILE as shell wildcard.
;Optional fourth arg FULL-DIRECTORY-P means file is a directory and
;switches do not contain `d'.
;
;SWITCHES default to dired-listing-switches.
;Uses dired-ls-program and maybe shell-file-name to do the work."
  (if (not dired-ls-program)
      (dos-dired-ls file switches wildcard full-directory-p)
    (progn
      (or switches (setq switches dired-listing-switches))
      (if wildcard
	  (let ((default-directory (file-name-directory file)))
	    (call-process shell-file-name nil t nil
			  (if (eq system-type 'ms-dos) "\/c" "-c")
			  (concat dired-ls-program " -d " switches " "
				  (file-name-nondirectory file))))
	(call-process dired-ls-program nil t nil switches
		      (if (eq system-type 'ms-dos)
			  (directory-file-name file)
			file))))))

(defun dired-call-process (program discard &rest arguments)
;  "Run PROGRAM with output to current buffer unless DISCARD is t.
;Remaining arguments are strings passed as command arguments to PROGRAM."
;;; patched by Manabu Higashida for demacs-1.1 91/10/28
;;; original line is
;  (apply 'call-process program nil (not discard) nil arguments))
;;; and new lines are
  (if (file-exists-p program)
      (apply 'call-process program nil (not discard) nil arguments)
    (and (not discard)
	 (insert "Command not found."))))
;;; end of patch

;; A "why" command (`W'?) could pop-up this:
(defconst dired-log-buf "*Dired log*")

(defun dired-why ()
  "Pop up a buffer with error log output from Dired's last subprocesses."
  (interactive)
  (pop-to-buffer dired-log-buf))

(defun dired-check-process-handler ()
  ;;"Run from function dired-check-process if there is output.
  ;; Insert output in a log buffer and returns nil."
  ;;- Old version raised error and aborted:
  ;;-(progn (display-buffer err-buffer) (error "%s... error!" msg))
  ;; Could cons up a list of failed args as with deleted files.
  (let ((log-buf dired-log-buf))
    (save-excursion
      (set-buffer (get-buffer-create log-buf))
      (goto-char (point-max))
      (insert "\n\t" (current-time-string) "\t("  program ")\n")
      (insert-buffer err-buffer))
    (message "%s... error - type W or see buffer %s" msg log-buf)
    ;;(ding t)				; annoying
    (sit-for 1)
    nil))

(defun dired-check-process (program msg &rest arguments)
;  "Run PROGRAM, display MSG while running, and check for output.
;Remaining arguments are strings passed as command arguments to PROGRAM.
;If dired-check-process-checker returns t, call
;dired-check-process-handler and return its value.
;Else returns t for success."
  (let (err-buffer err)
    (message "%s..." msg)
    (save-excursion
      ;; Get a clean buffer for error output:
      (setq err-buffer (get-buffer-create " *dired-check-process output*"))
      (set-buffer err-buffer)
      (erase-buffer)
      (apply 'dired-call-process program nil arguments)
      ;; In Emacs 19 the exit status should be checked instead.
      ;; The following is not The Right Thing as some compress
      ;; programs are verbose by default
      (setq err (/= 0 (buffer-size))))
    ;; Check for errors and display them:
    (if err
	(dired-check-process-handler)
      (kill-buffer err-buffer)
      (message "%s... done." msg)
      t)))

(defun dired-insert-headerline (dir)
  ;; No trailing slash, like ls does:
  (insert "  " (directory-file-name dir) ":")
  ;; put cursor on root subdir line:
  (save-excursion (insert "\n")))

(defun dired-readin (dirname buffer)
  (save-excursion
    (message "Reading directory %s..." dirname)
    (set-buffer buffer)
    (let ((buffer-read-only nil))
      (widen)
      (erase-buffer)
      (setq dirname (expand-file-name dirname))
      (if (eq system-type 'vax-vms)
	  (vms-read-directory dirname dired-actual-switches buffer)
	(if (file-directory-p dirname)
	    (dired-ls dirname dired-actual-switches nil t)
	  (if (not (file-readable-p
		    (directory-file-name (file-name-directory dirname))))
	      (insert "Directory " dirname " inaccessible or nonexistent.\n")
	    ;; else assume it contains wildcards:
	    (dired-ls dirname dired-actual-switches t))))
      (goto-char (point-min))
      (indent-rigidly (point-min) (point-max) 2)
      (run-hooks 'dired-readin-hook)
      ;; We need this to make the root dir have a header line as all
      ;; other subdirs have:
      (goto-char (point-min))
      (dired-insert-headerline default-directory))
    (set-buffer-modified-p nil)
    (message "Reading directory %s...done" dirname)))

;; This differs from dired-buffers in that it does not consider
;; subdirs of default-directory and searches for the _first_ match
(defun dired-find-buffer (dirname)
  (let ((blist (buffer-list))
	found)
    (while blist
      (save-excursion
        (set-buffer (car blist))
	(if (and (eq major-mode 'dired-mode)
		 (equal dired-directory dirname))
	    (setq found (car blist)
		  blist nil)
	  (setq blist (cdr blist)))))
    (or found
	(create-file-buffer (directory-file-name dirname)))))

(defun dired-read-dir-and-switches (str)
  ;; For use in interactive.
  (list
   (read-file-name (format "Dired %s (directory): " str)
		   nil default-directory nil)
   (if current-prefix-arg 
       (read-string "Dired listing switches: "
		    dired-listing-switches))))

(defun dired (dirname &optional switches)
  "`Edit' directory DIRNAME--delete, rename, print, etc. some files in it.
Prefix arg lets you change the buffer local value of dired-actual-switches.
Dired displays a list of files in DIRNAME (which may also have
  shell wildcards appended to select certain files).
You can move around in it with the usual commands.
You can flag files for deletion with C-d and then delete them by
  typing `x'. 
Type `h' after entering dired for more info."
  ;; Cannot use (interactive "D") because of wildcards.
  (interactive (dired-read-dir-and-switches ""))
  (switch-to-buffer (dired-noselect dirname switches)))

(defun dired-other-window (dirname &optional switches)
  "`Edit' directory DIRNAME.  Like M-x dired but selects in another window."
  (interactive (dired-read-dir-and-switches "in other window "))
  (switch-to-buffer-other-window (dired-noselect dirname switches)))

(defun dired-noselect (dirname &optional switches)
  ;; Like M-x dired but returns the dired buffer as value, does not
  ;; select it.
  (or dirname (setq dirname default-directory))
  ;; This loses the distinction between "/foo/*/" and "/foo/*" that
  ;; some shells make:
  (setq dirname (expand-file-name (directory-file-name dirname)))
  (if (file-directory-p dirname)
      (setq dirname (file-name-as-directory dirname)))
  (dired-internal-noselect dirname switches))

(defun dired-internal-noselect (dirname &optional switches)
  (let ((buffer (dired-find-buffer dirname))
	(old-buf (current-buffer)))
    (or switches (setq switches dired-listing-switches))
    (save-excursion
      (set-buffer buffer)
      ;; must be set before dired-readin inserts the root line:
      (setq default-directory (if (file-directory-p dirname)
				  dirname (file-name-directory dirname)))
      (let ((dired-actual-switches switches))
	(dired-readin dirname buffer))
      (dired-mode dirname switches))
    ;; changing point inside a save-excursion is rather pointless... 
    (unwind-protect
	(progn			
	  (set-buffer buffer)
	  (goto-char (point-min))
	  (dired-initial-position))
      (set-buffer old-buf))
    buffer))

(defun dired-remember-marks ()
  ;; Return alist of files and their marks, from point to eob.
  (let (fil chr alist)
    (while (re-search-forward dired-re-mark nil t)
      (if (setq fil (dired-get-filename nil t))
	  (setq chr (preceding-char)
		alist (cons (cons fil chr) alist))))
    alist))

(defun dired-mark-remembered (alist)
  ;; Mark all files remembered in ALIST.
  (let (elt fil chr)
    (while alist
      (setq elt (car alist)
	    alist (cdr alist)
	    fil (car elt)
	    chr (cdr elt))
      (if (dired-goto-file fil)
	  (save-excursion
	    (beginning-of-line)
	    (delete-char 1)
	    (insert chr))))))

(defun dired-revert (&optional arg noconfirm)
  ;; Reread the dired buffer.  Should not fail even on completely
  ;; garbaged buffers.
  ;; All marks/flags are preserved.
  (let ((opoint (point))
	(ofile (dired-get-filename nil t))
	(mark-alist nil)		; save marked files
	;; Save old alist except default-directory:
	(old-subdir-alist (cdr (reverse dired-subdir-alist)))
	(buffer-read-only nil))
    ;; Remember all marks/flags.  Must unhide to make this work.
    (if selective-display
	(subst-char-in-region (point-min) (point-max) ?\r ?\n))
    (goto-char 1)
    (setq mark-alist (dired-remember-marks))
    (dired-readin dired-directory (current-buffer))
    (dired-advertise)			; no harm if already called
    (setq dired-used-F			; ls switches may have changed
	  (string-match "F" dired-actual-switches))
    (dired-build-subdir-alist)		; moving/retrieval cmds work now

    ;; Try to insert all subdirs that were displayed before
    (or (string-match "R" dired-actual-switches)
	(let (elt dir)
	  (while old-subdir-alist
	    (setq elt (car old-subdir-alist)
		  old-subdir-alist (cdr old-subdir-alist)
		  dir (car elt))
	    (condition-case ()
		(dired-insert-subdir dir)
	      (error nil)))))

    ;; Mark files that were marked before
    (dired-mark-remembered mark-alist)

    ;; Move cursor to where it was before
    (or (and ofile (dired-goto-file ofile))
	(goto-char opoint))
    (dired-move-to-filename))

  ;; outside of the let scope:
  (setq buffer-read-only t)		; gets sometimes out of sync
)

(defvar dired-mode-map nil "Local keymap for dired-mode buffers.")
(if dired-mode-map
    nil
  (setq dired-mode-map (make-keymap))
  (suppress-keymap dired-mode-map)
  (define-key dired-mode-map " "  'dired-next-line)
  (define-key dired-mode-map "!" 'dired-mark-shell-command)
  (define-key dired-mode-map "#" 'dired-flag-auto-save-files)
  (define-key dired-mode-map "$" 'dired-hide-subdir)
  (define-key dired-mode-map "&" 'dired-mark-background-shell-command)
  (define-key dired-mode-map "*" 'dired-mark-executables)
  (define-key dired-mode-map "+" 'dired-create-directory)
  (define-key dired-mode-map "." 'dired-clean-directory)
  (define-key dired-mode-map "/" 'dired-mark-dirlines)
  (define-key dired-mode-map "<" 'dired-prev-dirline)
  (define-key dired-mode-map "=" 'dired-hide-all)
  (define-key dired-mode-map ">" 'dired-next-dirline)
  (define-key dired-mode-map "?" 'dired-summary)
  (define-key dired-mode-map "@" 'dired-mark-symlinks)
  (define-key dired-mode-map "B" 'dired-mark-byte-recompile)
  (define-key dired-mode-map "C" 'dired-mark-compress)
  (define-key dired-mode-map "D" 'dired-diff)
  (define-key dired-mode-map "F" 'dired-flag-regexp-files)
  (define-key dired-mode-map "G" 'dired-mark-chgrp)
  (define-key dired-mode-map "K" 'dired-kill-subdir)
  (define-key dired-mode-map "L" 'dired-mark-load)
  (define-key dired-mode-map "M" 'dired-mark-chmod)
  (define-key dired-mode-map "O" 'dired-mark-chown)
  (define-key dired-mode-map "P" 'dired-mark-print)
  (define-key dired-mode-map "R" 'dired-rename-regexp)
  (define-key dired-mode-map "S" 'dired-sort-other)
  (define-key dired-mode-map "U" 'dired-mark-uncompress)
  (define-key dired-mode-map "W" 'dired-why)
  (define-key dired-mode-map "X" 'dired-mark-delete)
  (define-key dired-mode-map "\177" 'dired-backup-unflag)
  (define-key dired-mode-map "\C-_" 'dired-undo)
  (define-key dired-mode-map "\C-d" 'dired-flag-file-deleted)
  (define-key dired-mode-map "\C-n" 'dired-next-line)
  (define-key dired-mode-map "\C-p" 'dired-previous-line)
  (define-key dired-mode-map "\C-xu" 'dired-undo)
  (define-key dired-mode-map "\M-\C-?" 'dired-unflag-all-files)
  (define-key dired-mode-map "\M-g" 'dired-goto-file)
  (define-key dired-mode-map "\M-d" 'dired-down-subdir)
  (define-key dired-mode-map "\M-G" 'dired-goto-subdir)
  (define-key dired-mode-map "\M-k" 'dired-mark-kill)
  (define-key dired-mode-map "\M-m" 'dired-mark-files)
  (define-key dired-mode-map "\M-n" 'dired-next-subdir)
  (define-key dired-mode-map "\M-p" 'dired-prev-subdir)
  (define-key dired-mode-map "\M-u" 'dired-up-subdir)
  (define-key dired-mode-map "\M-~" 'dired-backup-diff)
  (define-key dired-mode-map "^" 'dired-up-directory)
  (define-key dired-mode-map "c" 'dired-mark-copy)
  (define-key dired-mode-map "d" 'dired-flag-file-deleted)
  (define-key dired-mode-map "e" 'dired-find-file)
  (define-key dired-mode-map "f" 'dired-find-file)
  (define-key dired-mode-map "g" 'revert-buffer)
  (define-key dired-mode-map "h" 'describe-mode)
  (define-key dired-mode-map "i" 'dired-insert-subdir)
  (define-key dired-mode-map "k" 'dired-kill-line)
  (define-key dired-mode-map "l" 'dired-mark-redisplay)
;  (define-key dired-mode-map "m" 'dired-mark-file)
  (define-key dired-mode-map "m" 'dired-mark-subdir-or-file)
  (define-key dired-mode-map "n" 'dired-next-line)
  (define-key dired-mode-map "o" 'dired-find-file-other-window)
  (define-key dired-mode-map "p" 'dired-previous-line)
  (define-key dired-mode-map "q" 'kill-buffer)
  (define-key dired-mode-map "r" 'dired-mark-move)
  (define-key dired-mode-map "s" 'dired-sort-toggle)
  (define-key dired-mode-map "u" 'dired-unflag)
  (define-key dired-mode-map "v" 'dired-view-file)
  (define-key dired-mode-map "w" 'dired-copy-filename-as-kill)
  (define-key dired-mode-map "x" 'dired-do-deletions)
  (define-key dired-mode-map "z" 'bury-buffer)
  (define-key dired-mode-map "~" 'dired-flag-backup-files)
)


;; Dired mode is suitable only for specially formatted data.
(put 'dired-mode 'mode-class 'special)

(defun dired-mode (&optional dirname switches)
  "Mode for `editing' directory listings.
In dired, you are `editing' a list of the files in a directory and
\(optionally) its subdirectories.
You can move using the usual cursor motion commands.
Letters no longer insert themselves.  Digits are prefix arguments.
Instead, type d to flag a file for Deletion.
Type m to mark a file or subdirectory for later commands.
  Most commands operate on the marked files and use the current file
  if no files are marked (or a prefix argument is given).
Type u to Unflag a file (remove its D flag or any mark).
  Type DEL to back up one line and unflag.
Type x to eXecute the deletions requested.
Type f to Find the current line's file
  (or dired it in another buffer, if it is a directory).
Type i to dired a subdirectory In situ and K to kill it again or ^ to
  go back.  Type v to view a file or its in situ subdirectory.
Type ^ to go to the parent directory.
Type < and > to move to file lines that are directories.
Type M-n, M-p, M-u, M-d to move to in situ subdirectory headerlines.
Type M-g to go to a file's line, M-G to go to a subdir headerline.
Type o to find file or dired directory in Other window.
Type # to flag temporary files (names beginning with #) for deletion.
Type ~ to flag backup files (names ending with ~) for deletion.
Type . to flag numerical backups for deletion.
  (Spares dired-kept-versions (or prefix argument) recent versions.)
Type + to create a new directory.
Type r to Rename a file or move the marked files to another directory.
Type c to Copy files.
Type D to Diff a file, M-~ to diff it with its backup.
Type l to reList files or subdirectories.
Type s to toggle sorting by name/date, S to set dired-actual-switches.
Type g to read all directories again.  This retains all marks.
Space and Rubout can be used to move down and up by lines.
Also:
 C 	 -- compress files		  U -- uncompress files
 ! 	 -- run shell command on files    & -- background shell command
 M, G, O -- change mode, group or owner of files
 L, B 	 -- load or byte-compile emacs lisp files
 F, M-m  -- flag (`D') or mark (`*') files matching a regexp
 *, @, / -- (un)mark executables, symbolic links, directories
 $, = 	 -- (un)hide this or all subdirectories
 X       -- delete marked files

If dired ever gets confused, you can either type \\[dired-revert] \
to read the
directories again, type \\[dired-mark-redisplay] \
to relist a single file or subdirectory, or
type \\[dired-build-subdir-alist] to parse the buffer again for the
directory tree.

Hooks: dired-load-hook, dired-mode-hook, dired-readin-hook (q.v.)

\\{dired-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (make-local-variable 'revert-buffer-function)
  (setq revert-buffer-function 'dired-revert)
  (setq major-mode 'dired-mode)
  (setq mode-name "Dired")
  (make-local-variable 'dired-directory)
  (setq dired-directory (or dirname default-directory))
  (make-local-variable 'list-buffers-directory)
  (setq list-buffers-directory dired-directory)	; never used!?
  (make-local-variable 'dired-actual-switches)
  (setq dired-actual-switches (or switches
				  dired-listing-switches))
  (set (make-local-variable 'dired-used-F)
       (string-match "F" dired-actual-switches))
  (setq mode-line-buffer-identification
	(list (concat "Dired " dired-version " (beta): %17b")))
  (setq case-fold-search nil)
  (setq buffer-read-only t)
  (use-local-map dired-mode-map)
  (make-local-variable 'minor-mode-alist)
  (setq selective-display t)		; for subdirectory hiding
  (dired-advertise)
  (make-local-variable 'dired-subdir-alist)
  (setq dired-subdir-alist nil)
  (dired-build-subdir-alist)
  (make-local-variable 'dired-sort-mode)
  (dired-sort-mode)
  (setq minor-mode-alist
	(cons '(dired-sort-mode dired-sort-mode)
	      minor-mode-alist))
  (run-hooks 'dired-mode-hook))


(defun dired-repeat-over-lines (arg function)
  ;; This version skips non-file lines.
  (beginning-of-line)
  (while (and (> arg 0) (not (eobp)))
    (setq arg (1- arg))
    (beginning-of-line)
    (while (and (not (eobp)) (dired-between-files)) (forward-line 1))
    (save-excursion (funcall function))
    (forward-line 1)
    (dired-move-to-filename))
  (while (and (< arg 0) (not (bobp)))
    (setq arg (1+ arg))
    (forward-line -1)
    (while (and (not (bobp)) (dired-between-files)) (forward-line -1))
    (beginning-of-line)
    (save-excursion (funcall function))
    (dired-move-to-filename)))

(defun dired-flag-file-deleted (arg)
  "In dired, flag the current line's file for deletion.
With arg, repeat over several lines."
  (interactive "p")
  (dired-repeat-over-lines arg
    '(lambda ()
       (let ((buffer-read-only nil))
	 (delete-char 1)
	 (insert "D")
	 nil))))

(defun dired-read-regexp (prompt)
;; This is an extra function so that gmhist can redefine it.
  (setq dired-flagging-regexp
	(read-string prompt dired-flagging-regexp)))

(defun dired-flag-regexp-files (regexp &optional arg marker-char)
  "In dired, flag all files containing the specified REGEXP for deletion.
Use `^' and `$' if the match should span the whole (non-directory
  part) of the filename.   Exclude subdirs by hiding them.
Directories are not flagged unless a prefix argument is given."
  (interactive (list (dired-read-regexp "Flagging regexp: ")
		     current-prefix-arg))
  (let ((dired-marker-char (or marker-char ?D)))
    (dired-mark-if
     (and (or arg (not (looking-at dired-re-dir)))
	  (not (eolp))
	  (dired-this-file-matches regexp))
     "matching file")))

(defun dired-summary ()
  (interactive)
  ;>> this should check the key-bindings and use substitute-command-keys if non-standard
  (message
   ;;"d-elete, u-ndelete, x-ecute, f-ind, o-ther window, r-ename, c-opy, v-iew"
   "d-elete, u-ndelete, x-ecute, f-ind, o-ther window, r-ename, c-opy, h-elp"
   ;;"m-ark, u-nmark, d-elete, f-ind, o-ther window, r-ename, c-opy, h-elp"
))

(defun dired-unflag (arg)
  "In dired, remove the current line's delete flag then move to next line."
  (interactive "p")
  (dired-repeat-over-lines arg
    '(lambda ()
       (let ((buffer-read-only nil))
	 (delete-char 1)
	 (insert " ")
	 (forward-char -1)
	 nil))))

(defun dired-backup-unflag (arg)
  "In dired, move up a line and remove deletion flag there."
  (interactive "p")
  (dired-unflag (- arg)))

(defun dired-next-line (arg)
  "Move down ARG lines then position at filename."
  (interactive "p")
  (next-line arg)
  (dired-move-to-filename))

(defun dired-previous-line (arg)
  "Move up ARG lines then position at filename."
  (interactive "p")
  (previous-line arg)
  (dired-move-to-filename))

(defun dired-up-directory ()
  "Dired parent directory.  Tries first to find it in this buffer."
  (interactive)
  (let ((fn "..")
	(dir (dired-current-directory)))
    (setq fn (file-name-as-directory (expand-file-name fn dir)))
    (or (dired-goto-file (directory-file-name dir))
	(dired (expand-file-name	; give user a chance to abort
		(read-file-name "Dired: " fn fn t))))))

(defun dired-find-file ()
  "In dired, visit the file or directory named on this line."
  (interactive)
  (find-file (dired-get-filename)))

(defun dired-view-file ()
  "In dired, examine a file in view mode, returning to dired when done.
When file is a directory, tries to go to its in situ subdirectory."
  (interactive)
  (if (file-directory-p (dired-get-filename))
      (or (dired-goto-subdir (dired-get-filename))
	  (message "Directory %s not inserted - type i to insert or f to dired."
		   (dired-get-filename t)))
    (view-file (dired-get-filename))))

(defun dired-find-file-other-window ()
  "In dired, visit this file or directory in another window."
  (interactive)
  (find-file-other-window (dired-get-filename)))

; Now that there is dired-move-to-end-of-filename,
; use it in dired-get-filename.
(defun dired-get-filename (&optional localp no-error-if-not-filep)
  "In dired, return name of file mentioned on this line.
Value returned normally includes the directory name.
A non-nil 1st argument means use path name relative to
  default-directory, which may contain slashes if in a subdirectory.
A non-nil 2nd argument says return nil if no filename on this line,
  otherwise an error occurs."
  (let ((case-fold-search nil) file p1 p2)
    (save-excursion
      (if (setq p1 (dired-move-to-filename (not no-error-if-not-filep)))
	  (setq p2 (dired-move-to-end-of-filename no-error-if-not-filep))))
    ;; nil if no file on this line, but no-error-if-not-filep is t:
    (setq file (and p1 p2 (buffer-substring p1 p2)))
    (and file (dired-make-absolute file (dired-current-directory localp)))))

(defun dired-move-to-filename (&optional raise-error eol)
  "In dired, move to first char of filename on this line.
Returns position (point) or nil if no filename on this line."
  (or eol (setq eol (progn (end-of-line) (point))))
  (beginning-of-line)
  (if (eq system-type 'vax-vms)
      (if (re-search-forward ". [][.A-Z-0-9_$;<>]" eol t)
	  (backward-char 1)
	(if raise-error
	    (error "No file on this line.")
	  nil))
    ;; Unix case
    (if (re-search-forward
	 "\\(Jan\\|Feb\\|Mar\\|Apr\\|May\\|Jun\\|Jul\\|Aug\\|Sep\\|Oct\\|Nov\\|Dec\\)[ ]+[0-9]+"
	 eol t)
	(progn
	  (skip-chars-forward " ")	; there is one SPC after day of month
	  (skip-chars-forward "^ " eol)	; move after time of day (or year)
	  (skip-chars-forward " " eol)	; there is one SPC before the file name
	  (point))
      (if raise-error
	  (error "No file on this line.")
	nil))))

(defun dired-move-to-end-of-filename (&optional no-error eol)
  ;; Assumes point is at beginning of filename,
  ;; thus the rwx bit re-search-backward below will succeed in *this* line.
  ;; So, it should be called only after (dired-move-to-filename t).
  ;; case-fold-search must be nil, at least for VMS.
  ;; On failure, signals an error or returns nil.
  (let (opoint flag ex sym hidden)
    (setq opoint (point))
    (or eol (setq eol (save-excursion (end-of-line) (point))))
    (setq hidden (and selective-display
		      (save-excursion (search-forward "\r" eol t))))
    (if hidden
	nil
      (if (eq system-type 'vax-vms)
	  ;; Non-filename lines don't match
	  ;; because they have lower case letters.
	  (re-search-forward "[][.A-Z-0-9_$;<>]+" eol t)
	;; Unix case
	(save-excursion
	  (or (re-search-backward
	       "\\(.\\)[-r][-w]\\(.\\)[-r][-w]\\(.\\)[-r][-w]\\(.\\)"
	       nil t)
	      no-error
	      (error "No file on this line."))
	  (setq flag (buffer-substring (match-beginning 1) (match-end 1))
		sym (string= flag "l")
		;; ex is actually only needed when dired-used-F is t.
		ex (string-match
		    "[xst]";; execute bit set anywhere?
		    (concat
		     (buffer-substring (match-beginning 2) (match-end 2))
		     (buffer-substring (match-beginning 3) (match-end 3))
		     (buffer-substring (match-beginning 4) (match-end 4))))))
	(if sym
	    (if (re-search-forward " ->" eol t)
		(progn
		  (forward-char -3)
		  ;; we check that ls -lF really marks the link
		  (if (and dired-ls-F-marks-symlinks (eq (preceding-char) ?@))
		      (forward-char -1))))
	  (goto-char eol))
	(if (and dired-used-F
		 (or (string= flag "d")
		     (string= flag "s")
		     (and (not sym) ex))) ; ls -lF ignores x bits on symlinks
	    (forward-char -1))))
    (or no-error
	(not (eq opoint (point)))
	(error (if hidden
		   "File line is hidden, type $ to unhide."
		 "No file on this line.")))
    (if (eq opoint (point))
	nil
      (point))))

(defun dired-map-dired-file-lines (fn)
  ;; perform fn with point at the end of each non-directory line:
  ;; arguments are the short and long filename
  (save-excursion
    (let (filename longfilename (buffer-read-only nil))
      (goto-char (point-min))
      (while (not (eobp))
	(save-excursion
	  (and (not (looking-at dired-re-dir))
	       (not (eolp))
	       (setq filename (dired-get-filename t t)
		     longfilename (dired-get-filename nil t))
	       (progn (end-of-line)
		      (funcall fn filename longfilename))))
	(forward-line 1)))))

;; Perhaps something could be done to handle VMS' own backups.

(defun dired-clean-directory (keep)
  "Flag numerical backups for deletion.
Spares dired-kept-versions latest versions, and kept-old-versions oldest.
Positive numeric arg overrides dired-kept-versions;
negative numeric arg overrides kept-old-versions with minus the arg.

To clear the flags on these files, you can use \\[dired-flag-backup-files]
with a prefix argument."
  (interactive "P")
  (setq keep (if keep (prefix-numeric-value keep) dired-kept-versions))
  (let ((early-retention (if (< keep 0) (- keep) kept-old-versions))
	(late-retention (if (<= keep 0) dired-kept-versions keep))
	(file-version-assoc-list ()))
    ;; Look at each file.
    ;; If the file has numeric backup versions,
    ;; put on file-version-assoc-list an element of the form
    ;; (FILENAME . VERSION-NUMBER-LIST)
    (dired-map-dired-file-lines 'dired-collect-file-versions)
    ;; Sort each VERSION-NUMBER-LIST,
    ;; and remove the versions not to be deleted.
    (let ((fval file-version-assoc-list))
      (while fval
	(let* ((sorted-v-list (cons 'q (sort (cdr (car fval)) '<)))
	       (v-count (length sorted-v-list)))
	  (if (> v-count (+ early-retention late-retention))
	      (rplacd (nthcdr early-retention sorted-v-list)
		      (nthcdr (- v-count late-retention)
			      sorted-v-list)))
	  (rplacd (car fval)
		  (cdr sorted-v-list)))
	(setq fval (cdr fval))))
    ;; Look at each file.  If it is a numeric backup file,
    ;; find it in a VERSION-NUMBER-LIST and maybe flag it for deletion.
    (dired-map-dired-file-lines 'dired-trample-file-versions)))

(defun dired-collect-file-versions (ignore fn)
  ;; If it looks like fn has versions, we make a list of the versions.
  ;; We may want to flag some for deletion.
    (let* ((base-versions
	    (concat (file-name-nondirectory fn) ".~"))
	   (bv-length (length base-versions))
	   (possibilities (file-name-all-completions
			   base-versions
			   (file-name-directory fn)))
	   (versions (mapcar 'backup-extract-version possibilities)))
      (if versions
	  (setq file-version-assoc-list (cons (cons fn versions)
					      file-version-assoc-list)))))

(defun dired-trample-file-versions (ignore fn)
  (let* ((start-vn (string-match "\\.~[0-9]+~$" fn))
	 base-version-list)
    (and start-vn
	 (setq base-version-list	; there was a base version to which
	       (assoc (substring fn 0 start-vn)	; this looks like a
		      file-version-assoc-list))	; subversion
	 (not (memq (string-to-int (substring fn (+ 2 start-vn)))
		    base-version-list))	; this one doesn't make the cut
	 (progn (beginning-of-line)
		(delete-char 1)
		(insert "D")))))

(defun dired-flag-backup-and-auto-save-files ()
  "Flag all backup and temporary files for deletion.
Backup files have names ending in `~'.  Auto save file names usually
start with `#'."
  (interactive)
  (dired-flag-backup-files)
  (dired-flag-auto-save-files))

(defun dired-create-directory (directory)
  "Create a directory called DIRECTORY"
  (interactive
   (list (read-file-name "Create directory: " (dired-current-directory))))
  (let ((expanded (directory-file-name (expand-file-name directory))))
    (make-directory expanded)
    (dired-add-entry-all-buffers (file-name-directory expanded)
				 (file-name-nondirectory expanded))
  (dired-next-line 1)))


(defun dired-buffers (dir)
;; Return a list of buffers that dired DIR (possibly as subdir).
;; As a side effect, killed dired buffers for DIR are removed from
;; dired-buffers.
  (setq dir (file-name-as-directory dir))
  (let ((alist dired-buffers) result elt)
    (while alist
      (setq elt (car alist))
      (if (dired-in-this-tree dir (car elt))
	  (let ((buf (cdr elt)))
	    (if (buffer-name buf)
		(setq result (cons buf result))
	      ;; else buffer is killed - clean up:
	      (setq dired-buffers (delq elt dired-buffers)))))
      (setq alist (cdr alist)))
    result))

(defun dired-fun-in-all-buffers (directory fun)
  ;; In all buffers dired'ing DIRECTORY, run FUN.
  ;; FUN returns t for success, nil else.
  (let ((buf-list (dired-buffers directory)) buf success-list)
    (while buf-list
      (setq buf (car buf-list)
	    buf-list (cdr buf-list))
      (save-excursion
	(set-buffer buf)
	(if (funcall fun)
	    (setq success-list (cons (buffer-name buf) success-list)))))
    success-list))

(defun dired-add-entry-all-buffers (directory filename)
  (dired-fun-in-all-buffers
   directory
   (function (lambda () (dired-add-entry directory filename)))))
   
(defun dired-add-entry (directory filename)
  ;; Note that this adds the entry `out of order' if files sorted by
  ;; time, etc.
  ;; At least this version tries to insert in the right subdirectory.
  ;; And it skips "." or ".." (dired-trivial-filenames).
  ;; Hidden subdirs are exposed if a file is added there.
  (setq directory (file-name-as-directory directory))
  (let*
      ((opoint (point))
       (cur-dir (dired-current-directory))
       (reason
	(catch 'not-found
	  (if (string= directory cur-dir)
	      (progn;; unhide if necessary
		(if (dired-subdir-hidden-p cur-dir) (dired-unhide-subdir))
		;; We are already where we should be, except in one case:
		;; If point is before the *root* subdir line or its
		;; total line, inserting there is ugly.
		;; (Everything *before* the rootline is considered as
		;; belonging to the root dir, too - in contrast to other
		;; subdirs)
		(if (string= default-directory cur-dir)
		    (let ((p (save-excursion
			       (dired-goto-next-file)
			       (point))))
		      (if (<= (point) p)
			  (goto-char p)))))
	    ;; else try to find correct place to insert
	    (if (dired-goto-subdir directory)
		(progn;; unhide if necessary
		  (if (looking-at "\r");; point is at end of subdir line
		      (dired-unhide-subdir))
		  ;; found - skip subdir and `total' line
		  ;; and uninteresting files like . and ..
		  (dired-goto-next-nontrivial-file))
	      ;; not found
	      (throw 'not-found "Subdir not found")))
	  ;; found and point is at The Right Place:
	  (let ((buffer-read-only nil))
	    (beginning-of-line)
	    (insert "  ")
	    (dired-ls (dired-make-absolute filename directory)
		      (concat dired-actual-switches "d"))
	    (forward-line -1)
	    (dired-move-to-filename t)	; raise an error if ls output
					; is strange
	    (let* ((beg (point))
		   (end (progn (dired-move-to-end-of-filename) (point))))
	      (setq filename (buffer-substring beg end))
	      (delete-region beg end)
	      (insert (file-name-nondirectory filename)))
	    (beginning-of-line)
	    (if dired-readin-hook
		(save-restriction
		  (narrow-to-region (point)
				    (save-excursion (forward-line 1) (point)))
		  (run-hooks 'dired-readin-hook)))
	    )
	  ;; return nil if all went well
	  nil)))
    (if reason
	(progn
	  (goto-char opoint)		; don't move away on failure
	  ;;-(message "Couldn't add %s%s: %s" directory filename reason)
	  ))
    (not reason)			; return t on succes, nil else
    ))

(defun dired-remove-entry-all-buffers (file)
  (dired-fun-in-all-buffers
   (file-name-directory file)
   (function (lambda () (dired-remove-entry file)))))

(defun dired-remove-entry (file)
  (save-excursion
    (and (dired-goto-file file)
	 (let ((buffer-read-only nil))
	   (delete-region (progn (beginning-of-line) (point))
			  (save-excursion (forward-line 1) (point)))))))


(defun dired-diff (file)
  "Compare this file with another (default: file at mark), by running `diff'.
The other file is the first file given to `diff'.
See the command `diff'."
  (interactive
   (let ((default (if (mark)
		      (save-excursion (goto-char (mark))
				      (dired-get-filename t)))))
     (list (read-file-name (format "Diff %s with: %s"
				   (dired-get-filename t)
				   (if default
				       (concat "(default " default ") ")
				     ""))
			   (dired-current-directory) default t))))
  (diff file (dired-get-filename t)))

(defun dired-backup-diff ()
  "Diff this file with its backup file.
Uses the latest backup, if there are several numerical backups.
If this file is a backup, diff it with its original.
The backup file is the first file given to `diff'."
  (interactive)
  (let (bak ori (file (dired-get-filename)))
    (if (backup-file-name-p file)
	(setq bak file
	      ori (file-name-sans-versions file))
      (setq bak (latest-backup-file file)
	    ori file))
    (diff bak ori)))

;; This function is missing in files.el:
(defun latest-backup-file (fn)
  "Return the latest existing backup of FILE, or nil."
  ;; First try simple backup, then the highest numbered of the
  ;; numbered backups.
  ;; Ignore the value of version-control because we look for existing
  ;; backups, which maybe were made earlier with another value of
  ;; version-control.
  (or
   (let ((bak (make-backup-file-name fn)))
     (if (file-exists-p bak) bak))
   (let* ((base-versions (concat (file-name-nondirectory fn) ".~"))
	  (bv-length (length base-versions)))
     (car (sort
	   (file-name-all-completions base-versions (file-name-directory fn))
	   ;; bv-length is a fluid var for backup-extract-version:
	   (function
	    (lambda (fn1 fn2)
	      (> (backup-extract-version fn1)
		 (backup-extract-version fn2)))))))))

(defun dired-compress ()
  (let* ((buffer-read-only nil)
	 (from-file (dired-get-filename))
	 (to-file (concat from-file ".Z")))
    (if (dired-check-process
;;; patched by Manabu Higashida for demacs-1.1 91/10/29
;;; original line is
;	 "compress" (format "Compressing %s" from-file) "-f" from-file)
;;; and new line is
	 dired-compress-program (format "Compressing %s" from-file) "-f" from-file)
;;; end of patch	 
	(dired-redisplay to-file))))

(defun dired-uncompress ()
  (let* ((buffer-read-only nil)
	 (from-file (dired-get-filename))
	 (to-file (substring from-file 0 -2)))
    (if (dired-check-process
;;; patched by Manabu Higashida for demacs-1.1 91/10/29
;;; original line is
;	 "uncompress" (format "Uncompressing %s" from-file) from-file)
;;; and new line is
	 dired-uncompress-program (format "Uncompressing %s" from-file) from-file)
;;; end of patch
	(dired-redisplay to-file))))

; The (un)compress functions are just mapped over all marked files
; It is not very effective to call many processes if one would suffice,
; but you can use dired-mark-shell-command if necessary,
; This version has the advantage of redisplaying after each
; (un)compress the corresponding (different!) filename.
; And it does not stop if a single file cannot be compressed.

(defun dired-mark-compress (&optional arg)
  "Compress marked files
\(or this file if none are marked or a prefix argument is given)."
  (interactive "P")
  (dired-mark-map (dired-compress) arg))

(defun dired-mark-uncompress (&optional arg)
  "Uncompress marked files
\(or this file if none are marked or a prefix argument is given)."
  (interactive "P")
  (dired-mark-map (dired-uncompress) arg))

;; Elisp commands on files

(defun dired-byte-recompile ()
  (let* ((buffer-read-only nil)
	 (from-file (dired-get-filename))
	 (new-file (concat from-file "c")))
    (if (not (string-match "\\.el$" from-file))
	(message "%s is no .el file!" from-file)
      (byte-compile-file from-file)
      (dired-remove-entry-all-buffers new-file)
      (dired-add-entry-all-buffers (file-name-directory new-file)
				   (file-name-nondirectory new-file)))))

(defun dired-mark-byte-recompile (&optional arg)
  "Byte recompile marked Emacs lisp files
\(or this file if none are marked or a prefix argument is given)."
  (interactive "P")
  (dired-mark-map (dired-byte-recompile) arg))

(defun dired-mark-load (&optional arg)
  "Load the marked Emacs lisp files
\(or this file if none are marked or a prefix argument is given)."
  (interactive "P")
  (dired-mark-map (load (dired-get-filename)) arg))

;; Change file modes.

; Don't use absolute path for ch{mod,grp} as /bin should be in
; any PATH.  However, chown is special: dired-chown-program.

(defun dired-mark-chmod (&optional arg)
  "Change mode of marked files
\(or this file if none are marked or a prefix argument is given)."
  (interactive "P")
  (let* ((files (dired-mark-get-files nil t arg))
 	 (mode (read-string (format "Change %s to Mode: "
 				    (dired-mark-prompt)))) )
;;; patched by Manabu Higashida for demacs-1.1 91/10/29
;;; original line is
;    (apply 'dired-check-process "chmod"
;;; and new line is
    (apply 'dired-check-process dired-chmod-program
;;; end of patch
 	   (format "chmod %s " mode) mode files)
    (dired-mark-redisplay arg)))

(defun dired-mark-chgrp (&optional arg)
  "Change group of marked files
\(or this file if none are marked or a prefix argument is given)."
  (interactive "P")
  (let* ((files (dired-mark-get-files nil t arg))
	 (group (read-string (format "Change %s to Group: "
				    (dired-mark-prompt)))) )
;;; patched by Manabu Higashida for demacs-1.1 91/10/29
;;; original line is
;    (apply 'dired-check-process "chgrp"
;;; and new line is
    (apply 'dired-check-process dired-chgrp-program
;;; end if patch
	   (format "chgrp %s " group) group files)
    (dired-mark-redisplay arg)))

(defun dired-mark-chown (&optional arg)
  "Change owner of marked files
\(or this file if none are marked or a prefix argument is given)."
  (interactive "P")
  (let* ((files (dired-mark-get-files nil t arg))
	 (owner (read-string (format "Change %s to Owner: "
				    (dired-mark-prompt)))) )
    (apply 'dired-check-process dired-chown-program
	   (format "chown %s " owner) owner files)
    (dired-mark-redisplay arg)))

(defun dired-redisplay (file)
  ;; Redisplay the file on this line.
  ;; Keeps any marks that may be present in column one.
  ;; Does not bother to update other dired buffers.
  (beginning-of-line)
  (let ((char (following-char)) (opoint (point)))
    (delete-region (point) (progn (forward-line 1) (point)))
    (if file
	(progn
	  (dired-add-entry (file-name-directory    file)
			   (file-name-nondirectory file))
	  ;; Replace space by old marker without moving point.
	  ;; Faster than goto+insdel inside a save-excursion?
	  (subst-char-in-region opoint (1+ opoint) ?\040 char))))
  (dired-move-to-filename))

(defun dired-mark-redisplay (&optional arg)
  "Redisplay all marked files
\(or this file if none are marked or a prefix argument is given).
If on a subdir line, redisplay that subdirectory."
  (interactive "P")
  (if (dired-get-subdir)
      (dired-insert-subdir (dired-get-subdir))
    (message "Redisplaying ...")
    (dired-mark-map (dired-redisplay (dired-get-filename)) arg)
    (dired-move-to-filename)
    (message "Redisplaying ... done.")))

(defun dired-mark-delete ()
  "Delete all files marked with the current marker char."
  (interactive)
  (dired-do-deletions t))

(defun dired-mark-kill (&optional arg)
  "Kill all marked lines (not files).
With a prefix arg, kill all lines not marked or flagged."
  (interactive "P")
  (save-excursion
    (goto-char (point-min))
    (let ((buffer-read-only nil))
      (if (not arg)
	  (flush-lines (dired-marker-regexp))
	(while (not (eobp))
	  (if (or (dired-between-files)
		  (not (looking-at "^  ")))
	      (forward-line 1)
	    (delete-region (point) (save-excursion
				     (forward-line 1)
				     (point)))))))))

(defun dired-do-deletions (&optional marked)
  "In dired, delete the files flagged for deletion."
  ;; Optional arg MARKED means delete marked instead flagged files.
  (interactive)
  (let ((regexp (if marked (dired-marker-regexp) "^D"))
	delete-list answer)
    (save-excursion
      (goto-char 1)
      (while (re-search-forward regexp nil t)
	(setq delete-list
	      (cons (cons (dired-get-filename t) (1- (point)))
		    delete-list))))
    (if (null delete-list)
	(message "(No deletions requested)")
      ;; Make the `dx' idiom less painful:
      (if (= (length delete-list) 1)
	  (setq answer
		(dired-yes (format "Delete '%s'? " (car (car delete-list)))))
	(save-window-excursion
	  (set-buffer (get-buffer-create " *Deletions*"))
	  (funcall (if (> (length delete-list) (* (window-height) 2))
		       'switch-to-buffer 'switch-to-buffer-other-window)
		   (current-buffer))
	  (erase-buffer)
	  (setq fill-column 70)
	  (let ((l (reverse delete-list)))
	    ;; Files should be in forward order for this loop.
	    (while l
	      (if (> (current-column) 59)
		  (insert ?\n)
		(or (bobp)
		    (indent-to (* (/ (+ (current-column) 19) 20) 20) 1)))
	      (insert (car (car l)))
	      (setq l (cdr l))))
	  ;; let window shrink to fit:
	  (let* ((window (selected-window))
		 (start (window-start window))
		 (window-lines (window-height window)))
	    (goto-char (point-min))
	    (enlarge-window (- (max (+ 2 (vertical-motion window-lines))
				    window-min-height)
			       window-lines))
	    (set-window-start (selected-window) start))
	  (setq answer (dired-yes "Delete these files? "))))
      (if answer
	  (save-excursion
	    (let ((l delete-list)
		  failures)
	      ;; Files better be in reverse order for this loop!
	      ;; That way as changes are made in the buffer
	      ;; they do not shift the lines still to be changed.
	      (while l
		(goto-char (cdr (car l)))
		(let ((buffer-read-only nil))
		  (condition-case ()
		      (let ((fn (dired-make-absolute (car (car l))
						     default-directory)))
			(if (and (file-directory-p fn)
				 (not (file-symlink-p fn)))
			    (remove-directory fn)
			  (delete-file fn))
			(delete-region (point)
				       (progn (forward-line 1) (point)))
			(save-excursion
			  (if (dired-goto-subdir fn)
			      (dired-kill-subdir))))
		    (error (delete-char 1)
			   (insert " ")
			   (setq failures (cons (car (car l)) failures)))))
		(setq l (cdr l)))
	      (if failures
		  (message "Deletions failed: %s"
			   (prin1-to-string failures)))))))))


(defun dired-replace-in-string (regexp to string)
  ;; Replace REGEXP with TO in STRING and return result.
  ;; No \\DIGIT escapes will be recognized in TO.
  (let ((result "") (start 0) mb me)
    (while (string-match regexp string start)
      (setq mb (match-beginning 0)
	    me (match-end 0)
	    result (concat result (substring string start mb) to)
	    start me))
    (concat result (substring string start))))

(defun dired-next-dirline (arg)
  "Goto ARG'th next directory file line."
  (interactive "p")
  (if (if (> arg 0)
	  (re-search-forward dired-re-dir nil t arg)
	(re-search-backward dired-re-dir nil t
			    (if (save-excursion (beginning-of-line)
						(looking-at dired-re-dir))
				(- 1 arg)
			      (- arg))))
      (dired-move-to-filename)		; user may type `i' or `f'
    (error "No more subdirectories.")))

(defun dired-prev-dirline (arg)
  "Goto ARG'th previous directory file line."
  (interactive "p")
  (dired-next-dirline (- arg)))

(defun dired-unflag-all-files (flag)
  "Remove a specific or all flags from every file."
  (interactive "sRemove flag: (default: all flags) ")
  (let ((count 0)
	(re (if (zerop (length flag)) dired-re-mark
	      (concat "^" (regexp-quote flag)))))
    (save-excursion
      (let ((buffer-read-only nil))
	(goto-char (point-min))
	(while (re-search-forward re nil t)
	  (progn (delete-char -1) (insert " ") (setq count (1+ count)))
	  (forward-line 1))))
    (message (format "All flags removed: %d %s" count flag) )))


(defun dired-kill-line (arg)
  "Kill this line (but not this file).
If file is displayed as in situ subdir, kill that as well, unless a
prefix arg is given."
  (interactive "P")
  (let ((buffer-read-only nil) (file (dired-get-filename nil t)))
    (delete-region (progn (beginning-of-line) (point))
		   (progn (forward-line 1) (point)))
    (and (not arg)
	 file
	 (dired-goto-subdir file)
	 (dired-kill-subdir))))

;; This function is missing in simple.el:
(defun copy-string-as-kill (string)
  "Save STRING as if killed in a buffer."
  (setq kill-ring (cons string kill-ring))
  (if (> (length kill-ring) kill-ring-max)
	(setcdr (nthcdr (1- kill-ring-max) kill-ring) nil))
  (setq kill-ring-yank-pointer kill-ring))

(defun dired-copy-filename-as-kill (&optional arg)
  "Copy this file (or subdir) name into the kill ring.
With a prefix arg, use the complete pathname of file.
Subdirs are always complete pathnames."
  (interactive "P")
  (copy-string-as-kill
   (or (dired-get-subdir)
       (if arg;; dired-get-filename's localp is not what we usually
	   (dired-get-filename);; want, esp. deep in a tree
	 (file-name-nondirectory (dired-get-filename)))))
  (message "%s" (car kill-ring)))

;; file marking

(defconst dired-marker-char ?*
  ;; so that you can write things like
  ;; (let ((dired-marker-char ?X))
  ;;    ;; great code using X markers ...
  ;;    )
  ;; For example, commands operating on two sets of files, A and B.
  ;; Or marking files with digits 0-9.  This could implicate
  ;; concentric sets or an order for the marked files.
  "In dired, character used to mark files for later commands.")

(defun dired-marker-regexp ()
  (concat "^" (regexp-quote (char-to-string dired-marker-char))))

(defun dired-mark-file (arg)
  "In dired, mark the current line's file for later commands.
With arg, repeat over several lines.
Use \\[dired-unflag-all-files] to remove all flags."
  (interactive "p")
  (let ((buffer-read-only nil))
    (dired-repeat-over-lines
     arg
     (function (lambda () (delete-char 1) (insert dired-marker-char))))))

(defun dired-mark-files (regexp &optional arg)
  "Mark all files matching REGEXP for use in later commands.
Directories are not marked unless a prefix argument is given.

This is an Emacs regexp, not a shell wildcard.	E.g., use \\.o$ for
object files - just .o will mark more than you might think.

An empty string will match all files except directories."
  (interactive
   (list (dired-read-regexp "Mark files (regexp): ")
	 current-prefix-arg))
  (dired-flag-regexp-files regexp arg dired-marker-char))

(defun dired-mark-symlinks (unflag-p)
  "Mark all symbolic links.
With prefix argument, unflag all those files."
  (interactive "P")
  (let ((dired-marker-char (if unflag-p ?\  dired-marker-char)))
    (dired-mark-if (looking-at dired-re-sym) "symbolic link")))

(defun dired-mark-dirlines (unflag-p)
  "Mark all directory file lines except `.' and `..'.
With prefix argument, unflag all those files."
  (interactive "P")
  (let ((dired-marker-char (if unflag-p ?\  dired-marker-char)))
    (dired-mark-if (and (looking-at dired-re-dir)
			(not (looking-at dired-re-dot)))
		   "directory file")))

(defun dired-mark-executables (unflag-p)
  "Mark all executable files.
With prefix argument, unflag all those files."
  (interactive "P")
  (let ((dired-marker-char (if unflag-p ?\  dired-marker-char)))
    (dired-mark-if (looking-at dired-re-exe) "executable file")))

(defun dired-flag-auto-save-files (&optional unflag-p)
  "Flag for deletion files whose names suggest they are auto save files.
A prefix argument says to unflag those files instead."
  (interactive "P")
  (let ((dired-marker-char (if unflag-p ?\  ?D))
	(bound (fboundp 'auto-save-file-name-p)))
    (dired-mark-if
       (and (not (looking-at dired-re-dir))
	    (if bound
		(let ((fn (dired-get-filename t t)))
		  (if fn (auto-save-file-name-p fn)))
	      (if (save-excursion
		    (dired-move-to-filename)
		    (looking-at "#")))))
       "auto save file")))

(defun dired-flag-backup-files (&optional unflag-p)
  "Flag all backup files (names ending with `~') for deletion.
With prefix argument, unflag all those files."
  (interactive "P")
  (let ((dired-marker-char (if unflag-p ?\  ?D))
	(bound (fboundp 'backup-file-name-p)))
    (dired-mark-if
     (and (not (looking-at dired-re-dir))
	  (if bound
	      (let ((fn (dired-get-filename t t)))
		(if fn (backup-file-name-p fn)))
	    (save-excursion
	      (end-of-line)		; symlinks are never backups
	      (forward-char -1)
	      (looking-at "~"))))
     "backup file")))

(defun dired-mark-get-files (&optional localp defaultp this-file)
  "Return the marked files as list of strings.
Values returned normally do include the directory name.
A non-nil first argument LOCALP means do not include it.
A non-nil second argument DEFAULTP means default to list with current
  file as single element if none are marked.  If this happens,
  dired-mark-defaulted is set to t.
A non-nil third argument THIS-FILE forces to use the current file.
Sets the global variables  dired-mark-count and  dired-mark-files."
  (setq dired-mark-defaulted nil)
  (if this-file
      (setq dired-mark-count 1
	    dired-mark-files (list (dired-get-filename localp)))
    (let (the-list (regexp (dired-marker-regexp)))
      (save-excursion
	(setq dired-mark-count 0)
	(goto-char (point-max))		; make list same order
	(while (re-search-backward regexp nil t) ; as in buffer
	  (setq the-list (cons (dired-get-filename localp) the-list))
	  (dired-count-up)))
      (setq dired-mark-defaulted (and defaultp (not the-list))
	    dired-mark-count (if the-list dired-mark-count (if defaultp 1 0))
	    dired-mark-files
	    (or the-list (if defaultp (list (dired-get-filename localp)) nil))))))

(defun dired-rename-regexp (regexp newname)
  "Rename all marked files containing REGEXP to NEWNAME.
See dired-flag-regexp-files for more info on REGEXP.
NEWNAME may contain \\N or \\& as in replace-match (q.v.).
REGEXP defaults to the last regexp used, but with a prefix arg
dired-basename-regexp is provided.  This makes the basename as \\1 and
the extension as \\2 available in NEWNAME."
  (interactive
   (let ((a1 (read-string "Rename from (regexp): "
			  (if current-prefix-arg
			      dired-basename-regexp
			    dired-flagging-regexp))))
     (list a1 (read-string (format "Rename %s to: " a1)))))
  (save-excursion
      (goto-char (point-min))
      (let ((buffer-read-only nil)
	    (dired-mark-count 0)
	    (re (dired-marker-regexp))
	    old new) 
	(while (and (re-search-forward re nil t)
		    (setq old (dired-get-filename)))
	  (if (dired-this-file-matches regexp)
	      (progn
		(replace-match newname t)
		(setq new (dired-get-filename))
		(rename-file old new)
		(dired-count-up))))
	  (message "%d file%s renamed." dired-mark-count (dired-plural-s)))))

(defun dired-this-file-matches (regexp)
;	  (let ((fn (dired-get-filename t t)))
;	    (if fn (string-match regexp fn)))
; fails in subdirs.
; But much worse, we can not use (replace-match) for renaming by
; regexp unless the match was in a buffer (not a string)
  (save-excursion
    (let ((beg (dired-move-to-filename)) end)
      (and beg
	   (setq end (dired-move-to-end-of-filename t))
      (save-restriction			; so that "^" in the
	(narrow-to-region beg end)	; regexp works.
	(goto-char beg)
	;; search is better than looking-at because then it is easy to
	;; replace "frizzle" by "frozzle" anywhere in a name.
	;; "^" and "$" can still be used to constrain a match.
	(re-search-forward regexp end t))))))

;;; Shell commands

(defun shell-quote (filename)
  ;; Quote everything except POSIX filename characters.
  ;; This should be safe enough even for really wierd shells.
  (let ((result "") (start 0) end)
    (while (string-match "[^---0-9a-zA-Z_./]" filename start)
      (setq end (match-beginning 0)
	    result (concat result (substring filename start end)
			   "\\" (substring filename end (1+ end)))
	    start (1+ end)))
    (concat result (substring filename start))))

(defun dired-read-shell-command (prompt)
  "Read a dired shell command prompting with PROMPT (using read-string).
This is an extra function so that you can redefine it, e.g., to use gmhist."
  (read-string prompt))

(defun dired-mark-prompt ()
  ;; Either the current file name or the marker and a count of marked
  ;; files for use in a prompt.
  (if (eq dired-mark-count 1)
      (file-name-nondirectory (car dired-mark-files))
    ;; more than 1 file:
    (format "%c [%d files]" dired-marker-char dired-mark-count)))

(defun dired-mark-background-shell-command (&optional arg)
  "Like \\[dired-mark-shell-command], but starts command in background.
This requires background.el to work."
  (interactive "P")
  (require 'background)
  (dired-mark-shell-command arg t))

(defun dired-mark-shell-command (&optional arg in-background)
  "Run a shell command on the marked files.
If there is output, it goes to a separate buffer.
The list of marked files is appended to the command string unless asterisks
  `*' indicate the place(s) where the list should go.  See variables
  dired-mark-prefix, -separator, -postfix.  If you have a curly brace
  expanding shell, you may want to set these to \"{\",\",\" and \"}\"
  to make commands like `mv *~ bak; compress bak/*~' work.
If no files are marked or a prefix arg is given, uses file on the
  current line. The prompt mentions the file or the marker, as
  appropriate.  See variables dired-shell-prompt, dired-background-prompt.
No automatic redisplay is attempted, as the file names may have
  changed.  Type \\[dired-mark-redisplay] to redisplay the marked files.

Function dired-run-shell-command does the actual work and can be
redefined for customization."
  ;; Bug: There is no way to quote a *
  (interactive "P")
  (let (result command fns
	       (prompt (if in-background dired-background-prompt
			 dired-shell-prompt)))
    (setq fns (mapconcat (function shell-quote)
			 (dired-mark-get-files t t arg)
			 dired-mark-separator))
    (if (> dired-mark-count 1)
	(setq fns (concat dired-mark-prefix fns dired-mark-postfix)))
    ;; Want to give feedback whether this file or marked files are used.
    (setq command (dired-read-shell-command (format prompt
						    (dired-mark-prompt))))
    (setq result (if (string-match "\\*" command)
		     (dired-replace-in-string "\\*" fns command)
		   (concat command " " fns)))
    ;; execute the shell command
    (dired-run-shell-command result in-background)))

;; This is an extra function so that it can be redefined for remote
;; shells or whatever.
(defun dired-run-shell-command (command &optional in-background)
  "Run shell COMMAND, optionally IN-BACKGROUND.
If COMMAND is longer than shell-maximum-command-length, you are asked
for confirmation."
  (if in-background
      (setq command (concat "cd " default-directory "; " command)))
  (if (or (and shell-maximum-command-length
	       (< (length command) shell-maximum-command-length))
	  (yes-or-no-p
	   (format
	    "Dired shell command is %d bytes long - execute anyway? "
	    (length command))))
      (if in-background
	  (background command)
	(shell-command command))))

(defun dired-mark-print (&optional arg)
  "Print the marked files
\(or this file if none are marked or a prefix argument is given).
Uses the shell command in variable dired-print-command as default."
  (interactive "P")
  (let* ((files (mapconcat (function shell-quote)
			   (dired-mark-get-files t t arg)
			   " "))
	 (command (read-string (format "Print %s with cmd: "
				       (dired-mark-prompt))
			       dired-print-command)))
    (setq dired-print-command command)
    (dired-run-shell-command (format command files))))
   

;;; Copy, move and rename

(defun dired-rename-visited (filename to-file)
  ;; Optionally rename the visited file of any buffer visiting this file.
  (and (get-file-buffer filename)
	 (y-or-n-p (message "Change visited file name of buffer %s too? "
			    (buffer-name (get-file-buffer filename))))
	 (save-excursion
	   (set-buffer (get-file-buffer filename))
	   (let ((modflag (buffer-modified-p)))
	     (set-visited-file-name to-file)
	     (set-buffer-modified-p modflag)))))

(defun dired-mark-cp-or-mv (fun fun2 msg msg1 &optional arg)
  (let* ((fn-list (dired-mark-get-files nil t arg))
	 ;; this depends on dired-mark-get-files to be run first:
	 (target (expand-file-name
		  (read-file-name
		   (format "%s %s to: "
			   (if (= 1 dired-mark-count) msg1 msg)
			   (dired-mark-prompt))
		   (dired-current-directory))))
	 (is-dir (file-directory-p target)))
    (if (and (> dired-mark-count 1)
	     (not is-dir))
	(error "Marked %s: target must be a directory: %s" msg target))
    (let (to overwrite (buffer-read-only nil))
      (or is-dir (setq to target))
      (or is-dir			; paranoid
	  (= 1 (length fn-list))
	  (error "Internal error: non-dir and more than 1 file: %s" fn-list))
      (mapcar
       (function
	(lambda (from)
	  (if is-dir			; else to = target
	      (setq to (expand-file-name
			(file-name-nondirectory from) target)))
	  (setq overwrite (file-exists-p to))
	  (funcall fun from to 0)
	  (and fun2 (funcall fun2 from to))
	  (if overwrite;; if we get here, fun hasn't been aborted
	      ;; and the old entry has to be deleted
	      ;; before adding the new entry
	      (dired-remove-entry-all-buffers to))
	  (dired-add-entry-all-buffers (file-name-directory to)
				       (file-name-nondirectory to))))
       fn-list)))
  (dired-move-to-filename))

(defun dired-mark-copy (&optional arg)
 "Copy all marked files (or this file if none are marked or prefix given)."
  (interactive "P")
  (dired-mark-cp-or-mv 'copy-file nil "Copy" "Copy" arg))

(defun dired-mark-move (&optional arg)
  "Move all marked files into a directory
\(or rename this file if none are marked or prefix given)."
  (interactive "P")
  (dired-mark-cp-or-mv
   'rename-file
   (function (lambda (from to)
	       (dired-remove-entry-all-buffers from)
	       (dired-rename-visited from to)))
   "Move" "Rename" arg))

;; tree dired

;;---------------------------------------------------------------------

(defvar dired-buffers nil
  ;; Enlarged/modified by dired-mode and dired-revert
  ;; Queried by function dired-buffers. When this detects a
  ;; killed buffer, it is removed from this list.
  "Alist of directories and their associated dired buffers.")

;;---------------------------------------------------------------------

;;; utility functions

(defconst dired-subdir-regexp "^. \\([^ ]*\\)\\(:\\)[\n\r]"
  "Regexp matching a maybe hidden subdirectory line in ls -lR output.
Subexpression 1 is subdirectory proper, no trailing slash.
The match starts at the beginning of the line and ends after the end
of the line (\\n or \\r).
Subexpression 2 must end right before the \\n or \\r.")

(defun dired-relative-path-p (file)
  ;;"Return t iff FILE is a relative path name.
  ;;Dired uses dired-make-absolute to convert it to an absolute pathname."
  ;; Only used in dired-normalize-subdir, but might perhaps be
  ;; redefined (for VMS?)
  (not (file-name-absolute-p file)))

(defun dired-make-absolute (file dir)
  ;;"Convert FILE (a pathname relative to DIR) to an absolute pathname."
  ;; This should be good enough for ange-ftp, but might easily be
  ;; redefined (for VMS?).
  ;; It should be reasonably fast, though, as it is called in
  ;; dired-get-filename.
  (concat dir file))

(defun dired-make-relative (file dir)
  ;;"Convert FILE (an absolute pathname) to a pathname relative to DIR.
  ;;Else error."
  ;; DIR must be file-name-as-directory, as with all directory args in
  ;; elisp code. 
  (if (string-match (concat "^" (regexp-quote dir)) file)
      (substring file (match-end 0))
    (error  "%s: not in directory tree growing at %s." file dir)))

(defun dired-in-this-tree (file dir)
  ;;"Is FILE part of the directory tree starting at DIR?"
  (string-match (concat "^" (regexp-quote dir)) file))

(defun dired-normalize-subdir (dir)
  ;; prepend default-directory if relative path name
  ;; and make sure it ends in a slash, like default-directory does
  ;; Make this "end in a slash or a colon" for ange-ftp.  The point is
  ;; that dired-make-absolute (i.e. concat) must suffice in
  ;; dired-get-filename to make a valid filename from a file and its
  ;; directory.
  (file-name-as-directory
   (if (dired-relative-path-p dir)
       (dired-make-absolute dir default-directory)
     dir)))

(defun dired-between-files ()
  ;; Point must be at beginning of line
  ;; Should be equivalent to (save-excursion (not (dired-move-to-filename)))
  ;; but faster.
  (or (looking-at "^$")
      (looking-at "^. *$")		; should not be marked
      (looking-at "^. total")		; but may be
      (looking-at dired-subdir-regexp)))

(defun dired-get-subdir ()
  ;;"Return the subdir name on this line, or nil."
  (save-excursion
    (beginning-of-line)
    (if (looking-at dired-subdir-regexp)
	(file-name-as-directory
	 (buffer-substring (match-beginning 1)
			   (match-end 1))))))

;;; We use an alist of directories for speed.

(defconst dired-subdir-alist nil
  "Association list of subdirectories and their buffer positions:

  \((lastdir . lastmarker) ... (default-directory . firstmarker)).

The markers point right at the end of the line, so that the cursor
looks at either \\n or \\r, the latter for a hidden subdir.") 

(defun dired-clear-alist ()
  (while dired-subdir-alist
    (set-marker (cdr (car dired-subdir-alist)) nil)
    (setq dired-subdir-alist (cdr dired-subdir-alist))))

(defun dired-build-subdir-alist ()
  "Build dired-subdir-alist anew and return it's new value."
  (interactive)
  (dired-clear-alist)
  (save-excursion
    (let ((count 0))
      (goto-char (point-min))
      (setq dired-subdir-alist nil)
      (while (re-search-forward dired-subdir-regexp nil t)
	(setq count (1+ count))
	(message "%d" count)
	(dired-alist-add (buffer-substring (match-beginning 1)
					   (match-end 1))
			 (progn
			   (goto-char (match-end 2))
			   (point-marker))))
      (message "%d director%s." count (if (= 1 count) "y" "ies"))
      ;; return new alist:
      dired-subdir-alist)))

(defun dired-alist-add (dir new-marker)
  ;; Add new DIR at NEW-MARKER (at end of buffer, but beginning of alist!)
  ;; Should perhaps use setcar for speed?
  (setq dired-subdir-alist
	(cons (cons (dired-normalize-subdir dir) new-marker)
	      dired-subdir-alist)))

(defun dired-unsubdir (dir)
  ;; Remove DIR from the alist
  (setq dired-subdir-alist
	(delq (assoc dir dired-subdir-alist) dired-subdir-alist)))

(defun dired-goto-next-nontrivial-file ()
  ;; Position point on first nontrivial file after point.
  (dired-goto-next-file);; so there is a file to compare with
  (if (stringp dired-trivial-filenames)
      (while (and (not (eobp))
		  (string-match dired-trivial-filenames
				(file-name-nondirectory
				 (or (dired-get-filename nil t) ""))))
	(forward-line 1)
	(dired-move-to-filename))))

(defun dired-goto-next-file ()
  (while (and (not (dired-move-to-filename)) (not (eobp)))
    (forward-line 1)))

(defun dired-goto-subdir (dir)
  "Goto header line of DIR in this dired buffer."
  ;; Search for DIR (an absolute pathname) in alist and move to it.
  ;; Return buffer position on success, otherwise return nil.
  (interactive (list (expand-file-name
		      ;;(read-file-name "Goto directory: ")
		      (completing-read "Goto directory: " ; prompt
				       dired-subdir-alist ; table
				       nil ; predicate
				       t ; require-match
				       (dired-current-directory)))))
  (let ((elt (assoc (file-name-as-directory dir) dired-subdir-alist)))
    (and elt (goto-char (cdr elt)))))

(defun dired-goto-file (file)
  "Goto file line of FILE in this dired buffer."
  (interactive (list (expand-file-name
		      (read-file-name "Goto file: "
				      (dired-current-directory)))))
  (setq file (directory-file-name file)) ; does no harm if no directory
  (let (found)
    (save-excursion
      (if (dired-goto-subdir (file-name-directory file))
	  (let ((keep-going t)
		(match nil)
		(string (file-name-nondirectory file))
		(boundary (dired-subdir-max)))
	    (while keep-going
	      (setq keep-going
		    (and (< (point) boundary)
			 (setq match (search-forward string nil 'move))))
	      (if (and match (equal file (dired-get-filename nil t)))
		  (setq found (point) keep-going nil)))
	    )))
    (and found (goto-char found))))

(defun dired-initial-position ()
  ;; Where point should go in new listings.
  ;; Point assumed at beginning of new subdir line.
  (end-of-line)
  (if dired-trivial-filenames (dired-goto-next-nontrivial-file)))

;;; moving by subdirectories

(defun dired-subdir-index (dir)
  ;; Return an index into alist for use with nth
  ;; for the sake of subdir moving commands.
  (let (found (index 0) (alist dired-subdir-alist))
    (while alist
      (if (string= dir (car (car alist)))
	  (setq alist nil found t)
	(setq alist (cdr alist) index (1+ index))))
    ;; (message "%s %s" dir (nth index dired-subdir-alist))
    (if found index nil)))

(defun dired-next-subdir (arg &optional no-error-if-not-found)
  "Go to next subdirectory, regardless of level.
Use 0 prefix argument to go to this directory's header line."
  (interactive "p")
  (let ((this-dir (dired-current-directory))
	pos index)
    ;; nth with negative arg does not return nil but the first element
    (setq index (- (dired-subdir-index this-dir) arg))
    (setq pos (if (>= index 0) (cdr (nth index dired-subdir-alist)) nil))
    (if pos
	(goto-char pos)			; exit with non-nil return value
      (if no-error-if-not-found
	  nil				; return nil if not found
	(error "No more directories.")))))

(defun dired-prev-subdir (arg &optional no-error-if-not-found)
  "Go to previous subdirectory, regardless of level.
When called interactively and not on a subdir line, go to subdir line."
  (interactive
   (list (if current-prefix-arg
	     (prefix-numeric-value current-prefix-arg)
	   (if (and (dired-get-subdir) (not (bolp))) 1 0))))
  (dired-next-subdir (- arg) no-error-if-not-found))

(defun dired-up-subdir (arg)
  "Go up ARG levels in the dired tree."
  (interactive "p")
  (let ((dir (concat (dired-current-directory) "..")))
    (while (> arg 1) (setq arg (1- arg) dir (concat dir "/..")))
    (setq dir (expand-file-name dir))
    (or (dired-goto-subdir dir)
	(error "Cannot go up to %s - not in this tree." dir))))

(defun dired-down-subdir (arg)
  "Go down ARG levels in the dired tree."
  (interactive "p")
  (let ((dir (dired-current-directory)) ; has slash
	(tail "[^/]+"))			; at least one more path name component
    (while (> arg 1) (setq arg (1- arg) tail (concat tail "/[^/]+")))
    (if (re-search-forward		; can't use $ searches when
	 (concat "^. " dir tail ":[\n\r]") nil t) ; dir is hidden
	(backward-char 1)
      (error "At the bottom."))))

;;; hiding

(defun dired-subdir-hidden-p (dir)
  (save-excursion
    (and selective-display
	 (dired-goto-subdir dir)
	 (looking-at "\r"))))

(defun dired-unhide-subdir ()
  (let ((buffer-read-only nil))
    (subst-char-in-region (dired-subdir-min) (dired-subdir-max) ?\r ?\n)))

(defun dired-hide-check ()
  (or selective-display
      (error "selective-display must be t for subdir hiding to work!")))

(defun dired-hide-subdir (arg)
  "Hide or unhide the current subdirectory and move to next directory.
Optional prefix arg is a repeat factor.
Use \\[dired-hide-all] to (un)hide all directories."
  (interactive "p")
  (dired-hide-check)
  (let (from-char to-char end-pos (buffer-read-only nil))
    (dired-next-subdir 0)	; to end of subdir line
    (while (> arg 0)
      (setq arg (1- arg))
      (if (looking-at "\n")
	  (setq from-char ?\n to-char ?\r) ; hide
	(setq to-char ?\n from-char ?\r)) ; unhide
      (subst-char-in-region
       (point)
       (save-excursion
	 (or (setq end-pos (dired-next-subdir 1 t))
	     (goto-char (point-max)))
	 ;;(forward-line -1) does work only with \n, not \r
	 ;; search backward for \n or \r:
	 (skip-chars-backward (concat "^" (char-to-string from-char)))
	 ;; this is necessary, else blank lines will be deleted:
	 (if (= from-char ?\n) (backward-char 1))
	 (point))
       from-char to-char)
      (if end-pos (goto-char end-pos)))))

(defun dired-hide-all (arg)
  "Hide all subdirectories, leaving only their header lines.
If there is already something hidden, make everything visible again.
Use \\[dired-hide-subdir] to (un)hide a particular subdirectory."
  (interactive "P")
  (dired-hide-check)
  (let ((buffer-read-only nil))
    (if (save-excursion
	  (goto-char (point-min))
	  (search-forward "\r" nil t))
	;; unhide - bombs on \r in filenames
	(subst-char-in-region (point-min) (point-max) ?\r ?\n)
      ;; hide
      (let ((pos (point-max))		; pos of end of last directory
	    (alist dired-subdir-alist))
	(while alist			; while there are dirs before pos
	  (subst-char-in-region (cdr (car alist)) ; pos of prev dir
				(save-excursion
				  (goto-char pos) ; current dir
				  (forward-line -1)
				  (point))
				?\n ?\r)
	  (setq pos (cdr (car alist)))	; prev dir gets current dir
	  (setq alist (cdr alist)))))))

(defun dired-undo ()
  "Undo in a dired buffer.
This doesn't recover lost files, it is just normal undo with temporarily
writeable buffer.  You can use it to recover killed lines or subdirs.
You might have to do \\[dired-build-subdir-alist] to parse the buffer again."
  (interactive)
  (let ((buffer-read-only nil))
    (undo)))

(defun dired-advertise ()
  "Advertise in  dired-buffers  what directory we dired."
  (if (memq (current-buffer) (dired-buffers default-directory))
      t					; we have already advertised ourselves
    (setq dired-buffers
	  (cons (cons default-directory (current-buffer))
		dired-buffers))))

; unused:
;(defun dired-unadvertise (dir)
;  ;; Remove DIR from the buffer alist in variable dired-buffers.
;  (setq dired-buffers
;      (delq (assoc dir dired-buffers) dired-buffers)))

;; This function is the heart of tree dired
(defun dired-current-directory (&optional relative)
  "Get the subdirectory to which this line belongs.
This returns a string with trailing slash, like default-directory.
Optional argument means return a name relative to default-directory."
  (let (elt
	dir
	(here (point))
	;; Under strange circumstances, when dired-revert calls
	;; dired-get-filename and thus this function, the alist is not
	;; defined.  I don't understand how this can happen.
	(alist (or dired-subdir-alist (dired-build-subdir-alist))))
    (while alist
      (setq elt (car alist)
	    dir (car elt))
      (if (<= (cdr elt) here)		; subdir line is part of subdir
	  ;; found - exit while
	  (setq alist nil)
	;; else have to loop once more
	(setq alist (cdr alist))))
    (if relative
	(dired-make-relative dir default-directory)
      dir)))

(defun dired-subdir-min ()
  (save-excursion
    (if (not (dired-prev-subdir 0 t))
	(error "Not in a subdir!")
      (beginning-of-line)
      (point))))

(defun dired-subdir-max ()
  (save-excursion
    (if (not (dired-next-subdir 1 t))
	(point-max)
      (beginning-of-line)
      (point))))

(defun dired-kill-subdir (&optional no-build)
  "Remove all lines of current subdirectory.
Lower levels are unaffected."
  (interactive)
  (let ((buffer-read-only nil))
    ;;(end-of-line);;  necessary if on a subdir line
    (if (and (interactive-p)
	     (equal (dired-current-directory) default-directory))
	(error "Cannot kill top level directory."))
    (delete-region (dired-subdir-min) (dired-subdir-max))
    ;; leave one blank line when between directories:
    (skip-chars-backward " \n")
    (or (eobp) (forward-char 1))
    (while (and (not (eobp))
		(looking-at "[ \n]"))
      (delete-char 1))
    ;;(insert "\n")
    (or (eobp) (insert "\n  "))
    (or no-build (dired-unsubdir (dired-current-directory)))))

(defun dired-mark-files-in-region (start end &optional arg)
  (let ((buffer-read-only nil))
    (if (> start end)
	(error "start > end"))
    (goto-char start)			; assumed at beginning of line
    (while (< (point) end)
      ;; Skip subdir line and following garbage like the `total' line:
      (while (and (< (point) end) (dired-between-files))
	(forward-line 1))
      (if (and (or arg (not (looking-at dired-re-dir)))
	       (dired-get-filename nil t))
	  (progn
	    (delete-char 1)
	    (insert dired-marker-char)))
      (forward-line 1))))

(defun dired-mark-subdir-files (&optional arg)
  "Mark all files except directories in this subdir.
With prefix arg, mark even directories."
  (interactive "P")
  (let ((buffer-read-only nil)
	(p-min (dired-subdir-min)))
    (dired-mark-files-in-region p-min (dired-subdir-max) arg)
    ;; This only makes sense if marking also works when subdir is hidden.
    ;; But should it work on hidden files?
;    (save-excursion
;      (goto-char p-min)
;      (delete-char 1)
;      (insert dired-marker-char))
    ))

(defun dired-mark-subdir-or-file (arg)
  "If looking at a subdir, mark all its files, else like dired-mark-file."
  (interactive "P")
  (if (dired-get-subdir)
      (save-excursion
	(end-of-line)
	(dired-mark-subdir-files arg))
    (dired-mark-file (prefix-numeric-value arg))))

(defun dired-insert-subdir (dirname &optional switches)
  "Insert this subdirectory into the same dired buffer.
If subdirectory is already present, overwrites previous entry, else
appends at end of buffer.
With a prefix arg, you may edit the ls switches used for this listing."
  ;; This function takes some pains to conform to ls -lR output.
  (interactive
   (list (dired-get-filename)
	 (if current-prefix-arg
	     (read-string "Switches for listing: " dired-actual-switches))))
  (setq dirname (file-name-as-directory (expand-file-name dirname)))
  (dired-make-relative dirname default-directory) ; error on failure
  (let (beg end index old-marker new-marker mark-alist (buffer-read-only nil)) 
    (or (file-directory-p dirname) (error  "Not a directory: %s" dirname))
    (if (setq index (dired-subdir-index dirname))
	(progn
	  (setq old-marker (cdr (nth index dired-subdir-alist)))
	  (goto-char old-marker)
	  (forward-line -1)
	  (setq beg (point))
	  (goto-char old-marker)
	  (setq end (dired-subdir-max))
	  (save-restriction
	    (narrow-to-region old-marker end)
	    ;; Must unhide to make remembering work:
	    (subst-char-in-region (point-min) (point-max) ?\r ?\n)
	    (setq mark-alist (dired-remember-marks)))
	  (delete-region beg end)
	  ;; must make an empty line to
	  ;; separate it from next subdir (if any)
	  (if (not (eobp))
	      (save-excursion (insert "\n"))))
      (goto-char (point-max)))
    (or (bobp) (insert "\n"))
    (setq beg (point))
    (message "Reading directory %s..." dirname)
    (dired-ls dirname
	      (or switches
		  (dired-replace-in-string "R" "" dired-actual-switches))
	      nil t)
    (message "Reading directory %s...done" dirname)
    (indent-rigidly beg (point) 2)
    (if dired-readin-hook
	(save-restriction
	  (narrow-to-region beg (point))
	  (run-hooks 'dired-readin-hook)))
    ;;  call dired-insert-headerline afterwards, as under VMS dired-ls
    ;;  does insert the headerline itself and the insert function just
    ;;  moves point.
    (goto-char beg)
    (dired-insert-headerline dirname)	; must put point where
    (setq new-marker (point-marker))	; dired-build-subdir-alist
					; would
    (if index (set-marker old-marker new-marker))

    (if index				; if already present,
	(set-marker new-marker nil)	; new-marker is unused
      (dired-alist-add dirname new-marker))
    (if (and switches (string-match "R" switches))
	(dired-build-subdir-alist))
    (dired-initial-position)
    (save-excursion
      (goto-char beg)
      (dired-mark-remembered mark-alist))))

;; sorting

(defvar dired-sort-by-date-regexp "^-altR?$"
  "Regexp recognized by dired-sort-mode to set by date mode.")

(defvar dired-sort-by-name-regexp "^-alR?$"
  "Regexp recognized by dired-sort-mode to set by name mode.")

(defun dired-sort-mode ()
  "Set dired-sort-mode according to dired-actual-switches."
  (cond ((string-match dired-sort-by-date-regexp dired-actual-switches)
	 (dired-sort-by-date))
	((string-match dired-sort-by-name-regexp dired-actual-switches)
	 (dired-sort-by-name))
	(t (dired-sort-other dired-actual-switches t))))

(defun dired-sort-toggle ()
  "Toggle between sort by date/name."
  (interactive)
  (if (string-match dired-sort-by-date-regexp dired-actual-switches)
      (dired-sort-by-name)
    (dired-sort-by-date))
  (revert-buffer))

;; We can't preserve arbitrary ls switches because they may override
;; the presence or absence of the `t' option.
;; And we have to make sure to set dired-actual-switches to a legal
;; value.
;; And when displaying `by name' or `by date' in the modeline, this
;; should correspond to a definite listing format.

(defun dired-sort-by-date ()
  ;; Force sort by date, but preserve `R' and `a' ls switches.
  (setq dired-actual-switches
	(concat "-" (if (string-match "a" dired-actual-switches) "a" "")
		"lt" (if (string-match "R" dired-actual-switches) "R" "")))
  (setq dired-sort-mode " by date")
  (set-buffer-modified-p (buffer-modified-p))) ;No-op, but updates mode line.

(defun dired-sort-by-name ()
  ;; Force sort by name, but preserve `R' and `a' ls switches.
  (setq dired-actual-switches
	(concat "-" (if (string-match "a" dired-actual-switches) "a" "")
		"l" (if (string-match "R" dired-actual-switches) "R" "")))
  (setq dired-sort-mode " by name")
  (set-buffer-modified-p (buffer-modified-p))) ;No-op, but updates mode line.

(defun dired-sort-other (switches &optional no-revert)
  "Specify dired-actual-switches for dired-mode.
Values matching dired-sort-by-date-regexp or dired-sort-by-name-regexp
set the minor mode accordingly, others appear literally in the mode line.
With prefix arg, don't revert the buffer afterwards."
  (interactive
   (list (read-string "ls switches (must contain -l): "
		      dired-actual-switches)
	 current-prefix-arg))
  (setq dired-actual-switches switches)
  (setq dired-sort-mode (concat " " dired-actual-switches))
  ;; might really be by name or by date
  (if (string-match dired-sort-by-date-regexp dired-actual-switches)
      (dired-sort-by-date)
    (if (string-match dired-sort-by-name-regexp dired-actual-switches)
	(dired-sort-by-name)))
  (set-buffer-modified-p (buffer-modified-p)) ;No-op, but updates mode line.
  (or no-revert (revert-buffer)))

(if (eq system-type 'vax-vms)
    (load "dired-vms"))

;;; patched by Manabu Higashida for demacs-1.1 91/10/28
(if (eq system-type 'ms-dos)
    (load "direddos"))

(run-hooks 'dired-load-hook)		; for your customizations

;;; debugging:

(defun dired-log (fmt &rest args)
  (save-excursion
    (set-buffer (get-buffer-create "*Dired Log*"))
    (goto-char (point-max))
    (insert "\n" (apply 'format fmt args))))
