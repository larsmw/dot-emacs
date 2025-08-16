;; -*- lexical-binding: t;-*-

;; Magit configuration
(use-package magit
  :ensure t
  :commands (magit-status magit-get-current-branch)
  :defer nil
  :bind (("C-x g" . magit-status))  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))


(global-set-key (kbd "C-c g") 'magit-diff-buffer-file)


(use-package diff-hl
  :ensure t
  :after magit
  :config
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  (add-hook 'diff-hl-mode-hook 'diff-hl-show-hunk-mouse-mode)
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1)
  (diff-hl-dired-mode 1)
  (diff-hl-margin-mode 1)
  (diff-hl-amend-mode 1)
  :custom
  (diff-hl-update-async t)
  :init
  (global-diff-hl-mode 1)
  :hook (diff-hl-mode . (lambda ()
                          (unless (display-graphic-p)
                            (diff-hl-margin-local-mode)))))


(provide 'vc)
