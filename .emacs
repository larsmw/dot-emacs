;;; package --- Summary  -*- lexical-binding: t; byte-compile-warning: nil  -*-


;;; Commentary:
;;; .emacs - Configuration


;;; Code:
;; (use-package swiper)

(defvar config-dir (expand-file-name "config" user-emacs-directory))

;; Add config directory to load-path
(add-to-list 'load-path config-dir)

(load (expand-file-name "core/packages" config-dir))
(load (expand-file-name "core/ui" config-dir))
(load (expand-file-name "core/vc" config-dir))
(load (expand-file-name "web/webmode" config-dir))
(load (expand-file-name "web/phpmode" config-dir))


;; Duplicate line
(global-set-key "\C-c\C-d" "\C-a\C- \C-n\M-w\C-y")


(use-package auto-complete
  :ensure t
  :init
    (ac-config-default)
    (global-auto-complete-mode t)
    )

(use-package counsel
  :ensure t
  )
  ;; search the buffer or all buffer


(use-package ivy
  :ensure t
  :init
  (setq ivy-re-builders-alist
    '((swiper . ivy--regex-plus)
      (counsel-ag . ivy--regex-plus)
      (counsel-grep-or-swiper . ivy--regex-plus)
      (t . ivy--regex-fuzzy)))
  )

(global-flycheck-mode)
(require 'ivy)
(ivy-mode 1)
(load-theme 'tango-dark)

(use-package projectile
	     :diminish projectile-mode
	     :config (projectile-mode)
	     :custom ((projectile-completion-system 'ivy))
	     :bind-keymap
	       ("C-c p" . projectile-command-map)
	     :init
	     (when (file-directory-p "~/src")
	       (setq projectile-project-search-path '("~/src")))
	     (setq projectile-switch-project-action #'projectile-dired))

;; (use-package counsel-projectile
;;   :config (counsel-projectile-mode))


(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t))


;;(use-package nginx-mode)
;;(require 'nginx-mode)
;;(nginx-mode 1)



(dap-mode 1)
(dap-ui-mode 1)
(dap-tooltip-mode 1)
(dap-ui-controls-mode 1)

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

(setq counsel-grep-base-command
      "rg -i -M 120 --no-heading --line-number --color never '%s' %s")

(global-set-key (kbd "C-s") 'counsel-grep-or-swiper)

;;; .emacs ends here


