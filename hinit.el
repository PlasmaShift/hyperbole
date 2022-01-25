;;; hinit.el --- Standard initializations for GNU Hyperbole  -*- lexical-binding: t; -*-
;;
;; Author:       Bob Weiner
;;
;; Orig-Date:     1-Oct-91 at 02:32:51
;; Last-Mod:     24-Jan-22 at 00:18:33 by Bob Weiner
;;
;; Copyright (C) 1991-2021  Free Software Foundation, Inc.
;; See the "HY-COPY" file for license information.
;;
;; This file is part of GNU Hyperbole.

;;; Commentary:

;;; Code:
;;; ************************************************************************
;;; Public variables
;;; ************************************************************************

(defvar   hyperb:user-email nil
  "Email address for the current user.  Set automatically by `hyperb:init'.")

;;; ************************************************************************
;;; Other required Elisp libraries
;;; ************************************************************************

(eval-and-compile (mapc #'require '(hvar hui-menu hui-mouse hypb hui hui-mini hbmap hibtypes)))

;;; ************************************************************************
;;; Public functions
;;; ************************************************************************

(unless (fboundp 'br-in-browser)
  ;; Then the OO-Browser is not loaded, so we can never be within the
  ;; browser.  Define this as a dummy function that always returns nil
  ;; until the OO-Browser is ever loaded.
  (defun br-in-browser ()
    "Always returns nil since the OO-Browser is not loaded."
    nil))

;;;###autoload
(defun hyperb:init-menubar ()
  "Add a pulldown menu for Hyperbole after Emacs is initialized."
  (interactive)
  (unless (featurep 'infodock)
    ;; Initialize now since Emacs startup has finished.
    (if after-init-time	(hyperbole-menubar-menu)
      ;; Defer initialization until after Emacs startup.  This really is needed.
      (add-hook 'after-init-hook #'hyperbole-menubar-menu))
    ;; Avoid returning the large Hyperbole menu.
    nil))

;;; ************************************************************************
;;; Menu Support Functions
;;; ************************************************************************

;;;###autoload
(defmacro hui-menu-remove (menu-sym &optional keymap)
  "Remove MENU-SYM menu from any menubars generated by optional KEYMAP or the `global-map'."
  `(prog1 (if (null ,keymap) (setq keymap global-map))
     (define-key (or ,keymap global-map) [menu-bar ,menu-sym] nil)
     ;; Force a menu-bar update.
     (force-mode-line-update)))

;;; ************************************************************************
;;; Private functions
;;; ************************************************************************

(defun hyperb:check-dir-user ()
  "Ensures `hbmap:dir-user' exists and is writable or signals an error."
  (if (or (null hbmap:dir-user) (not (stringp hbmap:dir-user))
	  (and (setq hbmap:dir-user (file-name-as-directory
				     (expand-file-name hbmap:dir-user)))
	       (file-directory-p hbmap:dir-user)
	       (not (file-writable-p (directory-file-name hbmap:dir-user)))))
      (error
       "(hyperb:init): `hbmap:dir-user' must be a writable directory name"))
  (let ((hbmap:dir-user (directory-file-name hbmap:dir-user)))
    (or (file-directory-p hbmap:dir-user)   ;; Exists and is writable.
	(let* ((parent-dir (file-name-directory
			    (directory-file-name hbmap:dir-user))))
	  (cond
	   ((not (file-directory-p parent-dir))
	    (error
	     "(hyperb:init): `hbmap:dir-user' parent dir does not exist"))
	   ((not (file-writable-p parent-dir))
	    (error
	     "(hyperb:init): `hbmap:dir-user' parent directory not writable"))
	   ((or (if (fboundp 'make-directory)
		    (progn (make-directory hbmap:dir-user) t))
		(hypb:call-process-p "mkdir" nil nil hbmap:dir-user))
	    (or (file-writable-p hbmap:dir-user)
		(or (progn (hypb:chmod '+ 700 hbmap:dir-user)
			   (file-writable-p hbmap:dir-user))
		    (error "(hyperb:init): Can't write to 'hbmap:dir-user'"))))
	   (t (error "(hyperb:init): `hbmap:dir-user' create failed"))))))
  t)

(provide 'hinit)


;;; hinit.el ends here
