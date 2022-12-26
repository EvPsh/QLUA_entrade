-- "��� ��� �����"" �� ����� Lua ��� Quik
-- Telegram @JJ_FXE 
-- https://napodrabotku.ru/order/48741304?region=all
---

--[[
��������� ���������� ������ (���� == 1), �� �.1 - 7
���� ~= 1, �� �������� ������:
	- ���������� ������
	- ��������� ����� ��� �������� �������
	- ����� �� ���������� ������
	- �������� ������ ����� ��� ������� ����� = (90% * ���������_�����) / ��

1. �������� ������ �����������
	������� �����������:
		���������� (��� ��������)
		����������� (buy/sell)
		����� �������� �������
		����� ������������ ������� (90% �� ���������)
		��������� ��� (15 ��� �� ���������)
		������ ������ (�� ������� ����� ��������)
	
	�� quik ��������:
		���� ����� Ask ��� Bid
		��������� �������� � �������� ������ (������� ������������ �� ���������� ������
		�� �� ������� ������� ������

1.1 �������� ������ � �������� �� �����������
		���� ������� � ������ ����� ����  - ��������� ��������
		
		(� �������� ����� ��� ���� �������� ������� � ���������� ����� � ���������������, 
		��� ������ ��������� ��������� ������� �������� � �������� � ��������������� �������. 
		��������, ������� ������� � +15 ���������� (�������). 
		� 18:30 ������ ���� ������� �� 90% �� �������� (�������� ����� -15 ����������). 
		��� ��� ������ ������� �� 15, � 30 ���������� +15 � 30 = -15 + ��� ������� �� �������, � ��� ������� �� �������.

2. �������� ������ ������� (���� ask � bid)
3. �������� �������� ������� �� ask
	��������� ����������, ���� �� ������, ��:
4. ��� 15 ���
5. ��������� ���������� ���� ������, 
6. ���� ������ ����������� - ��, 
7. ���� �� �����������, �������� �������, ��������� �.2 - 7

--]]

--[[
local pairs = pairs
local type = type

module(...)

--- ������� ����� ������� (�������)
-- @return ����� ������� (�������)
function copy(array)
    local copy_array = {}
    if type(array) ~= "table" then
        return array
    end
    for k, v in pairs(array) do
        if type(v) == "table" then
            copy_array[k] = copy(v)
        else
            copy_array[k] = v
        end
    end
    return copy_array
end

--- ������, ���������� �� ���������� � ������� � ���� ��� � �������.
-- @return 0 ��� 1
function base(array)
    if array[0] ~= nil then
        return 0
    else
        return 1
    end
end

--- ��������� ����� ��������� � �������.
-- @return ����� ��������� � �������
function size(array)
    local n = 0
    for _, _ in pairs(array) do
        n = n + 1
    end
    return n
end

--- ��������� ������ ��� ��� ������.
-- @return true/false
function isEmpty(array)
    for _, _ in pairs(array) do
        return false
    end
    return true
end

--- �������� ������ ������ �������, ��� ������ �� ��������. ����� ���������� � 1.
-- @return ������ ������ �������, ��� ������ �� ��������
function firstEmptyIndex(array)
    local i = 1
    while array[i] ~= nil do
        i = i + 1
    end
    return i
end

--]]


nFile = ""              -- �������� ������������ ����� (�� ����� �����������)
scName = ""             -- �������� ������������ �������

function OnInit()
	    --�������������
    scName = string.match(debug.getinfo(1).short_src, "\\([^\\]+)%.lua$") -- ��������� ����� ����������� �������
    nFile = getScriptPath() .. "\\" .. scName .. ".csv"
end

function OnStop() -- �������� ��� ��������� �������
    -- if t_id ~= nil then
    --     DestroyTable(t_id)
    -- end
    is_run = false
end

function main()
    CreateTable() -- ������ �������
    SetTableNotificationCallback(t_id, f_cb) -- ��������� callback ���������

    while is_run do
        for i, _ in pairs(tInstr) do
            ds[i] = {}
            ds[i] = getNumCandles(tInstr[i][2])
            -- ���������� ����� DataSource

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
        end

        if (IsWindowClosed(t_id)) then OnStop()
        end
    end
end