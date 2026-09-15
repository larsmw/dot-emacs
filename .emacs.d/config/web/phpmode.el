
(require 'php-mode)

(use-package php-ts-mode
  :ensure t
  :hook ((php-ts-mode . (lambda ()
                          (auto-complete-mode 1)

                          (require 'ac-php)
                          (setq ac-sources '(ac-source-php))
                          (set (make-local-variable 'company-backends)
       '(;; list of backends
         company-phpactor
         company-files
         )))))
  )

(use-package dap-mode
  :ensure t
  )

(unless (file-directory-p "~/.emacs.d/elpa/dap-mode/") 
  (package-vc-install
    '(auto-complete :url "https://github.com/emacs-lsp/dap-mode.git"
  		    :listp-dir "lisp"))
  )

(use-package eldoc
  :ensure t
  )
(use-package php-eldoc
  :ensure t
  )

(add-to-list 'treesit-language-source-alist
             '(php "https://github.com/tree-sitter/tree-sitter-php" "master" "php/src"))
(define-key php-mode-map (kbd "C-c s") 'ac-php-find-symbol-at-point)

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



(setq package-selected-packages '(lsp-mode yasnippet lsp-treemacs flycheck company which-key dap-mode php-mode))

(when (cl-find-if-not #'package-installed-p package-selected-packages)
  (package-refresh-contents)
  (mapc #'package-install package-selected-packages))

(which-key-mode)
(add-hook 'php-mode-hook 'lsp)


(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (require 'dap-php)
  (yas-global-mode))

(use-package company-php)


(use-package lsp-ui
  :requires lsp-mode flycheck
  :config

  (setq lsp-ui-doc-enable t
        lsp-ui-doc-use-childframe t
        lsp-ui-doc-position 'top
        lsp-ui-doc-include-signature t
        lsp-ui-sideline-enable nil
        lsp-ui-flycheck-enable t
        lsp-ui-flycheck-list-position 'right
        lsp-ui-flycheck-live-reporting t
        lsp-ui-peek-enable t
        lsp-ui-peek-list-width 60
        lsp-ui-peek-peek-height 25)

  (add-hook 'lsp-mode-hook 'lsp-ui-mode))





(provide 'php-mode)
