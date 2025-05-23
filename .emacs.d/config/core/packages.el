;; -*- lexical-binding: t; -*-


(require 'package)

;;; Start package configuration
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("elpa"  . "https://elpa.org/packages/") t)
(add-to-list 'package-archives '("melpa"  . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu-devel" . "https://elpa.gnu.org/devel") t)

(package-initialize)

(eval-when-compile
  (require 'use-package))

(add-to-list 'load-path "~/.emacs.d/elpa/")
(add-to-list 'load-path "~/.emacs.d/dap-mode/")
(add-to-list 'load-path "~/.emacs.d/php-mode/")


;;; Fetch updates for packages
(use-package auto-package-update
  :custom
    (auto-package-update-interval 2)
    (auto-package-update-prompt-before-update t)
    (auto-package-update-hide-results 1)
  :config
    (auto-package-update-maybe)
    (auto-package-update-at-time "20:50"))

