;;;; Emacs 19 compatibility functions for use in Emacs 18.55
;;;; $Id: emacs-19.el,v 1.2 90/12/19 17:49:19 sk Exp $

(defun remove-directory (fn)
  "Remove a directory."
  (interactive 
   (list (expand-file-name (read-file-name "Remove directory: " nil nil 'confirm)))) 
  (if (file-directory-p fn)
      (call-process "rmdir" nil nil nil fn)
    (error "Not a directory: %s" fn))
  (if (file-exists-p fn)
      (error "Could not remove directory %s" fn)))

(defun make-directory (fn)
  "Make a directory."
  (interactive (list (expand-file-name (read-file-name "Make directory: "))))
  (if (file-exists-p fn)
      (error "Cannot make directory %s: file already exists" fn)
    (call-process "mkdir" nil nil nil fn))
  (or (file-directory-p fn)
      (error "Could not make directory %s" fn)))

(defun diff (fn1 fn2 &optional interactive)
  "Diff two files.
If interactive (optional third arg if called from a program), edit the
command before execution to insert diff switches." 
  (interactive "fDiff: \nfDiff %s with: \np")
  (let ((command (concat  "diff " fn1 " " fn2)))
  (if interactive
      (setq command (read-string "Execute: " command)))
  (require 'compile "compile")
  (compile1 command "No more diff's" "diff")))


(defun vms-read-directory (dirname switches buffer)
  ;; Dired calls this function only in the current buffer
  ;; dired-ls gets redefined in dired-vms.el to work under VMS.
  (and buffer
       (not (eq buffer (current-buffer)))
       (error "Must be called in current buffer"))
  (dired-ls dirname switches nil t))

(provide 'emacs-19)
