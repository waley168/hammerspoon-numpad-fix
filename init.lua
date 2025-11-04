-- ============================================================================
-- Numpad Halfwidth Converter for macOS
-- ============================================================================
-- 功能：將數字鍵盤（Numpad）的輸入強制轉換為半形字元
-- 適用於中文輸入法環境，解決 Numpad 預設輸出全形字元的問題
-- 支援組字狀態下的即時轉換
-- ============================================================================

-- ============================================================================
-- 基本設定
-- ============================================================================

-- 功能開關：使用 Ctrl+Option+Command+N 切換功能啟用/停用
local enabled = true
hs.hotkey.bind({"ctrl","alt","cmd"}, "N", function()
  enabled = not enabled
  hs.alert.show("Numpad ASCII: " .. (enabled and "ON" or "OFF"))
end)

-- ============================================================================
-- Numpad 按鍵對照表
-- ============================================================================
-- 格式：[numpad keyCode] = {char = "輸出字元", mainKeyCode = 主鍵盤 keyCode}
-- mainKeyCode 保留供未來擴充使用
local MAP = {
  [82] = {char = "0", mainKeyCode = 29},
  [83] = {char = "1", mainKeyCode = 18},
  [84] = {char = "2", mainKeyCode = 19},
  [85] = {char = "3", mainKeyCode = 20},
  [86] = {char = "4", mainKeyCode = 21},
  [87] = {char = "5", mainKeyCode = 23},
  [88] = {char = "6", mainKeyCode = 22},
  [89] = {char = "7", mainKeyCode = 26},
  [91] = {char = "8", mainKeyCode = 28},
  [92] = {char = "9", mainKeyCode = 25},
  [75] = {char = "/", mainKeyCode = 44},
  [67] = {char = "*", mainKeyCode = 28, needShift = true},
  [78] = {char = "-", mainKeyCode = 27},
  [69] = {char = "+", mainKeyCode = 24, needShift = true},
  [65] = {char = ".", mainKeyCode = 47},
}

-- ============================================================================
-- 應用程式黑名單（可選）
-- ============================================================================
-- 在這些應用程式中不啟用 Numpad 轉換功能
-- 取消註解以排除特定應用程式
local BLACKLIST = {
  -- ["com.apple.Terminal"] = true,
  -- ["com.googlecode.iterm2"] = true,
  -- ["com.microsoft.VSCode"] = true,

  -- 網頁瀏覽器（如果特定網頁有問題，可暫時加入黑名單）
  -- ["com.apple.Safari"] = true,
  -- ["com.google.Chrome"] = true,
  -- ["company.thebrowser.Browser"] = true,  -- Arc Browser
}

local function isBlacklisted()
  local app = hs.application.frontmostApplication()
  return app and BLACKLIST[app:bundleID()] or false
end

-- ============================================================================
-- 輸入法檢測與處理
-- ============================================================================

-- 檢測當前是否使用中文輸入法
local function isChineseIME()
  local source = hs.keycodes.currentSourceID()
  return source:match("com%.apple%.inputmethod") or
         source:match("Chinese") or
         source:match("Pinyin") or
         source:match("Zhuyin")
end

-- 輸入半形字元
-- 策略：直接使用 keyStrokes 輸入，不切換輸入法，不送出 Enter/ESC
local function injectChar(info)
  hs.timer.doAfter(0, function()
    local char = info.char

    -- 直接輸入半形字元
    -- keyStrokes 會自動處理輸入法狀態，輸出 ASCII 字元
    hs.eventtap.keyStrokes(char)
  end)
end

-- ============================================================================
-- 按鍵事件處理
-- ============================================================================

-- 主要事件處理函數
local function handler(e)
  -- 檢查功能是否啟用
  if not enabled then return false end

  -- 檢查是否在黑名單應用程式中
  if isBlacklisted() then return false end

  -- 檢查是否處於安全輸入模式（例如密碼輸入框）
  if hs.eventtap.isSecureInputEnabled() then return false end

  -- 若有修飾鍵（Cmd/Alt/Ctrl/Shift），則不處理
  local f = e:getFlags()
  if f.cmd or f.alt or f.ctrl or f.shift then return false end

  -- 檢查是否為 Numpad 按鍵
  local info = MAP[e:getKeyCode()]
  if info then
    injectChar(info)
    return true  -- 攔截原始事件，防止輸出全形字元
  end

  return false  -- 非 Numpad 按鍵，不處理
end

-- ============================================================================
-- EventTap 建立與管理
-- ============================================================================

local tap

-- 建立或重建 EventTap
local function buildTap()
  if tap then
    tap:stop()
    tap = nil
  end

  tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    local ok, ret = xpcall(
      function() return handler(e) end,
      function(err) hs.printf("[numpad] error: %s", err); return false end
    )
    return ok and ret or false
  end)

  tap:start()
end

-- 初始化
buildTap()
hs.alert.show("Numpad ASCII loaded (toggle: ⌃⌥⌘+N)")

-- ============================================================================
-- 穩定性保障機制
-- ============================================================================

-- 定期檢查：每 2 秒確認 EventTap 是否正常運作
hs.timer.doEvery(2, function()
  if not tap or not tap:isEnabled() then
    hs.printf("[numpad] tap was disabled, rebuilding...")
    buildTap()
  end
end)

-- 系統事件監控：喚醒、解鎖、螢幕開啟時重建 EventTap
hs.caffeinate.watcher.new(function(ev)
  if ev == hs.caffeinate.watcher.systemDidWake
     or ev == hs.caffeinate.watcher.screensDidUnlock
     or ev == hs.caffeinate.watcher.screensDidWake then
    hs.printf("[numpad] system event detected, rebuilding tap")
    buildTap()
  end
end):start()

-- 應用程式切換監控：切換應用時檢查 EventTap 狀態
hs.application.watcher.new(function(name, event, app)
  if event == hs.application.watcher.activated then
    hs.timer.doAfter(0.1, function()
      if not tap or not tap:isEnabled() then
        hs.printf("[numpad] app switch detected, rebuilding tap")
        buildTap()
      end
    end)
  end
end):start()

-- 桌面空間切換監控：切換 Space 時檢查 EventTap 狀態
hs.spaces.watcher.new(function()
  hs.timer.doAfter(0.1, function()
    if not tap or not tap:isEnabled() then
      hs.printf("[numpad] space change detected, rebuilding tap")
      buildTap()
    end
  end)
end):start()
