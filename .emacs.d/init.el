;;; package --- Summary  -*- lexical-binding: t; byte-compile-warning: nil; flycheck-emacs-lisp-load-path: inherit;  -*-


;;; Commentary:
;;; .emacs - Configuration


;;; Code:

(defvar config-dir (expand-file-name "config" user-emacs-directory))

;; The daemon runs from systemd and never reads ~/.bashrc, so per-user
;; tools (rust-analyzer, intelephense, ddev) need adding here.
(let ((local-bin (expand-file-name "~/.local/bin")))
  (add-to-list 'exec-path local-bin)
  (unless (member local-bin (split-string (getenv "PATH") path-separator))
    (setenv "PATH" (concat local-bin path-separator (getenv "PATH")))))

;; Add config directory to load-path
(add-to-list 'load-path config-dir)

(load (expand-file-name "core/packages" config-dir))
(load (expand-file-name "core/ui" config-dir))
(load (expand-file-name "core/vc" config-dir))
(load (expand-file-name "core/project" config-dir))
(load (expand-file-name "core/ide" config-dir))
(load (expand-file-name "web/webmode" config-dir))
(load (expand-file-name "web/phpmode" config-dir))
(load (expand-file-name "web/php-tools" config-dir))
(load (expand-file-name "lang/rust" config-dir))
(load (expand-file-name "ai/llm" config-dir))

;; Keep Customize settings out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

(provide 'init)
;;; init.el ends here
