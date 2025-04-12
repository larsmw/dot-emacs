;; -*- lexical-binding: t; -*-

(use-package magit
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))


(use-package rjsx-mode
  :ensure t
  :mode "\\.js\\'")

(use-package web-mode
  :ensure t
  :mode "\\.twig\\'")

(use-package sass-mode
  :ensure t)
