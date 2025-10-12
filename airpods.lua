local menubar = hs.menubar.new();

-- 🎧 设置 AirPods 音量的函数
local function setAirPodsVolume()
    -- 添加一个短暂的延迟，确保设备信息已完全更新
    hs.timer.doAfter(1, function()
        local currentDevice = hs.audiodevice.defaultOutputDevice()
        if currentDevice then
            local deviceName = currentDevice:name()
            -- 检查设备名称中是否包含 "AirPods"
            if deviceName and string.find(deviceName, "AirPods") then
                -- 如果当前音量不是20，才进行设置并提示，避免不必要的打扰
                if currentDevice:volume() ~= 20 then
                    currentDevice:setVolume(20)
                    hs.alert.show("🎧 AirPods 音量设为 20%")
                end
            end
        end
    end)
end

-- 📌 监听所有音频设备的变化(包括连接/断开)
local function audioDeviceCallback(event)
    if event == "dOut" or event == "dev#" then
        setAirPodsVolume()
    end
end

-- ⏰ 注册音频设备监听
hs.audiodevice.watcher.setCallback(audioDeviceCallback)
hs.audiodevice.watcher.start()

-- ############## 修改部分开始 ##############

-- 💻 监听会话状态变化 (锁定/解锁) 的函数
local function sessionStateCallback(event)
    -- 我们只关心 "屏幕被解锁" 这个事件
    if event == hs.caffeinate.watcher.screensDidUnlock then
        -- 解锁后，执行一次音量检查
        setAirPodsVolume()
    end
end

-- ⏰ 注册会话状态监听 (监听解锁事件)
local sessionWatcher = hs.caffeinate.watcher.new(sessionStateCallback)
sessionWatcher:start()

-- ############## 修改部分结束 ##############

-- 🔄 脚本加载时立即检查一次
setAirPodsVolume()

hs.alert.show("🎧 AirPods 音量管家已启动")
