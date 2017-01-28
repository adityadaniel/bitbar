APP := App
DIST := "$(PWD)/Dist/BitBar.xcarchive/Products/Applications"
PROJECT_NAME ?= BitBar
ifdef class
	# 'make test class=BufferTests' lets you test a specific class
	ARGS="-only-testing:BitBarTests/$(class)"
endif
BUILD_ATTR := xcodebuild -workspace $(APP)/$(PROJECT_NAME).xcworkspace DEVELOPMENT_TEAM=8Z44P9V4VF -scheme
CONFIG := Debug
BUILD := $(BUILD_ATTR) $(PROJECT_NAME)
TEST := $(BUILD_ATTR) BitBarTests $(ARGS) test
BUNDLE := $(PROJECT_NAME).app

default: clean
build:
	@echo "[Task] Building $(PROJECT_NAME), this might take a while..."
	@$(BUILD) | xcpretty
archive:
	@echo "[Task] Building app for deployment..."
	@mkdir -p Dist
	@$(BUILD_ATTR) BitBar -archivePath Dist/BitBar archive | xcpretty
	@echo "[Task] Completed building"
clean:
	@echo "[Task] Cleaning up..."
	@$(BUILD) clean | xcpretty
install:
	@echo "[Task] Installing dependencies..."
	@pod install --project-directory=$(APP) --repo-update
kill:
	@echo "[Task] Killing all running instances of $(PROJECT_NAME)..."
	@killall $(PROJECT_NAME) || :
open:
	@echo "[Task] Opening $(BUNDLE) build from $(CONFIG)..."
	@open $(APP)/.build/$(PROJECT_NAME)/Build/Products/$(CONFIG)/$(BUNDLE)
test:
	@echo "[Task] Running test suite..."
	@$(TEST) | xcpretty -c
ci:
	@set -o pipefail && $(TEST) | xcpretty -c
watch:
	@echo "[Task] Watching for file changes..."
	@find . -name "*.swift" | entr -rp make test
init:
	@echo "[Task] Installing dependencies..."
	@gem install cocoapods xcpretty --no-ri --no-rdoc
	# @brew install swiftlint
	# @brew install entr
setup: init install
lint:
	@echo "[Task] Linting swift files..."
	@swiftlint
fix:
	@echo "[Task] Fixing linting errors..."
	@swiftlint autocorrect
doc:
	echo "[Task] Generating documentation..."
	@jazzy \
		--clean \
		--author BitBar \
		--author_url https://getbitbar.com/ \
		--github_url https://github.com/matryer/bitbar \
		--xcodebuild-arguments -workspace,App/BitBar.xcworkspace,-scheme,BitBar \
		--module BitBar \
		--output Docs \
		--min-acl private
compress:
	@echo "[Task] Compressing application..."
	@ditto -c -k --sequesterRsrc --keepParent "$(DIST)/BitBar.app" "BitBar-$(version).zip"
	@echo "[Task] File has been compressed to BitBar-$(version).zip"
release: archive compress
