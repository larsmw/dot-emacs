(require 'package)

;;; Start package configuration
(add-to-list 'package-archives
             '(("org"   . "https://orgmode.org/elpa/")
               ("elpa"  . "https://elpa.org/packages/")
               ("gnu-devel" . "https://elpa.gnu.org/devel")
	     ))

(package-initialize)

(eval-when-compile
  (require 'use-package))

(add-to-list 'load-path "~/.emacs.d/elpa/")
(add-to-list 'load-path "~/.emacs.d/dap-mode/")
;; (add-to-list 'load-path "~/.emacs.d/counsel-projectile")
(add-to-list 'load-path "~/.emacs.d/php-mode/")

