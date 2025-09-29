;; -*- lexical-binding: t; -*-

;; (use-package lsp-mode
;;   :ensure t
;;   :config
;;  (setq lsp-headerline-breadcrumb-enable nil) ;; works
;;  (setq lsp-enable-symbol-highlighting nil) ;; works
;;  (setq lsp-signature-render-documentation nil)
;;  (setq lsp-completion-provider :none) ;; works
;;  (setq lsp-diagnostics-provider :flymake) ;; underline error
;;  (setq lsp-clients-php-server-command "/home/lars/bin/phpactor")
;;  )


;;; (require 'lsp-mode)
(add-hook 'php-mode-hook #'lsp)

(use-package dap-php)

(require 'php-mode)
(define-key php-mode-map (kbd "C-c g") 'ac-php-find-symbol-at-point)

;; (with-eval-after-load 'lsp-mode
;;  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
;;  (require 'dap-php)
;;  (yas-global-mode))

(defun my-php-mode-setup ()
  "My PHP-mode hook."
  (require 'flycheck-phpstan)
  (flycheck-mode t))

(add-hook 'php-mode-hook 'my-php-mode-setup)

(add-hook 'php-mode-hook
         (lambda ()
            (auto-complete-mode t)
            (require 'ac-php)
            (setq ac-sources '(ac-source-php))
            (subword-mode 1)
            (yas-global-mode 1)

            (ac-php-core-eldoc-setup)


            (define-key php-mode-map (kbd "C-]")
                       'ac-php-find-symbol-at-point)
            (define-key php-mode-map (kbd "C-t")
                       'ac-php-location-stack-back)))


(add-to-list 'auto-mode-alist '("\.php$" . php-ts-mode))
(add-to-list 'auto-mode-alist '("\.inc$" . php-ts-mode))



(dap-mode 1)
(dap-ui-mode 1)
(dap-tooltip-mode 1)
(dap-ui-controls-mode 1)


(provide 'php-mode)
