;; -*- lexical-binding: t; -*-

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

;;         (display-line-numbers-mode 1)

            (define-key php-mode-map (kbd "C-]")
                       'ac-php-find-symbol-at-point)
            (define-key php-mode-map (kbd "C-t")
                       'ac-php-location-stack-back)))



;;(add-hook 'php-mode-hook 'eglot-ensure)

;; Dont mix eglot and lsp...
;;; (with-eval-after-load 'eglot
;;   (add-to-list 'eglot-server-programs
;;               '(php-mode . ("php" "--stdio"))))



;; (use-package dap-mode)
;; (use-package dap-php)
;; (use-package dap-node)
;; (require 'dap-node)
;; (dap-node-setup)

;; (require 'dap-php)


;;; PHP mode


;; Use php ts mode.
;; (use-package php-ts-mode
;;   :mode ("\\.php$" . php-ts-mode)
;;   :hook (php-ts-mode . eglot-ensure)
;;   :config
;;   (with-eval-after-load 'apheleia
;;     (setf (alist-get 'phpcs apheleia-formatters)
;;           '("composer" "--no-interaction" (concat "--working-dir=" (r/project-root))
;;             "exec" "php-cs-fixer" "fix" "--quiet" (buffer-file-name)))))
