;; -*- lexical-binding: t; -*-
;;; packages.el --- Package management configuration

;;; Commentary:
;; Centralized package installation and configuration.
;; Uses package-vc-install for git-based packages and MELPA for others.

;;; Code:

(require 'gnutls)
(add-to-list 'gnutls-trustfiles "/usr/lib/ssl/cert.pem")

(require 'package)

;;; Package archives
(add-to-list 'package-archives '("elpa" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(package-initialize)

(eval-when-compile
  (require 'use-package))

;;; Load paths
(add-to-list 'load-path (expand-file-name "elpa/" user-emacs-directory))
(add-to-list 'load-path "~/src/github/org-mode/lisp")

;;; Install packages from git
(defvar my-elpa-dir (expand-file-name "elpa/" user-emacs-directory)
  "Directory for git-cloned elpa packages.")

(defun my-install-package-from-git (pkg dir url)
  "Install package PKG from git URL, into DIR under my-elpa-dir."
  (unless (file-directory-p (concat my-elpa-dir dir))
    (package-vc-install `(,pkg :url ,url))))

;; Core utilities
(my-install-package-from-git 'auto-package-update "auto-package-update/"
  "https://github.com/rranelli/auto-package-update.el.git")

(my-install-package-from-git 'powerline "powerline/"
  "https://github.com/milkypostman/powerline.git")

(my-install-package-from-git 'centaur-tabs "centaur-tabs/"
  "https://github.com/ema2159/centaur-tabs.git")

;; PHP development
(add-to-list 'load-path (expand-file-name "elpa/php-mode/lisp/" user-emacs-directory))
(my-install-package-from-git 'lsp-mode "lsp-mode/"
  "https://github.com/emacs-lsp/lsp-mode.git")

(my-install-package-from-git 'php-mode "php-mode/"
  "https://github.com/emacs-php/php-mode.git")

;; Debugging
(my-install-package-from-git 'dap-mode "dap-mode/"
  "https://github.com/emacs-lsp/dap-mode.git")

(my-install-package-from-git 'smartparens "smartparens/"
  "https://github.com/Fuco1/smartparens.git")

;; Auto-package-update configuration
(use-package auto-package-update
  :custom
    (auto-package-update-interval 2)
    (auto-package-update-prompt-before-update t)
    (auto-package-update-hide-results 1)
  :config
    (auto-package-update-maybe)
    (auto-package-update-at-time "20:50"))

(provide 'packages)
