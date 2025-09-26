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


;; Duplicate line
(global-set-key "\C-c\C-d" "\C-a\C- \C-n\M-w\C-y")


(use-package flymake
  :ensure t
  :custom
  (flymake-show-diagnostics-at-end-of-line nil)
  ;; (flymake-show-diagnostics-at-end-of-line 'short)
  (flymake-indicator-type 'margins)
  (flymake-margin-indicators-string
   `((error "!" compilation-error)
     (warning "?" compilation-warning)
     (note "i" compilation-info)))
  :init
  (define-minor-mode my/diagnostic-at-eol
    "Minor mode to show flymake diagnostic at eol."
    :init-value nil
    :global nil
    :lighter nil
    (if my/diagnostic-at-eol
        (setq flymake-show-diagnostics-at-end-of-line 'short)
      (setq flymake-show-diagnostics-at-end-of-line nil))
    (flymake-mode -1) ;; Disable Flymake
    (flymake-mode 1)
    ))

(global-flycheck-mode)

(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t))


;;(use-package nginx-mode)
;;(require 'nginx-mode)
;;(nginx-mode 1)

(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)


;; (depends-on "puppet-mode")
;;(use-package puppet-mode
;;  :ensure t)

;; (add-to-list 'auto-mode-alist '("\\.pp\\'" . puppet-mode)


(defun kill-dired-buffers ()
     (interactive)
     (mapc (lambda (buffer)
           (when (eq 'dired-mode (buffer-local-value 'major-mode buffer))
             (kill-buffer buffer)))
           (buffer-list)))


(use-package org)

(global-nlinum-mode 1)

;; This highlights the current line.
(global-hl-line-mode t)

(defalias 'list-buffers 'ibuffer)


(global-set-key (kbd "C-M-s") 'rgrep)

;; very nice buffer shifting :)
(global-set-key (kbd "C-x b") 'counsel-switch-buffer)

(add-to-list 'load-path "~/.emacs.d/ts-fold-0.4.0/")


(use-package tree-sitter
  :ensure t
  )


;; configure folding
(require 'ts-fold)
;; (global-set-key (kbd "C-x +") 'treesit-fold-open)
;; (global-set-key (kbd "C-x -") 'treesit-fold-close)


(desktop-save-mode 1)



;;; Test llm integration
(use-package gptel
  :ensure t)

(setq gptel-backend
      (gptel-make-openai "LM Studio"
        :host "localhost:1234"
        :protocol "http"
        :endpoint "/v1/chat/completions"
        :key "not-needed"))



;;Setup buffer local topic and branching context:
;; (gptel-org-set-topic "gptel:-emacs-llm-interface")
;; (setq gptel-org-branching-context t)


;;Set your LLM backend (e.g., LM Studio)



;;; .emacs ends here

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-vc-selected-packages
   '((auto-package-update :url
			  "https://github.com/rranelli/auto-package-update.el.git"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
