#!/bin/bash
# Disable package and macro fingerprint validation to enable the SwiftLint plugin during the build process.
# Typo in "Validation" is intended: https://github.com/realm/SwiftLint/issues/5624
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
