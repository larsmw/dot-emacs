;; -*- lexical-binding: t;-*-


;; Magit configuration
(use-package magit
  :ensure t
  :defer nil
  :bind (("C-x g" . magit-status)))

(global-set-key (kbd "C-c g") 'magit-diff-buffer-file)


(use-package diff-hl
  :ensure t
  :after magit
  :config
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1)
  (diff-hl-dired-mode 1)
  (diff-hl-margin-mode 1)
  (diff-hl-amend-mode 1))

(provide 'vc)
