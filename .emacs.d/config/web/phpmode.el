;; -*- lexical-binding: t; -*-

(require 'treesit)
(add-to-list 'treesit-language-source-alist
             '(php "https://github.com/tree-sitter/tree-sitter-php" "master" "php/src"))

;; php-ts-mode is built into Emacs 30+
(use-package php-ts-mode
  :ensure nil
  :mode ("\\.php\\'" "\\.inc\\'")
  :hook (php-ts-mode . eglot-ensure))

;; Language servers via eglot (built in); diagnostics go to flymake,
;; completion to corfu, docs to eldoc.
(use-package eglot
  :ensure nil
  :config
  (add-to-list 'eglot-server-programs
               `(php-ts-mode . ,(eglot-alternatives
                                 '(("phpactor" "language-server")
                                   ("~/opt/bin/phpactor" "language-server")
                                   ("intelephense" "--stdio"))))))

(provide 'my-phpmode)
;;; phpmode.el ends here
