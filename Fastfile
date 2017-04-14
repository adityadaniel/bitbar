fastlane_version "2.26.1"
default_platform :mac
chain = "travis.keychain"
key = ENV["encrypted_34de277e100a_key"]
iv = ENV["encrypted_34de277e100a_iv"]
pwd = ENV["CERTPWD"]
codesign = "/usr/bin/codesign"
env_cert = "Resources/bitbar.p12.enc"
cert = "Resources/bitbar.cer"

def security(*args)
  sh "security " + args.join(" ")
end

def openssl(*args)
  sh "openssl " + args.join(" ")
end

lane :lint do
  swiftlint mode: :lint
end

lane :fix do
  swiftlint mode: :autocorrect
end

platform :mac do
  before_all do
    # ensure_git_status_clean
    cocoapods repo_update: true
    update_project_codesigning(
      path: "BitBar.xcodeproj",
      use_automatic_signing: true,
      team_id: "8Z44P9V4VF"
    )
  end

  desc "Runs all the tests"
  lane :test do
    scan scheme: "BitBar", clean: true
  end

  desc "Import keys used for signing"
  lane :import_keys do
    next unless in_ci?
    Dir.chdir ".." do
      openssl "aes-256-cbc -K", key, "-iv", iv, "-in", env_cert, "-out bitbar.p12 -d"
      security "create-keychain -p travis", chain
      security "default-keychain -s", chain
      security "unlock-keychain -p travis", chain
      security "set-keychain-settings -t 3600 -u", chain
      security "import bitbar.p12 -A -P", pwd, "-k", chain, "-T", codesign
      security "import", cert, "-A -k", security, "-T", codesign
      security "set-key-partition-list -S apple-tool:,apple: -s -k travis", chain
    end
  end

  desc "Build and zip application"
  lane :build do
    gym
    zip path: "BitBar.app", output_path: "BitBar.zip"
    # sh "cd .. && ditto -c -k --sequesterRsrc --keepParent BitBar.app BitBar.zip"
  end

  # TODO
  # increment_build_number / increment_version_number
  # add_git_tag
  # ensure_git_branch
  # push_git_tags
  #   github_release = set_github_release(
  #   repository_name: "fastlane/fastlane",
  #   api_token: ENV["GITHUB_TOKEN"],
  #   name: "Super New actions",
  #   tag_name: "v1.22.0",
  #   description: (File.read("changelog") rescue "No changelog provided"),
  #   commitish: "master",
  #   upload_assets: ["example_integration.ipa", "./pkg/built.gem"]
  # )
  # after_all do |lane|
  # slack(
  #   message: "Successfully deployed new App Update."
  # )
  # end
end
