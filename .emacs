;;; package --- Summary

;;; Commentary:
;;; .emacs - Configuration


;;; Code:
;; (use-package swiper)

(defvar config-dir (expand-file-name "config" user-emacs-directory))

;; Add config directory to load-path
(add-to-list 'load-path config-dir)

(load (expand-file-name "core/packages" config-dir))


;; Duplicate line
(global-set-key "\C-c\C-d" "\C-a\C- \C-n\M-w\C-y")

;;; Set global fonts
(custom-set-faces
 '(default (
            (t (
                :inherit nil
                         :extend nil
                         :stipple nil
                         :background "#2e3436"
                         :foreground "#eeeeec"
                         :inverse-video nil
                         :box nil
                         :strike-through nil
                         :overline nil
                         :underline nil
                         :slant normal
                         :weight light
                         :height 100
                         :width normal
                         :foundry "JB"
                         :family "JetBrains Mono")))
           )
 )




;;; Buffer configuration
(tool-bar-mode -1)

(use-package which-key
  :ensure t
  :config (which-key-mode))


(show-paren-mode 1)

(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

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

(use-package magit
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))


(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t))

(display-line-numbers-mode 1)

;;(use-package nginx-mode)
;;(require 'nginx-mode)
;;(nginx-mode 1)

(use-package lsp-mode
  :ensure t
  :config
  (setq lsp-headerline-breadcrumb-enable nil) ;; works
  (setq lsp-enable-symbol-highlighting nil) ;; works
  (setq lsp-signature-render-documentation nil)
  (setq lsp-completion-provider :none) ;; works
  (setq lsp-diagnostics-provider :flymake) ;; underline error
  )

(require 'lsp-mode)
(add-hook 'php-mode-hook #'lsp)

(require 'php-mode)
(define-key php-mode-map (kbd "C-c g") 'ac-php-find-symbol-at-point)

(add-hook 'php-mode-hook
	  (lambda ()
            (auto-complete-mode t)
            (require 'ac-php)
            (setq ac-sources '(ac-source-php))
            (subword-mode 1)
            (yas-global-mode 1)

	    (ac-php-core-eldoc-setup)

;;	    (display-line-numbers-mode 1)

            (define-key php-mode-map (kbd "C-]")
			'ac-php-find-symbol-at-point)
            (define-key php-mode-map (kbd "C-t")
			'ac-php-location-stack-back)))




;;(add-hook 'php-mode-hook 'eglot-ensure)

;; Dont mix eglot and lsp...
;;; (with-eval-after-load 'eglot
;;   (add-to-list 'eglot-server-programs
;;               '(php-mode . ("php" "--stdio"))))


;;(defun eglot--post-self-insert-hook ()
;;  "Set `eglot--last-inserted-char', maybe call on-type-formatting."
;;  (setq eglot--last-inserted-char last-input-event)
;;  (let ((ot-provider (eglot--server-capable :documentOnTypeFormattingProvider))
        ;; transform carriage return into line-feed
;;        (adjusted-ie (if (= last-input-event 13) 10 last-input-event)))
;;    (when (and ot-provider
;;               (ignore-errors ; github#906, some LS's send empty strings
;;                 (or (eq adjusted-ie
;;                         (seq-first (plist-get ot-provider :firstTriggerCharacter)))
;;                     (cl-find adjusted-ie
;;                              (plist-get ot-provider :moreTriggerCharacter)
;;                              :key #'seq-first))))
;;      (eglot-format (point) nil adjusted-ie))))

;; (use-package dap-mode)
;; (use-package dap-php)
;; (use-package dap-node)
;; (require 'dap-node)
;; (dap-node-setup)

;; (require 'dap-php)

(dap-mode 1)
(dap-ui-mode 1)
(dap-tooltip-mode 1)
(dap-ui-controls-mode 1)

(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

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

(use-package web-mode
  :ensure t
  :mode "\\.twig\\'")

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

(setq counsel-grep-base-command
      "rg -i -M 120 --no-heading --line-number --color never '%s' %s")

(global-set-key (kbd "C-s") 'counsel-grep-or-swiper)

;;; .emacs ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(ac-php consult-eglot consult-projectile counsel csv-mode dap-mode
            dape dired-git dired-git-info flycheck ggtags magit
            nginx-mode phpinspect rjsx-mode sass-mode web-mode
            yaml-mode yasnippet-snippets)))
