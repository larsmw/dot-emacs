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

;;; Language servers
;;;
;;; phpactor (needs host PHP) is the default: free rename, find
;;; implementations, code actions (import class, implement interface,
;;; generate constructor/accessors, extract method/constant, ...) and
;;; inline PHPStan / php-cs-fixer / phpcs problems.
;;;
;;; intelephense runs on Node and needs no PHP.  Its type inference is
;;; often a bit sharper, but the refactorings above need a licence key
;;; in `my/intelephense-licence-file'.  Install with
;;;   npm install -g --prefix ~/.local intelephense
;;;
;;; Switch with M-x my/php-use-language-server (or C-u M-x eglot).

(defvar my/php-language-server 'phpactor
  "Preferred PHP language server: `phpactor' or `intelephense'.
Falls back to the other one when the preferred one is not installed.")
(put 'my/php-language-server 'safe-local-variable
     (lambda (v) (memq v '(phpactor intelephense))))

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

(defun my/phpactor-init-options (root)
  "phpactor settings for the project in ROOT, based on the tools it has.
Settings sent here override the project's .phpactor.json, so only
switch things on that the project is set up for."
  (let* ((has (lambda (&rest files)
                (seq-some (lambda (f) (file-exists-p (expand-file-name f root))) files)))
         (default-directory root)
         (version (my/php-project-version))
         (globs (vconcat (mapcar (lambda (ext) (concat "/**/*." ext))
                                 my/php-file-extensions))))
    `(;; We detect tools below; stop phpactor prompting to write .phpactor.json
      :language_server_configuration.auto_config :json-false
      :indexer.supported_extensions ,(vconcat my/php-file-extensions)
      :indexer.include_patterns ,globs
      :language_server.file_event_globs ,(vconcat (mapcar (lambda (g) (substring g 1)) globs))
      ,@(when version
          (list :php.version version))
      ,@(when (and (funcall has "vendor/bin/phpstan")
                   (funcall has "phpstan.neon" "phpstan.neon.dist" "phpstan.dist.neon"))
          '(:language_server_phpstan.enabled t
            :language_server_phpstan.mem_limit "1G"))
      ,@(when (and (funcall has "vendor/bin/php-cs-fixer")
                   (funcall has ".php-cs-fixer.php" ".php-cs-fixer.dist.php"))
          ;; host PHP may be newer than the fixer officially supports
          '(:language_server_php_cs_fixer.enabled t
            :language_server_php_cs_fixer.env (:XDEBUG_MODE "off"
                                               :PHP_CS_FIXER_IGNORE_ENV "1")))
      ,@(when (and (funcall has "vendor/bin/phpcs")
                   (funcall has "phpcs.xml" "phpcs.xml.dist" ".phpcs.xml" ".phpcs.xml.dist"))
          '(:php_code_sniffer.enabled t))
      ,@(when (funcall has "symfony.lock")
          '(:symfony.enabled t))
      ,@(when (funcall has "vendor/phpunit/phpunit")
          '(:phpunit.enabled t))
      ,@(when (funcall has "vendor/phpspec/prophecy")
          '(:prophecy.enabled t)))))

(defun my/php--servers (root)
  "Alist of installed PHP language servers and their eglot contacts."
  (append
   (when (and (executable-find "phpactor") (executable-find "php"))
     `((phpactor . ("phpactor" "language-server"
                    :initializationOptions ,(my/phpactor-init-options root)))))
   (when (executable-find "intelephense")
     `((intelephense . ("intelephense" "--stdio"
                        :initializationOptions ,(my/intelephense-init-options)))))))

(defun my/php-eglot-contact (&optional interactive project)
  "Eglot contact for PHP: `my/php-language-server', else whatever is installed.
With INTERACTIVE (C-u M-x eglot), ask which server to use."
  (let* ((root (if project (project-root project) default-directory))
         (servers (or (my/php--servers root)
                      (user-error "No PHP language server: install phpactor or intelephense"))))
    (cdr (or (and interactive (cdr servers)
                  (assq (intern (completing-read "PHP language server: "
                                                 (mapcar #'car servers) nil t))
                        servers))
             (assq my/php-language-server servers)
             (car servers)))))

(defun my/php-use-language-server (server)
  "Restart the current project's PHP language server as SERVER."
  (interactive (list (intern (completing-read "PHP language server: "
                                              '("phpactor" "intelephense") nil t))))
  (unless (derived-mode-p 'php-ts-mode)
    (user-error "Run this from a PHP buffer"))
  (setq my/php-language-server server)
  (when-let* ((current (eglot-current-server)))
    (eglot-shutdown current))
  ;; eglot attaches the project's other PHP buffers to the new server
  (apply #'eglot (eglot--guess-contact)))

(defun my/php-project-version ()
  "Return the PHP version DDEV runs for the current project, or nil."
  (when-let* ((root (locate-dominating-file default-directory ".ddev/config.yaml")))
    (with-temp-buffer
      (insert-file-contents (expand-file-name ".ddev/config.yaml" root))
      (when (re-search-forward "^php_version: *\"?\\([0-9.]+\\)" nil t)
        (match-string 1)))))

(defun my/intelephense-workspace-config (server)
  "Intelephense settings; matches the project's PHP version when known."
  (when-let* ((proc (and server (jsonrpc--process server)))
              ((equal (file-name-nondirectory (car (process-command proc)))
                      "intelephense")))
    (let ((version (my/php-project-version)))
      `(:intelephense
        (:files (:maxSize 5000000
                 :associations ,(vconcat (mapcar (lambda (ext) (concat "*." ext))
                                                 my/php-file-extensions)))
         ,@(when version
             `(:environment (:phpVersion ,(concat version ".0")))))))))

(use-package eglot
  :ensure nil
  :config
  (add-to-list 'eglot-server-programs '(php-ts-mode . my/php-eglot-contact))
  (setq-default eglot-workspace-configuration #'my/intelephense-workspace-config))

(provide 'my-phpmode)
;;; phpmode.el ends here
