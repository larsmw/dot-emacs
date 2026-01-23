
;;; Test llm integration
(use-package gptel
  :ensure t)

(setq gptel-backend
      (gptel-make-openai "LM Studio"
        :host "localhost:1234"
        :protocol "http"
        :endpoint "/v1/chat/completions"
        :key "not-needed")
      )
(setq gptel-backend
      (gptel-make-ollama "Ollama"
        :host "localhost:11434"
        :models '(llama3:latest)
        :stream t
        :endpoint "/api/generate")
      )



;;Setup buffer local topic and branching context:
;; (gptel-org-set-topic "gptel:-emacs-llm-interface")
;; (setq gptel-org-branching-context t)


;;Set your LLM backend (e.g., LM Studio)

