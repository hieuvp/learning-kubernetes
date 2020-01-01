OUTPUT_DIR := output-templates

.PHONY: clean
clean:
	rm -rf $(OUTPUT_DIR)
	mkdir $(OUTPUT_DIR)

.PHONY: template
template: clean
	scripts/template.sh $(OUTPUT_DIR)
