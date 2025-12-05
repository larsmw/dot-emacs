;; -*- lexical-binding: t; -*-

(unless (package-installed-p 'projectile)
  (package-install 'projectile))

(use-package projectile
	     :diminish projectile-mode
	     :config (projectile-mode)
	     :custom ((projectile-completion-system 'ivy))
	     :bind-keymap
	       ("C-c p" . projectile-command-map)
	     :init
	     (when (file-directory-p "~/src")
	       (setq projectile-project-search-path '("~/src")))
	     (setq projectile-switch-project-action #'projectile-dired)
       (setq projectile-sort-order 'access-time)
       )

(use-package counsel-projectile
  :ensure t
  :config (counsel-projectile-mode))


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

;; (global-flycheck-mode)

;;(use-package flycheck
;;  :ensure t
;;   :config (counsel-projectile-mode))
