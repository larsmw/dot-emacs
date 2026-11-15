;; -*- lexical-binding: t; -*-

;;; Commentary:
;;; Rust: rust-ts-mode + rust-analyzer (via eglot), cargo commands and
;;; debugging with gdb through dape.
;;;
;;; The toolchain is in /opt/rustc/bin (rustc, cargo, clippy, rustfmt,
;;; rust-src).  rust-analyzer is not part of it; put the release binary
;;; in ~/.local/bin/rust-analyzer.
;;;
;;; Keys in Rust buffers (C-c m opens a menu with all of them):
;;;   C-S-<f10>  run test at point      (Ctrl+Shift+F10)
;;;   S-<f10>    rerun last cargo run   (Shift+F10)
;;;   C-M-l      rustfmt (also runs on save)
;;; plus the LSP keys from core/ide.el (M-RET, S-<f6>, C-c l ...).

;;; Code:

(require 'treesit)
(require 'compile)
(require 'transient)

(use-package rust-ts-mode
  :ensure nil
  :init
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))
  :hook ((rust-ts-mode . eglot-ensure)
         (rust-ts-mode . my/rust-format-on-save-mode)))

(use-package eglot
  :ensure nil
  :config
  ;; Passed as initializationOptions so it does not fight with the
  ;; PHP `eglot-workspace-configuration' function.
  (add-to-list 'eglot-server-programs
               '(rust-ts-mode . ("rust-analyzer"
                                 :initializationOptions
                                 (:check (:command "clippy")
                                  :cargo (:allFeatures t)
                                  :procMacro (:enable t))))))

(define-minor-mode my/rust-format-on-save-mode
  "Run rustfmt (through rust-analyzer) before saving."
  :lighter nil
  (if my/rust-format-on-save-mode
      (add-hook 'before-save-hook #'my/rust--format-before-save nil t)
    (remove-hook 'before-save-hook #'my/rust--format-before-save t)))

(defun my/rust--format-before-save ()
  (when (and (bound-and-true-p eglot--managed-mode)
             (eglot-server-capable :documentFormattingProvider))
    (eglot-format-buffer)))

;;; Cargo

(defun my/rust--root ()
  "Directory of the nearest Cargo.toml (the crate, not the workspace)."
  (or (locate-dominating-file default-directory "Cargo.toml")
      (user-error "Not in a Cargo project")))

(defvar my/rust--last-run nil "(ROOT . COMMAND) of the last cargo run.")

(defun my/rust--compile (root command)
  (let ((default-directory root)
        ;; OSC 8 links would show up as junk in the output buffer
        (compilation-environment (cons "CARGO_TERM_HYPERLINKS=false"
                                       compilation-environment)))
    (save-some-buffers (not compilation-ask-about-save)
                       compilation-save-buffers-predicate)
    (setq my/rust--last-run (cons root command))
    (compilation-start command nil (lambda (_) "*cargo*"))))

(defun my/rust--cargo (args)
  "Run cargo with ARGS (a string) from the crate root."
  (my/rust--compile (my/rust--root) (concat "cargo " args)))

(defun my/rust-cargo (args)
  "Run cargo with ARGS, read from the minibuffer."
  (interactive (list (read-string "cargo " nil 'my/rust-cargo-history)))
  (my/rust--cargo args))

(defun my/rust-build () (interactive) (my/rust--cargo "build"))
(defun my/rust-run () (interactive) (my/rust--cargo "run"))
(defun my/rust-check () (interactive) (my/rust--cargo "clippy --all-targets"))
(defun my/rust-test-all () (interactive) (my/rust--cargo "test"))

(defun my/rust--fn-at-point ()
  "Name of the function around point, or nil."
  (when-let* ((fn (treesit-parent-until
                   (treesit-node-at (point))
                   (lambda (n) (equal (treesit-node-type n) "function_item"))
                   t)))
    (treesit-node-text (treesit-node-child-by-field-name fn "name") t)))

(defun my/rust-test-at-point ()
  "Run the test function around point; outside a function, this file's tests."
  (interactive)
  (my/rust--cargo
   (concat "test "
           (shell-quote-argument
            (or (my/rust--fn-at-point)
                (file-name-base buffer-file-name))))))

(defun my/rust-rerun ()
  "Rerun the last cargo command."
  (interactive)
  (unless my/rust--last-run (user-error "Nothing to rerun yet"))
  (my/rust--compile (car my/rust--last-run) (cdr my/rust--last-run)))

;;; Debugging with gdb (>= 14 speaks DAP).  rust-gdb is gdb with
;;; Rust pretty printers for Vec, String, Option, ...

(defun my/rust--debug-program ()
  "Path of the crate's first binary in the debug target dir."
  (let* ((default-directory (my/rust--root))
         (meta (json-parse-string
                (shell-command-to-string
                 "cargo metadata --no-deps --format-version 1 2>/dev/null")
                :object-type 'alist :array-type 'list))
         (manifest (expand-file-name "Cargo.toml"))
         (pkg (seq-find (lambda (p) (file-equal-p (alist-get 'manifest_path p) manifest))
                        (alist-get 'packages meta)))
         (bin (seq-find (lambda (tg) (member "bin" (alist-get 'kind tg)))
                        (alist-get 'targets pkg))))
    (unless bin (user-error "No binary target in %s" manifest))
    (expand-file-name (concat "debug/" (alist-get 'name bin))
                      (alist-get 'target_directory meta))))

(with-eval-after-load 'dape
  ;; Overrides go first: the first occurrence of a key wins.
  (add-to-list 'dape-configs
               `(rust-gdb
                 modes (rust-ts-mode)
                 command "rust-gdb"
                 command-cwd my/rust--root
                 compile "cargo build"
                 :program my/rust--debug-program
                 ,@(alist-get 'gdb dape-configs))))

(defun my/rust-debug ()
  "Build and debug the crate's binary (set breakpoints with C-<f8>)."
  (interactive)
  (dape (dape--config-eval 'rust-gdb nil)))

;;; Menu

(transient-define-prefix my/rust-menu ()
  "Cargo commands."
  [["Build"
    ("b" "build" my/rust-build)
    ("r" "run" my/rust-run)
    ("c" "clippy" my/rust-check)
    ("x" "cargo ..." my/rust-cargo)]
   ["Test"
    ("t" "test at point" my/rust-test-at-point)
    ("a" "all tests" my/rust-test-all)
    ("l" "rerun last" my/rust-rerun)]
   ["Debug"
    ("d" "debug binary" my/rust-debug)
    ("q" "stop debugging" dape-quit)]])

(with-eval-after-load 'rust-ts-mode
  (keymap-set rust-ts-mode-map "C-c m"     #'my/rust-menu)
  (keymap-set rust-ts-mode-map "C-S-<f10>" #'my/rust-test-at-point)
  (keymap-set rust-ts-mode-map "S-<f10>"   #'my/rust-rerun))

(provide 'my-rust)
;;; rust.el ends here
