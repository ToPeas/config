---
--  @author     topeas peiqxin@gmial.com
--  @license    MIT

-- 设置Grid 12x8(水平x竖直)
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDWIDTH = 12
hs.grid.GRIDHEIGHT = 8

-- 定义按键
local m_alt = {"alt"}
local m_shift_cmd = {"shift", "cmd"}
local m_shift_alt = {"shift", "alt"}

local m_switch_app = m_alt
local m_mod1 = m_shift_cmd
local m_mod2 = m_shift_alt

-- 应用列表映射
local APPNAMES = {
    IM = "QQ",
    Mail = "Foxmail",
    Doc = "Dash",
    Term = "iTerm 2",
    NotePlan = 'NotePlan.app',
    Vscode = "Visual Studio Code",
    OLu = "Eudic",
    WebStorm = "WebStorm",
    Alternote = 'Alternote',
    YouDao = "网易有道词典.app",
    YouXiang = "MailMaster.app",
    Browser = "Google Chrome",
    Leanote = "Leanote",
    Wangyi = 'NeteaseMusic',
    Work = '企业微信.app',
    XMind = 'XMind',
    Telegram = 'Telegram',
    Canary = 'Google Chrome Canary',
    Dash = 'Dash',
    Remotix = 'Microsoft Remote Desktop',
    Firefox = 'Firefox',
    QQMusic = 'QQMusic',
    PostMan = "Postman",
    HBuilder = "HBuilder",
    Charles = "Charles",
    Finder = "Finder",
    AirMail3 = "Airmail 3",
    TickTick = "TickTick.app",
    Android = 'Android Studio',
    Edge = "Microsoft Edge",
    DChat = "D-Chat.app",
    Notion = "Notion",
    WeChat = "WeChat",
    WizNote = "WizNote",
    YinXiang = '印象笔记',
    GoLand = 'GoLand.app',
    WeChatKF = 'wechatwebdevtools.app',
    Music = "QQMusic",
    Spark = "Spark",
    ZhifubaoKF = '小程序开发者工具.app'
}

---
--  常用布局(Grid 12x8)
--  {水平起始位置, 竖直起始位置, 宽度占比, 高度占比}
local LAYOUTS = {
    fullscreen = {0, 0, 12, 8},
    center = {3, 2, 6, 4},
    left = {0, 0, 6, 8},
    right = {6, 0, 6, 8},
    left4 = {0, 0, 4, 8},
    left6 = {0, 0, 6, 8},
    left8 = {0, 0, 8, 8},
    right4 = {8, 0, 4, 8},
    right6 = {6, 0, 6, 8},
    right8 = {4, 0, 8, 8},
    left_top = {0, 0, 6, 4},
    left_bottom = {0, 4, 6, 4},
    right_top = {6, 0, 6, 4},
    right_bottom = {6, 4, 6, 4}
}

---
--  常用应用布局
-- local APP_LAYOUT = {
--     [1] = {
--         one_monitor = {
--             [APPNAMES.Term] = {1, LAYOUTS.left},
--             [APPNAMES.Browser] = {1, LAYOUTS.right},
--             -- [APPNAMES.Mail] = {1, LAYOUTS.left},
--             [APPNAMES.IM] = {1, LAYOUTS.left},
--             -- [APPNAMES.Doc] = {1, LAYOUTS.right},
--             -- [APPNAMES.FileManager] = {1, LAYOUTS.right},
--             [APPNAMES.WeChat] = {1, LAYOUTS.left},
--             -- [APPNAMES.Preview] = {1, LAYOUTS.right},
--         },
--         two_monitor = {
--             [APPNAMES.Term] = {2, LAYOUTS.fullscreen},
--             [APPNAMES.Browser] = {1, LAYOUTS.fullscreen},
--             -- [APPNAMES.Mail] = {1, LAYOUTS.fullscreen},
--             [APPNAMES.IM] = {1, LAYOUTS.right},
--             -- [APPNAMES.Doc] = {1, LAYOUTS.right},
--             -- [APPNAMES.FileManager] = {1, LAYOUTS.right},
--             [APPNAMES.WeChat] = {1, LAYOUTS.right},
--             -- [APPNAMES.Preview] = {1, LAYOUTS.fullscreen},
--         }
--     }
-- }

---
--  调整窗口大小以及位置(基于网格布局)
--  @int    x       水平起始位置
--  @int    y       竖直起始位置
--  @int    w       宽度占比
--  @int    h       高度占比
--  @table  cell
local set_windows_to_grid = function(cell)
    return function()
        -- 获取得到焦点的显示器
        local win = hs.window.focusedWindow()
        if win then
            hs.grid.set(win,
                        {x = cell[1], y = cell[2], w = cell[3], h = cell[4]},
                        win:screen())
        else
            hs.alert.show("No focused window.")
        end
    end
end

---
--  移动窗口
local move_window = function(x, y)
    return function()
        local win = hs.window.focusedWindow()
        local f = win:frame()
        f.x = f.x + x
        f.y = f.y + y
        win:setFrame(f)
    end
end

---
--  数组长度可变的cycle
function mutable_cycle()
    local i = 1
    return function(arr)
        local x = arr[i % (#arr + 1)]
        i = i % #arr + 1
        return x
    end
end

---
--  打开/切换到App
local launch_or_focus_window = function(name)
    local mutable_cycle_func = mutable_cycle()
    return function()
        -- for index, window in pairs(hs.window.visibleWindows()) do
        --     print(window, "========", window:application(), "======",
        --           window:screen())
        -- end
        local app = hs.appfinder.appFromName(name)
        -- print(app)
        -- print(hs.window.visibleWindows())
        -- local w = hs.window.filter.allowedWindowRoles()
        -- print('w',w)
        if not app then
            hs.application.launchOrFocus(name)
            return
        end

        if #app:allWindows() == 1 then
            hs.application.launchOrFocus(name)
            return
        end

        local window_list = hs.fnutils.filter(app:allWindows(), function(item)
            return item:role() == "AXWindow"
        end)

        if #window_list == 0 then
            hs.application.launchOrFocus(name)
            return
        end

        table.sort(window_list, function(x, y) return x:id() < y:id() end)

        win = mutable_cycle_func(window_list)
        if win then win:focus() end
    end
end

---
--  移动窗口到指定屏幕&调整大小
function move_and_resize(win, layout_meta)
    local pos = layout_meta[2]
    local screens = hs.screen.allScreens()
    local cell = {x = pos[1], y = pos[2], w = pos[3], h = pos[4]}

    hs.grid.set(win, cell, screens[layout_meta[1]])
end

---
--  切换布局
function change_layout(layout)
    return function()
        local screens = hs.screen.allScreens()
        local layout_meta = nil

        local screen_count = #screens

        -- FIXME: 暂时只支持两个显示器
        if screen_count == 1 then
            layout_meta = layout.one_monitor
        elseif screen_count == 2 then
            layout_meta = layout.two_monitor
        else
            return
        end

        for name, place in pairs(layout_meta) do
            local app = hs.appfinder.appFromName(name)
            if app then
                for i, win in ipairs(app:allWindows()) do
                    move_and_resize(win, layout_meta[name])
                end
            end
        end
    end
end

--
--  修改窗口大小,
local resize_window = function(w, h)
    return function()
        local win = hs.window.focusedWindow()
        if win then
            local size = win:size()
            size.w = size.w + w
            size.h = size.h + h
            win:setSize(size)
        else
            hs.alert.show("No focused window.")
        end
    end
end

-----------------------------------------------------------------------------
-- 快捷键
-----------------------------------------------------------------------------

---
--  常用的窗口布局
hs.fnutils.each({
    {key = "up", layout = LAYOUTS.fullscreen},
    {key = "1", layout = LAYOUTS.left}, {key = "2", layout = LAYOUTS.right},
    {key = "3", layout = LAYOUTS.left_top},
    {key = "4", layout = LAYOUTS.left_bottom},
    {key = "5", layout = LAYOUTS.right_top},
    {key = "6", layout = LAYOUTS.right_bottom},
    {key = "down", layout = LAYOUTS.center}
}, function(meta)
    hs.hotkey.bind(m_mod1, meta.key, set_windows_to_grid(meta.layout))
end)

-- -- 绑定up键为把当前的窗口全屏
-- hs.hotkey.bind(m_mod1, 'up', function()
--     hs.grid.maximizeWindow()
-- end)

---
--  移动窗口
hs.fnutils.each({
    {key = "j", w = -50, h = 0}, {key = "k", w = 0, h = 50},
    {key = "i", w = 0, h = -50}, {key = "l", w = 50, h = 0}
    -- {key = "p", w = 20, h = 0},
}, function(meta)
    hs.hotkey.bind(m_mod1, meta.key, move_window(meta.w, meta.h), nil,
                   move_window(meta.w, meta.h))
end)

--  修改窗口大小
hs.fnutils.each({
    -- {key = "w", w = -20, h = 0},
    {key = "j", w = 50, h = 0}, {key = "k", w = 0, h = 50},
    {key = "l", w = -50, h = 0}, {key = "i", w = 0, h = -50}
    -- {key = "u", w = -40, h = -40},
}, function(meta)
    hs.hotkey.bind(m_mod2, meta.key, resize_window(meta.w, meta.h), nil,
                   resize_window(meta.w, meta.h))
end)

--  加载/切换到指定App
hs.fnutils.each({
    {key = "a", app = APPNAMES.WebStorm}, {key = "d", app = APPNAMES.DChat},
    {key = "g", app = APPNAMES.Browser}, {key = "y", app = APPNAMES.ZhifubaoKF},
    {key = "i", app = APPNAMES.Term}, {key = "r", app = APPNAMES.WeChatKF},
    {key = "b", app = APPNAMES.Finder}, {key = "v", app = APPNAMES.Vscode},
    {key = "u", app = APPNAMES.QQMusic}, {key = "n", app = APPNAMES.Notion},
    {key = "o", app = APPNAMES.OLu}, {key = "j", app = APPNAMES.XMind},
    {key = "q", app = APPNAMES.IM}, {key = "l", app = APPNAMES.GoLand},
    {key = "m", app = APPNAMES.Wangyi}, {key = "t", app = APPNAMES.Telegram},
    {key = "w", app = APPNAMES.WeChat}, {key = 'e', app = APPNAMES.Edge}
}, function(meta)
    hs.hotkey.bind(m_switch_app, meta.key, launch_or_focus_window(meta.app))
end)

---
-- 添加一个script,自动帮忙输入字符
local keyStrokes = function(str)
    return function() hs.eventtap.keyStrokes(str) end
end

-- 绑定一个输入的快捷方式
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "L", keyStrokes("console.log('')"))

--  重新加载配置文件
hs.hotkey.bind(m_mod2, "r", function()
    hs.reload()
    hs.alert.show("Config loaded")
end)

---
-- 移动软件到另一个屏幕
-- 目前是3个
function moveWindowToDisplay(d)
    return function()
        local displays = hs.screen.allScreens()
        local win = hs.window.focusedWindow()
        win:moveToScreen(displays[d], false, true)
    end
end

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "1", moveWindowToDisplay(1))
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "2", moveWindowToDisplay(2))
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "3", moveWindowToDisplay(3))

-- 切换屏幕的焦点
-- move cursor to previous monitor
hs.hotkey.bind(m_mod1, "left", function()
    focusScreen(hs.window.focusedWindow():screen():previous())
end)

-- move cursor to next monitor
hs.hotkey.bind(m_mod1, "right", function()
    focusScreen(hs.window.focusedWindow():screen():next())
end)

-- Predicate that checks if a window belongs to a screen
function isInScreen(screen, win) return win:screen() == screen end

function focusScreen(screen)
    -- Get windows within screen, ordered from front to back.
    -- If no windows exist, bring focus to desktop. Otherwise, set focus on
    -- front-most application window.
    local windows = hs.fnutils.filter(hs.window.orderedWindows(),
                                      hs.fnutils.partial(isInScreen, screen))
    local windowToFocus = #windows > 0 and windows[1] or hs.window.desktop()
    windowToFocus:focus()

    -- move cursor to center of screen
    local pt = hs.geometry.rectMidPoint(screen:fullFrame())
    hs.mouse.setAbsolutePosition(pt)
end
