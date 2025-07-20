# Makefile for Audio Toggle Extension

EXTENSION_NAME = audio-toggle@local
EXTENSION_DIR = $(HOME)/.local/share/gnome-shell/extensions/$(EXTENSION_NAME)
SOURCE_DIR = ./audio-toggle@local

.PHONY: all install uninstall test clean lint restart-shell enable disable status

# Default target
all: install

# Install the extension
install:
	@echo "Installing Audio Toggle Extension..."
	@mkdir -p $(HOME)/.local/share/gnome-shell/extensions
	@if [ -d "$(EXTENSION_DIR)" ]; then \
		echo "Removing existing extension..."; \
		rm -rf "$(EXTENSION_DIR)"; \
	fi
	@cp -r "$(SOURCE_DIR)" "$(EXTENSION_DIR)"
	@chmod +x "$(EXTENSION_DIR)"/*.js
	@echo "Extension installed to $(EXTENSION_DIR)"

# Uninstall the extension
uninstall:
	@echo "Uninstalling Audio Toggle Extension..."
	@if command -v gnome-extensions >/dev/null 2>&1; then \
		gnome-extensions disable $(EXTENSION_NAME) 2>/dev/null || true; \
	fi
	@if [ -d "$(EXTENSION_DIR)" ]; then \
		rm -rf "$(EXTENSION_DIR)"; \
		echo "Extension removed from $(EXTENSION_DIR)"; \
	else \
		echo "Extension not found in $(EXTENSION_DIR)"; \
	fi

# Test system compatibility
test:
	@echo "Running system compatibility test..."
	@./test-system.sh

# Clean build artifacts
clean:
	@echo "Cleaning up..."
	@rm -rf $(EXTENSION_DIR)

# Lint JavaScript files
lint:
	@echo "Linting extension files..."
	@if command -v gjs >/dev/null 2>&1; then \
		gjs -c $(SOURCE_DIR)/extension.js && echo "✅ extension.js syntax OK"; \
		gjs -c $(SOURCE_DIR)/prefs.js && echo "✅ prefs.js syntax OK"; \
	else \
		echo "⚠️  gjs not found, skipping syntax check"; \
	fi

# Restart GNOME Shell (X11 only)
restart-shell:
	@echo "Restarting GNOME Shell..."
	@if [ "$$XDG_SESSION_TYPE" = "x11" ]; then \
		busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting...")'; \
	else \
		echo "⚠️  Cannot restart GNOME Shell on Wayland. Please log out and log back in."; \
	fi

# Enable the extension
enable:
	@echo "Enabling extension..."
	@if command -v gnome-extensions >/dev/null 2>&1; then \
		gnome-extensions enable $(EXTENSION_NAME) && echo "✅ Extension enabled"; \
	else \
		echo "❌ gnome-extensions command not found"; \
	fi

# Disable the extension
disable:
	@echo "Disabling extension..."
	@if command -v gnome-extensions >/dev/null 2>&1; then \
		gnome-extensions disable $(EXTENSION_NAME) && echo "✅ Extension disabled"; \
	else \
		echo "❌ gnome-extensions command not found"; \
	fi

# Show extension status
status:
	@echo "Extension status:"
	@if command -v gnome-extensions >/dev/null 2>&1; then \
		if gnome-extensions list --enabled | grep -q $(EXTENSION_NAME); then \
			echo "✅ Extension is ENABLED"; \
		elif gnome-extensions list --disabled | grep -q $(EXTENSION_NAME); then \
			echo "❌ Extension is DISABLED"; \
		else \
			echo "❓ Extension not found or not installed"; \
		fi; \
		echo ""; \
		echo "Extension info:"; \
		gnome-extensions info $(EXTENSION_NAME) 2>/dev/null || echo "No info available"; \
	else \
		echo "❌ gnome-extensions command not found"; \
	fi

# Development workflow
dev: install enable
	@echo "Development setup complete!"
	@echo "Watching logs... (Press Ctrl+C to stop)"
	@journalctl -f -o cat /usr/bin/gnome-shell | grep -i "audio.toggle\|extension\|error" --color=always

# Quick reinstall for development
reinstall: uninstall install enable

# Show help
help:
	@echo "Audio Toggle Extension - Makefile"
	@echo "=================================="
	@echo ""
	@echo "Available targets:"
	@echo "  install       - Install the extension"
	@echo "  uninstall     - Remove the extension"
	@echo "  test          - Run system compatibility tests"
	@echo "  clean         - Clean up build artifacts"
	@echo "  lint          - Check JavaScript syntax"
	@echo "  restart-shell - Restart GNOME Shell (X11 only)"
	@echo "  enable        - Enable the extension"
	@echo "  disable       - Disable the extension"
	@echo "  status        - Show extension status"
	@echo "  dev           - Install, enable, and watch logs"
	@echo "  reinstall     - Quick uninstall + install + enable"
	@echo "  help          - Show this help"
	@echo ""
	@echo "Quick start:"
	@echo "  make install enable"
	@echo "  make test"
	@echo ""
	@echo "Development:"
	@echo "  make dev"
