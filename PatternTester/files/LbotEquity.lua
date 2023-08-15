-- 09.05.2019 LbotEquity
--https://youtu.be/jimZAxP_qdM
-- 29.09.2015
local table_insert = table.insert
local string_len = string.len
local io_open = io.open
local Quontity = {}
local MyTrade = {}    -- таблица позиций
local iPrice = 0      -- индекс таблицы позиций
local equity = 0   -- прибыль
local Last_index = 0   -- стартовый номер свечи
local e	-- Equity
local ifFirst = false	-- появились ли сделки?
local sec_code = ""

local function insert_leading_zero(value)
  if string_len(value) == 1 then
    value = "0" .. value
  end
  return value
end

local function dTs1(tbl) 
  local t = tbl.year .. insert_leading_zero(tbl.month) .. insert_leading_zero(tbl.day) .. insert_leading_zero(tbl.hour) .. insert_leading_zero(tbl.min) .. insert_leading_zero(tbl.sec)
  return t
end

local WFpath = getWorkingFolder()

Settings = 
{
	TradesFile = "LbotTest\\log\\LbotTest.csv",
	Name = "LbotEquity",
	line=
	{
		{Name = "Equity", Color = RGB(0, 128, 0), Type = 1, Width = 2},
	}
}

function Init()
	local name = WFpath..'\\LbotEquity.set'	-- set-файл в рабочий каталог QUIK
	local Fname = ""
	local f=io_open(name,"r")
	if f~=nil then
		for line in f:lines() do
			Settings.TradesFile = line
			Fname = ", set-файл: "..line
			--message('Файл для чтения задан в set-файле: '..line)
		end
		io.close(f) 
	end
	message("LbotEquity, ver.1.2 © lbot4quik@gmail.com, 29.05.2019"..Fname , 1)
	return 1
end

function string.ltrim(s)
  s = s:gsub("^" .. "%s+", "")
  return s
end

local function file_Exists(name)
	local f=io_open(name,"r")
	if f~=nil then io.close(f) return true else return false end
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
        local d, M, y, h, m, s, oper, qty, price, r = line:match("(%d+).(%d+).(%d+);%s*(%d+):(%d+);%s*(%w+);%s*(%w+);%s*(%d+);%s*(%d+.?%d+);%s*(%w+)")
		if (s == sec_code) and (oper == 'B' or oper == 'S')  then
			j = j + 1
			d = insert_leading_zero(d)
			M = insert_leading_zero(M)
			h = insert_leading_zero(h)
			m = insert_leading_zero(m)
			s = insert_leading_zero(s)
			local dt = tostring(y)..M..d..h..m..'00'
			csvFile[#csvFile+ 1] = { dt=dt, oper=oper, qty=qty, price=price, r = r}
		end
        
    end
    file:close()
	if #csvFile==0 then
		message('LbotEquity, '..sec_code..': нет данных, работа приостановлена!')
	end
    return csvFile
end

local function Equity(index)
	local dti = dTs1(T(index))	-- дата свечи
	local ifFound = false
	local delta = 0
	Quontity[index]=Quontity[index-1]
	if not data then
		return
	end
	local _d = #data
	if _d==0 then
		return
	end
	-- пока не пошли первые сделки, свечи просто пропускаем! - 29.05.2019
	if firstSdel > dti then
		Quontity[index] = 0
		equity = 0
		return nil
	end
	-- data получается из readCSV(csvF, ";") из OnCalculate(index) при index == 1
	for key, v in pairs(data) do
		--log("index = "..index..", "..type(data[key].dt)..", dti = "..type(dti))
		if data[key].dt == dti then
			ifFound = true
			local qty = data[key].qty
			local oper = data[key].oper
			local price = data[key].price
			if oper == 'B' then
				Quontity[index] = Quontity[index-1] + qty;
			elseif oper == 'S' then
				Quontity[index] = Quontity[index-1] - qty;
			end
			ifFirst = true
			local thisTrade={}
			thisTrade.price = price
			thisTrade.qty = Quontity[index]
			table_insert(MyTrade,thisTrade)	-- текущий вход в позицию
			iPrice=iPrice+1
			delta = price - MyTrade[iPrice-1].price	-- предыдущий вход в позицию
			equity = equity + MyTrade[iPrice-1].qty * delta
			data[key].dt = nil
		end
	end	
	if ifFound == false then
		if iPrice > 0 then
			if ifFirst == true then
				local delta = C(index) - MyTrade[iPrice].price	--	C(index-1)
				equity = equity + MyTrade[iPrice].qty * delta
				MyTrade[iPrice].price	= C(index)
			end
		end
	end
	return equity
end

function OnCalculate(index)
	if index == 1 then 
		--
		t=getDataSourceInfo()
		sec_code = t.sec_code
		--step = getSecurityInfo(t.class_code, t.sec_code).min_price_step	--NUMBER, Минимальный шаг цены
		--message(t.sec_code..", интервал="..t.interval..', step= '..step,1)
		Last_index = 1
		csvF = WFpath..'\\'..Settings.TradesFile
		--message('Файл '..csvF..' ищем')
		data = readCSV(csvF)
		if not data then
			--message('Файл '..csvF..' не найден, поищем '..Settings.TradesFile)
			csvF = Settings.TradesFile
			data = readCSV(csvF)
			if not data then
				message("Ошибка чтения файла "..csvF..'.\n Работа невозможна.')
				return
			end	
		end
		if data[1]==nil then
			return
		end
		local thisTrade={}
		thisTrade.price = C(index)	--С(index)
		thisTrade.qty = 0
		equity = 0   -- прибыль
		MyTrade = {}    -- таблица позиций
		table_insert(MyTrade,thisTrade)	-- текущий вход в позицию
		iPrice=1      -- начальный индекс таблицы позиций
		Quontity={}
		Quontity[0] = 0
		local dti = dTs1(T(index))	-- дата ПЕРВОЙ свечи
		firstSdel = data[1].dt
		if firstSdel > dti then
			Quontity[1] = 0
			return nil
		end
		e = Equity(index)
		return e
	else
		if index ~= Last_index then
			Last_index = index
			e = Equity(index)
			return e
		end
	end
end