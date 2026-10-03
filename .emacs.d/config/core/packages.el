;; -*- lexical-binding: t; -*-

(require 'gnutls)
(add-to-list 'gnutls-trustfiles "/usr/lib/ssl/cert.pem")

(require 'package)

;;; Start package configuration
(add-to-list 'package-archives '("elpa"  . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa"  . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable"  . "https://stable.melpa.org/packages/") t)
;; (package-refresh-contents)
(package-initialize)

(eval-when-compile
  (require 'use-package))

(add-to-list 'load-path "~/src/github/org-mode/lisp")

(use-package auto-package-update
  :ensure t
  :custom
    (auto-package-update-interval 2)
    (auto-package-update-prompt-before-update t)
    (auto-package-update-hide-results 1)
  :config
    (auto-package-update-maybe)
    (auto-package-update-at-time "20:50"))

