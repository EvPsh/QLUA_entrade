-- Параметры ------------------------------------------------------------------------------------

SEC_CODE = "CRH3" 
CLASS_CODE = "SPBFUT"
ACCOUNT = "SPBFUT00479" 
CLIENT_CODE = "QLUA_EnterTP"

IdGraf = "NLAB"


----------------------- Настройки переменных ---------------------

Is_run = true

Tprofit = 5		-- Take Profit в шагах цены
P_offset = 2 		-- отступ от тэйк-профита, шагах цены
P_spread = 0		-- защитный спрэд в TP, в шагах цены
Lot = 0

function main()
	local price_step, _ = GetParameters(CLASS_CODE, SEC_CODE)
    
		msg("price_step = " .. tostring(price_step)) -- todo	
			msg("GetPosition " .. tostring(GetPosition(SEC_CODE))) -- todo
	
	local lastbar = getNumCandles(IdGraf)
	local t, n, l = getCandlesByIndex(IdGraf, 0, lastbar - 1, 1)
		-- for k, v in pairs(t[0]) do
		-- 	msg("k =  " .. tostring(k) .. " / v = " .. tostring(v)) -- todo
		-- end		

		local seccode = GetSeccode(l)


		msg("Graf " .. tostring(n) .. " / " .. tostring(l)) -- todo
		
	while Is_run do
		local price, Lot = getEntryPrice(SEC_CODE) -- GetLot(CLASS_CODE, SEC_CODE)
					-- msg("Lot = " .. tostring(Lot)) -- todo
					-- msg("price = " .. tostring(price)) -- todo

		if Lot < 0 then
			price = removeZero(tonumber(price - Tprofit * price_step))
			--NewStopProfit(ACCOUNT, CLASS_CODE, SEC_CODE, CLIENT_CODE, "B", -Lot, price, P_offset, P_spread)
							msg("Price to enter - = " .. tostring(price)) -- todo
		elseif Lot > 0 then
			price = removeZero(tonumber(price + Tprofit * price_step))
				-- msg("Price to enter + = " .. tostring(price)) -- todo
			--NewStopProfit(ACCOUNT, CLASS_CODE, SEC_CODE, CLIENT_CODE, "S", Lot, price, P_offset, P_spread)
		end
		sleep(3000)
	end
end

function OnStop()
	-- msg("Остановлен") -- todo
	Is_run = false
end

function GetSeccode(str)
-- Получаем sec_code по легенде графика
-- возвращаем string sec_code
--- 

str = "CNY-3.23"
local txt = "securities"
	local n = getNumberOf(txt)
		msg("n = " .. tostring(n)) -- todo
	

	local function fn( ... )
			-- body
	end

	for i = 0, n - 1 do
		local sec_code = getItem(txt, i)
			-- msg("sec_code " .. tostring(sec_code)) -- todo
				-- for k, v in pairs(sec_code) do
				-- 	message("K = " .. tostring(k) .." / v = ".. tostring(v)) -- todo
				-- end
					-- msg("sec " .. tostring(sec_code)) -- todo

				

		if sec_code.short_name == str then -- убрать в названии графика цены слово [price] с помощью gsub

				msg("!!!!sec = " .. tostring(sec_code.sec_code)) -- todo
					-- for k, v in pairs(sec_code) do
					-- 	message("K = " .. tostring(k) .." / v = ".. tostring(v)) -- todo
					-- end
					
			return sec_code.sec_code
		end
	end

	
end

function GetParameters(classcode, seccode) -- todo
    local price_step = removeZero(getParamEx(classcode, seccode, "SEC_PRICE_STEP").param_value)
    local openprice = nil
    -- получаем наличие инструмента в портфеле
    -- определяем цену входа
    -- определяем направление входа
    -- определяем количество лотов входа

    return price_step, openprice -- openprice - цена открытия сделки по инструменту
end

-- function OnTrade(trades)
-- 	if (trades.class_code == CLASS_CODE and trades.sec_code == SEC_CODE and trades.brokerref == CLIENT_CODE) then
-- 		Lot = trades.qty
-- 			msg("Lot = " .. tostring(Lot)) -- todo
-- 	end
-- end

function GetLot(classcode, seccode)
	for i = 0, getNumberOf("all_trades") - 1, 1 do
	   local data = {}
	   data = getItem("all_trades", i)
	   if data.class_code == classcode and data.sec_code == seccode then 
     		return tonumber(data.price), tonumber(data.qty)
	   end
	end
end

function NewStopProfit(account, classcode, seccode, comment, buySell, qty, price, prof_offset, prof_spread)
	-- функция установки стоп-проффит ордеров со спрэдом и отступом
	-- prof_offset - отступ
	-- prof_spread - защитный спрэд

	local trans_id = "123456"
	local transaction = {
		["ACCOUNT"] = account,
		["CLASSCODE"] = classcode,
		["SECCODE"] = seccode,
		["ACTION"] = "NEW_STOP_ORDER",
		["STOP_ORDER_KIND"] = "TAKE_PROFIT_STOP_ORDER",
		["TRANS_ID"] = trans_id,
		["CLIENT_CODE"] = comment, -- здесь указывается комментарий (CLIENT_CODE)
		["EXPIRY_DATE"] = "TODAY",
		["OPERATION"] = buySell,
		["QUANTITY"] = tostring(qty),
		["STOPPRICE"] = tostring(price),
		["OFFSET_UNITS"] = "PRICE_UNITS",
		["SPREAD_UNITS"] = "PRICE_UNITS",
		["OFFSET"] = tostring(prof_offset), -- отступ от цены
		["SPREAD"] = tostring(prof_spread) -- защитный спрэд
	}
	local result = sendTransaction(transaction)
end


--[[
function sOrder(instr, entryPrice, sl, tp)
	--
	-- отправка транзакции
	--

	if entryPrice="" then --send market order
	else
		--send limit entryPrice

	-- проверяем на срабатывание, если всё ок, то:
	inPosition=true

	if inPosition then
	-- выставляется связанный ордер, при срабатывании одной из цены (sl или tp), связанный ордер отменяется.
	-- проверка
	end
end

--]]

-- function round(number, znaq) -- функция округления числа num до знаков idp. округляет правильно
-- local num = tonumber(number)
-- local idp = tonumber(znaq)

-- 	if num then
-- 		local mult = 10 ^ (idp or 0)
-- 		if num >= 0 then return math.floor(num * mult + 0.5) / mult
-- 		else return math.ceil(num * mult - 0.5) / mult
-- 		end
-- 	else return num
-- 	end
-- end


-- function comma(what)
-- 	-- функция меняет '.' на ',' в what и возвращает текстовое значение
-- 	-- используется в csv для получения правильного числа (пример 50.50 -> 50,50)
-- 	---
-- 	local xstr = string.gsub(tostring(what), "%.", ",")
-- 	return tostring(xstr)
-- end


-- function RoundStep (num, nStep)
-- -- функция округления до шага цены
-- ---

-- 	if (nStep == nil or num == nil) then return nil
-- 	elseif (nStep == 0) then return num
-- 	end

-- 	local ost = num % nStep -- ищем остаток от деления
-- 	if (ost < nStep / 2) then return (math.floor(num / nStep) * nStep) --округление вниз
-- 	else return (math.ceil(num / nStep) * nStep) -- округление вверх
-- 	end

-- end


--[[
function Buy(classCode, secCode, size, action)
	local best_offer = getParamEx(classCode, secCode, "offer").param_value
	local buyPrice = best_offer + (OpenSlippage or 0)
	local res = send_order(action, classCode, secCode, account, "B", size, buyPrice)
	if string_len(res) ~= 0 then
		message('Ошибка: '..res..', '.. action..', '..secCode..', '.."B"..', '..size..', price='..buyPrice,3)
	end
end
-----------------------------

function Sell(classCode, secCode, size, action)
	local best_bid = getParamEx(classCode, secCode, "bid").param_value
	local sellPrice = best_bid - (OpenSlippage or 0)
	local res = send_order(action, classCode, secCode, account, "S", size, sellPrice)
	if string_len(res) ~= 0 then
		message('Ошибка: '..res..', '.. action..', '..secCode..', '.."S"..', '..size..', price='..sellPrice,3)
	end
end
-----------------------------

function BuyBid(classCode, secCode, size, action)
	local best_bid = getParamEx(classCode, secCode, "bid").param_value
	local buyPrice = best_bid - (OpenSlippage or 0)
	local res = send_order(action, classCode, secCode, account, "B", size, buyPrice)
	if string_len(res) ~= 0 then
		message('Ошибка: '..res..', '.. action..', '..secCode..', '.."B"..', '..size..', price='..buyPrice,3)
	end
end
-----------------------------

function SellOffer(classCode, secCode, size, action)
	local best_offer = getParamEx(classCode, secCode, "offer").param_value
	local sellPrice = best_offer + (OpenSlippage or 0)
	local res = send_order(action, classCode, secCode, account, "S", size, sellPrice)
	if string_len(res) ~= 0 then
		message('Ошибка: '..res..', '.. action..', '..secCode..', '.."S"..', '..size..', price='..sellPrice,3)
	end
end
-----------------------------

function KillOrders()
	local NumberOf = getNumberOf("orders")
	for i = 0, NumberOf - 1 do
		local ord = getItem("orders", i)
		local ord_status = get_order_status(ord.flags)
		if ord_status == "active" and (ord.sec_code == secCode) and ord.account == account  then
			trans_id = get_trans_id()
			local trans_params =
				{
					["CLASSCODE"] = classCode,
					["TRANS_ID"] = trans_id,
					["ACTION"] = "KILL_ORDER",
					["ORDER_KEY"] = tostring(ord.order_num)
				}
			local res =  sendTransaction(trans_params)
			if 0 < string_len(res) then
				message('Ошибка: '..res,1)
			end
		end
	end
end
-----------------------------
--]]


--[[

покупка по коридору:
если за n-свечей средняя цена была ниже на 2 ticks и выше на 2 ticks средней цены,
то покупаем по нижней, продаем по верхней границе,
либо проще - берём EMA: цена выше ема на 1..2 ticks - продажа, цена ниже ема на 1..2 ticks - покупка


--]]

--[[

local SecCode = "LKU0"
local Quantity = 1

function main()

while stopped == false do
	local Quotes = getQuoteLevel2("SPBFUT", SecCode)
	local Offer_Price = tonumber(Quotes.offer[1].price) -- получение цен ask (offer)
	local Offer_Vol = tonumber(Quotes.offer[1].quantity)

	--отправка формы заявки
	local LimitOrderBuy = {ххххх}

	--условие входа в лонг

	if Offer_Vol > 10 then
		message(Order)
		local Order = sendTransaction(LimitOrderBuy)
	end

	sleep (200)
end
--]]

--[[
map = {[1] = 10, [2] = 15, [3] = 44, [4] = 18}
for i, value in ipairs(map) do
	-- перебираются данные по порядку
	print (i.." = "..value)
end
--]]

--[[
nMap={name="Ivan", city="Moscow", age="23"}
for key,value in pairs(nMap) do
	print (key.." = "..value)
	print (nMap.city)
end

--]]

-- удаление точки и нулей после нее
function removeZero(str)
   while (string.sub(str,-1) == "0" and str ~= "0") do
      str = string.sub(str,1,-2)
   end
   if (string.sub(str,-1) == ".") then
      str = string.sub(str,1,-2)
   end
   return str
end


---[[
-- https://quikluacsharp.ru/quik-qlua/poluchenie-dannyh-iz-tablits-quik-v-qlua-lua/
-- Перебирает строки таблицы "Позиции по клиентским счетам (фьючерсы)", ищет Текущие чистые позиции по инструменту "RIH5"
function GetPosition(seccode) -- to do

	for i = 0, getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do
	   local orders = getItem("FUTURES_CLIENT_HOLDING", i)  
	   if orders.sec_code == seccode and orders.totalnet ~= 0 then
	   	
	   -- 	for k, v in pairs(orders) do
				-- msg("" .. tostring(k) .. " / " .. tostring(v)) -- todo
	   -- 	end


			return orders.totalnet	-- Количество лотов 
       else return 0 -- позиций по инструменту нет.
		end
	end
end
--]]

-- function BuyAsk(account, classcode, seccode, price, size)
-- -- функция для покупки ордером
-- -- покупаем по цене ask
-- -- сделать проверку срабатывания. если не работает - снимаем заявку, ждём следующую
-- ---

-- 	local trans_id = "100"
-- 	--local best_offer = getParamEx(classcode, seccode, "offer").param_value
-- 	--local best_offer = 0

-- 	--ql2 = getQuoteLevel2(classcode, seccode)
-- 	--best_offer = tonumber(ql2.offer[1].price) --0 - nil, 1 - 1 цена справа стакана на покупку (long pos), tonumber(ql2.offer_count) - последняя цена справа стакана (нижняя)
-- 	--price = tostring(ql2.bid[tonumber(ql2.bid_count)].price) -- 1 - нижняя цена, bid_count - верхняя цена слева стакана на продажу (short pos)

-- 	if price == 0 then
-- 		msg(scName .. ". Ошибка получения последней цены.\n Остановка")
-- 		TGsend(scName .. ". Ошибка получения последней цены. Остановка")
-- 		DestroyTable(t_id)
-- 		is_run = false
-- 	end

-- 	local transaction = {
-- 		["ACTION"] = "NEW_ORDER",
-- 		["SECCODE"] = seccode,
-- 		["ACCOUNT"] = account,
-- 		["CLASSCODE"] = classcode,
-- 		["OPERATION"] = "B",
-- 		["PRICE"] = tostring(price), --tostring(best_offer)
-- 		["QUANTITY"] = tostring(size),
-- 		["TYPE"] = "L",
-- 		["TRANS_ID"] = trans_id,
-- 		["CLIENT_CODE"] = account
-- 	}
-- 	--message(tostring(transaction.status))
-- 	local res = sendTransaction(transaction)

-- 	if #res ~= 0 then
-- 		msg(scName .. ". Ошибка отправки транзакции на покупку. Остановка")
-- 		TGsend(scName .. ". Ошибка отправки транзакции на покупку. Остановка")
-- 		is_run = false
-- 	end
-- end

-- function SellBid(account, classcode, seccode, price, size)
-- 	-- функция для продажи ордером
-- 	-- покупаем по цене bid
-- 	---

-- 	local trans_id = "100"
-- 	--local best_offer = getParamEx(classcode, seccode, "offer").param_value
-- 	--local best_offer = 0

-- 	--ql2 = getQuoteLevel2(classcode, seccode)
-- 	--best_offer = tonumber(ql2.offer[1].price) --0 - nil, 1 - 1 цена справа стакана на покупку (long pos), tonumber(ql2.offer_count) - последняя цена справа стакана (нижняя)
-- 	--price = tostring(ql2.bid[tonumber(ql2.bid_count)].price) -- 1 - нижняя цена, bid_count - верхняя цена слева стакана на продажу (short pos)

-- 	if price == 0 then
-- 		msg(scName .. ". Ошибка получения последней цены.\n Остановка")
-- 		TGsend(scName .. ". Ошибка получения последней цены. Остановка")
-- 		DestroyTable(t_id)
-- 		is_run = false
-- 	end

-- 	local transaction = {
-- 		["ACTION"] = "NEW_ORDER",
-- 		["SECCODE"] = seccode,
-- 		["ACCOUNT"] = account,
-- 		["CLASSCODE"] = classcode,
-- 		["OPERATION"] = "S",
-- 		["PRICE"] = tostring(price), --tostring(best_offer)
-- 		["QUANTITY"] = tostring(size),
-- 		["TYPE"] = "L",
-- 		["TRANS_ID"] = trans_id,
-- 		["CLIENT_CODE"] = account
-- 	}
-- 	--message(tostring(transaction.status))
-- 	local res = sendTransaction(transaction)

-- 	if #res ~= 0 then
-- 		msg(scName .. ". Ошибка отправки транзакции на покупку. Остановка")
-- 		TGsend(scName .. ". Ошибка отправки транзакции на покупку. Остановка")
-- 		is_run = false
-- 	end
-- end

-- function CheckPosition(lot)
-- -- функция проверки открытых позиций = необходимому лоту. true/false
-- ---

-- local count = 1
-- --local posNew = 0

-- 	sleep(100)
-- 	for i = 1, 300 do
-- 		local posNew = math.abs(PosNowFunc(ACCOUNT, SEC_CODE)) -- именно здесь для получения текущей позиции в разный момент времени
-- 		if posNew == lot then
-- 			--TGsend(scName.. ". Транзакция прошла за "..tostring(count*100).." мсек")
-- 			--message(scName.. ". Транзакция прошла за "..tostring(count*100).." мсек")
-- 			return true
-- 		end
-- 		count = count + 1
-- 		sleep(100)
-- 	end
-- 	return false
-- end

function SLTPorder(account, classcode, seccode, buySell, qty, tprice, slprice, prof_offset, prof_spread)
-- функция установки стоп-профит ордеров со спрэдом и отступом
-- trans_id сделать глобальной, покупка + выставление ордера должны быть с одним номером
-- buySell = "B" -- или "S" покупка/продажа
-- qty - количество лотов
-- tprice - take Profit цена
-- slprice - stop Loss цена
-- prof_offset - отступ
-- prof_spread - защитный спрэд
---

	local stprice = 0 -- цена стоп-ордера для выхода из позиции по stop-loss

	if buySell == "B" then
		stprice = slprice - prof_spread
	elseif buySell == "S" then
		stprice = slprice + prof_spread
	else
		TGsend(scName .. ". Неверно указано направление ордера TakeProfit & StopLoss. Остановка")
		is_run = false
	end

	local trans_id = "100"
	local transaction = {
		["ACTION"] = "NEW_STOP_ORDER",
		["TRANS_ID"] = trans_id,
		["CLASSCODE"] = classcode,
		["SECCODE"] = seccode,
		["ACCOUNT"] = account,
		["CLIENT_CODE"] = account,
		["OPERATION"] = buySell,
		["QUANTITY"] = tostring(qty),
		["PRICE"] = tostring(slprice), -- цена SL при касании
		["STOPPRICE"] = tostring(tprice), -- установка TP
		["STOP_ORDER_KIND"] = "TAKE_PROFIT_AND_STOP_LIMIT_ORDER",
		["OFFSET"] = tostring(prof_offset), -- отступ от цены
		["OFFSET_UNITS"] = "PRICE_UNITS",
		["SPREAD"] = tostring(prof_spread), -- защитный спрэд
		["SPREAD_UNITS"] = "PRICE_UNITS",
		["MARKET_TAKE_PROFIT"] = "NO",
		["STOPPRICE2"] = tostring(stprice), -- Sl price
		["EXPIRY_DATE"] = "GTC", --"TODAY", -- до отмены или сегодня
		["MARKET_STOP_LIMIT"] = "NO" --? YES
	}
--[[
MARKET_STOP_LIMIT	-	Признак исполнения заявки по рыночнои? цене при наступлении условия "стоп- лимит". Значения "YES" или "NO". Параметр заявок типа "Тэи?к-профит и стоп- лимит"
MARKET_TAKE_PROFIT	-	Признак исполнения заявки по рыночнои? цене при наступлении условия "тэи?к- профит". Значения "YES" или "NO". Параметр заявок типа "Тэи?к-профит и стоп-лимит"
--]]

	local result = sendTransaction(transaction)
	--[[
--Лукойл, покупка 1 лота, активация тейк-профита при достижении цены 2000 с отступом в 5% и защитным спредом в 3%,
стоп-цена 2222, цена лимитированной заявки 2255, время действия с 10:00:01 по 19:45:45
local transaction={}
transaction={
		ACTION=NEW_STOP_ORDER;
		TRANS_ID=10055;
		CLASSCODE= TQBR;
		SECCODE=LKOH;
		ACCOUNT=L01-00000F00;
		CLIENT_CODE=Q7;
		OPERATION=B;
		QUANTITY=1;
	PRICE=2255;
		STOPPRICE=2000;
		STOP_ORDER_KIND=TAKE_PROFIT_AND_STOP_LIMIT_ORDER;
		OFFSET=5;
		OFFSET_UNITS=PERCENTS;
		SPREAD=3;
		SPREAD_UNITS=PERCENTS;
	MARKET_TAKE_PROFIT=NO;
	STOPPRICE2=2222;
	IS_ACTIVE_IN_TIME=YES;
	ACTIVE_FROM_TIME=100001;
	ACTIVE_TO_TIME=194545;
	MARKET_STOP_LIMIT=NO
}
--]]
end

function msg(txt) -- функция вывода сообщений в QUIK
	message(tostring(txt), 2)
end

function getEntryPrice(seccode)
-- функция возвращает цену сделки входа в позицию
---
	local orderNum = nil
	local order = nil
	local trade = nil
	--ЖДЕТ пока ЗАЯВКА на ОТКРЫТИЕ сделки будет ИСПОЛНЕНА полностью
	--Запоминает время начала в секундах
	while orderNum == nil do
	   --Перебирает ТАБЛИЦУ ЗАЯВОК
		for i = getNumberOf('orders') - 1, 0, -1 do
		order = getItem('orders', i)
		--Если заявка по отправленной транзакции ИСПОЛНЕНА ПОЛНОСТЬЮ
			if order.balance == 0 then
				orderNum = order.order_num
				break
			end
		end

		for i = getNumberOf('trades') - 1, 0, -1  do
			trade = getItem('trades', i)
			-- for k, v in pairs(trade) do
			-- 		msg("k = " .. tostring(k) .. "/ v = " .. tostring(v)) -- todo
				
			-- end

			if trade.order_num == orderNum then
				return trade.price, trade.qty
			end
		end
	end
end


-- function getEntryPrice(trans_id)
-- -- функция возвращает цену сделки входа в позицию
-- ---
-- 	local orderNum = nil
-- 	local order = nil
-- 	local trade = nil
-- 	--ЖДЕТ пока ЗАЯВКА на ОТКРЫТИЕ сделки будет ИСПОЛНЕНА полностью
-- 	--Запоминает время начала в секундах
-- 	while orderNum == nil do
-- 	   --Перебирает ТАБЛИЦУ ЗАЯВОК
-- 		for i = 0, getNumberOf('orders') - 1 do
-- 		order = getItem('orders', i)
-- 		--Если заявка по отправленной транзакции ИСПОЛНЕНА ПОЛНОСТЬЮ
-- 			if order.trans_id == trans_id and order.balance == 0 then
-- 				orderNum  = order.order_num
-- 				break
-- 			end
-- 		end

-- 		for i = 0, getNumberOf('trades') - 1 do
-- 			trade = getItem('trades', i)
-- 			if trade.order_num == orderNum then
-- 				return trade.price
-- 			end
-- 		end
-- 	end
-- end
function StrText(int) 
-- добавляем "0" к данным, если число 1 < x < 10
-- возвращает 01, 02, .. , 09. значения типа string
---
    local m = tostring(int)
    local mLen = string.len(int)

    if mLen == 1 then output = "0" .. tostring(m)
    else output = m
    end

    return output
end

-- function getExitPrice (trans_id)
-- -- функция возвращает цену сделки выхода из позиции
-- ---
-- 	return nil --убрать
-- end

--[[
	
-- Функция проверяет установлен бит, или нет (возвращает true, или false)
CheckBit = function(flags, _bit)
   -- Проверяет, что переданные аргументы являются числами
   if type(flags) ~= "number" then error("Ошибка!!! Checkbit: 1-й аргумент не число!") end
   if type(_bit) ~= "number" then error("Ошибка!!! Checkbit: 2-й аргумент не число!") end
 
   if _bit == 0 then _bit = 0x1
   elseif _bit == 1 then _bit = 0x2
   elseif _bit == 2 then _bit = 0x4
   elseif _bit == 3 then _bit  = 0x8
   elseif _bit == 4 then _bit = 0x10
   elseif _bit == 5 then _bit = 0x20
   elseif _bit == 6 then _bit = 0x40
   elseif _bit == 7 then _bit  = 0x80
   elseif _bit == 8 then _bit = 0x100
   elseif _bit == 9 then _bit = 0x200
   elseif _bit == 10 then _bit = 0x400
   elseif _bit == 11 then _bit = 0x800
   elseif _bit == 12 then _bit  = 0x1000
   elseif _bit == 13 then _bit = 0x2000
   elseif _bit == 14 then _bit  = 0x4000
   elseif _bit == 15 then _bit  = 0x8000
   elseif _bit == 16 then _bit = 0x10000
   elseif _bit == 17 then _bit = 0x20000
   elseif _bit == 18 then _bit = 0x40000
   elseif _bit == 19 then _bit = 0x80000
   elseif _bit == 20 then _bit = 0x100000
   end
 
   if bit.band(flags,_bit ) == _bit then return true
   else return false end
end


-- Пример использования

Run = true;
 
function main()
   -- ОСНОВНОЙ ЦИКЛ
   while Run do
      sleep(500);
   end;
end;
 
function OnOrder(order)
   --бит 0 (0x1)     Заявка активна, иначе – не активна  
   --бит 1 (0x2)     Заявка снята. Если флаг не установлен и значение бита «0» равно «0», то заявка исполнена  
   --бит 2 (0x4)     Заявка на продажу, иначе – на покупку. Данный флаг для сделок и сделок для исполнения определяет направление сделки (BUY/SELL)  
   --бит 3 (0x8)     Заявка лимитированная, иначе – рыночная  
   --бит 4 (0x10)    Разрешить / запретить сделки по разным ценам  
   --бит 5 (0x20)    Исполнить заявку немедленно или снять (FILL OR KILL)  
   --бит 6 (0x40)    Заявка маркет-мейкера. Для адресных заявок – заявка отправлена контрагенту  
   --бит 7 (0x80)    Для адресных заявок – заявка получена от контрагента  
   --бит 8 (0x100)   Снять остаток  
   --бит 9 (0x200)   Айсберг-заявка  
 
   -- Проверка бита 2
   if CheckBit(order.flags, 2) then 
      message("Заявка на продажу"); 
   else 
      message("Заявка на покупку"); 
   end;
end;
 
function OnStop()
   Run = false;
end;
 
-- Функция проверяет установлен бит, или нет (возвращает true, или false)
CheckBit = function(flags, _bit)
   -- Проверяет, что переданные аргументы являются числами
   if type(flags) ~= "number" then error("Ошибка!!! Checkbit: 1-й аргумент не число!") end
   if type(_bit) ~= "number" then error("Ошибка!!! Checkbit: 2-й аргумент не число!") end
 
   if _bit == 0 then _bit = 0x1
   elseif _bit == 1 then _bit = 0x2
   elseif _bit == 2 then _bit = 0x4
   elseif _bit == 3 then _bit  = 0x8
   elseif _bit == 4 then _bit = 0x10
   elseif _bit == 5 then _bit = 0x20
   elseif _bit == 6 then _bit = 0x40
   elseif _bit == 7 then _bit  = 0x80
   elseif _bit == 8 then _bit = 0x100
   elseif _bit == 9 then _bit = 0x200
   elseif _bit == 10 then _bit = 0x400
   elseif _bit == 11 then _bit = 0x800
   elseif _bit == 12 then _bit  = 0x1000
   elseif _bit == 13 then _bit = 0x2000
   elseif _bit == 14 then _bit  = 0x4000
   elseif _bit == 15 then _bit  = 0x8000
   elseif _bit == 16 then _bit = 0x10000
   elseif _bit == 17 then _bit = 0x20000
   elseif _bit == 18 then _bit = 0x40000
   elseif _bit == 19 then _bit = 0x80000
   elseif _bit == 20 then _bit = 0x100000
   end
 
   if bit.band(flags,_bit ) == _bit then return true
   else return false end
end


-- Флаг поддержания работы скрипта
IsRun = true;
 
function main()
   -- Пытается открыть файл в режиме "чтения/записи"
   f = io.open(getScriptPath().."\\Test.txt","r+");
   -- Если файл не существует
   if f == nil then 
      -- Создает файл в режиме "записи"
      f = io.open(getScriptPath().."\\Test.txt","w"); 
      -- Закрывает файл
      f:close();
      -- Открывает уже существующий файл в режиме "чтения/записи"
      f = io.open(getScriptPath().."\\Test.txt","r+");
   end;
   -- Записывает в файл 2 строки
   f:write("Line1\nLine2"); -- "\n" признак конца строки
   -- Сохраняет изменения в файле
   f:flush();
   -- Встает в начало файла 
      -- 1-ым параметром задается относительно чего будет смещение: "set" - начало, "cur" - текущая позиция, "end" - конец файла
      -- 2-ым параметром задается смещение
   f:seek("set",0);
   -- Перебирает строки файла, выводит их содержимое в сообщениях
   for line in f:lines() do message(tostring(line));end
   -- Закрывает файл
   f:close();
   -- Цикл будет выполнятся, пока IsRun == true
   while IsRun do
      sleep(100);
   end;   
end;
 
function OnStop()
   IsRun = false;
end;



--]]

--[[
https://arqatech.com/ru/support/files/
Утилиты и документация
Документация по языку LUA в QUIK и примерыzip, 4 МБ	
Примеры функций расчета индикаторов терминала QUIK на языке Luazip, 76 КБ
--]]

--[[

S = "Текст";
string.byte(S, i); -- Возвращает числовой код символа в строке по индексу i
   -- i (необязательный параметр) - начальный индекс (по умолчанию, 1)
S:byte(i); -- Эквивалентно
 
string.byte(S, 1); -- Вернет 210
string.byte(S, 2); -- Вернет 229
string.byte(S, 3); -- Вернет 234
string.byte(S, 4); -- Вернет 241
string.byte(S, 5); -- Вернет 242

string.char

string.char(n,...);               -- Возвращает символы по числовым кодам, может принимать любое количество кодов через запятую
string.char(210);                 -- Вернет "Т"
string.char(210,229,234,241,242); -- Вернет "Текст"
string.dump

string.dump(func); -- Возвращает двоичное представление функции func
string.find

-- Ищет вхождение подстроки в строку и возвращает индекс начала вхождения, или nil, если совпадение не найдено
S = "Текст";
string.find(S,"екс"); -- Вернет 2
S:find("екс"); -- Эквивалентно
-- В строке поиска можно использовать регулярные выражения

string.format

-- Выводит отформатированную строку
string.format("quik%scsharp%s", "lua", ".ru"); -- Вернет строку "quikluacsharp.ru"
 
-- Поддерживаемые опции:
%a	-- Шестнадцатеричное в виде 0xh.hhhhp+d (только С99)
%A	-- Шестнадцатеричное в виде 0Xh.hhhhP+d (только С99)
%c	-- Символ по коду
%d	-- Десятичное целое со знаком
%i	-- Десятичное целое со знаком
%e	-- Экспоненциальное представление ('е' на нижнем регистре)
%E	-- Экспоненциальное представление ('Е' на верхнем регистре)
%f	-- Десятичное с плавающей точкой
%g	-- В зависимости от того, какой вывод будет короче, используется %е или %f
%G	-- В зависимости от того, какой вывод будет короче, используется %Е или %F
%o	-- Восьмеричное без знака
%s	-- Строка символов
%u	-- Десятичное целое без знака
%x	-- Шестнадцатеричное без знака (буквы на нижнем регистре)
%X	-- Шестнадцатеричное без знака (буквы на верхнем регистре)
%p	-- Выводит указатель
%n	-- Аргумент, соответствующий этому спецификатору, должен быть указателем на целочисленную переменную. Спецификатор позволяет сохранить в этой переменной количество записанных символов (записанных до того места, в котором находится код %n)
%%	-- Выводит знак %
string.match

string.match (S, "шаблон", i); -- Ищет первое вхождение "шаблона" в строку S, при нахождении, возвращает совпадение, иначе nil
   -- i (необязательный параметр) - указывает с какого по счету символа начинать поиск (по-умолчанию, 1)
S:match ("шаблон", i); -- Эквивалентно
string.gmatch

string.gmatch (S, "шаблон"); -- Возвращает итератор, который, при каждом вызове, возвращает следующее вхождение шаблона в S
S:gmatch("шаблон"); -- Эквивалентно
-- Пример:
Str = "Привет, Мир!";
for S in string.gmatch (Str, "р") do
-- какой-то код
end;
-- Данный цикл совершит 2 итерации, каждый раз помещая в переменную S букву "р"
string.gsub

string.gsub(S, "Шаблон поиска", "Шаблон замены", n); -- Возвращает копию S, в которой все вхождения "Шаблона поиска" заменяются на "Шаблон замены", который может быть строкой, таблицей или функцией, вторым значением возвращает общее количество проведенных подстановок
   -- в "Шаблоне замены" символ % работает как символ со специальным назначением: любая последовательность в виде %n, где n от 1 до 9, заменяется на n-ную захваченную подстроку
   -- n (необязательный параметр) - указывает сколько максимум раз можно сделать подстановку
S:gsub("Шаблон поиска", "Шаблон замены", n); -- Эквивалентно
 
-- Примеры:
string.gsub("Привет, Мир!", "Мир", "Lua"); -- Вернет "Привет, Lua!"
string.gsub("Привет, Мир!", "Мир", "%1%1"); -- Вернет "Привет, МирМир!"
string.len

string.len(S); -- Возвращает длину строки S
S:len(); -- Эквивалентно
#S;      -- Эквивалентно
string.upper

string.upper(S); -- Возвращает копию строки S, где все буквы в нижнем регистре заменены на буквы в верхнем регистре
S:upper(); -- Эквивалентно
string.lower

string.lower(S); -- Возвращает копию строки S, где все буквы в верхнем регистре заменены на буквы в нижнем регистре
S:lower(); -- Эквивалентно
string.rep

string.rep(S,n); -- Возвращает строку, которая содержит n копий строки S
S:rep(n); -- Эквивалентно
string.reverse

string.reverse(S); -- Возвращает строку, в которой символы строки S расположены в обратном порядке
S:reverse(); -- Эквивалентно
string.sub

string.sub(S, i, j); -- Возвращает подстроку строки S, которая начинается с символа с индексом i и заканчивается символом с индексом j
   -- j (необязательный параметр) - по-умолчанию, индекс последнего символа
S:sub(i,j); -- Эквивалентно
Поддерживаемые опции регулярных выражений:

.	-- Любой символ
%a	-- Буква (только англ.!)
%A	-- Любая буква (русская), символ, или цифра, кроме английской буквы 
%c	-- Управляющий символ
%d	-- Цифра
%D	-- Любая буква, или символ, кроме цифры
%l	-- Буква в нижней раскладке (только англ.!)
%L	-- Любая буква, символ, или цифра, кроме английской буквы в нижней раскладке
%p	-- Символ пунктуации
%P	-- Любая буква, символ, или цифра, кроме символа пунктуации
%s	-- Символ пробел
%S	-- Любая буква, символ, или цифра, кроме символа пробела
%u	-- Буква в верхней раскладке (только англ.!)
%U	-- Любая буква, символ, или цифра, кроме английской буквы в верхней раскладке
%w	-- Любая буква, или цифра (только англ.!)
%W	-- Любой символ, или буква (русская), кроме английской буквы, или цифры
%x	-- Шестнадцатеричное число
%X	-- Любая буква, или символ,  кроме цифры, или английской буквы, используемой в записи шестнадцатеричного числа 
%z	-- Строковые параметры, содержащие символы с кодом 0

--]]


--[[

https://quik2dde.ru/viewtopic.php?id=149


    Суть проста- я хотел бы чтобы LUA скрипт каждый день мне выгружал свечи минутки по нужному инструменту в файл. И "дозаписывал" этот файл.
    Идеально было бы например в Excel или базу данных.
    Но для начала хотя бы в txt файл.

    Плюс к этому было бы хорошо, чтобы он и внутри себя имел массив свечей минуток. Ну т.е нажал кнопку "загрузить", и дальше можно внутри скрипта увидеть таблицу минуток и с ней работать.
    Пока не могу понять с какой стороны подойти к этому вопросу.
    Хотя бы как из Quik в LUA забрать значения свечек минуток сразу?

    local n = getNumCandles(ind)--кол-во свечек, где ind = идентификатор графика
    local t, res, _ = getCandlesByIndex (ind, 0, 0, n)--получаем все свечи
    или так:
    local t, res, _ = getCandlesByIndex (ind, 0, n - 500, 500)--получить последние 500 свечей (для справки)

    --t - таблица со свечками, res - длина таблицы, _ - легенда (подпись) графика
    --t[0] - первая свеча
    --t[res-1] - последняя свеча
    если проделать такой трюк:
    t[0] = nil,
    то получим обычный массив Lua и скорость работы с таблицей чуть увеличится, но вы этого не заметите ))

    Хотя бы как из Quik в LUA забрать значения свечек минуток сразу?

    local n = getNumCandles(ind)--кол-во свечек, где ind = идентификатор графика
    local t, res, _ = getCandlesByIndex (ind, 0, 0, n)--получаем все свечи
    или так:
    local t, res, _ = getCandlesByIndex (ind, 0, n - 500, 500)--получить последние 500 свечей (для справки)

    --t - таблица со свечками, res - длина таблицы, _ - легенда (подпись) графика
    --t[0] - первая свеча
    --t[res-1] - последняя свеча
    если проделать такой трюк:
    t[0] = nil,
    то получим обычный массив Lua и скорость работы с таблицей чуть увеличится, но вы этого не заметите ))


    Я на данный момент реализовал вот таким способом:
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


    И пока не понимаю как "суммировать год, месяц, день  и часы, минуты и секунды, чтобы представить их в двух столбцах таблицы.

    4kalikazandr2015-04-29 18:49:45 (2015-04-29 18:52:35 отредактировано kalikazandr)
    Member
    Неактивен
    Зарегистрирован: 2014-09-10
    Сообщений: 371
    slkumax пишет:
    И пока не понимаю как "суммировать год, месяц, день  и часы, минуты и секунды, чтобы представить их в двух столбцах таблицы.

    local FTEXT = function (V)
        V=tostring (V)
        if string.len (V) == 1 then V = "0".. V end
        return V 
    end

    local bar = t[1]
    local datetime = bar.datetime
    local DATE = (datetime.year .. FTEXT (datetime.month) .. FTEXT (datetime.day)) + 0 --число (ГГГГММДД)
    local DATE = datetime.year .. "." .. FTEXT (datetime.month) .. "." ..  FTEXT (datetime.day) --строка (ГГГГ.ММ.ДД)
    local TIME = (datetime.hour .. FTEXT (datetime.min) .. FTEXT (datetime.sec)) + 0 --число HHMMSS
    local TIME = datetime.hour .. ":" .. FTEXT (datetime.min) .. ":" .. FTEXT (datetime.sec) --строка HH:MM:SS

    в вашем примере аналогично, FTEXT у меня локальная, поставьте выше строк с ее использованием

    Следующим шагом понять, как сделать чтобы робот дозаписывал в файл только новые данные. Два раза в сутки например.

    нзч.
    а зачем? если не лень, откройте все интересующие вас графики, пропишите идентификатор (пару часов убъете, если много инструментов и разные тайм фреймы)
    и что-то вроде этого:

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
      local t, res, _ = getCandlesByIndex (ind, 0, getNumCandles(ind) - 500, 500)--500 свечей достаточно
      t[0] = nil--делаю массив из t
      local tt = t
      for i = 1, #tt do
        local bar = tt[i]
        local datetime = bar.datetime
        if datetime.hour + 0 = 10 then break end
        table_remove (t,i)--удаляю свечи вчерашнего дня
      end
      return t--возвращаю с 100000 -вым баром в качестве первого
    end

    for i = 1, #s_list do
      local sec = s_list[i]
      local ind = ind_list[sec]
      local tab = findStartDayBar (ind)
      local file = path.."\\" .. sec .. ".CSV"
      local f = io.open(file, "a+")--в режиме до записи
      for j = 1, #tab do
        local bar = tab[j]
        local datetime = bar.datetime
        local DATE = datetime.year .. FTEXT (datetime.month) .. FTEXT (datetime.day)
        local TIME = datetime.hour .. FTEXT (datetime.min) .. "00" --минутки - секунды не обязательны?
        local wr = DATE .. ";" .. TIME .. ";" .. bar.open .. ";" .. bar.high .. ";" .. bar.low .. ";" .. bar.close
        f:write(wr)
      end
      f:flush()
    end
    f:close()
    do message("запись завершена",2) end
    не проверял, писал прямо тут, но должно работать можно запускать в конце дня, можно добавить фильтр цены закрытия сессии. В экселе разделитель целой и дробной части поставьте "точку".
    Да, в качестве идентификатора графика удобно использовать sec_code инструмента:
    SBER -дневной график;
    SBERm1 - минуточный
    тогда ind = sec .. "m1"

    Хотя бы как из Quik в LUA забрать значения свечек минуток сразу?

    local n = getNumCandles(ind)--кол-во свечек, где ind = идентификатор графика
    local t, res, _ = getCandlesByIndex (ind, 0, 0, n)--получаем все свечи
    или так:
    local t, res, _ = getCandlesByIndex (ind, 0, n - 500, 500)--получить последние 500 свечей (для справки)

    --t - таблица со свечками, res - длина таблицы, _ - легенда (подпись) графика
    --t[0] - первая свеча
    --t[res-1] - последняя свеча
    если проделать такой трюк:
    t[0] = nil,
    то получим обычный массив Lua и скорость работы с таблицей чуть увеличится, но вы этого не заметите ))


    А какой формат у этой таблицы? Т.е как обратиться например к High свечи?

    а вот выше посмотрите ))
    local bar = t[20]--20 свеча в таблице по счету,
    key = datetime, open, high, low, close, volume
    local high = bar.high
--]]

-- message("Human_time " .. to_human_time(DS:T(DS:Size())))
-- function to_human_time(time)
--     return tostring(string.format("%02d", time.hour) .. ":" .. string.format("%02d", time.min) .. ":" .. string.format("%02d", time.sec))
-- end
