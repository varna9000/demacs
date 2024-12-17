;; direddos.el - DOS support for dired.
;; Copyright (C) 1991 Manabu Higashida

;; This file is part of Demacs (MS-DOS version of GNU Emacs and Nemacs).

;; Demacs is distributed in the forms of patches to GNU
;; Emacs under the terms of the GNU EMACS GENERAL PUBLIC
;; LICENSE which is distributed along with GNU Emacs by the
;; Free Software Foundation.

;; Demacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU EMACS GENERAL PUBLIC LICENSE for
;; more details.

;; You should have received a copy of the GNU EMACS GENERAL
;; PUBLIC LICENSE along with Demacs; see the file COPYING.
;; If not, write to the Free Software Foundation, 675 Mass
;; Ave, Cambridge, MA 02139, USA. */

(setq dired-chmod-program nil)
(setq dired-chgrp-program nil)
(setq dired-chown-program nil)
(setq dired-ls-program nil)
(setq dired-compress-program nil)
(setq dired-uncompress-program nil)

(defun sort-files-by-modified-time (files)
  (sort files
	'(lambda (a b)
	   (let ((aa (car (nth 5 a)))
		 (ab (car (cdr (nth 5 a))))
		 (ba (car (nth 5 b)))
		 (bb (car (cdr (nth 5 b)))))
	     (cond ((> aa ba) t)
		   ((= aa ba) (> ab bb))
		   (t nil))))))

(defun time-string-to-time-list (date)
  (let* ((garbage (string-match
		   " \\([A-Z][a-z][a-z]\\) *\\([0-9]*\\) \\([0-9:]*\\) \\([0-9]*\\)$"
		   date))
	 (time (substring date (match-beginning 3) (match-end 3)))
	 (day (string-to-int
	       (substring date (match-beginning 2) (match-end 2))))
	 (month
	  (cdr (assoc
		(substring date (match-beginning 1) (match-end 1))
		'(("Jan" . 1) ("Feb" . 2)  ("Mar" . 3)  ("Apr" . 4)
		  ("May" . 5) ("Jun" . 6)  ("Jul" . 7)  ("Aug" . 8)
		  ("Sep" . 9) ("Oct" . 10) ("Nov" . 11) ("Dec" . 12)))))
	 (year (string-to-int
		(substring date (match-beginning 4) (match-end 4)))))
    (list year month day time)))

(defun file-modified-time-string (tem)
  (let* ((mtime        (time-string-to-time-list (time-to-string tem)))
	 (current-time (time-string-to-time-list (current-time-string)))
	 (month
	  (aref ["Jan" "Feb" "Mar" "Apr" "May" "Jun"
		 "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"]
		(1- (nth 1 mtime)))))
    (if (and (< (nth 0 mtime) (nth 0 current-time))
	     (< (nth 1 mtime) (nth 1 current-time))
	     (< (nth 2 mtime) (nth 2 current-time))
	     (string< (nth 3 mtime) (nth 3 current-time)))
	(format "%s %02d %5d" month (nth 2 mtime) (nth 0 mtime))
      (format "%s %02d %s" month (nth 2 mtime) (substring (nth 3 mtime) 0 5)))))

(defun wildcard-to-regexp (path)
  (concat "^"
	  (replace-letter (replace-letter path "." "\\.") "*" ".*")
	  "$"))

(defun list-directory-file-attributes (path &optional wildcard)
  (and wildcard
       (setq wildcard (wildcard-to-regexp (file-name-nondirectory path))))
  (let* ((dirname (if wildcard
		      (file-name-directory path)
		    (file-name-as-directory path)))
	 (files (reverse (directory-files dirname)))
	 file place)
    (while files
      (setq file (car files))
      (if (or (not wildcard)
	      (string-match wildcard file))
	  (setq place (cons (cons file
				  (file-attributes (concat dirname file)))
			    place)))
      (setq files (cdr files)))
    place))

(defun file-attributes-to-string (attributes)
  (format "%s %3d %-8s %8d %s %s"
	  (nth 8 attributes)
	  (nth 1 attributes)
	  (user-login-name)
	  (nth 7 attributes)
	  (file-modified-time-string (nth 4 attributes))))

(defun dos-dired-ls (file &optional switches wildcard full-directory-p)
  (or switches (setq switches dired-listing-switches))
  (if (or (and full-directory-p
	       (not (string-match "-.*d.*" switches)))
	  wildcard)
      (let* ((place (list-directory-file-attributes file wildcard))
	     filename attributes)
	(if (string-match "-.*t.*" switches)
	    (setq place (sort-files-by-modified-time place)))
	(if (string-match "-.*r.*" switches)
	    (setq place (reverse place)))
	(insert (format "total %d file(s)\n" (length place)))
	(while place
	  (setq filename   (car (car place))
		attributes (cdr (car place)))
	  (insert (concat (file-attributes-to-string attributes)
			  " "
			  filename)
		  ?\n)
	  (setq place (cdr place))))
    (let ((attributes (file-attributes file)))
      (insert (concat (file-attributes-to-string attributes) " "
		      (file-name-nondirectory file))
	      ?\n))))


;;; from c-fill.el
;;;
;;; replace-letter - Given a string, an old letter and a new letter,
;;; 		     perform the substitution.
;;; 
(defun replace-letter (str old-letter new-letter)
  (let (new-str c
	(sp 0)
	(size (length str)))
    (while (< sp size)
      (setq c (substring str sp (1+ sp)))
      (setq new-str (concat new-str (if (string= c old-letter) new-letter c)))
      (setq sp (1+ sp)))
    new-str))
