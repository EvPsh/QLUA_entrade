-- ��������� ------------------------------------------------------------------------------------

SEC_CODE = "CRH3" 
CLASS_CODE = "SPBFUT"
ACCOUNT = "SPBFUT00479" 
CLIENT_CODE = "QLUA_EnterTP"

IdGraf = "NLAB"


----------------------- ��������� ���������� ---------------------

Is_run = true

Tprofit = 5		-- Take Profit � ����� ����
P_offset = 2 		-- ������ �� ����-�������, ����� ����
P_spread = 0		-- �������� ����� � TP, � ����� ����
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
	-- msg("����������") -- todo
	Is_run = false
end

function GetSeccode(str)
-- �������� sec_code �� ������� �������
-- ���������� string sec_code
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

				

		if sec_code.short_name == str then -- ������ � �������� ������� ���� ����� [price] � ������� gsub

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
    -- �������� ������� ����������� � ��������
    -- ���������� ���� �����
    -- ���������� ����������� �����
    -- ���������� ���������� ����� �����

    return price_step, openprice -- openprice - ���� �������� ������ �� �����������
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
	-- ������� ��������� ����-������� ������� �� ������� � ��������
	-- prof_offset - ������
	-- prof_spread - �������� �����

	local trans_id = "123456"
	local transaction = {
		["ACCOUNT"] = account,
		["CLASSCODE"] = classcode,
		["SECCODE"] = seccode,
		["ACTION"] = "NEW_STOP_ORDER",
		["STOP_ORDER_KIND"] = "TAKE_PROFIT_STOP_ORDER",
		["TRANS_ID"] = trans_id,
		["CLIENT_CODE"] = comment, -- ����� ����������� ����������� (CLIENT_CODE)
		["EXPIRY_DATE"] = "TODAY",
		["OPERATION"] = buySell,
		["QUANTITY"] = tostring(qty),
		["STOPPRICE"] = tostring(price),
		["OFFSET_UNITS"] = "PRICE_UNITS",
		["SPREAD_UNITS"] = "PRICE_UNITS",
		["OFFSET"] = tostring(prof_offset), -- ������ �� ����
		["SPREAD"] = tostring(prof_spread) -- �������� �����
	}
	local result = sendTransaction(transaction)
end


--[[
function sOrder(instr, entryPrice, sl, tp)
	--
	-- �������� ����������
	--

	if entryPrice="" then --send market order
	else
		--send limit entryPrice

	-- ��������� �� ������������, ���� �� ��, ��:
	inPosition=true

	if inPosition then
	-- ������������ ��������� �����, ��� ������������ ����� �� ���� (sl ��� tp), ��������� ����� ����������.
	-- ��������
	end
end

--]]

-- function round(number, znaq) -- ������� ���������� ����� num �� ������ idp. ��������� ���������
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
-- 	-- ������� ������ '.' �� ',' � what � ���������� ��������� ��������
-- 	-- ������������ � csv ��� ��������� ����������� ����� (������ 50.50 -> 50,50)
-- 	---
-- 	local xstr = string.gsub(tostring(what), "%.", ",")
-- 	return tostring(xstr)
-- end


-- function RoundStep (num, nStep)
-- -- ������� ���������� �� ���� ����
-- ---

-- 	if (nStep == nil or num == nil) then return nil
-- 	elseif (nStep == 0) then return num
-- 	end

-- 	local ost = num % nStep -- ���� ������� �� �������
-- 	if (ost < nStep / 2) then return (math.floor(num / nStep) * nStep) --���������� ����
-- 	else return (math.ceil(num / nStep) * nStep) -- ���������� �����
-- 	end

-- end


--[[
function Buy(classCode, secCode, size, action)
	local best_offer = getParamEx(classCode, secCode, "offer").param_value
	local buyPrice = best_offer + (OpenSlippage or 0)
	local res = send_order(action, classCode, secCode, account, "B", size, buyPrice)
	if string_len(res) ~= 0 then
		message('������: '..res..', '.. action..', '..secCode..', '.."B"..', '..size..', price='..buyPrice,3)
	end
end
-----------------------------

function Sell(classCode, secCode, size, action)
	local best_bid = getParamEx(classCode, secCode, "bid").param_value
	local sellPrice = best_bid - (OpenSlippage or 0)
	local res = send_order(action, classCode, secCode, account, "S", size, sellPrice)
	if string_len(res) ~= 0 then
		message('������: '..res..', '.. action..', '..secCode..', '.."S"..', '..size..', price='..sellPrice,3)
	end
end
-----------------------------

function BuyBid(classCode, secCode, size, action)
	local best_bid = getParamEx(classCode, secCode, "bid").param_value
	local buyPrice = best_bid - (OpenSlippage or 0)
	local res = send_order(action, classCode, secCode, account, "B", size, buyPrice)
	if string_len(res) ~= 0 then
		message('������: '..res..', '.. action..', '..secCode..', '.."B"..', '..size..', price='..buyPrice,3)
	end
end
-----------------------------

function SellOffer(classCode, secCode, size, action)
	local best_offer = getParamEx(classCode, secCode, "offer").param_value
	local sellPrice = best_offer + (OpenSlippage or 0)
	local res = send_order(action, classCode, secCode, account, "S", size, sellPrice)
	if string_len(res) ~= 0 then
		message('������: '..res..', '.. action..', '..secCode..', '.."S"..', '..size..', price='..sellPrice,3)
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
				message('������: '..res,1)
			end
		end
	end
end
-----------------------------
--]]


--[[

������� �� ��������:
���� �� n-������ ������� ���� ���� ���� �� 2 ticks � ���� �� 2 ticks ������� ����,
�� �������� �� ������, ������� �� ������� �������,
���� ����� - ���� EMA: ���� ���� ��� �� 1..2 ticks - �������, ���� ���� ��� �� 1..2 ticks - �������


--]]

--[[

local SecCode = "LKU0"
local Quantity = 1

function main()

while stopped == false do
	local Quotes = getQuoteLevel2("SPBFUT", SecCode)
	local Offer_Price = tonumber(Quotes.offer[1].price) -- ��������� ��� ask (offer)
	local Offer_Vol = tonumber(Quotes.offer[1].quantity)

	--�������� ����� ������
	local LimitOrderBuy = {�����}

	--������� ����� � ����

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
	-- ������������ ������ �� �������
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

-- �������� ����� � ����� ����� ���
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
-- ���������� ������ ������� "������� �� ���������� ������ (��������)", ���� ������� ������ ������� �� ����������� "RIH5"
function GetPosition(seccode) -- to do

	for i = 0, getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do
	   local orders = getItem("FUTURES_CLIENT_HOLDING", i)  
	   if orders.sec_code == seccode and orders.totalnet ~= 0 then
	   	
	   -- 	for k, v in pairs(orders) do
				-- msg("" .. tostring(k) .. " / " .. tostring(v)) -- todo
	   -- 	end


			return orders.totalnet	-- ���������� ����� 
       else return 0 -- ������� �� ����������� ���.
		end
	end
end
--]]

-- function BuyAsk(account, classcode, seccode, price, size)
-- -- ������� ��� ������� �������
-- -- �������� �� ���� ask
-- -- ������� �������� ������������. ���� �� �������� - ������� ������, ��� ���������
-- ---

-- 	local trans_id = "100"
-- 	--local best_offer = getParamEx(classcode, seccode, "offer").param_value
-- 	--local best_offer = 0

-- 	--ql2 = getQuoteLevel2(classcode, seccode)
-- 	--best_offer = tonumber(ql2.offer[1].price) --0 - nil, 1 - 1 ���� ������ ������� �� ������� (long pos), tonumber(ql2.offer_count) - ��������� ���� ������ ������� (������)
-- 	--price = tostring(ql2.bid[tonumber(ql2.bid_count)].price) -- 1 - ������ ����, bid_count - ������� ���� ����� ������� �� ������� (short pos)

-- 	if price == 0 then
-- 		msg(scName .. ". ������ ��������� ��������� ����.\n ���������")
-- 		TGsend(scName .. ". ������ ��������� ��������� ����. ���������")
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
-- 		msg(scName .. ". ������ �������� ���������� �� �������. ���������")
-- 		TGsend(scName .. ". ������ �������� ���������� �� �������. ���������")
-- 		is_run = false
-- 	end
-- end

-- function SellBid(account, classcode, seccode, price, size)
-- 	-- ������� ��� ������� �������
-- 	-- �������� �� ���� bid
-- 	---

-- 	local trans_id = "100"
-- 	--local best_offer = getParamEx(classcode, seccode, "offer").param_value
-- 	--local best_offer = 0

-- 	--ql2 = getQuoteLevel2(classcode, seccode)
-- 	--best_offer = tonumber(ql2.offer[1].price) --0 - nil, 1 - 1 ���� ������ ������� �� ������� (long pos), tonumber(ql2.offer_count) - ��������� ���� ������ ������� (������)
-- 	--price = tostring(ql2.bid[tonumber(ql2.bid_count)].price) -- 1 - ������ ����, bid_count - ������� ���� ����� ������� �� ������� (short pos)

-- 	if price == 0 then
-- 		msg(scName .. ". ������ ��������� ��������� ����.\n ���������")
-- 		TGsend(scName .. ". ������ ��������� ��������� ����. ���������")
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
-- 		msg(scName .. ". ������ �������� ���������� �� �������. ���������")
-- 		TGsend(scName .. ". ������ �������� ���������� �� �������. ���������")
-- 		is_run = false
-- 	end
-- end

-- function CheckPosition(lot)
-- -- ������� �������� �������� ������� = ������������ ����. true/false
-- ---

-- local count = 1
-- --local posNew = 0

-- 	sleep(100)
-- 	for i = 1, 300 do
-- 		local posNew = math.abs(PosNowFunc(ACCOUNT, SEC_CODE)) -- ������ ����� ��� ��������� ������� ������� � ������ ������ �������
-- 		if posNew == lot then
-- 			--TGsend(scName.. ". ���������� ������ �� "..tostring(count*100).." ����")
-- 			--message(scName.. ". ���������� ������ �� "..tostring(count*100).." ����")
-- 			return true
-- 		end
-- 		count = count + 1
-- 		sleep(100)
-- 	end
-- 	return false
-- end

function SLTPorder(account, classcode, seccode, buySell, qty, tprice, slprice, prof_offset, prof_spread)
-- ������� ��������� ����-������ ������� �� ������� � ��������
-- trans_id ������� ����������, ������� + ����������� ������ ������ ���� � ����� �������
-- buySell = "B" -- ��� "S" �������/�������
-- qty - ���������� �����
-- tprice - take Profit ����
-- slprice - stop Loss ����
-- prof_offset - ������
-- prof_spread - �������� �����
---

	local stprice = 0 -- ���� ����-������ ��� ������ �� ������� �� stop-loss

	if buySell == "B" then
		stprice = slprice - prof_spread
	elseif buySell == "S" then
		stprice = slprice + prof_spread
	else
		TGsend(scName .. ". ������� ������� ����������� ������ TakeProfit & StopLoss. ���������")
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
		["PRICE"] = tostring(slprice), -- ���� SL ��� �������
		["STOPPRICE"] = tostring(tprice), -- ��������� TP
		["STOP_ORDER_KIND"] = "TAKE_PROFIT_AND_STOP_LIMIT_ORDER",
		["OFFSET"] = tostring(prof_offset), -- ������ �� ����
		["OFFSET_UNITS"] = "PRICE_UNITS",
		["SPREAD"] = tostring(prof_spread), -- �������� �����
		["SPREAD_UNITS"] = "PRICE_UNITS",
		["MARKET_TAKE_PROFIT"] = "NO",
		["STOPPRICE2"] = tostring(stprice), -- Sl price
		["EXPIRY_DATE"] = "GTC", --"TODAY", -- �� ������ ��� �������
		["MARKET_STOP_LIMIT"] = "NO" --? YES
	}
--[[
MARKET_STOP_LIMIT	-	������� ���������� ������ �� ��������? ���� ��� ����������� ������� "����- �����". �������� "YES" ��� "NO". �������� ������ ���� "���?�-������ � ����- �����"
MARKET_TAKE_PROFIT	-	������� ���������� ������ �� ��������? ���� ��� ����������� ������� "���?�- ������". �������� "YES" ��� "NO". �������� ������ ���� "���?�-������ � ����-�����"
--]]

	local result = sendTransaction(transaction)
	--[[
--������, ������� 1 ����, ��������� ����-������� ��� ���������� ���� 2000 � �������� � 5% � �������� ������� � 3%,
����-���� 2222, ���� �������������� ������ 2255, ����� �������� � 10:00:01 �� 19:45:45
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

function msg(txt) -- ������� ������ ��������� � QUIK
	message(tostring(txt), 2)
end

function getEntryPrice(seccode)
-- ������� ���������� ���� ������ ����� � �������
---
	local orderNum = nil
	local order = nil
	local trade = nil
	--���� ���� ������ �� �������� ������ ����� ��������� ���������
	--���������� ����� ������ � ��������
	while orderNum == nil do
	   --���������� ������� ������
		for i = getNumberOf('orders') - 1, 0, -1 do
		order = getItem('orders', i)
		--���� ������ �� ������������ ���������� ��������� ���������
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
-- -- ������� ���������� ���� ������ ����� � �������
-- ---
-- 	local orderNum = nil
-- 	local order = nil
-- 	local trade = nil
-- 	--���� ���� ������ �� �������� ������ ����� ��������� ���������
-- 	--���������� ����� ������ � ��������
-- 	while orderNum == nil do
-- 	   --���������� ������� ������
-- 		for i = 0, getNumberOf('orders') - 1 do
-- 		order = getItem('orders', i)
-- 		--���� ������ �� ������������ ���������� ��������� ���������
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

-- function getExitPrice (trans_id)
-- -- ������� ���������� ���� ������ ������ �� �������
-- ---
-- 	return nil --������
-- end

--[[
	
-- ������� ��������� ���������� ���, ��� ��� (���������� true, ��� false)
CheckBit = function(flags, _bit)
   -- ���������, ��� ���������� ��������� �������� �������
   if type(flags) ~= "number" then error("������!!! Checkbit: 1-� �������� �� �����!") end
   if type(_bit) ~= "number" then error("������!!! Checkbit: 2-� �������� �� �����!") end
 
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


-- ������ �������������

Run = true;
 
function main()
   -- �������� ����
   while Run do
      sleep(500);
   end;
end;
 
function OnOrder(order)
   --��� 0 (0x1)     ������ �������, ����� � �� �������  
   --��� 1 (0x2)     ������ �����. ���� ���� �� ���������� � �������� ���� �0� ����� �0�, �� ������ ���������  
   --��� 2 (0x4)     ������ �� �������, ����� � �� �������. ������ ���� ��� ������ � ������ ��� ���������� ���������� ����������� ������ (BUY/SELL)  
   --��� 3 (0x8)     ������ ��������������, ����� � ��������  
   --��� 4 (0x10)    ��������� / ��������� ������ �� ������ �����  
   --��� 5 (0x20)    ��������� ������ ���������� ��� ����� (FILL OR KILL)  
   --��� 6 (0x40)    ������ ������-�������. ��� �������� ������ � ������ ���������� �����������  
   --��� 7 (0x80)    ��� �������� ������ � ������ �������� �� �����������  
   --��� 8 (0x100)   ����� �������  
   --��� 9 (0x200)   �������-������  
 
   -- �������� ���� 2
   if CheckBit(order.flags, 2) then 
      message("������ �� �������"); 
   else 
      message("������ �� �������"); 
   end;
end;
 
function OnStop()
   Run = false;
end;
 
-- ������� ��������� ���������� ���, ��� ��� (���������� true, ��� false)
CheckBit = function(flags, _bit)
   -- ���������, ��� ���������� ��������� �������� �������
   if type(flags) ~= "number" then error("������!!! Checkbit: 1-� �������� �� �����!") end
   if type(_bit) ~= "number" then error("������!!! Checkbit: 2-� �������� �� �����!") end
 
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


-- ���� ����������� ������ �������
IsRun = true;
 
function main()
   -- �������� ������� ���� � ������ "������/������"
   f = io.open(getScriptPath().."\\Test.txt","r+");
   -- ���� ���� �� ����������
   if f == nil then 
      -- ������� ���� � ������ "������"
      f = io.open(getScriptPath().."\\Test.txt","w"); 
      -- ��������� ����
      f:close();
      -- ��������� ��� ������������ ���� � ������ "������/������"
      f = io.open(getScriptPath().."\\Test.txt","r+");
   end;
   -- ���������� � ���� 2 ������
   f:write("Line1\nLine2"); -- "\n" ������� ����� ������
   -- ��������� ��������� � �����
   f:flush();
   -- ������ � ������ ����� 
      -- 1-�� ���������� �������� ������������ ���� ����� ��������: "set" - ������, "cur" - ������� �������, "end" - ����� �����
      -- 2-�� ���������� �������� ��������
   f:seek("set",0);
   -- ���������� ������ �����, ������� �� ���������� � ����������
   for line in f:lines() do message(tostring(line));end
   -- ��������� ����
   f:close();
   -- ���� ����� ����������, ���� IsRun == true
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
������� � ������������
������������ �� ����� LUA � QUIK � �������zip, 4 ��	
������� ������� ������� ����������� ��������� QUIK �� ����� Luazip, 76 ��
--]]

--[[

S = "�����";
string.byte(S, i); -- ���������� �������� ��� ������� � ������ �� ������� i
   -- i (�������������� ��������) - ��������� ������ (�� ���������, 1)
S:byte(i); -- ������������
 
string.byte(S, 1); -- ������ 210
string.byte(S, 2); -- ������ 229
string.byte(S, 3); -- ������ 234
string.byte(S, 4); -- ������ 241
string.byte(S, 5); -- ������ 242

string.char

string.char(n,...);               -- ���������� ������� �� �������� �����, ����� ��������� ����� ���������� ����� ����� �������
string.char(210);                 -- ������ "�"
string.char(210,229,234,241,242); -- ������ "�����"
string.dump

string.dump(func); -- ���������� �������� ������������� ������� func
string.find

-- ���� ��������� ��������� � ������ � ���������� ������ ������ ���������, ��� nil, ���� ���������� �� �������
S = "�����";
string.find(S,"���"); -- ������ 2
S:find("���"); -- ������������
-- � ������ ������ ����� ������������ ���������� ���������

string.format

-- ������� ����������������� ������
string.format("quik%scsharp%s", "lua", ".ru"); -- ������ ������ "quikluacsharp.ru"
 
-- �������������� �����:
%a	-- ����������������� � ���� 0xh.hhhhp+d (������ �99)
%A	-- ����������������� � ���� 0Xh.hhhhP+d (������ �99)
%c	-- ������ �� ����
%d	-- ���������� ����� �� ������
%i	-- ���������� ����� �� ������
%e	-- ���������������� ������������� ('�' �� ������ ��������)
%E	-- ���������������� ������������� ('�' �� ������� ��������)
%f	-- ���������� � ��������� ������
%g	-- � ����������� �� ����, ����� ����� ����� ������, ������������ %� ��� %f
%G	-- � ����������� �� ����, ����� ����� ����� ������, ������������ %� ��� %F
%o	-- ������������ ��� �����
%s	-- ������ ��������
%u	-- ���������� ����� ��� �����
%x	-- ����������������� ��� ����� (����� �� ������ ��������)
%X	-- ����������������� ��� ����� (����� �� ������� ��������)
%p	-- ������� ���������
%n	-- ��������, ��������������� ����� �������������, ������ ���� ���������� �� ������������� ����������. ������������ ��������� ��������� � ���� ���������� ���������� ���������� �������� (���������� �� ���� �����, � ������� ��������� ��� %n)
%%	-- ������� ���� %
string.match

string.match (S, "������", i); -- ���� ������ ��������� "�������" � ������ S, ��� ����������, ���������� ����������, ����� nil
   -- i (�������������� ��������) - ��������� � ������ �� ����� ������� �������� ����� (��-���������, 1)
S:match ("������", i); -- ������������
string.gmatch

string.gmatch (S, "������"); -- ���������� ��������, �������, ��� ������ ������, ���������� ��������� ��������� ������� � S
S:gmatch("������"); -- ������������
-- ������:
Str = "������, ���!";
for S in string.gmatch (Str, "�") do
-- �����-�� ���
end;
-- ������ ���� �������� 2 ��������, ������ ��� ������� � ���������� S ����� "�"
string.gsub

string.gsub(S, "������ ������", "������ ������", n); -- ���������� ����� S, � ������� ��� ��������� "������� ������" ���������� �� "������ ������", ������� ����� ���� �������, �������� ��� ��������, ������ ��������� ���������� ����� ���������� ����������� �����������
   -- � "������� ������" ������ % �������� ��� ������ �� ����������� �����������: ����� ������������������ � ���� %n, ��� n �� 1 �� 9, ���������� �� n-��� ����������� ���������
   -- n (�������������� ��������) - ��������� ������� �������� ��� ����� ������� �����������
S:gsub("������ ������", "������ ������", n); -- ������������
 
-- �������:
string.gsub("������, ���!", "���", "Lua"); -- ������ "������, Lua!"
string.gsub("������, ���!", "���", "%1%1"); -- ������ "������, ������!"
string.len

string.len(S); -- ���������� ����� ������ S
S:len(); -- ������������
#S;      -- ������������
string.upper

string.upper(S); -- ���������� ����� ������ S, ��� ��� ����� � ������ �������� �������� �� ����� � ������� ��������
S:upper(); -- ������������
string.lower

string.lower(S); -- ���������� ����� ������ S, ��� ��� ����� � ������� �������� �������� �� ����� � ������ ��������
S:lower(); -- ������������
string.rep

string.rep(S,n); -- ���������� ������, ������� �������� n ����� ������ S
S:rep(n); -- ������������
string.reverse

string.reverse(S); -- ���������� ������, � ������� ������� ������ S ����������� � �������� �������
S:reverse(); -- ������������
string.sub

string.sub(S, i, j); -- ���������� ��������� ������ S, ������� ���������� � ������� � �������� i � ������������� �������� � �������� j
   -- j (�������������� ��������) - ��-���������, ������ ���������� �������
S:sub(i,j); -- ������������
�������������� ����� ���������� ���������:

.	-- ����� ������
%a	-- ����� (������ ����.!)
%A	-- ����� ����� (�������), ������, ��� �����, ����� ���������� ����� 
%c	-- ����������� ������
%d	-- �����
%D	-- ����� �����, ��� ������, ����� �����
%l	-- ����� � ������ ��������� (������ ����.!)
%L	-- ����� �����, ������, ��� �����, ����� ���������� ����� � ������ ���������
%p	-- ������ ����������
%P	-- ����� �����, ������, ��� �����, ����� ������� ����������
%s	-- ������ ������
%S	-- ����� �����, ������, ��� �����, ����� ������� �������
%u	-- ����� � ������� ��������� (������ ����.!)
%U	-- ����� �����, ������, ��� �����, ����� ���������� ����� � ������� ���������
%w	-- ����� �����, ��� ����� (������ ����.!)
%W	-- ����� ������, ��� ����� (�������), ����� ���������� �����, ��� �����
%x	-- ����������������� �����
%X	-- ����� �����, ��� ������,  ����� �����, ��� ���������� �����, ������������ � ������ ������������������ ����� 
%z	-- ��������� ���������, ���������� ������� � ����� 0

--]]


--[[

https://quik2dde.ru/viewtopic.php?id=149


    ���� ������- � ����� �� ����� LUA ������ ������ ���� ��� �������� ����� ������� �� ������� ����������� � ����. � "�����������" ���� ����.
    �������� ���� �� �������� � Excel ��� ���� ������.
    �� ��� ������ ���� �� � txt ����.

    ���� � ����� ���� �� ������, ����� �� � ������ ���� ���� ������ ������ �������. �� �.� ����� ������ "���������", � ������ ����� ������ ������� ������� ������� ������� � � ��� ��������.
    ���� �� ���� ������ � ����� ������� ������� � ����� �������.
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

-- message("Human_time " .. to_human_time(DS:T(DS:Size())))
-- function to_human_time(time)
--     return tostring(string.format("%02d", time.hour) .. ":" .. string.format("%02d", time.min) .. ":" .. string.format("%02d", time.sec))
-- end
