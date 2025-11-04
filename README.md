# Hammerspoon Numpad Fix

> **繁體中文說明 | Traditional Chinese**

## 專案簡介

這是一個 Hammerspoon 腳本，專門解決 **macOS 使用中文輸入法時，數字鍵盤（Numpad）無法輸入半形數字和符號** 的問題。

### 遇到的問題

在 macOS 使用注音、拼音等中文輸入法時，按數字鍵盤的數字鍵會輸出全形字元（如 `０１２３`），而不是我們需要的半形 ASCII 字元（如 `0123`）。這對經常需要輸入數字的使用者來說非常困擾，特別是在填表單、編輯試算表時。

### 解決方案

這個腳本會自動攔截數字鍵盤的按鍵事件，強制轉換為半形字元輸出。無論你當前使用什麼輸入法，數字鍵盤都能正常輸入半形數字和符號。

### 主要特色

- ✅ **免費開源**：使用免費的 Hammerspoon，無需付費軟體
- ✅ **簡單易用**：安裝後自動運作，無需額外設定
- ✅ **智慧處理**：即使在打字到一半（有底線的組字狀態），也能正確輸入數字
- ✅ **支援長按**：按住數字鍵可以連續輸入
- ✅ **穩定可靠**：自動處理系統喚醒、切換應用程式等情況
- ✅ **可自訂**：可設定特定應用程式不啟用（例如終端機）
- ✅ **快速切換**：按 `Ctrl+Option+Command+N` 即可開關功能

### 支援的按鍵

數字鍵盤的所有數字（0-9）和運算符號（+ - * / .）都會自動轉換為半形字元。

---

## English Documentation

A Hammerspoon configuration that forces numpad input to output halfwidth (ASCII) characters instead of fullwidth characters when using Chinese input methods on macOS.

## Problem

When using Chinese input methods (like Zhuyin or Pinyin) on macOS, the numpad keys output fullwidth characters (e.g., `０１２３`) instead of the expected halfwidth ASCII characters (e.g., `0123`). This can be frustrating for users who need to input numbers frequently, especially in professional environments like spreadsheets or forms.

## Solution

This Hammerspoon script intercepts numpad key events and converts them to halfwidth ASCII characters, regardless of the current input method. It also handles edge cases like:

- **IME composition state**: When you're in the middle of typing with Chinese input (characters with underlines), the script automatically cancels the composition and inputs the halfwidth number.
- **Long press support**: Hold down numpad keys to repeat input, just like regular keys.
- **Stability**: Multiple watchers ensure the script continues working after app switches, space changes, or system wake/unlock events.

## Features

- ✅ **Automatic halfwidth conversion** for all numpad keys (0-9, +, -, *, /, .)
- ✅ **IME-aware**: Works even during Chinese input composition
- ✅ **Long press support**: Repeats input when holding keys
- ✅ **Stable**: Auto-recovers from system events
- ✅ **Toggle on/off**: Press `Ctrl+Option+Command+N` to enable/disable
- ✅ **Application blacklist**: Optionally exclude specific apps

## Requirements

- macOS (tested on macOS 10.14+)
- [Hammerspoon](https://www.hammerspoon.org/) (free and open-source)

## Installation

### 1. Install Hammerspoon

Download and install Hammerspoon from the [official website](https://www.hammerspoon.org/).

### 2. Install the Script

**Option A: Fresh Installation**

```bash
# Download the init.lua file to Hammerspoon config directory
curl -o ~/.hammerspoon/init.lua https://raw.githubusercontent.com/waley168/hammerspoon-numpad-fix/main/init.lua
```

**Option B: Append to Existing Configuration**

If you already have Hammerspoon configurations:

```bash
# Download the script
curl -o ~/Downloads/numpad-fix.lua https://raw.githubusercontent.com/waley168/hammerspoon-numpad-fix/main/init.lua

# Then manually copy the contents to your ~/.hammerspoon/init.lua
```

### 3. Reload Hammerspoon

Click the Hammerspoon menu bar icon → "Reload Config"

You should see an alert: "Numpad ASCII loaded (toggle: ⌃⌥⌘+N)"

## Usage

### Basic Usage

Once installed, the script automatically converts all numpad input to halfwidth characters. No additional configuration needed!

### Toggle On/Off

Press `Ctrl+Option+Command+N` to toggle the feature on or off.

### Application Blacklist

To disable the conversion in specific applications, edit the `BLACKLIST` section in `init.lua`:

```lua
local BLACKLIST = {
  ["com.apple.Terminal"] = true,        -- Terminal
  ["com.googlecode.iterm2"] = true,     -- iTerm2
  ["com.microsoft.VSCode"] = true,      -- VS Code
}
```

To find an application's bundle ID, run in Terminal:

```bash
osascript -e 'id of app "APPLICATION_NAME"'
```

## How It Works

1. **Event Interception**: Uses Hammerspoon's `eventtap` to intercept numpad keyDown events
2. **IME Detection**: Checks if the current input source is a Chinese input method
3. **Composition Handling**: If in composition state (typing with underlines), sends ESC to cancel
4. **Character Injection**: Injects the halfwidth character using `keyStrokes`
5. **Stability Watchers**: Multiple watchers ensure the eventtap remains active:
   - Timer-based health check (every 2 seconds)
   - System event watcher (wake/unlock/screen on)
   - Application switch watcher
   - Space (desktop) switch watcher

## Troubleshooting

### Script Not Working

1. **Check Hammerspoon is running**: Look for the Hammerspoon icon in the menu bar
2. **Reload configuration**: Click Hammerspoon icon → "Reload Config"
3. **Check Console for errors**: Click Hammerspoon icon → "Console"
4. **Verify Accessibility permissions**: System Preferences → Security & Privacy → Privacy → Accessibility → Ensure Hammerspoon is checked

### Still Outputs Fullwidth Characters

1. Try toggling the feature off and on: `Ctrl+Option+Command+N` twice
2. Check if the app is in the blacklist
3. Check Hammerspoon Console for error messages

### High CPU Usage

This should not happen (typical usage < 0.1% CPU). If you experience high CPU:
1. Check Hammerspoon Console for error loops
2. Try reloading the configuration
3. Please report the issue with Console logs

## Key Mappings

The script handles these numpad keys:

| Numpad Key | Output |
|------------|--------|
| 0-9        | 0-9    |
| /          | /      |
| *          | *      |
| -          | -      |
| +          | +      |
| .          | .      |

To add more keys (like Enter), edit the `MAP` table in `init.lua`.

## Advanced Configuration

### Adjust Health Check Interval

Change the timer interval (default: 2 seconds):

```lua
hs.timer.doEvery(5, function()  -- Change 2 to 5 for 5-second interval
  ...
end)
```

### Disable Specific Watchers

If you don't need certain stability features, comment out the corresponding watcher:

```lua
-- Disable space switch watcher
-- hs.spaces.watcher.new(function()
--   ...
-- end):start()
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Credits

Created by ueda for the macOS Chinese input community.

## Related Links

- [Hammerspoon Official Documentation](https://www.hammerspoon.org/docs/)
- [Hammerspoon GitHub](https://github.com/Hammerspoon/hammerspoon)

## Changelog

### v1.0.0 (2025-11-04)

- Initial release
- Numpad to halfwidth conversion
- IME composition state handling
- Multiple stability watchers
- Application blacklist support
- Toggle hotkey support
