ifdef test
	_test=--only_testing=Tests/$(test)
endif
setup:
	gem install bundler fastlane --pre
	bundle install
	fastlane setup
test:
	@bundle exec fastlane scan $(_test) || :
wait: test
	@find . -name "*.swift" | entr -p make test

