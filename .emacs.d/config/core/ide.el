;; -*- lexical-binding: t; -*-

;;; Commentary:
;;; Language-agnostic IDE features: LSP keys, debugger, project tree,
;;; snippets, multiple cursors.  Keys follow PhpStorm where Emacs has
;;; nothing important on them.
;;;
;;;   M-RET      code actions / quick fix      (Alt+Enter)
;;;   S-<f6>     rename symbol                 (Shift+F6)
;;;   M-<f7>     find usages                   (Alt+F7)
;;;   C-M-l      reformat buffer               (Ctrl+Alt+L)
;;;   C-<f12>    file structure                (Ctrl+F12)
;;;   M-1        project tree                  (Alt+1)
;;;   C->/C-<    add cursor at next/prev match (Alt+J)
;;;   C-<f8>     toggle breakpoint             (Ctrl+F8)
;;;   <f7>/<f8>  step into / step over         (F7 / F8)
;;;   S-<f8>     step out                      (Shift+F8)
;;;   <f9>       resume                        (F9)
;;;   C-<f2>     stop debugging                (Ctrl+F2)
;;;   C-c l ...  everything LSP, under one prefix (see which-key)

;;; Code:

(use-package eglot
  :ensure nil
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-config '(:size 0 :format full)) ; logging slows big projects
  (eglot-extend-to-xref t)       ; stay connected when jumping into vendor/
  :bind (:map eglot-mode-map
              ("M-RET"   . eglot-code-actions)
              ("S-<f6>"  . eglot-rename)
              ("C-c l a" . eglot-code-actions)
              ("C-c l r" . eglot-rename)
              ("C-c l f" . eglot-format-buffer)
              ("C-c l i" . eglot-find-implementation)
              ("C-c l t" . eglot-find-typeDefinition)
              ("C-c l d" . consult-flymake)
              ("C-c l s" . consult-eglot-symbols)
              ("C-c l R" . eglot-reconnect)))

(defun my/format-buffer ()
  "Reformat the buffer via the language server, else re-indent it."
  (interactive)
  (if (bound-and-true-p eglot--managed-mode)
      (eglot-format-buffer)
    (indent-region (point-min) (point-max))))

(global-set-key (kbd "C-M-l")   #'my/format-buffer)
(global-set-key (kbd "M-<f7>")  #'xref-find-references)
(global-set-key (kbd "C-<f12>") #'consult-imenu)
(global-set-key (kbd "C-S-f")   #'consult-ripgrep) ; Find in Path (GUI only)

;; Search symbols across the whole project (Navigate > Symbol)
(use-package consult-eglot
  :ensure t
  :after (consult eglot))

;; "Namespace > Class > method" in the header line
(use-package breadcrumb
  :ensure t
  :hook (prog-mode . breadcrumb-local-mode))

;; Respect the project's .editorconfig, as PhpStorm does
(editorconfig-mode 1)

;;; Snippets / live templates.  eglot also uses yasnippet to expand
;;; completion snippets (method arguments, /** doc blocks).
(use-package yasnippet
  :ensure t
  :config (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)

(use-package multiple-cursors
  :ensure t
  :bind (("C->"           . mc/mark-next-like-this)
         ("C-<"           . mc/mark-previous-like-this)
         ("C-c C-<"       . mc/mark-all-like-this)
         ("M-S-<mouse-1>" . mc/add-cursor-on-click)))

;;; Project tree
(use-package treemacs
  :ensure t
  :custom
  (treemacs-width 40)
  :config
  (treemacs-follow-mode 1)
  (treemacs-project-follow-mode 1)
  (treemacs-git-mode 'simple)
  :bind ("M-1" . my/treemacs-toggle))

(defun my/treemacs-toggle ()
  "Show the current project in treemacs, or hide treemacs if visible."
  (interactive)
  (require 'treemacs)
  (if (eq (treemacs-current-visibility) 'visible)
      (delete-window (treemacs-get-local-window))
    (treemacs-add-and-display-current-project-exclusively)))

;;; Debugger (DAP).  Adapters live in ~/.emacs.d/debug-adapters.
(use-package dape
  :ensure t
  :demand t
  :custom
  (dape-buffer-window-arrangement 'right)
  (dape-inlay-hints t)
  :config
  (dape-breakpoint-global-mode 1) ; click the fringe to set breakpoints
  :bind (("C-<f8>" . dape-breakpoint-toggle)
         ("<f7>"   . dape-step-in)
         ("<f8>"   . dape-next)
         ("S-<f8>" . dape-step-out)
         ("<f9>"   . dape-continue)
         ("C-<f2>" . dape-quit)))

(provide 'my-ide)
;;; ide.el ends here
