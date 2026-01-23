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
                         :height 160
                         :width normal
                         :foundry "JB"
                         :family "JetBrains Mono")))
           )
 )

;;; Buffer configuration

;;; Fetch from https://github.com/auto-complete/auto-complete.git
(unless (file-directory-p "~/.emacs.d/elpa/auto-complete/") 
  (package-vc-install
    '(auto-complete :url "https://github.com/auto-complete/auto-complete.git"
  		    :listp-dir "lisp"))
  )
(use-package auto-complete
  :ensure t
  :init
    (ac-config-default)
    (global-auto-complete-mode t)
    )

;; https://github.com/auto-complete/auto-complete/issues/533
(add-hook 'auto-complete-mode-hook
          (lambda ()
            (setq ac-sources (remove 'ac-source-abbrev ac-sources))))

(use-package ivy
  :ensure t
  :init
  (setq ivy-re-builders-alist
    '((swiper . ivy--regex-plus)
      (counsel-ag . ivy--regex-plus)
      (counsel-grep-or-swiper . ivy--regex-plus)
      (t . ivy--regex-fuzzy)))
  :config
  (ivy-mode 1)
  :custom
  (ivy-use-virtual-buffers t)
  (ivy-display-style 'fancy)
  :hook
  (ivy-occur-mode . hl-line-mode)
  )

(use-package counsel
  :ensure t)

(use-package counsel-etags
  :ensure t)

;; remember to install ripgrep
(setq counsel-grep-base-command
      "rg -i -M 120 --no-heading --line-number --color never '%s' %s")

(global-set-key (kbd "C-s") 'counsel-grep-or-swiper)

(require 'ivy)
(ivy-mode 1)
(load-theme 'tango-dark)

(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)

(use-package which-key
  :ensure t
  :config (which-key-mode))

(use-package centaur-tabs
  :ensure t
  :config
  (setq centaur-tabs-set-icons t
        centaur-tabs-set-bar 'over
        centaur-tabs-set-modified-marker t
        )
  (centaur-tabs-mode t))

;; very nice buffer shifting :)
(global-set-key (kbd "C-x b") 'counsel-switch-buffer)

(show-paren-mode 1)

;; (require 'smartparens-mode)

;; (add-hook 'php-mode-hook #'smartparens-mode)
;; (add-hook 'phpts-mode-hook #'smartparens-mode)

(global-display-line-numbers-mode 1)

(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

;; (global-nlinum-mode 1)

;; This highlights the current line.
(global-hl-line-mode t)

(use-package swiper
  :ensure t
  :config
  (ivy-mode)
  (setq ivy-mode-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
)

(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

(column-number-mode)

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))


(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  )


;; (when (maybe-require-package 'orderless)
;;   (with-eval-after-load 'vertico
;;     (require 'orderless)
;;     (setq completion-styles '(orderless basic))))
(setq completion-category-defaults nil
      completion-category-overrides nil)
(setq completion-cycle-threshold 4)

;; Corfu - Completion in region.
;; https://github.com/minad/corfu
(use-package corfu
  :ensure t)

(setq corfu-auto t
      corfu-quit-no-match 'separator) 

(orderless-define-completion-style orderless-literal-only
  (orderless-style-dispatchers nil)
  (orderless-matching-styles '(orderless-literal)))

(add-hook 'corfu-mode-hook
          (lambda ()
            (setq-local completion-styles '(orderless-literal-only basic)
                        completion-category-overrides nil
                        completion-category-defaults nil)))

