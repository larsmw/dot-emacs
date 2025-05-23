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
                         :height 100
                         :width normal
                         :foundry "JB"
                         :family "JetBrains Mono")))
           )
 )




;;; Buffer configuration
(tool-bar-mode -1)

(use-package which-key
  :ensure t
  :config (which-key-mode))


(show-paren-mode 1)

(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

(column-number-mode)

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

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
