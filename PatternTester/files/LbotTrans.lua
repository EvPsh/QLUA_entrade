-- 01.08.2015
-- Сделки с текстового файла на график
local string_len = string.len
local data = {}
local io_open = io.open
local function insert_leading_zero(value)
	if string_len(value) == 1 then
		value = "0" .. value
	end
	return value
end

local function dTs(tbl)
	local t = tbl.year ..
	insert_leading_zero(tbl.month) ..
	insert_leading_zero(tbl.day) ..
	insert_leading_zero(tbl.hour) .. insert_leading_zero(tbl.min) .. insert_leading_zero(tbl.sec)
	return t
end

local WFpath = getWorkingFolder()
Settings =
{
	TradesFile = "LbotTest\\log\\LbotTest.csv",
	Name = "LbotTrans",
	line =
	{
		{ Name = "buy",  Color = RGB(0, 0, 200), Type = TYPE_TRIANGLE_UP,   Width = 1 },
		{ Name = "sell", Color = RGB(0, 200, 0), Type = TYPE_TRIANGLE_DOWN, Width = 1 }
	}
}

function Init()
	local name = WFpath .. '\\LbotEquity.set' -- set-файл в рабочий каталог QUIK
	local Fname = ""
	local f = io_open(name, "r")
	if f ~= nil then
		for line in f:lines() do
			Settings.TradesFile = line
			Fname = ", set-файл: " .. line
			--message('Файл для чтения задан в set-файле: '..line)
		end
		io.close(f)
	end
	message("LbotTrans, ver.1.1 © lbot4quik@gmail.com, 29.05.2019" .. Fname, 1)
	return 2
end

local function file_Exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else return false end
end

local function readCSV(path)
	if not file_Exists(path) then
		--assert(false, "\nОшибка чтения "..path..'.\n Работа невозможна.')
		return nil
	end
	local csvFile = {}
	local file = assert(io_open(path, "r"))
	local j = 0
	for line in file:lines() do
		--26.08.2015 04:17; GAZP; buy; 1; 136.72; BAL
		local d, M, y, h, m, s, oper, qty, price, r = line:match(
		"(%d+).(%d+).(%d+);%s*(%d+):(%d+);%s*(%w+);%s*(%w+);%s*(%d+);%s*(%d+.?%d+);%s*(%w+)")
		if (s == sec_code) and (oper == 'B' or oper == 'S') then
			j = j + 1
			d = insert_leading_zero(d)
			M = insert_leading_zero(M)
			h = insert_leading_zero(h)
			m = insert_leading_zero(m)
			s = insert_leading_zero(s)
			local dt = tostring(y) .. M .. d .. h .. m .. '00'
			csvFile[#csvFile + 1] = { dt = dt, oper = oper, qty = qty, price = price, r = r }
		end
	end
	file:close()
	if #csvFile == 0 then
		message('LbotTrans, ' .. sec_code .. ': нет данных, работа приостановлена!')
	end
	return csvFile
end

local function Equity(index)
	local dti = dTs(T(index))
	local buy, sell
	if not data then
		return
	end
	local _d = #data
	if _d == 0 then
		return
	end
	for key, v in pairs(data) do
		if data[key].dt == dti then
			if data[key].oper == 'B' then
				buy = data[key].price
			elseif data[key].oper == 'S' then
				sell = data[key].price
			end
			data[key].dt = nil
		end
	end
	return buy, sell
end

function OnCalculate(index)
	if index == 1 then
		t = getDataSourceInfo()
		sec_code = t.sec_code
		csvF = WFpath .. '\\' .. Settings.TradesFile
		--message('Файл '..csvF..' ищем')
		data = readCSV(csvF)
		if not data then
			--message('Файл '..csvF..' не найден, поищем '..Settings.TradesFile)
			csvF = Settings.TradesFile
			data = readCSV(csvF)
			if not data then
				--assert(false, "\nОшибка чтения "..csvF..'.\n Работа невозможна.')
				message("Ошибка чтения файла " .. csvF .. '.\n Работа невозможна.')
				return
			end
		end
		if data[1] == nil then
			return
		end
	end
	if not data then return nil end
	local b, s = Equity(index)
	return b, s
end
