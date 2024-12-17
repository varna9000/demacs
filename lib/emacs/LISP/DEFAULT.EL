;;; On MS-DOS file system, we can't control version of backup file.
(setq version-control 'never)

;;; exec-directory may change by specifing EMACSEXECPATH environment variable.
(setq Info-directory (expand-file-name "../info/" exec-directory))
