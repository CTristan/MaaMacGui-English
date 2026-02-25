# MAA Mac GUI

MAA stands for MAA Assistant Arknights

A game assistant for Arknights

**This repository contains the MAA Mac GUI and includes English translation support. It is used as a submodule in the main MAA repository.**

This repo is the Mac GUI repository for MAA and is a submodule of the main MAA repository. For more information about MAA, please refer to the [MAA Assistant Arknights main repository](https://github.com/MaaAssistantArknights/MaaAssistantArknights).

## Development

### Clone the code
1. Clone the [main repository](https://github.com/MaaAssistantArknights/MaaAssistantArknights)
2. Initialize the submodule `git submodule update --init --recursive`

### Build MAA Core
> For convenience, the build process has been written as a one-click script. During version iteration, the script may not be updated in time. In this case, please refer to the macOS-related content in the workflow definition.

1. Install dependencies `brew install ninja`
2. Run the script located in the main repository `MAA_DEBUG=1 ./tools/build_macos_universal.zsh`

🎉 Open Xcode and you can try to build

### Q&A

1. What to do if code signing cannot be obtained?
    - During development, you can switch to personal developer signing locally, but please do not commit these changes when submitting code
2. Various dependency download failures/timeouts?
    - Use a proxy/VPN
3. Is the Mirror-chan CDK different between the local test environment and the official version?
    - This feature involves keychain access. Due to signing issues, the test environment and the official version cannot be shared.
