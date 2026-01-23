
(require 'php-mode)

(use-package php-ts-mode
  :ensure t
  )

(add-to-list 'treesit-language-source-alist
             '(php "https://github.com/tree-sitter/tree-sitter-php" "master" "php/src"))

(define-key php-mode-map (kbd "C-c g") 'ac-php-find-symbol-at-point)

(use-package ac-php
  :ensure t
  )

(use-package ac-php-core
  :ensure t
  )

(require 'lsp-mode)
(add-hook 'php-mode-hook #'lsp)

(use-package dap-php
  :ensure t
  )
(use-package eldoc
  :ensure t
  )
(use-package php-eldoc
  :ensure t
  )



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

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (require 'dap-php)
  (yas-global-mode)
  )

(dap-mode 1)
(dap-ui-mode 1)
(dap-tooltip-mode 1)
(dap-ui-controls-mode 1)

(provide 'php-mode)
