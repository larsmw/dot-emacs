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
