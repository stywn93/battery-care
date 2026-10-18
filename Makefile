APP_NAME = BatteryCare
BUILD_DIR = build
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app

.PHONY: all build run install clean

all: build

build:
	@chmod +x build.sh
	@./build.sh

run: build
	@echo "Launching $(APP_NAME)..."
	@open $(APP_BUNDLE)

install: build
	@echo "Installing $(APP_NAME) to /Applications..."
	@cp -R $(APP_BUNDLE) /Applications/
	@echo "Installed successfully! You can launch it from Applications or Spotlight."

clean:
	@rm -rf $(BUILD_DIR)
	@echo "Cleaned build artifacts."

test-notify:
	@osascript -e 'display notification "Battery is down to 15%. Plug in your charger soon." with title "Battery Care ⚠️" subtitle "Low Battery Warning" sound name "Blow"'
	@echo "Sent test notification!"
