;; TODO: LSP? 
;; TODO: Starlark/buck2 mode?
;; TODO(@huwaireb): The options we need, `check.overrideCommand` and `workspace.discoverConfig.*` aren't part of lsp-config atm
;; I've reached out to see how we could pass it manually.

((auto-mode-alist
		("/\\.buckconfig\\'" . conf-mode)
		("BUCK\\'" . python-mode)
		("PACKAGE\\'" . python-mode)
		("\\.bzl\\'" . python-mode)
		("\\.bxl\\'" . python-mode)))
