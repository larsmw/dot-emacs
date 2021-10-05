;;; package --- Summary

;;; Commentary:
;;; .emacs - Configuration


;;; Code:
(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(eval-when-compile
  (require 'use-package))


(add-to-list 'load-path "~/.emacs.d/elpa/")
(add-to-list 'load-path "~/.emacs.d/elpa/geben/")
(add-to-list 'load-path "~/.emacs.d/php-mode/")

(show-paren-mode 1)

(projectile-mode 1)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(setq projectile-completion-system 'ivy)

(require 'php-mode)
(define-key php-mode-map (kbd "C-c g") 'counsel-etags-find-tag-at-point)

(global-flycheck-mode)
(require 'ivy)
(ivy-mode 1)
(load-theme 'tango-dark)

(global-linum-mode 1)


(add-hook 'php-mode-hook
	  '(lambda ()
             (auto-complete-mode t)
             (require 'ac-php)
             (setq ac-sources '(ac-source-php))
             (yas-global-mode 1)

             (define-key php-mode-map (kbd "C-]")
               'ac-php-find-symbol-at-point)
             (define-key php-mode-map (kbd "C-t")
               'ac-php-location-stack-back)))

(use-package rjsx-mode
  :ensure t
  :mode "\\.js\\'")


(defun kill-dired-buffers ()
     (interactive)
     (mapc (lambda (buffer)
           (when (eq 'dired-mode (buffer-local-value 'major-mode buffer))
             (kill-buffer buffer)))
           (buffer-list)))

(use-package rjsx-mode
	     :ensure t
	     :mode "\\.js\\'")


;;; .emacs ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(use-package yaml-mode yaml web-mode twig-mode sql-indent projectile-codesearch picpocket phpstan mmm-mode json-mode ivy-phpunit geben flyspell-correct-ivy flymake-phpcs flymake-php flymake flycheck-projectile drupal-spell drupal-mode counsel-projectile counsel-etags composer ac-php)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
