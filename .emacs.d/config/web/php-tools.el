;; -*- lexical-binding: t; -*-

;;; Commentary:
;;; PHP tooling that runs where the project's PHP lives: DDEV, a docker
;;; compose service, or the host.  Tests, PHPStan, coding-standard
;;; fixers, Composer and Xdebug all go through `my/php--command'.
;;;
;;; DDEV projects (a .ddev/ directory) need no setup.  For docker
;;; compose, put this in the project's .dir-locals.el:
;;;
;;;   ((nil . ((my/php-exec . ("docker" "compose" "exec" "-T" "php"))
;;;            (my/php-container-root . "/app"))))
;;;
;;; Keys in PHP buffers (C-c m opens a menu with all of them):
;;;   C-S-<f10>  run test at point   (Ctrl+Shift+F10)
;;;   S-<f10>    rerun last test run (Shift+F10)
;;;   C-M-l      reformat with the project's fixer (Ctrl+Alt+L)

;;; Code:

(require 'compile)
(require 'transient)

(defvar my/php-exec nil
  "Command prefix that runs PHP tools for the project.
nil means autodetect: \"ddev exec\" in DDEV projects, else the host.")
(put 'my/php-exec 'safe-local-variable
     (lambda (v) (and (listp v) (seq-every-p #'stringp v))))

(defvar my/php-container-root nil
  "Project root inside the container; nil means autodetect.")
(put 'my/php-container-root 'safe-local-variable #'string-or-null-p)

(defvar my/php-test-command nil
  "Test runner, relative to the project root.  nil means Pest or PHPUnit.")
(put 'my/php-test-command 'safe-local-variable #'string-or-null-p)

(defun my/php--root ()
  "Root directory of the current PHP project."
  (or (locate-dominating-file default-directory "composer.json")
      (when-let* ((pr (project-current))) (project-root pr))
      (user-error "Not in a PHP project")))

(defun my/php--ddev-p ()
  (file-directory-p (expand-file-name ".ddev" (my/php--root))))

(defun my/php--exec ()
  (or my/php-exec (and (my/php--ddev-p) '("ddev" "exec"))))

(defun my/php--container-root ()
  (or my/php-container-root (and (my/php--ddev-p) "/var/www/html")))

(defun my/php--quote (arg)
  "Quote ARG for sh, leaving plain words readable."
  (if (string-match-p "\\`[-[:alnum:]_./=:@%+,]+\\'" arg)
      arg
    (concat "'" (string-replace "'" "'\\''" arg) "'")))

(defun my/php--command (&rest args)
  "Shell command running ARGS from the project root, inside the container."
  (let ((inner (mapconcat #'my/php--quote args " "))
        (exec (my/php--exec)))
    (cond ((null exec) inner)
          ;; ddev exec joins its arguments into one `bash -c' string, so
          ;; pass the command as a single, already-quoted argument.
          ((equal exec '("ddev" "exec"))
           (concat "ddev exec " (my/php--quote inner)))
          (t (concat (mapconcat #'my/php--quote exec " ") " " inner)))))

(defun my/php--relative (file)
  (file-relative-name file (my/php--root)))

(defun my/php--tool (&rest candidates)
  "First of CANDIDATES (project-relative paths) that exists, or nil."
  (seq-find (lambda (f) (file-exists-p (expand-file-name f (my/php--root))))
            candidates))

;;; Output buffer: clickable file:line, also for container paths

(add-to-list 'compilation-error-regexp-alist-alist
             ;; PHPUnit/PHPStan "file.php:12", Pest "at file.php:12"
             '(php-file-line
               "^\\(?:.* at \\)?[ \t]*\\([^: \t\n]+\\.php\\):\\([0-9]+\\)\\(?::\\|$\\)"
               1 2))
(add-to-list 'compilation-error-regexp-alist-alist
             ;; PHP errors: "in /path/file.php on line 12"
             '(php-on-line
               " in \\([^ \t\n]+\\.php\\)\\(?: on line \\|:\\)\\([0-9]+\\)" 1 2))

(define-compilation-mode my/php-compilation-mode "PHP"
  "Compilation mode for PHP tools; maps container paths to the host."
  (hack-dir-local-variables-non-file-buffer)
  (setq-local compilation-error-regexp-alist '(php-file-line php-on-line))
  (when-let* ((croot (my/php--container-root)))
    (setq-local compilation-transform-file-match-alist
                (cons (list (concat "\\`" (regexp-quote (file-name-as-directory croot)))
                            "")
                      compilation-transform-file-match-alist))))

(defvar my/php--last-run nil "(ROOT . COMMAND) of the last test run.")

(defun my/php--run (command &optional name)
  "Run COMMAND from the project root in a PHP compilation buffer."
  (let ((default-directory (my/php--root)))
    (compilation-start command #'my/php-compilation-mode
                       (lambda (_) (format "*php %s*" (or name "run"))))))

;;; Tests

(defun my/php--test-runner ()
  (or my/php-test-command
      (my/php--tool "vendor/bin/pest" "vendor/bin/phpunit")
      (user-error "No vendor/bin/pest or vendor/bin/phpunit; run composer install")))

(defun my/php--test-filter-at-point ()
  "PHPUnit/Pest --filter for the test around point, or nil."
  (let ((node (treesit-node-at (point))))
    (when-let* ((test (treesit-parent-until
                       node
                       (lambda (n)
                         (or (equal (treesit-node-type n) "method_declaration")
                             (and (equal (treesit-node-type n) "function_call_expression")
                                  (member (treesit-node-text
                                           (treesit-node-child-by-field-name n "function") t)
                                          '("it" "test")))))
                       t)))
      (if (equal (treesit-node-type test) "method_declaration")
          (format "::%s( with data set .*)?$"
                  (treesit-node-text (treesit-node-child-by-field-name test "name") t))
        ;; Pest: it('does things', fn () => ...)
        (when-let* ((args (treesit-node-child-by-field-name test "arguments"))
                    (desc (treesit-search-subtree args "\\`string_content\\'")))
          (regexp-quote (treesit-node-text desc t)))))))

(defun my/php--test (name &rest args)
  (let ((command (apply #'my/php--command (my/php--test-runner) args)))
    (setq my/php--last-run (cons (my/php--root) command))
    (my/php--run command name)))

(defun my/php-test-at-point ()
  "Run the test method (or Pest test) at point; the whole file if none."
  (interactive)
  (save-buffer)
  (let ((file (my/php--relative buffer-file-name))
        (filter (my/php--test-filter-at-point)))
    (if filter
        (my/php--test "test" "--filter" filter file)
      (my/php--test "test" file))))

(defun my/php-test-file ()
  "Run all tests in the current file."
  (interactive)
  (save-buffer)
  (my/php--test "test" (my/php--relative buffer-file-name)))

(defun my/php-test-all ()
  "Run the whole test suite."
  (interactive)
  (my/php--test "test"))

(defun my/php-test-rerun ()
  "Run the last test command again."
  (interactive)
  (unless my/php--last-run (user-error "No tests run yet"))
  (let ((default-directory (car my/php--last-run)))
    (my/php--run (cdr my/php--last-run) "test")))

;;; Static analysis and coding standards

(defun my/php-phpstan (&optional file)
  "Run PHPStan on the project, or on FILE (interactively: with prefix arg)."
  (interactive (list (and current-prefix-arg buffer-file-name)))
  (let ((phpstan (or (my/php--tool "vendor/bin/phpstan")
                     (user-error "PHPStan is not installed in this project"))))
    (my/php--run (apply #'my/php--command phpstan "analyse" "--no-progress"
                        "--error-format=raw" "--memory-limit=1G"
                        (and file (list (my/php--relative file))))
                 "phpstan")))

(defun my/php--fixer ()
  "Command list that fixes a file per the project's coding standard, or nil."
  (cond
   ((and (my/php--tool ".php-cs-fixer.php" ".php-cs-fixer.dist.php")
         (my/php--tool "vendor/bin/php-cs-fixer"))
    '("vendor/bin/php-cs-fixer" "fix" "--quiet"))
   ((and (my/php--tool "phpcs.xml" "phpcs.xml.dist" ".phpcs.xml" ".phpcs.xml.dist")
         (my/php--tool "vendor/bin/phpcbf"))
    '("vendor/bin/phpcbf" "-q"))))

(defun my/php-format ()
  "Reformat the buffer with the project's fixer, else the language server.
The fixer runs on the host when PHP is installed there (no container
start-up), otherwise in the project's container."
  (interactive)
  (if-let* ((fixer (my/php--fixer)))
      (let* ((default-directory (my/php--root))
             (host (executable-find "php"))
             (my/php-exec (if host '("env" "PHP_CS_FIXER_IGNORE_ENV=1") my/php-exec))
             (command (apply #'my/php--command
                             (append fixer (list (my/php--relative buffer-file-name))))))
        (save-buffer)
        (with-temp-buffer
          (let ((status (process-file-shell-command command nil t)))
            ;; phpcbf exits 1 when it fixed something
            (unless (memq status '(0 1))
              (error "%s failed: %s" (car fixer) (string-trim (buffer-string))))))
        (revert-buffer t t t)
        (message "Formatted with %s" (file-name-nondirectory (car fixer))))
    (my/format-buffer)))

;;; Refactoring with phpactor's CLI (needs host PHP).  Rename, extract,
;;; import etc. are code actions in the language server (M-RET).

(defun my/php--class-transfer (action)
  "Run phpactor class:ACTION from this buffer's file to a prompted path."
  (unless (executable-find "phpactor")
    (user-error "phpactor is not installed"))
  (let* ((root (my/php--root))
         (src buffer-file-name)
         (dest (expand-file-name
                (read-file-name (format "%s class to: " (capitalize action))
                                (file-name-directory src) nil nil
                                (file-name-nondirectory src)))))
    (when (equal dest src) (user-error "Same file"))
    (save-some-buffers nil (lambda () (and buffer-file-name
                                         (file-in-directory-p buffer-file-name root))))
    (with-temp-buffer
      (let ((default-directory root))
        (unless (zerop (process-file
                        "phpactor" nil t nil (concat "class:" action) "--no-interaction"
                        (if (file-directory-p (expand-file-name ".git" root))
                            "--filesystem=git" "--filesystem=simple")
                        (file-relative-name src root) (file-relative-name dest root)))
          (error "phpactor class:%s failed: %s" action (string-trim (buffer-string))))))
    ;; Pick up the reference updates phpactor wrote to other files
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when (and buffer-file-name (file-in-directory-p buffer-file-name root)
                   (not (buffer-modified-p)))
          (if (file-exists-p buffer-file-name)
              (unless (verify-visited-file-modtime buf) (revert-buffer t t t))
            (kill-buffer buf)))))
    (find-file dest)))

(defun my/php-move-class ()
  "Move this class to another file/namespace and update all references."
  (interactive)
  (my/php--class-transfer "move"))

(defun my/php-copy-class ()
  "Copy this class to another file/namespace."
  (interactive)
  (my/php--class-transfer "copy"))

;;; Composer

(defvar my/php-composer-history nil)

(defun my/php-composer (args)
  "Run composer with ARGS in the project's PHP environment."
  (interactive (list (read-string "composer " nil 'my/php-composer-history)))
  (my/php--run (concat (my/php--command "composer") " " args) "composer"))

;;; Debugging with Xdebug (dape listens on port 9003)

(defun my/php--dape-path-mappings ()
  (if-let* ((croot (my/php--container-root)))
      (list (intern (concat ":" croot))
            (directory-file-name (expand-file-name (my/php--root))))
    (make-hash-table)))                 ; {} rather than null

(with-eval-after-load 'dape
  (add-to-list 'dape-configs
               `(xdebug-project
                 ,@(alist-get 'xdebug dape-configs)
                 :pathMappings my/php--dape-path-mappings)))

(defun my/php-debug-listen ()
  "Start listening for Xdebug connections, like PhpStorm's phone icon."
  (interactive)
  (when (and (my/php--ddev-p) (executable-find "ddev"))
    (let ((default-directory (my/php--root)))
      (call-process "ddev" nil nil nil "xdebug" "on")))
  (dape (dape--config-eval 'xdebug-project nil)))

;;; Menu

(transient-define-prefix my/php-menu ()
  "PHP project commands."
  [["Test"
    ("t" "test at point" my/php-test-at-point)
    ("f" "test file" my/php-test-file)
    ("a" "all tests" my/php-test-all)
    ("l" "rerun last" my/php-test-rerun)]
   ["Quality"
    ("s" "PHPStan project" my/php-phpstan)
    ("S" "PHPStan this file" (lambda () (interactive) (my/php-phpstan buffer-file-name)))
    ("x" "fix code style" my/php-format)]
   ["Refactor"
    ("m" "move class" my/php-move-class)
    ("y" "copy class" my/php-copy-class)
    ("L" "switch language server" my/php-use-language-server)]
   ["Project"
    ("c" "composer..." my/php-composer)
    ("d" "debug (listen for Xdebug)" my/php-debug-listen)
    ("q" "stop debugging" dape-quit)]])

(with-eval-after-load 'php-ts-mode
  (keymap-set php-ts-mode-map "C-c m"     #'my/php-menu)
  (keymap-set php-ts-mode-map "C-S-<f10>" #'my/php-test-at-point)
  (keymap-set php-ts-mode-map "S-<f10>"   #'my/php-test-rerun)
  (keymap-set php-ts-mode-map "C-M-l"     #'my/php-format))

(provide 'my-php-tools)
;;; php-tools.el ends here
