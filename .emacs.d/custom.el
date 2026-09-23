;;; custom.el --- Settings written by Customize  -*- lexical-binding: t; -*-

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(ac-php auto-package-update centaur-tabs company-php company-phpactor
            corfu counsel-etags counsel-projectile dap-mode diff-hl
            flycheck gptel lsp-ui magit orderless php-eldoc
            plantuml-mode rg ripgrep sass-mode smartparens
            tree-sitter treesit-fold twig-mode web-mode))
 '(safe-local-variable-values
   '((eval font-lock-add-keywords nil
           `
           ((,(concat "("
                      (regexp-opt
                       '("sp-do-move-op" "sp-do-move-cl"
                         "sp-do-put-op" "sp-do-put-cl" "sp-do-del-op"
                         "sp-do-del-cl")
                       t)
                      "\\_>")
             1 'font-lock-variable-name-face)))
     (flycheck-emacs-lisp-load-path . inherit) (byte-compile-warning))))

;;; custom.el ends here
