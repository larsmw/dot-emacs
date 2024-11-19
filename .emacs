;;; package --- Summary

;;; Commentary:
;;; .emacs - Configuration


;;; Code:
(require 'package)

(add-to-list 'package-archives
             '(("melpa" . "https://melpa.org/packages/")
               ("org"   . "https://orgmode.org/elpa/")
               ("elpa"  . "https://elpa.org/packages/")
	     ))

(package-initialize)

(eval-when-compile
  (require 'use-package))

(tool-bar-mode -1)

(use-package which-key
  :ensure t
  :config (which-key-mode))

(add-to-list 'load-path "~/.emacs.d/elpa/")
(add-to-list 'load-path "~/.emacs.d/elpa/geben/")
(add-to-list 'load-path "~/.emacs.d/php-mode/")

(use-package auto-package-update
  :custom
    (auto-package-update-interval 2)
    (auto-package-update-prompt-before-update t)
    (auto-package-update-hide-results 1)
  :config
    (auto-package-update-maybe)
    (auto-package-update-at-time "23:50"))


(show-paren-mode 1)

(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

(use-package auto-complete
  :ensure t
  :init
    (ac-config-default)
    (global-auto-complete-mode t)
    )

(use-package dap-mode)
(use-package dap-php)
;(use-package dap-node)
;(require 'dap-node)
;(dap-node-setup)
(require 'dap-php)

(dap-mode 1)
(dap-ui-mode 1)
(dap-tooltip-mode 1)
(dap-ui-controls-mode 1)

(use-package counsel
  :ensure t
  )

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

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t))

(use-package ivy)
;; (global-flycheck-mode)
(require 'ivy)
(ivy-mode 1)
(load-theme 'tango-dark)

;; (display-line-numbers-mode 1)

;;(use-package nginx-mode)
;;(require 'nginx-mode)
;;(nginx-mode 1)

(require 'php-mode)
(define-key php-mode-map (kbd "C-c g") 'counsel-etags-find-tag-at-point)

(add-hook 'php-mode-hook
	  (lambda ()
            (auto-complete-mode t)
            (require 'ac-php)
            (setq ac-sources '(ac-source-php))

            (yas-global-mode 1)

	    (ac-php-core-eldoc-setup)

	    (display-line-numbers-mode 1)

            (define-key php-mode-map (kbd "C-]")
			'ac-php-find-symbol-at-point)
            (define-key php-mode-map (kbd "C-t")
			'ac-php-location-stack-back)))

(add-hook 'php-mode-hook 'eglot-ensure)

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
              '(php-mode . ("php" "--stdio"))))






;; Use php ts mode.
;; (use-package php-ts-mode
;;   :mode ("\\.php$" . php-ts-mode)
;;   :hook (php-ts-mode . eglot-ensure)
;;   :config
;;   (with-eval-after-load 'apheleia
;;     (setf (alist-get 'phpcs apheleia-formatters)
;;           '("composer" "--no-interaction" (concat "--working-dir=" (r/project-root))
;;             "exec" "php-cs-fixer" "fix" "--quiet" (buffer-file-name)))))





(use-package rjsx-mode
  :ensure t
  :mode "\\.js\\'")

(use-package sass-mode
  :ensure t)

(defun kill-dired-buffers ()
     (interactive)
     (mapc (lambda (buffer)
           (when (eq 'dired-mode (buffer-local-value 'major-mode buffer))
             (kill-buffer buffer)))
           (buffer-list)))


(use-package org)
;; (use-package hlinum)

(global-nlinum-mode 1)

;; This highlights the current line.
(global-hl-line-mode t)

(defalias 'list-buffers 'ibuffer)


;;; .emacs ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(use-package yaml-mode yaml web-mode twig-mode sql-indent projectile-codesearch picpocket phpstan mmm-mode json-mode ivy-phpunit geben flyspell-correct-ivy flymake-phpcs flymake-php flymake flycheck-projectile drupal-spell drupal-mode counsel-projectile counsel-etags composer ac-php)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
