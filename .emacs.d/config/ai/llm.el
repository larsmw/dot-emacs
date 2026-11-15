;; -*- lexical-binding: t; -*-

;;; Test llm integration
(use-package gptel
  :ensure t)

;;;(setq gptel-backend
;;;      (gptel-make-openai "LM Studio"
;;;        :host "localhost:1234"
;;;        :protocol "http"
;;;        :endpoint "/v1/chat/completions"
;;;        :key "not-needed")
;;;      )
(setq gptel-backend
      (gptel-make-llama-cpp "Llama.cpp"
                            "localhost:8000"
                            "models/qwen3-8b.gguf"
                            "http"
                            "not-needed"
                            :n_ctx 2048)
      )

(setq gptel-use-curl t
      gptel-stream nil)

;;Setup buffer local topic and branching context:
;; (gptel-org-set-topic "gptel:-emacs-llm-interface")
;; (setq gptel-org-branching-context t)


;;Set your LLM backend (e.g., LM Studio)

