setup:
	bundle install
	fastlane import_keys
test:
	fastlane test
build:
	fastlane build