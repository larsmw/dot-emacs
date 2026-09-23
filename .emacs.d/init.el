;;; package --- Summary  -*- lexical-binding: t; byte-compile-warning: nil; flycheck-emacs-lisp-load-path: inherit;  -*-


;;; Commentary:
;;; .emacs - Configuration


;;; Code:

(defvar config-dir (expand-file-name "config" user-emacs-directory))

;; Add config directory to load-path
(add-to-list 'load-path config-dir)

(load (expand-file-name "core/packages" config-dir))
(load (expand-file-name "core/ui" config-dir))
(load (expand-file-name "core/vc" config-dir))
(load (expand-file-name "core/project" config-dir))
(load (expand-file-name "web/webmode" config-dir))
(load (expand-file-name "web/phpmode" config-dir))
(load (expand-file-name "ai/llm" config-dir))

(ffap-bindings)

;; Keep Customize settings out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

(provide 'init)
;;; init.el ends here
