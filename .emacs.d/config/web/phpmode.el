;; -*- lexical-binding: t; -*-

(require 'treesit)
(add-to-list 'treesit-language-source-alist
             '(php "https://github.com/tree-sitter/tree-sitter-php" "master" "php/src"))

;; Drupal keeps PHP in a handful of non-.php extensions
(defconst my/php-file-extensions
  '("php" "phtml" "inc" "module" "install" "theme" "profile" "engine"))

;; php-ts-mode is built into Emacs 30+
(use-package php-ts-mode
  :ensure nil
  :init
  (add-to-list 'auto-mode-alist
               (cons (concat "\\." (regexp-opt my/php-file-extensions) "\\'")
                     'php-ts-mode))
  :hook (php-ts-mode . eglot-ensure))

;;; Language server.  Intelephense runs on Node, so it works without a
;;; host PHP (PHP lives in DDEV/docker here).  Install / update with:
;;;   npm install -g --prefix ~/.local intelephense
;;; Premium features (rename, implementations, code actions) unlock when
;;; a licence key is put in `my/intelephense-licence-file'.

(defvar my/intelephense-licence-file "~/.config/intelephense/licence.txt")

(defun my/intelephense-init-options ()
  "Return initializationOptions for intelephense."
  (let ((licence (expand-file-name my/intelephense-licence-file)))
    `(:storagePath ,(expand-file-name "~/.cache/intelephense")
      :globalStoragePath ,(expand-file-name "~/.local/share/intelephense")
      ,@(when (file-readable-p licence)
          (list :licenceKey (string-trim
                             (with-temp-buffer
                               (insert-file-contents licence)
                               (buffer-string))))))))

(defun my/php-eglot-contact (&optional _interactive _project)
  "Pick a PHP language server: intelephense, else phpactor (needs host PHP)."
  (let ((phpactor (or (executable-find "phpactor")
                      (let ((f (expand-file-name "phpactor/vendor/bin/phpactor"
                                                 user-emacs-directory)))
                        (and (file-executable-p f) f)))))
    (cond
     ((executable-find "intelephense")
      `("intelephense" "--stdio" :initializationOptions ,(my/intelephense-init-options)))
     ((and phpactor (executable-find "php"))
      (list phpactor "language-server"))
     (t (user-error "No PHP language server: npm install -g --prefix ~/.local intelephense")))))

(defun my/php-project-version ()
  "Return the PHP version DDEV runs for the current project, or nil."
  (when-let* ((root (locate-dominating-file default-directory ".ddev/config.yaml")))
    (with-temp-buffer
      (insert-file-contents (expand-file-name ".ddev/config.yaml" root))
      (when (re-search-forward "^php_version: *\"?\\([0-9.]+\\)" nil t)
        (match-string 1)))))

(defun my/intelephense-workspace-config (_server)
  "Intelephense settings; matches the project's PHP version when known."
  (let ((version (my/php-project-version)))
    `(:intelephense
      (:files (:maxSize 5000000
               :associations ,(vconcat (mapcar (lambda (ext) (concat "*." ext))
                                               my/php-file-extensions)))
       ,@(when version
           `(:environment (:phpVersion ,(concat version ".0"))))))))

(use-package eglot
  :ensure nil
  :config
  (add-to-list 'eglot-server-programs '(php-ts-mode . my/php-eglot-contact))
  (setq-default eglot-workspace-configuration #'my/intelephense-workspace-config))

(provide 'my-phpmode)
;;; phpmode.el ends here
