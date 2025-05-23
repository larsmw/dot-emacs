;; -*- lexical-binding: t; -*-


(use-package rjsx-mode
  :ensure t
  :mode "\\.js\\'")

;;(use-package web-mode
;;  :ensure t
;;  :mode "\\.twig\\'")

(use-package sass-mode
  :ensure t)


(use-package web-mode
  :ensure t
  :mode (("\\.html?\\'" . web-mode)
         ("\\.twig\\'" . web-mode)
         ("\\.jsx\\'" . web-mode))
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2
        web-mode-block-padding 2
        web-mode-comment-style 2
        web-mode-enable-css-colorization t
        web-mode-enable-auto-pairing t
        web-mode-enable-comment-keywords t
        web-mode-enable-current-element-highlight t)
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "tsx" (file-name-extension buffer-file-name))
              (tide-setup)
              (tide-hl-identifier-mode)
              (flycheck-mode)
              (eldoc-mode)
              (ivy-mode))))
)
