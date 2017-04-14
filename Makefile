APP := App
DIST := "$(PWD)/Dist/BitBar.xcarchive/Products/Applications"
CERT := bitbar.p12
APP2="BitBar"
KEYCHAIN := build.chain
PROJECT_NAME ?= BitBar
version ?= beta
ifdef class
	ARGS=-only-testing:BitBarTests/$(class)
endif
BUILD_ATTR := xcodebuild -workspace $(PROJECT_NAME).xcworkspace -scheme
BUILD := $(BUILD_ATTR) $(PROJECT_NAME)
BUNDLE := $(PROJECT_NAME).app

watch:
	@echo "[Task] Watching for file changes..."
	@find . -name "*.swift" | entr -r make test
init:
	bundle install
import_cert: unpack_p12
	fastlane import_keys
setup: init import_cert
compress:
	@echo "[Task] Compressing application..."
	@ditto -c -k --sequesterRsrc --keepParent "$(DIST)/BitBar.app" "BitBar-$(version).zip"
	@echo "[Task] File has been compressed to BitBar-$(version).zip"
test:
	fastlane test
ci: test
unpack_p12:
	openssl aes-256-cbc -K $(encrypted_34de277e100a_key) -iv $(encrypted_34de277e100a_iv) -in Resources/bitbar.p12.enc -out bitbar.p12 -d

