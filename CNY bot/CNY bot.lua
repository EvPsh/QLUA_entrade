
------------------------------------------ ��������� ������-�������� -------------------------------------------------
--- ���� �������� � 19-10 �� 22-00 �� ���, ����� ���� ������ � range (+/- 1 ticks)
--- ����� ��������� ���� �� 19-10 ��� ������� � ������� ����, �������� �� ������ �������, tp + 1 tick, �� tp �������������� ������� + 1 tick
---

SEC_CODE = "CRU2" --��� �����������/������
CLASS_CODE = "SPBFUT" --��� ������ �����������/������, ���� ����� �������� ����� - ������� TQBR ������ SPBFUT
ACCOUNT = "SPBFUT00xx" -- ���� �� ������� �����

lot = 1 -- ��������� ���
tprofit = 0.02 -- 0.02 ����������� tp
spread = 0.00 -- �������� ��������� ����, ����� ������� ����� ���������� ������ �� ����/��������� ������� 0.08, 0.09
price = 8.90
--enPriceShort = 9.90 --enPriceLong + 0.01

----------------------------------------------------------------------------------------------------------------------

is_run = true
--inPosition = false
date1 = "" -- ���� � ����� ����� � �������
t_id = nil -- ������������� ������� (�������� ��������? = 0)
nFile = "" -- �������� ������������ ����� (�� ����� �����������)
scName = "" -- �������� ������������ �������

function OnInit()
    local pFile = "w:\\temp" --����, ��� ����� ����������� ����
	-- �������� ������ � ������ �������
	local Error = ""

	DS, Error = CreateDataSource(CLASS_CODE, SEC_CODE, INTERVAL_M1)
	-- ��������
	if DS == nil then
		message("������ ��������� ������� � ������! " .. Error)
		TGsend(scName .. ". ������ ��������� ������� � ������! " .. Error)
		is_run = false
		return
	end
	scName = string.match(debug.getinfo(1).short_src, "\\([^\\]+)%.lua$") -- ��������� ����� ����������� �������
	nFile = pFile .. "\\" .. tostring(SEC_CODE) .. "_" .. scName .. ".csv"
end

function OnStop()
	-- ������� ��� ���������� ������ (��� ������� �� ���������� ������, ����������� �����)
	--message("���������")
	DestroyTable(t_id)
	if inPosition then
		--kill all orders
		--message("�������� ���������� ������� �� " .. tostring(round(enPrice, 2) .. " " .. tostring(date1)))
	else
		is_run = false
	end
	-- ��������� ����
	--CSV:close()
end

function daysToDie(CLASS_CODE, SEC_CODE)
    local days = 0
    days = round(getParamEx(CLASS_CODE, SEC_CODE, "DAYS_TO_MAT_DATE").param_value, 0)
	
    if days <= 4 then
		message("���������� ���� �� ��������� ����������� " .. SEC_CODE .. " ����� " .. tostring(days) 
        .. ". ���������� �������� ���������� � ���������� ������ " .. scName)

		--TGsend("���������� ���� �� ��������� ����������� " .. SEC_CODE .. " ����� " .. tostring(daysToDie) .. ". ���������� �������� ���������� � ���������� ������ " .. scName)
	end
end

function main()

    local ticks = 0 -- ��������� ��������� (ticks)
	--local tickstemp = 0 -- ��� �������� ������������� �������� ticks
	local inPosition = false -- ���� � �������/���
	local numDeals = 0 -- ���������� ������ �� �������� ������
    --local ql2 -- ������� �������
    --local tp = 0 -- ���� ������
    
    daysToDie(CLASS_CODE, SEC_CODE) -- ��������� ���������� ���� �� ����� �����������
    CreateTable()

	lot = getLot(ACCOUNT, CLASS_CODE, SEC_CODE, 80) -- ������������ ��� = 50% �� ��������
	--message(tostring(lot).." - ������������ ���")

    while is_run do
        
        --[[
            �������� ��������� �������� �������� (�� 19-20 �� ���������), ����� ����� 22-00
            �������� ���� ������ long, ������ short, reverse mode (��� ���������� tp �������� �������)
            �������� �������� ��������� ������� (���� ������� ���������� ����� � ������� �� bid ������ ��� �� ask - ������ �������� �� �������, 
            ���� ����� - ����� ������ ������� bid > 1000, ���� ����� = ������� bid + 1
            ��������� �� ����������� ����/����� � �������
        --]]

            if inPosition == false then -- ���� �� ���� ����� ������� �� ����,
                date1 = tostring(os.date())
                
				-------------------------- ���� � ������� long + TakeProfit + stop-loss ---------------------------------
				BuyAsk(ACCOUNT, CLASS_CODE, SEC_CODE, price, lot)
					if CheckPosition(lot) == false then
						message(scName .. ". ������ ���������� ��� �������!")
						--TGsend(scName .. ". ������ ���������� ��� �������!")
						is_run = false
					end
				
				inPosition = true
				while inPosition do
					message(tostring(trans_reply.status))
					
					if trans_reply.status == 3 then
						inPosition = false
					end
		
					sleep(1000) -- ������
				end
				is_run = false -- ������

				SellBid(ACCOUNT, CLASS_CODE, SEC_CODE, price, lot)
					if CheckPosition(lot) == false then
						message(scName .. ". ������ ���������� ��� �������!")
						--TGsend(scName .. ". ������ ���������� ��� �������!")
						is_run = false
					end
				--SLTPorder(ACCOUNT, CLASS_CODE, SEC_CODE, "S", lot, tp, 0, 0, spread)
				
				----------------------------------------------------------------------------------------------------

            end
		end
end
--[[
    inPosition = true -- �� ������� ��� �� � �������
    numDeals = numDeals + 1
    SetCell(t_id, 1, 5, tostring(numDeals)) -- ���������� ������ ������� �������� � �������

    while inPosition do
        sleep(1000)

        ------ ������� � ��� ���������� �������	------------------------
        
        tickstemp = round((v2 - enPrice), 2) * 100 -- ������� ticks � ������
        ticks = ticks + tickstemp
        SetCell(t_id, 1, 6, tostring(ticks)) -- ��������� ������� � ������� �������� � �������

        pDataTable("��� �������", SEC_CODE, "", "", "", "")
        lightTable(tickstemp, 1, 6) -- ��������� ������ (���� ������ ���� = �������, ���� ������ = �������)
        lightAllTable(ticks) -- ��������� ������

        inPosition = false
    end
--]]







    
    -- �������� �������� �� �����
    -- ���� �������� inPosition = true
    -- ��� 5 ���
    -- �� � �������?
    -- ���� ��, ��� ���� �� ������
    -- ���� �� � ������� 
        -- ��������� � ��������� �� ������ ����
        --���� ���� - ��������, ���� ���� - ������.
    -- ���������� ���������� � tp
    -- ��� ������ �� �������

	
	

	-- QuoteStr = tostring(ql2.bid[tonumber(ql2.bid_count)].price) -- 1 - ������ ����, bid_count - ������� ���� ����� �������
	-- 	message(tostring(QuoteStr))
	
	-- QuoteStr = tostring(ql2.offer[1].price) --0 - nil, 1 - 1 ���� ������ �������, tonumber(ql2.offer_count) - ��������� ���� ������ ������� (������)
	-- 	message(tostring(QuoteStr))


--                 if v2 >= tp then
--                     --�������� tp
--                     --������� ������
--                     tp = v2 + tprofit
--                     sl = v2 - sloss -- trailing new
--                     --sl=v2-tprofit+sttr -- ��� trailing stop
--                     -- ��� ���� �������� ������� ������� ������ (������ ����� � ����)

--                     pDataTable(date1, SEC_CODE, "+", enPrice, sl, tp) -- sl --> � sttr

--                     -- ������� trailing ����� �� �������� QUIK.
--                     -- ���� ��������� ����� �� tprofit, ������ ��������:
--                     --[[
--                         logger (date1, tostring (os.date()), SEC_CODE, "+", lot, enPrice, v2)
--                         tickstemp = round((v2 - enPrice), 2) * 100 -- ������� ticks � ������
--                         ticks = ticks + tickstemp
--                         SetCell(t_id, 1, 6, tostring(ticks)) -- ��������� ������� � ������� �������� � �������
--                         pDataTable("��� �������", SEC_CODE, "", "", "", "")
--                         inPosition = false
--                     --]]
--                 end
--             end

--             -- elseif inPosition then -- ���� ��� � ������� � ����������� '+'
--             -- ���������� ������, ����� ��������� sl � sttr
--         end

--     elseif rslt >= spread then -- ��� reverse mode
--     -- elseif rslt <= -spread then -- ��� direct mode

--         TGsend(scName .. ". �������� �� " .. SEC_CODE
--         .. ", ������� � ticks = " .. rslt .. ". ������ �� ������� �� "
--         .. v2 .. ". ����� " .. getInfoParam("SERVERTIME"))

--         if inPosition == false then -- ���� �� ���� ����� ������� �� ����,
--             -- ������� short
--             enPrice = v2 --������ �������� �� ���� V2
--             date1 = tostring(os.date())

--             sl = enPrice + sloss -- stop Loss
--             tp = enPrice - tprofit -- take Profit

--             if tradeFlag == true then
--                 -- orderSellMarket (id, SEC_CODE)
--                 -- �������� ������������
--                 -- orderSLBuy (id, SEC_CODE, sl)

--                 -- enPrice = getInfoParam(xxx).param_value  -- �������� ���� �����

--                 -- trans_id ���������� ������ �������.
--                 -- �������� ����������
--                 -- �������� ������������
--                 -- �������� ��������� ������ sl � tp. ����� �������
--                 -- ����� ���������� � �������
--             end

--             -- ����� ���������� � �������
--             --message("-"..tostring(enPrice).." "..tostring(date1))
--             pDataTable(date1, SEC_CODE, "-", enPrice, sl, tp)

--             inPosition = true -- � �������
--             numDeals = numDeals + 1 -- ���������� ������ ����� �� 1 ������
--             SetCell(t_id, 1, 7, tostring(numDeals)) -- ���������� ������ ������� �������� � �������

--             while inPosition == true do
--                 v2 = round(getParamEx(CLASS_CODE, SEC_CODE, "last").param_value, 2)
--                 sleep(1000)

--                 if v2 >= sl then
--                     -- �������� sl
--                     -- ��������� ������������

--                     ------ ������� � ��� ���������� �������	------------------------
--                     logger(date1, tostring(os.date()), SEC_CODE, "-", lot, enPrice, v2)
--                     tickstemp = tonumber(string.format("%.2f", round(enPrice - v2, 2))) * 100 -- ������� ticks � ������
--                     ticks = ticks + tickstemp
--                     SetCell(t_id, 1, 6, tostring(ticks)) -- ��������� ������� � ������� �������� � �������

--                     pDataTable("��� �������", SEC_CODE, "", "", "", "")
--                     lightTable(tickstemp, 1, 6) -- ��������� ������ (���� ������ ���� = �������, ���� ������ = �������)
--                     lightAllTable(ticks) -- ��������� ������

--                     inPosition = false
--                 end

--                 if v2 <= tp then
--                     --�������� tp
--                     --������� ������

--                     tp = v2 - tprofit
--                     sl = v2 + sloss -- trailing new
--                     --sl=v2+tprofit-sttr -- ��� trailing stop
--                     pDataTable(date1, SEC_CODE, "-", enPrice, sl, tp) -- sl -> sttr
--                     -- ��� ���� ��������� ������ ������ ������� (������ � ����)

--                     -- ���� ����� ����� �� tprofit, ������ ��������:
--                     --[[
--                     logger (date1, tostring (os.date()), SEC_CODE, "-", lot, enPrice, v2)
--                     tickstemp = tonumber(string.format("%.2f", round(enPrice - v2, 2))) * 100 -- ������� ticks � ������
--                     ticks = ticks + tickstemp
--                     SetCell(t_id, 1, 6, tostring(ticks)) -- ��������� ������� � ������� �������� � �������
--                     pDataTable("��� �������", SEC_CODE, "", "", "", "")
--                     inPosition=false
--                     --]]
--                 end
--             end
--         end
--     end
-- end

function PosNowFunc(account, seccode) -- ��������������� �-��� � CheckPosition
	-- ����������� ������� ������� �� ����������� seccode ����� account
	-- �� �-��� ����� ������� ��� �� ������ ���������
	-- seccode = SEC_CODE
	-- account = ACCOUNT

	local nSize = getNumberOf("futures_client_holding")
	local i = 0
	if (nSize ~= nil) then
		for i = 0, nSize - 1 do
			local row = getItem("futures_client_holding", i)
			if (row ~= nil and row.sec_code == seccode and row.trdaccid == account) then
				return tonumber(row.totalnet)
			end
		end
	end
	return 0
end

function CreateTable()
	-- ������� �������� ������� � ������������
	local days = round(getParamEx(CLASS_CODE, SEC_CODE, "DAYS_TO_MAT_DATE").param_value, 0)

	t_id = AllocTable()
	-- ��������� �������
	AddColumn(t_id, 0, "����", true, QTABLE_STRING_TYPE, 25)
	AddColumn(t_id, 1, "����������", true, QTABLE_STRING_TYPE, 15)
	AddColumn(t_id, 2, "���" .. "(" .. spread .. ")", true, QTABLE_STRING_TYPE, 15)
	AddColumn(t_id, 3, "���� �����", true, QTABLE_STRING_TYPE, 15)
	--AddColumn(t_id, 4, "Stop Loss " .. "(" .. sloss .. ")", true, QTABLE_STRING_TYPE, 17)
	AddColumn(t_id, 4, "Take Profit " .. "(" .. tprofit .. ")", true, QTABLE_STRING_TYPE, 17)
	AddColumn(t_id, 5, "���������", true, QTABLE_STRING_TYPE, 14)
	AddColumn(t_id, 6, "���-�� ������", true, QTABLE_STRING_TYPE, 14)
	-- �������
	--t = CreateWindow(t_id)
	CreateWindow(t_id)
	-- ���� ���������
	SetWindowCaption(t_id, "����� ������� " .. scName .. " / " .. spread .. " ����� / "
	.. tprofit .. " tp / " .. SEC_CODE .. " / ���� ��: ".. days)
	-- ������������ ���� �������
    SetWindowPos(t_id, 0, 820, 760, 90) --x, y, dx, dy
	-- ��������� ������
	InsertRow(t_id, -1)
end

function pDataTable(date1, instrument, direction, entry_price, tprofit, result, numDeals) -- �-��� ���������� �������
	-- �-��� ���������� �������
	-- ���� �����
	-- ����������
	-- �����������
	-- ���� �����
	-- ����-����
	-- ����-������
	-- ���������� ������ �� �������� ������
	---

	--Clear(t_id)
	SetCell(t_id, 1, 0, tostring(date1))
	SetCell(t_id, 1, 1, tostring(instrument))
	SetCell(t_id, 1, 2, tostring(direction))
	SetCell(t_id, 1, 3, tostring(entry_price))
	--SetCell(t_id, 1, 4, tostring(sloss))
	SetCell(t_id, 1, 4, tostring(tprofit))
    SetCell(t_id, 1, 5, tostring(result)) -- ��������� ������ �������� �� ������� pDataTable
	SetCell(t_id, 1, 6, tostring(numDeals)) -- ��������� ����������
	
end

function logger(date1, date2, instrument, quantity, entry_price, exit_price)
	-- ������� ������������ ������.
	-- ������� ���� � ����������� ����������� ����������? a,b,c..z
		-- ����� ����� ���������� arr() �� ����
		-- ����� ������ �������������� from arr(1) to #arr()
	--

	-- direction � quantity ����� ���������� � ���� ������� quantity, � ���� ���������� '+1' ��� '-1'

	CSV = io.open(nFile, "a+")
	local Position = CSV:seek("end", 0)
	local x = 0 -- exit_price-entry_price ��� ��������
	local txt = "" --��� ������ � ����
	local pnlstr = ""

	--� logger ������� ����, �����_�����, �����_������, ����������, �����������, ���, ����_�����, ����_������, PnL, H, L, ������� (-) O-H, L-O (���� ���� � (+) H-O, O-L)

	local kDollar = round(getParamEx(CLASS_CODE, SEC_CODE, "STEPPRICE").param_value, 3) -- �������� ��������� ���� ���� � ����������� �� ��� ������. ���� STEPPRICET
	-- ���� ���� �� ������
	-- ��������� ������������� ����� � �������� ����� �������
	if Position == 0 then
		-- ��������� ������ ������� �����
		-- ������� ������ � ����������� ��������
		local Header =
		"����1;����2;��� ������;����������;����_�����;����_������;Ticks;PnL\n"
		-- ��������� ������ ���������� � ����
		CSV:write(Header)
		-- ��������� ��������� � �����
		CSV:flush()
		Position = CSV:seek("end", 0)
	end

	if Position ~= 0 then --��� � ��������� ������ csv �����
		-- ������� ������ � ������������
		-- "����;�����;��� ������;��������;����������;����_�����;����_������;PnL*���\n"
		if quantity > 0  then
			x = tonumber(string.format("%.2f", exit_price - entry_price)) * 100 -- ������� ticks � ������
		elseif quantity < 0 then
			x = tonumber(string.format("%.2f", entry_price - exit_price)) * 100 -- ������� ticks � ������
		else
			x = 0 -- ���� � direction ������ �� ������� ��� �����������
		end

		--xstr=string.gsub(tostring(x), "%.", ",") -- ������ � ������� ���������� ����� �� ������� ��� csv
		--entry_price_str=string.gsub(tostring(entry_price), "%.", ",") -- ������ ����� �� ������� � ���� ����_�����
		--exit_price_str=string.gsub(tostring(exit_price), "%.", ",") -- ������ ����� �� ������� � ���� ����_������

		pnlstr = tostring(x * math.abs(tonumber(quantity)) * kDollar) -- ��������� �� �������
		--pnlstr=string.gsub(pnlstr, "%.", ",") -- ������ ����� �� ������� � ���������� �� �������

		txt = tostring(date1) ..
			";" ..
			tostring(date2) ..
			";" ..
			tostring(instrument) ..
			";" ..
			tostring(quantity) ..
			";" ..
			comma(entry_price) ..
			";" ..
			comma(exit_price) ..
			";" ..
			comma(x) ..
			";" ..
			comma(pnlstr) ..
			";" .. "\n"
		-- txt = tostring(time)..";"

		-- ��������� ������ ����������� � ����
		CSV:write(txt)

		-- ��������� ��������� � �����
		CSV:flush()

		-- ��������� ����
		CSV:close()
	else
		--message("������ �������� ����� ")
	end
end

function comma(what)
	-- ������� ������ '.' �� ',' � what � ���������� ��������� ��������
	local xstr = string.gsub(tostring(what), "%.", ",")
	return tostring(xstr)
end

function round(what, signs)
	-- ������� ���������� ����� what � ����������� ������ signs. ��������� �� ������ ���������, �� ��� ����� �����
	--
	--local formatted = string.format("%."..signs.."f",what*100/100)
	local formatted = string.format("%." .. signs .. "f", what)
	return tonumber(formatted)
end

function BuyAsk(account, classcode, seccode, price, size)
	-- ������� ��� ������� �������
	-- �������� �� ���� ask
	---

	--local ql2
	local trans_id = "300"
	--local best_offer = getParamEx(classcode, seccode, "offer").param_value
	--local best_offer = 0

	--ql2 = getQuoteLevel2(classcode, seccode)
	--best_offer = tonumber(ql2.offer[1].price) --0 - nil, 1 - 1 ���� ������ ������� �� ������� (long pos), tonumber(ql2.offer_count) - ��������� ���� ������ ������� (������)
	--price = tostring(ql2.bid[tonumber(ql2.bid_count)].price) -- 1 - ������ ����, bid_count - ������� ���� ����� ������� �� ������� (short pos)
	
	if price == 0 then
		message("������ ��������� ��������� ����.\n ���������")
		--TGsend(scName .. ". ������ ��������� ��������� ����. ���������")
		DestroyTable(t_id)
		is_run = false
	end

	local transaction = {
		["ACTION"] = "NEW_ORDER",
		["SECCODE"] = seccode,
		["ACCOUNT"] = account,
		["CLASSCODE"] = classcode,
		["OPERATION"] = "B",
		["PRICE"] = tostring(price), --tostring(best_offer)
		["QUANTITY"] = tostring(size),
		["TYPE"] = "L",
		["TRANS_ID"] = trans_id,
		["CLIENT_CODE"] = account
	}
	--message(tostring(transaction.status))
	local res = sendTransaction(transaction)

	if #res ~= 0 then
		message (scName .. ". ������ �������� ���������� �� �������. ���������")
		--TGsend(scName .. ". ������ �������� ���������� �� �������. ���������")
		is_run = false
	end
end

function CheckPosition(lot)
	-- ������� �������� �������� ������� = ������������ ����. true/false

	local count = 1
	local posNew = 0

	sleep(100)
	for i = 1, 300 do
		posNew = math.abs(PosNowFunc(ACCOUNT, SEC_CODE))
		if posNew == lot then
			--TGsend(scName.. ". ���������� ������ �� "..tostring(count*100).." ����")
			message(scName.. ". ���������� ������ �� "..tostring(count*100).." ����")
			return true
		end
		count = count + 1
		sleep(100)
	end
	return false
end

-- function SLTPorder(account, classcode, seccode, buySell, qty, tprice, slprice, prof_offset, prof_spread)
-- 	-- ������� ��������� ����-������ ������� �� ������� � ��������
-- 	-- trans_id ������� ����������, ������� + ����������� ������ ������ ���� � ����� �������
-- 	-- buySell ="B" -- ��� "S" �������/�������
-- 	-- qty - ���������� �����
-- 	-- tprice - take Profit ����
-- 	-- slprice - stop Loss ����
-- 	-- prof_offset - ������
-- 	-- prof_spread - �������� �����

-- 	local stprice = 0 -- ���� ����-������ ��� ������ �� ������� �� stop-loss

-- 	if buySell == "B" then
-- 		stprice = slprice - prof_spread
-- 	elseif buySell == "S" then
-- 		stprice = slprice + prof_spread
-- 	else
-- 		TGsend(scName .. ". ������� ������� ����������� ������ TakeProfit & StopLoss. ���������")
-- 		is_run = false
-- 	end

-- 	local trans_id = "300"
-- 	local transaction = {
-- 		["ACTION"] = "NEW_STOP_ORDER",
-- 		["TRANS_ID"] = trans_id,
-- 		["CLASSCODE"] = classcode,
-- 		["SECCODE"] = seccode,
-- 		["ACCOUNT"] = account,
-- 		["CLIENT_CODE"] = account,
-- 		["OPERATION"] = buySell,
-- 		["QUANTITY"] = tostring(qty),
-- 		["PRICE"] = tostring(slprice), -- ���� SL ��� �������
-- 		["STOPPRICE"] = tostring(tprice), -- ��������� TP
-- 		["STOP_ORDER_KIND"] = "TAKE_PROFIT_AND_STOP_LIMIT_ORDER",
-- 		["OFFSET"] = tostring(prof_offset), -- ������ �� ����
-- 		["OFFSET_UNITS"] = "PRICE_UNITS",
-- 		["SPREAD"] = tostring(prof_spread), -- �������� �����
-- 		["SPREAD_UNITS"] = "PRICE_UNITS",
-- 		["MARKET_TAKE_PROFIT"] = "NO",
-- 		["STOPPRICE2"] = tostring(stprice), -- Sl price
-- 		["EXPIRY_DATE"] = "TODAY",
-- 		["MARKET_STOP_LIMIT"] = "NO" --? YES
-- 	}
-- 	local result = sendTransaction(transaction)
-- end


-- function TransOpenPos()
-- 	-- ���������� ������ �� �������� �������
-- 	-- �������� ID ��� ��������� ����������
-- 	trans_id = trans_id + 1
-- 	-- ��������� ��������� ��� �������� ����������
-- 	local Transaction={
-- 	  ['TRANS_ID']  = tostring(trans_id),   -- ����� ����������
-- 	  ['ACCOUNT']   = ACCOUNT,              -- ��� �����
-- 	  ['CLASSCODE'] = CLASS_CODE,           -- ��� ������
-- 	  ['SECCODE']   = SEC_CODE,             -- ��� �����������
-- 	  ['ACTION']    = 'NEW_ORDER',          -- ��� ���������� ('NEW_ORDER' - ����� ������)
-- 	  ['OPERATION'] = 'B',                  -- �������� ('B' - buy, ��� 'S' - sell)
-- 	  ['TYPE']      = 'L',                  -- ��� ('L' - ��������������, 'M' - ��������)
-- 	  ['QUANTITY']  = '1',                  -- ����������
-- 	  ['PRICE']     = tostring(OpenPrice)   -- ����
-- 	}
-- 	-- ���������� ����������
-- 	local Res = sendTransaction(Transaction)
-- 	if Res ~= '' then message('TransOpenPos(): ������ �������� ����������: '..Res) else message('TransOpenPos(): ���������� ����������') end
--   end
   
--   -- ������� ���������� ����������, ����� � ������� �������� ����� ���������� � �����������
  function OnTransReply(trans_reply)
	
	local ticks = 0
	local numDeals = 0
	
	-- ���� ������ ���������� �� ����� ����������
	 if trans_reply.trans_id == trans_id then
	
		-- ���� ������ ������ ��� ��� ���������, ������� �� �������, ����� ���������� ������, ����� �� ������������ ��� ��������
		if trans_reply.status == LastStatus then
			return
		else
			message(tostring(trans_reply.status))
			LastStatus = trans_reply.status
		end

		if trans_reply.status == 3 then -- ���� ���������� ���������
			ticks = ticks + tprofit
			numDeals = numDeals + 1
			pDataTable(date1, SEC_CODE, lot, price, tprofit, ticks, numDeals)
			logger(date1, tostring(os.date()), trans_reply.sec_code, lot, trans_reply.price, tprofit) -- ��������� ��� ������ � ����

			lot = -lot

		end


                
                

		-- ������� � ��������� ������� ���������� ����������
		-- if       trans_reply.status == 0    then message('OnTransReply(): ���������� ���������� �������') 
		-- elseif   trans_reply.status == 1    then message('OnTransReply(): ���������� �������� �� ������ QUIK �� �������') 
		-- elseif   trans_reply.status == 2    then message('OnTransReply(): ������ ��� �������� ���������� � �������� �������. ��� ��� ����������� ����������� ����� ���������� �����, �������� ���������� �� ������������') 
		-- elseif   trans_reply.status == 3    then message('OnTransReply(): ���������� ��������� !!!') 
		-- elseif   trans_reply.status == 4    then message('OnTransReply(): ���������� �� ��������� �������� ��������. ����� ��������� �������� ������ ������������ � ���� ���������� (trans_reply.result_msg)') 
		-- elseif   trans_reply.status == 5    then message('OnTransReply(): ���������� �� ������ �������� ������� QUIK �� �����-���� ���������. ��������, �������� �� ������� ���� � ������������ �� �������� ���������� ������� ����') 
		-- elseif   trans_reply.status == 6    then message('OnTransReply(): ���������� �� ������ �������� ������� ������� QUIK') 
		-- elseif   trans_reply.status == 10   then message('OnTransReply(): ���������� �� �������������� �������� ��������') 
		-- elseif   trans_reply.status == 11   then message('OnTransReply(): ���������� �� ������ �������� ������������ ����������� �������� �������') 
		-- elseif   trans_reply.status == 12   then message('OnTransReply(): �� ������� ��������� ������ �� ����������, �.�. ����� ������� ��������. ����� ���������� ��� ������ ���������� �� QPILE') 
		-- elseif   trans_reply.status == 13   then message('OnTransReply(): ���������� ����������, ��� ��� �� ���������� ����� �������� � �����-������ (�.�. ������ � ��� �� ����� ���������� ������)')
		-- end
	 end
  end

  function SellBid(account, classcode, seccode, price, size)
	-- ������� ��� ������� �������
	-- ������� �� ���� bid
	-- ���� ���������� �� market ����� (������� ���� �-��� �����/������� �����������)

	local trans_id = "300"
	--local best_bid = getParamEx(classCode, secCode, "bid").param_value
	local best_bid = price

	local transaction = {
		["ACTION"] = "NEW_ORDER",
		["SECCODE"] = seccode,
		["ACCOUNT"] = account,
		["CLASSCODE"] = classcode,
		["OPERATION"] = "S",
		["PRICE"] = tostring(best_bid),
		["QUANTITY"] = tostring(size),
		["TYPE"] = "L",
		["TRANS_ID"] = trans_id,
		["CLIENT_CODE"] = account -- ����� ����������� �����������
	}
	local res = sendTransaction(transaction)

	if #res ~= 0 then
		--TGsend(scName .. ". ������ �������� ���������� �� �������. ���������")
		message (scName .. ". ������ �������� ���������� �� �������. ���������")
		is_run = false
	end
end

function getLot(account, classcode, seccode, ltPercent)
	--function getLot(account, classcode, seccode, ltPercent)
	--
	-- ������� ��������� ���������� ���������� �����,
	-- ������ �� �� � ������� �� �����. ���������� �������� ��������
	-- ltPercent = 100 -- ������������ ��� ��������� �������� �� �����

	local lbuy = tonumber(getParamEx(classcode, seccode, "BUYDEPO").param_value) -- �� ����������
	local lsell = tonumber(getParamEx(classcode, seccode, "SELLDEPO").param_value) -- �� ��������
	
	local fMoney = getItem("futures_client_limits", 0).cbplimit
	--message("������� �� ����� "..tostring(fMoney))
	
	local vm1 = getFuturesLimit(classcode, account, 0, "SUR").varmargin -- �������� ���. ����� �� ��������
	message(tostring(vm1))
	local vm2 = getFuturesLimit(classcode, account, 0, "SUR").accruedint --�������� ���. ����� ����� ��������
	message(tostring(vm1).."----")
	-- �������� ������� ���.����� �, ���� ��� �������������, �� ������� �� fMoney; ���� �������������, �� ������ �� ������.
	if vm1 < 0 then
		if vm2 < 0 then
			fMoney = fMoney + vm1 + vm2
			message(tostring(fMoney.."�������"))
		end
		fMoney = fMoney - vm1
		message(tostring(fMoney.."������� 2"))
	else
		message(tostring(fMoney.."������� 3")) -- ��������
	end
	is_run = false

	-- ������ ���� ������ �� ������������� �� ��� �����������.
	if fMoney == 0 or fMoney == "" or fMoney == nil then -- ���� ������ �� ��������� ��������� �� ��������
		return 0
	else
		if lbuy <= lsell then
			lot = round(fMoney * ltPercent / 100 / lsell, 0)
		else
			lot = round(fMoney * ltPercent / 100 / lbuy, 0)
		end
	end
	return lot
end
