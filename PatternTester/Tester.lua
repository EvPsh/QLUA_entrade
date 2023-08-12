-- ������ ������ �������� �� �������� � �������
-- � ����������� ������������ �� ��������, � �������, ���������� ��������� ���������
-- Telegram @JJ_FXE 
---

dofile(getScriptPath() .. "\\include\\Parameters.lua")   -- ���������, ��������������� �������
dofile(getScriptPath() .. "\\include\\Patterns.lua")        -- �������� VSA ��� ��������

is_run = true           -- ���� ������ �������
CorrTime = 3            -- ����� ���. C ������� ����� �������� ��� �������������.
Cbars = 3               -- ������� ������ ���� �������
ds = {}                 -- data source ��� ��������� ������ ������
Classcode = "SPBFUT"    -- ��� ������ �����������/������, ���� ����� �������� ����� - ������� TQBR ������ SPBFUT. ���� �� ������������.
SlTime = 0.1            -- ����� ������������ ��� �������� �������� �� �������, � ������� (0.1 = 6 ������, 0.5 = 30 ������, 1 = 1 ������ � �.�.)

Bars = {                -- ������ ������ �����
        ["O"] = {},     -- ������ ������ �� ���������� Cbars
        ["H"] = {},
        ["L"] = {},
        ["C"] = {},
        ["V"] = {},
        ["T"] = {}
    }

nFile = ""              -- �������� ������������ ����� (�� ����� �����������)
scName = ""             -- �������� ������������ �������

function OnInit()
    --�������������
    scName = "PatternTester" -- string.match(debug.getinfo(1).short_src, "\\([^\\]+)%.lua$") -- ��������� ����� ����������� �������
    nFile = getScriptPath() .. "\\" .. scName .. ".csv"

--[[
    scName = string.match(debug.getinfo(1).short_src, "\\([^\\]+)%.lua$") -- ��������� ����� ����������� �������
	nFile = getScriptPath() .. "\\" .. scName .. ".csv"
--]]
end
-- https://quikluacsharp.ru/quik-qlua/poluchenie-v-qlua-lua-dannyh-iz-grafikov-i-indikatorov/
-- function CreateDS() -- ������ ������� ����� DS
-- local i
--     for i, _ in pairs(tInstr) do
--         ds[i] = {}
        
--         -- tInstr[i][1] -- �������� �����������
--         -- tInstr[i][2] -- ����� �����������
--         -- tInstr[i][3] -- ��������

--         --msg(tInstr[i][1] .. " +++ " .. tInstr[i][2] .. " +++ " ..tInstr[i][3] .." i = " .. i)

--         ds[i], error = CreateDataSource(Classcode, tInstr[i][1], tInstr[i][3])   -- ������� �������� ������ ��� ��������� ������
--         ds[i]:SetEmptyCallback()
--         --repeat sleep(1000) until ds[i]:Size() ~= 0 -- ������ ��������, ���� ����� �� ��������

--         if  ds[i] == nil then
--             msg("������ ��������� ������� � ������!\n" .. tostring(error))
--             OnStop()
--         end
--     end
-- end


function OnStop() -- �������� ��� ��������� �������
    is_run = false
    if t_id ~= nil then DestroyTable(t_id) end
end

function OnClose()
    WriteToFile(nFile, t_id)
end

function OnDisconnected()
    WriteToFile(nFile, t_id)
end

function main()
    CreateTable() -- ������ �������
    SetTableNotificationCallback(t_id, f_cb) -- ��������� callback ���������

	-- LoadInTable(nFile, t_id)

    while is_run do
        for i, _ in pairs(tInstr) do
            ds[i] = {}
            ds[i] = getNumCandles(tInstr[i][2])
                -- msg(ds[i] .. " ���������� ������: " .. tInstr[i][2] .. ": i = " .. i) -- ��� �������� ��������� ������

            if ds[i] == 0 or ds[i] == nil then
                -- i = nil -- ���� tag �� ���������, ������� ������� �������
                msg("�� �������� ������ � �������.\n��� ��� ����� " .. tostring(tInstr[i][2]) .. "\n������ ����������� " .. tostring(tInstr[i][1]) .. "\n���������")
                OnStop()
                return -- ��� ��� ���������� ����� �� ������� �������, � �� � �����.
            end
                    
            pse(SlTime)

            --[[
                msg(Classcode)
                msg(tInstr[i][1])
                msg(tInstr[i][3])
                msg (ds[i])
                msg("i = " .. i)
            --]]

            Expansion(Classcode, tInstr[i][2], ds[i], dimPat)
        end

        if (IsWindowClosed(t_id)) then OnStop() 
        end
    end
end

function Expansion(classcode, tinstr, size, cbars)
    -- classcode - ���� �� ������������. �� ������� - ��� ����������� ������
    -- tinstr - ����� �������
    -- size - ���������� ���������� ������
    -- cbars - ����������� ������ ��� ������
    --- 

    local t = nil 		-- �������, ���������� ������������� ������, 
    local l = nil 		-- ������� �������
    
    t, _, l = getCandlesByIndex(tinstr, 0, size - cbars, cbars)
    	-- msg("n = " .. n)
    -- size - cbars - � ����� � �������� �������� (�����-�������),
    -- cbars - ���������� ������, ������� ���������� �� ��������
    
    -- t, n, l = ....
    -- t � �������, ���������� ������������� ������,
    -- n � ���������� ������ � ������� t,
    -- l � ������� (�������) �������.
	
	local m = getLinesCount(tinstr)		-- �������� ���������� ����� � �������
    if m ~= 1 then
        msg("���������� ����� �� ������� = " .. l .. " (" .. tinstr ..")" .. " ���� <> 1")
        OnStop()
        return
    end

        -- msg ("size - cbars " .. size .. "/" .. cbars)
        -- for i, _ in pairs(t) do
        --     msg(t[i].high .. " = t[i].high, i = " .. i)
        -- end

    local n = getNumCandles(tinstr)
	 	-- msg("n = " .. n .. " / Size = ".. size) -- ��� ��������

    if n > size then -- ��� ����� �������� �� ��������� ���������� ������
        -- ���� ���������� ������ �����������, �� ������ �� �������
        local x = 1
        for i = cbars - 1, 0, -1 do 		-- ������ �� 0 �� 2. 3 ��� (����� -> �������) = 1 ���� (������ -> ������)
            Bars.O[x] = t[i].open 			-- �������� �������� Open ��� ��������� ����� (���� �������� �����)
                -- msg("test t[i].open " .. t[i].open)
                -- msg("test Bars.O[i] " .. Bars.O[x] .. " x = " .. x)

            Bars.H[x] = t[i].high 			-- �������� �������� High ��� ��������� ����� (���������� ���� �����)
            Bars.L[x] = t[i].low 			-- �������� �������� Low ��� ��������� ����� (���������� ���� �����)
            Bars.C[x] = t[i].close 			-- �������� �������� Close ��� ��������� ����� (���� �������� �����)
            Bars.V[x] = t[i].volume 		-- �������� �������� Volume ��� ��������� ����� (����� ������ � �����)
            Bars.T[x] = t[i].datetime 		-- �������� �������� datetime ��� ��������� �����
            								-- ��� i - ������ ����� �� 0 �� n-1
            x = x + 1
        end
        x = x - 1 -- ������� � �������� up �������
	        --[[
	            for k = 1, #Bars.O do -- ��� ��������
	                msg("k = " .. k .. " #Bars = " .. #Bars.H)
	                msg("Bars.O[i] " .. k .. "/" .. tostring(Bars.O[k]))
	                msg("Bars.H[i] " .. k .. "/"  .. tostring(Bars.H[k]))
	                msg("Bars.L[i] " .. k .. "/"  .. tostring(Bars.L[k]))
	                msg("Bars.C[i] " .. k .. "/"  .. tostring(Bars.C[k]))
	            end
	        --]]

        local sTime = tostring(os.time(Bars.T[1])) -- ���� ��� tostring
        local datetime = os.date("!*t", sTime)

        sTime = StrText(datetime.hour + CorrTime) .. StrText(datetime.min) .. StrText(datetime.sec) -- ���������� ����� � ���� HHMMSS
        local date = StrText(datetime.year) .. StrText(datetime.month) .. StrText(datetime.day) -- ���������� ���� � ���� YYYYMMDD

        -- ��� ������� �������� � �������
        local tableTime = StrText(datetime.hour + CorrTime) .. ":" .. StrText(datetime.min) .. ":" .. StrText(datetime.sec) -- ���������� ����� � ���� HH:MM:SS
        local tableDate = StrText(datetime.year) .. "-" .. StrText(datetime.month) .. "-" .. StrText(datetime.day) -- ���������� ���� � ���� YYYY-MM-DD
        
            --[[ -- ����������� ������
                -- msg("sTime " .. sTime)
                -- msg("date " .. date)

                -- for i, _ in pairs(tinstr) do
                --     msg(Bars.O[i] .." ++++ " .. i) -- ��� ��������, �� �������, ����� ����� ��������� �����
                -- end
            --]]

        local res1, res2, res3 = Pattern(Bars, Mfunc) --res1 - ������ �������, res2 - nil, res3 - nil �� ��������
        if res1 ~= nil then
            --local lab_id = insLabel(tinstr, res1, res2, date, sTime, Bars.O[x]) -- lab_id - ������������� ����� �� �������, ��� �������� � �������
               -- msg("tInstr " .. res1) -- todo
           
            local lab_id = insLabel(tinstr, res1, res2, date, sTime, Bars.O[1]) -- lab_id - ������������� ����� �� �������, ��� �������� � �������
            -- https://forum.quik.ru/forum10/topic118/

            local nstr = PutIn(t_id, tinstr, getTimeFrame(Bars), res1, tableDate, tableTime, "������", lab_id, res2)
            lightAllTable(t_id, res2, tonumber(nstr))
            --msg("������� ������: " .. res1 .. ".\n������: " .. tinstr)
            WriteToFile(nFile, t_id)
        end
    end
end

-- dopfunc.lua --

function msg(txt) -- ���������
-- �-��� ������ ���������
-- ������ ���������� � ������, ��������� ��������� � ������������� '!'
---
    message(tostring(txt), 2)
end

function pse(tMin) -- ����� � �������
-- �-��� ���������
-- ������ ���������� � ����� (�� ������ ������)
---
    sleep(round(tonumber(tMin) * 1000 * 60), 0)
    --msg("-- " .. round(tonumber(tMin) * 1000 * 60), 0)
end

function Gsize(m)
-- ��������� ����������� ������� m
-- �� ���� - ������, �� ������ number ���������� ���������
---
    local count = 0
    for _, _ in pairs(m) do
        count = count + 1
    end
    return count
end

function round(number, znaq) -- ������� ���������� ����� num �� ������ znaq
local num = tonumber(number)
local idp = tonumber(znaq)

    if num then
        local mult = 10 ^ (idp or 0)
        if num >= 0 then return math.floor(num * mult + 0.5) / mult
        else return math.ceil(num * mult - 0.5) / mult
        end
    else return num
    end
end

function insLabel (idnt, lText, sgl, lDate, lTime, y) -- �-��� ��������� ����� �� �������
-- idnt ������������� �������
-- lText - ����� �����
-- sgl - ������ �����, ����. ����� ���� �������, ���� �������.
-- lDate - ���� � ������� YYYYMMDD (string)
-- lTime - ����� � ������� HHMMSS (string)
-- y - ������ ����� �� ������ ����
---

local signal = tonumber(sgl)

local lParams = {}
    lParams.DATE = tostring(lDate)
    lParams.TIME = tostring(lTime)

    lParams.YVALUE = tostring(y)
    lParams.ALIGNMENT = RIGHT -- LEFT -- LEFT, RIGHT, TOP, BOTTOM
    lParams.FONT_FACE_NAME = "Arial"
    lParams.FONT_HEIGHT = 9
    
    if signal > 0 then -- ���� ������ ������ 0, ����� long
        lParams.R = 0
        lParams.G = 125
        lParams.B = 255
    else
        lParams.R = 255 -- ���� ������ ������ 0, ����� short
        lParams.G = 0
        lParams.B = 0
    end


    lParams.TRANSPARENCY = 10
    lParams.TRANSPARENT_BACKGROUND = 1 -- ������������ ����. �0� � ���������, �1� � ��������

    lParams.TEXT = tostring(lText)
    --lParams.HINT = "��� ����������� ���������"

    local lab_id = AddLabel(idnt, lParams)
    return lab_id

    --[[
        https://luaq.ru/GetLabelParams.html

        BOOLEAN DelLabel(STRING chart_tag, NUMBER label_id)
        BOOLEAN DelAllLabels(STRING chart_tag)
        BOOLEAN SetLabelParams(STRING chart_tag, NUMBER label_id, TABLE label_params)

        ������� ��������� �������� ��������� �����. ������� ���������� ������� � ����������� �����.
        � ������ ����������� ���������� ������� ���������� �nil�.
        ������������ ���������� ����� � ������������? ������� ������� � ������ ��������, � ��� �������� ����� ��� � STRING.
            TABLE GetLabelParams(STRING chart_tag, NUMBER label_id)
                chart_tag � ��� �������, � �������� ������������� �����;
                label_id � ������������� �����.

        https://www.tutorialspoint.com/lua/lua_environment.htm
    --]]

end

function CreateTable() -- ������� �������� ������� � ������������

    t_id = AllocTable()
    -- ��������� �������
    AddColumn(t_id, 0, "����������", true, QTABLE_STRING_TYPE, 17)
    AddColumn(t_id, 1, "��������, ���.", true, QTABLE_STRING_TYPE, 17)
    AddColumn(t_id, 2, "������", true, QTABLE_STRING_TYPE, 17)
    AddColumn(t_id, 3, "����", true, QTABLE_STRING_TYPE, 15)
    AddColumn(t_id, 4, "�����", true, QTABLE_STRING_TYPE, 15)
    AddColumn(t_id, 5, "����./����.", true, QTABLE_STRING_TYPE, 17)
    AddColumn(t_id, 6, "����� �����", true, QTABLE_STRING_TYPE, 0)  -- ������ ��������� ������� �������
    AddColumn(t_id, 7, "UpDown", true, QTABLE_STRING_TYPE, 0)       -- ������ ��������� ������� �������
   
   -- �������
    CreateWindow(t_id)
    
    -- ���� ���������
    local n = Gsize(Mfunc)
    SetWindowCaption(t_id, "������� VSA 1.5 (" .. tostring(n) .. EndOfWord(n, " �������") .. ")" )
    
    -- ������������ ���� �������
    SetWindowPos(t_id, 0, 0, 650, 320) --x, y, dx, dy

    -- ��������� ������
    -- InsertRow(t_id, -1)
end

function EndOfWord(n, txt)
-- �-��� ��������� ��������� �����
-- ������ EndOfWord(4, "������") -> '4 �������'
-- n - �����, number
-- txt - �����, �������� ����� �������� ���������, string
---

local en1 = ""
local en2 = "�"
local en3 = "��"

    if n == 1 then return txt .. en1
    elseif (n >= 2 and n <= 4) then return txt .. en2
    elseif (n == 0 or n >= 5 and n <= 20) then return txt .. en3
    end 

    if (n > 20 and n <= 100) then
        local z = n % 10
        if (z == 0 or z >= 5 and z <= 9) then return txt .. en3
        elseif (z == 1) then return txt
        elseif (z >= 2 and z <= 4) then return txt .. en2
        else return txt
        end
    end
end

function PutIn(t_id, tinstr, inter, signal, date, time, comment, lab_id, updown) -- �-��� ���������� �������
    -- �-��� ���������� �������
    -- ������������� �������
    -- ����������
    -- ��������
    -- ������
    -- ����
    -- �����
    -- �����������
    -- ������������� ����� - lab_id (��� �������� ������� � �������). ������ ���� number. �������� ��� ��������
    ---
    
    InsertRow(t_id, -1)
    local rows, _ = GetTableSize(t_id)
    -- _ - cols - ���������� �������
    
    SetCell(t_id, rows, 0, tostring(tinstr))	-- ��� ������� (�����������)
    SetCell(t_id, rows, 1, tostring(inter)) 	-- ����������
    SetCell(t_id, rows, 2, tostring(signal)) 	-- ��� �������
    SetCell(t_id, rows, 3, tostring(date))		-- ���� �������
    SetCell(t_id, rows, 4, tostring(time))		-- ����� �������
    SetCell(t_id, rows, 5, tostring(comment))	-- �����������
    SetCell(t_id, rows, 6, tostring(lab_id))	-- ����� ������� (��� �������� � ������� �� ������ ����)
    SetCell(t_id, rows, 7, tostring(updown))    -- ����������� (�����, ����) ��� ��������� ������� ��� �������� �� �����
    
    return rows -- ���������� ����� ���� ��� ��� ����������� ��������� � �������

end

function getTimeFrame(m) -- �������� ��������� �� ������� ����� �������
-- �� ���� ������ ������
-- �� ���� �������� ��� ���� ������
-- ������ �� � ���������
-- ���������� ��������
---
    local sTime = tostring(os.time(m.T[1]))
    local datetime = os.date("!*t", sTime)
    local time1 = StrText(datetime.hour) .. ":" .. StrText(datetime.min) .. ":" .. StrText(datetime.sec) -- ���������� ����� � ���� HH:MM:SS

    sTime = tostring(os.time(m.T[2]))
    datetime = os.date("!*t", sTime)
    local time2 = StrText(datetime.hour) .. ":" .. StrText(datetime.min) .. ":" .. StrText(datetime.sec) -- ���������� ����� � ���� HH:MM:SS

    return string.format("%u", diffTime(time2, time1)) -- ���������� ������ ����� ��� '.0'
end

function f_cb(t_id, msge, x, y)
-- ������� ��������� ������� ������� (����������)
-- SetTableNotificationCallback(t_id, f_cb) ���� � onInit, ���� � main (�� � ����)
---
    if (msge == QTABLE_LBUTTONDBLCLK) then

        -- if (y == 0 and x ~= 0) then  -- ������� �� 1�� �������
        if (x ~= 0) then                -- � ����� ����� ������ (�� ������ � 1�� �������)
                -- msg("x = " .. tostring(x)) -- ��� �������� ������ � �������
             local lab_id = GetCell(t_id, x, 6).image -- 6 ������� - ������ ������� 0, ������������� ����� (�� ��� ������, ��� �������� � �������)
                --msg("lab_id " .. tostring(lab_id))
             
             local ident = GetCell(t_id, x, 0).image -- 0 - ����� ������� �����������
                --msg("ident " .. tostring(ident))
             
             DelLabel(ident, tonumber(lab_id)) -- ������� �� ������ ������, �� � ����� �� �������
             DeleteRow(t_id, x) -- ������� ��� �� �������
             msg("������ ������")
             WriteToFile(nFile, t_id)
             -- lab_id, ident = nil, nil
        end

        if (x == 0 and y == 5) then -- ���� ������� ���� �� ������ ������, ��������� �������
            WriteToFile(nFile, t_id)
            msg("���� �������� �\n" .. nFile)
        end

        if (x == 0 and y == 0) then -- ���� ������� ���� �� ������ ������, ������ �������
			--LoadInTable(nFile, t_id)
        end

        if (x == 0 and y == -1) then -- ���� ������� ���� �� ������ ������, ������� ������� 
            local rows, _ = GetTableSize(t_id) -- ����� ������ � 1 �� x, ����� ������� � 0 �� n-1
            
            for i = rows, 1, -1 do
                local lab_id = GetCell(t_id, i, 6).image -- 6 ������� - ������ ������� 0, ������������� ����� (�� ��� ������, ��� �������� � �������)
                local ident = GetCell(t_id, i, 0).image -- 0 - ����� ������� �����������
                DelLabel(ident, tonumber(lab_id)) -- ������� �� ������ ������, �� � ����� �� �������
                DeleteRow(t_id, i) -- ������� ��� �� �������
            end
        end

        -- if  (msge == QTABLE_CHAR)  and  (y == 19)  then   
        --     msg("��������� � CSV ���� ������� ��������� ������� ����� ������ ���������� ������ Ctrl+S")
        --     --CSV(tbl)
        -- end
       
        -- if  (x == 0 and y == 1)  then   
        -- ������� �� ����� ������
        -- ������� �� ������ ������
        -- takeprofit �� ������� ������?

        -- end


        -- if  (msge == QTABLE_CLOSE)  then   --�������� ����?
        --     OnStop()
        -- end

    end
    
    if (msge == QTABLE_CLOSE)  then   --�������� ����. ���� � ���������� � ��������. ���� �� �����?
        OnStop()
        -- https://luaq.ru/SetTableNotificationCallback.html
    end

    -- if (msge == QTABLE_LBUTTONDOWN) then -- ��������� ���� ����� ������
    --     if (x ~= 0 and y == 1) then -- ���� ������� ���� �� �� ������ ������, �� �� ������ �������
    --         msg("������ ����� ������ ����\n") --todo
    --     end
    -- end

    -- if (msge == QTABLE_RBUTTONDOWN) then -- ��������� ���� ������ ������
    --     if (x ~= 0 and y == 1) then -- ���� ������� ���� �� �� ������ ������, �� �� ������ �������
    --         msg("������ ������ ������ ����\n") --todo
    --     end
    -- end


end
    --[[

    -------------------------------�������------------------------------------------------------------------
    function   f_cb (t_id,msg,par1,par2)  --������� �� ������� ������
        if  (msg == QTABLE_CHAR)  and  (par2 =  =  19 )  then   --��������� � CSV ���� ������� ��������� ������� ����� ������ ���������� ������ Ctrl+S
        CSV(tbl)
        end

        if  (msg == QTABLE_CLOSE)  then   --�������� ����
        Stop()
        end

        if  (msg == QTABLE_VKEY)  and  (par2 =  =  116 )  then   --������� ��������������� ���������� ������� ��� ������� ������� Ctrl+F5
        for  SecCode  in   string.gmatch (SecList,  "([^,]+)" )  do   --���������� ������� �� �������.
            Calculate(Sec2row[SecCode], true )
            Highlight (tbl.t_id, Sec2row[SecCode], QTABLE_NO_INDEX,  RGB ( 255 , 0 , 0 ), QTABLE_DEFAULT_COLOR, INTERVAL)
        end

        end
    end

    --]]


function LoadInTable(nFile, t_id)
-- �������� � ������� �� ����� �������
---
    local n
    local v = {}

	v = LoadFromFile(nFile)
	if  v == nil then return end

	for i = 2, #v, 1 do -- ������ ������ ����������
        local str = {}
        for s in string.gmatch(v[i], "[^;]+") do
            str[#str + 1] = s
                -- msg("S (" .. tostring(#str)  .. ") = ".. s) -- todo  
        end

        -- if str[6] ~= nil then
            local nstr = PutIn(t_id, str[1], str[2], str[3], str[4], str[5], str[6], str[7], str[8])
            lightAllTable(t_id, str[8], tonumber(nstr))
        -- else
        --     local nstr = PutIn(t_id, str[1], str[2], str[3], str[4], str[5], "", str[7], str[8])
        --         msg("Nstr " .. nstr) -- todo
            
            -- lightAllTable(t_id, str[7], tonumber(nstr))
        -- end
	end
end

function LoadFromFile(nfile)
-- ��������� ������ �� �����
-- ����� � ������ varr ���� string �� �������
-- varr[i ... n] = ������ �� ����� i ... n 
---

local filedata, line
local varr = {}

    filedata = io.open(nfile, "r")
    
    if filedata then
        for line in filedata:lines() do 
            varr[#varr + 1] = line
            -- for s in string.gmatch(v, "[^;]+") do
            --         msg("Str " .. s) -- todo
            -- end
        end
        filedata:close()
        -- for k, v in pairs(varr) do
        --         msg("to print" .. tostring(k) .. " / " .. tostring(v)) -- todo
        -- end            
        return varr      
    else
        -- error('file not found')
        msg("�� ���� ������� ����:\n" .. nfile)
        return nil
    end
end
    
function WriteToFile(nfile, t_id) 
-- �-��� ������ ������� t_id � ���� nfile
-- ���� ����� ��� - ������, 
-- ���� ���� ���� - ���������� � �����
---
    
    local CSV = io.open(nfile, "w") -- "a+"
    local position = CSV:seek("end", 0)
    local txt = "" --��� ������ � ����
    
    if position == 0 then -- ��������� ������ ������� �����
        local header = "����������;����������;������;����;�����;�����������;�����(�� �������);UpDown(�� �������);\n"
        CSV:write(header)
        CSV:flush()
        position = CSV:seek("end", 0)
    end

    local rows, col = GetTableSize(t_id) -- ����� ������ � 1 �� x, ����� ������� � 0 �� n-1
        -- msg("rows, col " .. tostring(rows) .. "/" .. tostring(col)) -- todo
    
    
    if rows ~= 0 then
        for i = 1, rows do -- ����� ����� � "1"
            for j = 0, col - 1 do -- ����� ������� � "0" �� n - 1
                txt = txt .. tostring(GetCell(t_id, i, j).image) .. ";" -- .image - ��� ��������� ��������, .value - ��� number
            end            
            txt = txt .. "\n"
            CSV:write(txt)
            txt = "" -- �������� ������, ����� ��������� ��� � ����
        end
        -- ��������� ��������� � �����
        CSV:flush()
    end 
    -- ��������� ����
    CSV:close()    

    -- else
    --  --message("������ �������� ����� ")
    -- end
end

function Pattern(m, mfunc) -- ������ ������� � �������� ������ ������
-- �� ���� �������� ������ m, mfunc = {LP1, SPA1, .. , PPR} - ������ ������� �������.
-- m.O = {1, 2, .. , cBars} -- ���� Open
-- m.H = {1, 2, .. , cBars} -- ���� High
-- m.[..] = {1, 2, .. , cBars} -- � �.�. (O, H, L, C, V, T)
-- ������������ ��� � ������������ � ����������, ���������� ������ ��� �������, ��� ������ �� ������
---

    for key, _ in pairs(mfunc) do
        local res1, res2, res3 = mfunc[key](m)
        if  res1 ~= nil then
            do return res1, res2, res3 end  -- ��������� ������������
            break                           -- ��������� ������������
        end
    end
end

function StrText(int) 
-- ��������� "0" � ������, ���� ����� 1 < x < 10
-- ���������� 01, 02, .. , 09. �������� ���� string
---
    local m = tostring(int)
    local mLen = string.len(int)

    if mLen == 1 then output = "0" .. tostring(m)
    else output = m
    end

    return output
end

function comma(what) -- ������  '.' �� ','
    -- ������� ������ '.' �� ',' � what � ���������� ��������� ��������
    -- ������������ � csv ��� ��������� ����������� ����� (������ 50.50 -> 50,50)
    ---
    local xstr = string.gsub(tostring(what), "%.", ",")
    return tostring(xstr)
end


function diffTime(time1, time2)
-- ���������� ������� � ������� ����� time2-time1; ���� 0, ���� time1 > time2
-- time1 = "14:00:00"
-- time2 = "14:05:00"
-- result = diffTime(time1, time2) -- = 300 ������
---

local dt1 = {}
local dt2 = {}
local dTime1 = 0
local dTime2 = 0
local result = 0

    dt1.hour, dt1.min, dt1.sec = string.match(time1,"(%d*):(%d*):(%d*)")
    for key, value in pairs(dt1) do
        dt1[key] = tonumber(value)
    end

    dt2.hour, dt2.min, dt2.sec = string.match(time2,"(%d*):(%d*):(%d*)")
    for key, value in pairs(dt2) do
        dt2[key] = tonumber(value)
    end

    --����*3600 + ������*60 + �������.
    dTime1 = dt1.hour * 3600 + dt1.min * 60 + dt1.sec
    dTime2 = dt2.hour * 3600 + dt2.min * 60 + dt2.sec
    result = (dTime2 - dTime1)

    if result <= 0 then
        return 0
    else
        return result / 60
    end
end

function lightAllTable(t_id, sgl, x) -- ��������� ������ ������
	-- ��������� ������ �������
	-- ��������� ������ (���� signal ������ ���� = �������, ���� ������ = �������) �������� string, ������������� � number
	-- t_id ������������� ������������ �������
	-- x - ����� ���������� ������ number
	---
    local signal = 0
    if sgl ~= nil and sgl ~= "nil" then 
        signal = tonumber(sgl)
    end
    if x == nil or x == "nil" then x = 1 end
    
	if signal < 0 then SetColor(t_id, x, QTABLE_NO_INDEX, RGB(255, 193, 193), QTABLE_DEFAULT_COLOR, RGB(255, 193, 193), QTABLE_DEFAULT_COLOR)
	elseif signal > 0 then SetColor(t_id, x, QTABLE_NO_INDEX, RGB(193, 255, 193), QTABLE_DEFAULT_COLOR, RGB(193, 255, 193), QTABLE_DEFAULT_COLOR)
	elseif signal == 0 then 
        SetColor(t_id, x, QTABLE_NO_INDEX, RGB(220, 220, 220), QTABLE_DEFAULT_COLOR, RGB(220, 220, 220), QTABLE_DEFAULT_COLOR)
    end
end


--[[

https://quik2dde.ru/viewtopic.php?id=149


    ���� ������- � ����� �� ����� LUA ������ ������ ���� ��� �������� ����� ������� �� ������� ����������� � ����. � "�����������" ���� ����.
    �������� ���� �� �������� � Excel ��� ���� ������.
    �� ��� ������ ���� �� � txt ����.

    ���� � ����� ���� �� ������, ����� �� � ������ ���� ���� ������ ������ �������. �� �.� ����� ������ "���������", � ������ ����� ������ ������� ������� ������� ������� � � ��� ��������.
    ���� �� ���� ������ � ����� ������� ������� � ����� �������.
    ���� �� ��� �� Quik � LUA ������� �������� ������ ������� �����?

    2kalikazandr2015-04-29 18:16:12 (2015-04-29 18:26:25 ��������������� kalikazandr)
    Member
    ���������
    ���������������: 2014-09-10
    ���������: 371
    slkumax �����:
    ���� �� ��� �� Quik � LUA ������� �������� ������ ������� �����?

    local n = getNumCandles(ind)--���-�� ������, ��� ind = ������������� �������
    local t, res, _ = getCandlesByIndex (ind, 0, 0, n)--�������� ��� �����
    ��� ���:
    local t, res, _ = getCandlesByIndex (ind, 0, n - 500, 500)--�������� ��������� 500 ������ (��� �������)

    --t - ������� �� ��������, res - ����� �������, _ - ������� (�������) �������
    --t[0] - ������ �����
    --t[res-1] - ��������� �����
    ���� ��������� ����� ����:
    t[0] = nil,
    �� ������� ������� ������ Lua � �������� ������ � �������� ���� ����������, �� �� ����� �� �������� ))

    3slkumax2015-04-29 18:28:52
    Member
    ���������
    ���������������: 2013-06-13
    ���������: 68
    kalikazandr �����:
    slkumax �����:
    ���� �� ��� �� Quik � LUA ������� �������� ������ ������� �����?

    local n = getNumCandles(ind)--���-�� ������, ��� ind = ������������� �������
    local t, res, _ = getCandlesByIndex (ind, 0, 0, n)--�������� ��� �����
    ��� ���:
    local t, res, _ = getCandlesByIndex (ind, 0, n - 500, 500)--�������� ��������� 500 ������ (��� �������)

    --t - ������� �� ��������, res - ����� �������, _ - ������� (�������) �������
    --t[0] - ������ �����
    --t[res-1] - ��������� �����
    ���� ��������� ����� ����:
    t[0] = nil,
    �� ������� ������� ������ Lua � �������� ������ � �������� ���� ����������, �� �� ����� �� �������� ))


    � �� ������ ������ ���������� ��� ����� ��������:
    function BazToGrZap()
        Baz = CreateDataSource(CLASS, SEC, INTERVAL_M1)
        Raz=Baz:Size()
        for is=1, Raz do
        Open=Baz:O(is)
        Hight=Baz:H(is)
        Close=Baz:C(is)
        Low=Baz:L(is)
        Day=Baz:T(is).day
        Month=Baz:T(is).month
        Year=Baz:T(is).year
        DateTime=
        gridBaza:SetCell(2,is,SEC)
        gridBaza:SetCell(3,is,Open)
        gridBaza:SetCell(4,is,Hight)
        gridBaza:SetCell(5,is,Low)
        gridBaza:SetCell(6,is,Close)
        gridBaza:SetCell(0,is,Day)
        end   


    � ���� �� ������� ��� "����������� ���, �����, ����  � ����, ������ � �������, ����� ����������� �� � ���� �������� �������.

    4kalikazandr2015-04-29 18:49:45 (2015-04-29 18:52:35 ��������������� kalikazandr)
    Member
    ���������
    ���������������: 2014-09-10
    ���������: 371
    slkumax �����:
    � ���� �� ������� ��� "����������� ���, �����, ����  � ����, ������ � �������, ����� ����������� �� � ���� �������� �������.

    local FTEXT = function (V)
        V=tostring (V)
        if string.len (V) == 1 then V = "0".. V end
        return V 
    end

    local bar = t[1]
    local datetime = bar.datetime
    local DATE = (datetime.year .. FTEXT (datetime.month) .. FTEXT (datetime.day)) + 0 --����� (��������)
    local DATE = datetime.year .. "." .. FTEXT (datetime.month) .. "." ..  FTEXT (datetime.day) --������ (����.��.��)
    local TIME = (datetime.hour .. FTEXT (datetime.min) .. FTEXT (datetime.sec)) + 0 --����� HHMMSS
    local TIME = datetime.hour .. ":" .. FTEXT (datetime.min) .. ":" .. FTEXT (datetime.sec) --������ HH:MM:SS

    � ����� ������� ����������, FTEXT � ���� ���������, ��������� ���� ����� � �� ��������������

    ��������� ����� ������, ��� ������� ����� ����� ����������� � ���� ������ ����� ������. ��� ���� � ����� ��������.

    ���.
    � �����? ���� �� ����, �������� ��� ������������ ��� �������, ��������� ������������� (���� ����� ������, ���� ����� ������������ � ������ ���� ������)
    � ���-�� ����� �����:

    local table_remove, string_len = table.remove, string.len
    local FTEXT = function (V)
        V=tostring (V)
        if string_len (V) == 1 then V = "0".. V end
        return V  
    end
    ---------------------------------------
    local path = getScriptPath ()
    s_list = {SBER,GAZP,GMKN}
    ind_list = {SBER = ind1, GAZP = ind2, GMKN = ind3}
    ---------------------------------------
    local findStartDayBar =  function (ind)
      local t, res, _ = getCandlesByIndex (ind, 0, getNumCandles(ind) - 500, 500)--500 ������ ����������
      t[0] = nil--����� ������ �� t
      local tt = t
      for i = 1, #tt do
        local bar = tt[i]
        local datetime = bar.datetime
        if datetime.hour + 0 = 10 then break end
        table_remove (t,i)--������ ����� ���������� ���
      end
      return t--��������� � 100000 -��� ����� � �������� �������
    end

    for i = 1, #s_list do
      local sec = s_list[i]
      local ind = ind_list[sec]
      local tab = findStartDayBar (ind)
      local file = path.."\\" .. sec .. ".CSV"
      local f = io.open(file, "a+")--� ������ �� ������
      for j = 1, #tab do
        local bar = tab[j]
        local datetime = bar.datetime
        local DATE = datetime.year .. FTEXT (datetime.month) .. FTEXT (datetime.day)
        local TIME = datetime.hour .. FTEXT (datetime.min) .. "00" --������� - ������� �� �����������?
        local wr = DATE .. ";" .. TIME .. ";" .. bar.open .. ";" .. bar.high .. ";" .. bar.low .. ";" .. bar.close
        f:write(wr)
      end
      f:flush()
    end
    f:close()
    do message("������ ���������",2) end
    �� ��������, ����� ����� ���, �� ������ �������� ����� ��������� � ����� ���, ����� �������� ������ ���� �������� ������. � ������ ����������� ����� � ������� ����� ��������� "�����".
    ��, � �������� �������������� ������� ������ ������������ sec_code �����������:
    SBER -������� ������;
    SBERm1 - ����������
    ����� ind = sec .. "m1"

    ���� �� ��� �� Quik � LUA ������� �������� ������ ������� �����?

    local n = getNumCandles(ind)--���-�� ������, ��� ind = ������������� �������
    local t, res, _ = getCandlesByIndex (ind, 0, 0, n)--�������� ��� �����
    ��� ���:
    local t, res, _ = getCandlesByIndex (ind, 0, n - 500, 500)--�������� ��������� 500 ������ (��� �������)

    --t - ������� �� ��������, res - ����� �������, _ - ������� (�������) �������
    --t[0] - ������ �����
    --t[res-1] - ��������� �����
    ���� ��������� ����� ����:
    t[0] = nil,
    �� ������� ������� ������ Lua � �������� ������ � �������� ���� ����������, �� �� ����� �� �������� ))


    � ����� ������ � ���� �������? �.� ��� ���������� �������� � High �����?

    � ��� ���� ���������� ))
    local bar = t[20]--20 ����� � ������� �� �����,
    key = datetime, open, high, low, close, volume
    local high = bar.high
--]]
