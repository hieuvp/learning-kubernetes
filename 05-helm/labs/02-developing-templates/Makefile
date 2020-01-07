OUTPUT_DIR := output-templates

.PHONY: clean
clean:
	rm -rf $(OUTPUT_DIR)
	mkdir $(OUTPUT_DIR)

.PHONY: render
render: clean
	scripts/render-templates.sh $(OUTPUT_DIR)
