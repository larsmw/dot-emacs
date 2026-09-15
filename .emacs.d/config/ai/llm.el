;; -*- lexical-binding: t; -*-
;;; llm.el --- LLM integration configuration

;;; Commentary:
;; gptel integration for Ollama local LLM backend.

;;; Code:

(use-package gptel
  :ensure t)

;; Ollama backend
(setq gptel-backend
      (gptel-make-ollama "Ollama"
        :host "localhost:11434"
        :models '(llama3:latest)
        :stream t
        :endpoint "/api/generate"))

(provide 'llm)
