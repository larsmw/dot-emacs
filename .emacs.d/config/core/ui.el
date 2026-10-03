;; -*- lexical-binding: t; -*-

;;; Set global fonts
(custom-set-faces
 '(default (
            (t (
                :inherit nil
                         :extend nil
                         :stipple nil
                         :background "#2e3436"
                         :foreground "#eeeeec"
                         :inverse-video nil
                         :box nil
                         :strike-through nil
                         :overline nil
                         :underline nil
                         :slant normal
                         :weight light
                         :height 130
                         :width normal
                         :foundry "JB"
                         :family "JetBrains Mono")))
           )
 )

;;; Minibuffer completion: vertico + orderless + marginalia + consult + embark
(use-package vertico
  :ensure t
  :init (vertico-mode))

(use-package savehist
  :ensure nil
  :init (savehist-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :ensure t
  :init (marginalia-mode))

;; remember to install ripgrep
(use-package consult
  :ensure t
  :bind (("C-s"     . consult-line)
         ("C-x b"   . consult-buffer)
         ("M-y"     . consult-yank-pop)
         ("M-g g"   . consult-goto-line)
         ("M-g i"   . consult-imenu)
         ("M-g f"   . consult-flymake)
         ("M-s r"   . consult-ripgrep)
         ("M-s f"   . consult-find))
  :custom
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref))

(use-package embark
  :ensure t
  :bind (("C-." . embark-act)
         ("C-h B" . embark-bindings)))

(use-package embark-consult
  :ensure t
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(global-set-key (kbd "C-f") 'projectile-find-file)

(load-theme 'tango-dark)

(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)

(use-package which-key
  :ensure nil
  :config (which-key-mode))

(use-package centaur-tabs
  :ensure t
  :config
  (setq centaur-tabs-set-icons t
        centaur-tabs-set-bar 'over
        centaur-tabs-set-modified-marker t
        )
  (centaur-tabs-mode t))

(show-paren-mode 1)

(use-package smartparens
  :ensure t
  )

;; (add-hook 'php-mode-hook #'smartparens-mode)
;; (add-hook 'phpts-mode-hook #'smartparens-mode)

(global-display-line-numbers-mode 1)
(desktop-save-mode 1)

(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

;; (global-nlinum-mode 1)

;; This highlights the current line.
(global-hl-line-mode t)

(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

(column-number-mode)

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  )

(use-package tree-sitter
  :ensure t
  )
(use-package treesit-fold
  :ensure t
  )

;; configure folding
(require 'treesit-fold)
 (global-set-key (kbd "C-x +") 'treesit-fold-open)
 (global-set-key (kbd "C-x -") 'treesit-fold-close)

(setq completion-cycle-threshold 4)

;; Corfu - Completion in region.
;; https://github.com/minad/corfu
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-quit-no-match 'separator)
  :init
  (global-corfu-mode))

;; Extra completion sources for corfu (file names, words from open buffers)
(use-package cape
  :ensure t
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))

(orderless-define-completion-style orderless-literal-only
  (orderless-style-dispatchers nil)
  (orderless-matching-styles '(orderless-literal)))

(add-hook 'corfu-mode-hook
          (lambda ()
            (setq-local completion-styles '(orderless-literal-only basic)
                        completion-category-overrides nil
                        completion-category-defaults nil)))

(provide 'ui)
;;; ui.el ends here
