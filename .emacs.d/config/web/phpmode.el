;; -*- lexical-binding: t; -*-
;;; phpmode.el --- PHP development configuration

;;; Commentary:
;; php-ts-mode (tree-sitter), dap-mode for debugging, eldoc for documentation.

;;; Code:

(use-package php-ts-mode
  :ensure t)

(use-package dap-mode
  :ensure t)

(use-package eldoc
  :ensure t)

(use-package php-eldoc
  :ensure t)

(add-to-list 'treesit-language-source-alist
             '(php "https://github.com/tree-sitter/tree-sitter-php" "master" "php/src"))

(define-key php-mode-map (kbd "C-c s") 'ac-php-find-symbol-at-point)

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
           (define-key php-mode-map (kbd "C-]") 'ac-php-find-symbol-at-point)
           (define-key php-mode-map (kbd "C-t") 'ac-php-location-stack-back)))

(dap-ui-mode 1)
(dap-tooltip-mode 1)
(dap-ui-controls-mode 1)

(provide 'phpmode)
