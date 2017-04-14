setup:
	bundle install
	fastlane import_keys
# compress:
# 	@echo "[Task] Compressing application..."
# 	@ditto -c -k --sequesterRsrc --keepParent "$(DIST)/BitBar.app" "BitBar-$(version).zip"
# 	@echo "[Task] File has been compressed to BitBar-$(version).zip"
test:
	fastlane test
build:
	fastlane build