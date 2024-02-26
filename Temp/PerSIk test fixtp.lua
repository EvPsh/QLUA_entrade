-- ��������� ------------------------------------------------------------------------------------
is_run = true
----------------------- ��������� ������, �����������, ���������� ��������� ---------------------

dofile(getScriptPath() .. "\\include\\PeachSI_settings.lua")
-- ���������� ����� Peach_settings.lua
--SEC_CODE = "BRH2" --��� �����������/������
--CLASS_CODE = "SPBFUT" --��� ������ �����������/������, ���� ����� �������� ����� - ������� TQBR ������ SPBFUT
--ACCOUNT = "SPBFUT001dh" -- ���� �� ������� �����

--[[
	��� � ����� test
	git@github.com:EvPsh/QLUA_robot.git
	https://github.com/EvPsh/QLUA_robot.git
	-- ������� ����� ���������� demo+trade ����� �� ������� ��������� ������
--]]
----------------------------------------- ������������ ��������� ���������� ----------------------------------
SEC_PRICE_STEP = 0 --0.01 ��� ���� ��� �����������
enPrice = nil -- ���� �����
v2 = 0 -- ��������� ���� ������ (�� ��������� ��� �������� � ������� �� ������ ����)
date1 = "" -- ���� � ����� ����� � �������
inPosition = false -- � ������� ��/���
t_id = nil -- ������������� ������� (�������� ��������? = 0)
nFile = "" -- �������� ������������ ����� (�� ����� �����������)
scName = "" -- �������� ������������ �������
tTime = {
	"7:00:00", "9:10:00", -- ����� ������/��������� ����������� �������
	"13:45:00", "14:06:00", -- ����� ������/��������� ����������� �������
	"18:30:00", "19:08:00", -- ����� ������/��������� ����������� �������
	"23:30:00", "23:50:00" -- ����� ������/��������� ����������� �������
	-- �� ������� ��������� �� ������ ��������,
	-- ������ ����� 16:10. � ���������� ����� 14:00 � 16:10 �� ��������
	}

---------------------------------------- ���������� ��������� ���������� ������-������� --------------------
INTERVAL = INTERVAL_M1 -- ��������� ��������

lotPercent = 100 -- ���������� % ��������� �������� (� ���������) ��� ��������
sloss = 100 -- 0.17 ����������� sl
tprofit = 150 --25 ticks tp
--sttr = 0.03 -- ��� ����������� sl � sttr
spread = 51 -- �������� ��������� ����, ����� ������� ����� ���������� ������ �� ����/��������� ������� 0.08, 0.09
slTime = 30000 -- �������� ���������� ��������� ����� ���������� ������ 5000 --���� 20000 (20 ���)
pFile = "w:\\temp" --����, ��� ����� ����������� ����
-------------------------------------------------------------------------------------------------

--corrTime=3 --����� ���. C ������� ����� �������� ��� �������������.

--[[
-- ��������/�������� ������� �� ������� (super scalp)?

-- � ���� ������������� ���� ��� � ������ �������� ������� 8 ticks � ���� � �����������
-- ������ ���� 8 ticks � tp=high-open ��� low-close �� ��������� n ������.

-- �������� ������ � ��
-- �������� ������������ (����������� ������������� sl <= x � ���� spread) x = avg(o-c) ��� avg(h-l)

-- �������� ����������
-- �������� ������������ ���������� � ���������� �����
--	-- ���� �� ��, �� �����. ���� �� ��, �����?
-- � ������: �������� ����-������� (� ��������������, ��� ���������� ������ �������, ����� ������� �� �����)
-- -- ������������ sl ������� �� ������� ����������
-- -- ��� ������������ sl �������, �������� ��� ������� �������. ������ � ���� ������ ��������� ����� ������.
-- --
-- � 23-30 �������� �������, ������ �������
-- ��� sl ������ = ��������� �� ����� ���
-- ������� ������ �� ����������� - �������� ������� �� marketprice (����� �� scalp)
-- ������� ������ �� sl - ��������� sl = v2-0.2 � ���������� (sl ������ ���� ������ v2, ����� - �����)

https://smart-lab.ru/blog/762089.php

1.�����
2.���������
3.��������.
1. ����������� ������ ���������� ��������� 55/45 (60/40 � ��������)
2. ����������� ����/�������� 1/1 ������� (1,2/1 ��� �����).

�������� ������ � �������� ��� ������� ������-�������.
����� ������� �� ����
���� ����������� ������� �� �������� - ������� �������, ������ � ���������� ����������� 8 ������ ����� 54 Qlua Parabolic
����� ������� �� �����

������� ��������� ������� �� �������� (����������� � excel)
�������� ������ quik. ���� �� �������� - ��������� �������� ������� (������ � �� ������ ����������). ������� �� �������� ���������.

--]]
-------------------------------------------------------------------------------------------------
function stopProfit(result, what) -- ��������
	-- ������� ���������� ticks, ������� � stopProfit
	-- ���������� � what,
	-- ���� ������ what, ��� ��������� ������,
	-- ���� ������ ������� � ����� = ����-�����
	-- �������������:
	--[[
		1. ������ ����� �������� - � 10-00:
		�� +50 ������ (what)
		��� ������ +50 ������ ��� ��������� ������.
			��� ������ -50 ������ - ���� ����� �� ����� ���
				���� ������ � ���� - ��� ��������� ������
				���� ������ � ����� - ���� ����� �� ������� �����-���������.
					���� �������� ����� �� ������, �� ���������� �� �������� - ������� ������ �������, ������ ����������.
			���� 50 ������ �� �������, � ����� ������� �� ������ ����� - ������ � ����������� ��������� �� ���������

			������ ����� �������� - � 12-00
			��� ������ -50 ������ - ���� ����� �� ����� ���
			��� ������ +50 ������ ��� ��������� ������.
				���� ������ � ���� - ��� ��������� ������
				���� ������ � ����� - ���� �����
					���� �������� ����� �� ������, ������ ����������.
			���� 50 ������ �� �������, � ����� ������� �� ������ ����� - ������ � ����������� ��������� �� ���������

			������ ����� �������� � 16-00 �� 17-00
			��� ������ -50 ������ - ���� ����� �� ����� ���
			��� ������ +50 ������ - ��� ��������� ������
				���� ������ � ���� - ��� ��������� ������
				���� ������ � ����� - ���� �����

			��������� ����� �������� � 17-00 �� 19-00 -- ��������� ��������
			��� ������ -50 ������ - ���� ����� �� ����� ���
			��� ������ +50 ������ - ��� ��������� ������
				���� ������ � ���� - ��� ��������� ������
				���� ������ � ����� - ���� �����
	-- ]]

	if result >= what then
		return true
	end
	return false
end

function threeTradesMinus(result, tCount) -- ��������! tCount - ���������� ��������� ������ (�� ����� �������)
	-- �������� ������: ����, �����, ������� ������� ����� ����, ������� � �-���, ����� �������� +1, ���� -1 ��� ���������� ������� ������������
	-- tradesCount - ���������� ����������, �������� ���� �� ���������

	-- �-��� threeMinusTrades: 3 ������ � ����� ������ - ����-����� �� ����
	-- ���� ������ � ���� - ���
	-- ���� ������ � �����, ������� �� ���
	-- ������ ������ � �����, ������ - ���� �����
	--
	--[[
	�������� inPosition, ���� false - ��� ������
	���� true - ��� �� ��� ���, ���� �� ������ false
		���� ��������� +, ��� ������
		���� ��������� -, ������� tradesCount ���������� �� 1
	tradesCount = tCount ? ���������, ����� �� ���� � �������
	���� �� - stopTrade
	--]]
	-- �������������:
	--[[
		tradesCount = 0
	--]]
	if result < 0 then
		tradesCount = tradesCount + 1
	else
		-- ��������, ���� ����� ����� ������������� ���� ������������� - ����� ��������
		tradesCount = 0
	end

	if tradesCount == tCount then --tCount ���������� ��������� ������ ������
		return true
	end
	return false
end

function PosNowFunc(account, seccode)
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

function OnInit()
	-- �������� ������ � ������ �������
	local Error = ""

	DS, Error = CreateDataSource(CLASS_CODE, SEC_CODE, INTERVAL)
	-- ��������
	if DS == nil then
		message("������ ��������� ������� � ������! " .. Error)
		TGsend(scName .. ". ������ ��������� ������� � ������! " .. Error)
		-- ��������� ���������� �������
		is_run = false
		return
	end
	scName = string.match(debug.getinfo(1).short_src, "\\([^\\]+)%.lua$") -- ��������� ����� ����������� �������
	nFile = pFile .. "\\" .. tostring(SEC_CODE) .. "_" .. scName .. ".csv"
end

function getLot(account, classcode, seccode, ltPercent)
	--
	-- ������� ��������� ���������� ���������� �����,
	-- ������ �� �� � ������� �� �����. ���������� �������� ��������
	-- ltPercent = 100 -- ������������ ��� ��������� �������� �� �����

	local lbuy = getParamEx(classcode, seccode, "BUYDEPO").param_value -- �� ����������
	local lsell = getParamEx(classcode, seccode, "SELLDEPO").param_value -- �� ��������
	--local fMoney = getFuturesLimit(CLASS_CODE, ACCOUNT, 0, "SUR").cbplimit -- ��������� ���� ��� ���� ��������������� ��, ������� ��������� ����� ��� ���
	--local fMoney = getDepo(account, classcode, seccode, "depo_current_balance").param_value
	local fMoney = getItem("futures_client_limits", 0).cbplimit
	--message("������� �� ����� "..tostring(fMoney))

	-- ������ ���� ������ �� ������������� �� ��� �����������.
	if fMoney == 0 or fMoney == "" or fMoney == nil then -- ���� ������ �� ��������� ��������� �� ��������
		return 0
	else
		if lbuy <= lsell then
			lot = round(fMoney * ltPercent / 100 / lsell, 0)
		else
			lot = round(fMoney * ltPercent / 100 / lbuy, 0)
		end
		return lot
	end

	--[[
		TABLE getDepo (STRING client_code, STRING firmid, STRING sec_code, STRING trdaccid)
		�������� ��� ��������
		depo_limit_locked_buy_value NUMBER ��������� ������������, ��������������� �� �������
		depo_current_balance NUMBER ������� ������� �� ������������
		depo_limit_locked_buy NUMBER ���������� ����� ������������, ��������������� �� �������
		depo_limit_locked NUMBER ��������������� ���������� ����� ������������
		depo_limit_available NUMBER ��������� ���������� ������������
		depo_current_limit NUMBER ������� ����� �� ������������
		depo_open_balance NUMBER �������� ������� �� ������������
		depo_open_limit NUMBER �������� ����� �� ������������
	--]]
end

function main()
	--sleep (10000) -- ������������ �� 10 ���., ����� ����� � "���" �� ������
	local exPrice = 0 -- ���� ������ �� �������
	local sl = 0 -- ����-����
	local tp = 0 -- ����-������
	local ticks = 0 -- ��������� ��������� (ticks)
	local tickstemp = 0 -- ��� �������� ������������� �������� ticks
	local pos = 0 -- ������� �� �����������
	local lot = 0 -- ��������� ���, ���� 0 -> ������ ���������
	local daysToDie = 0 -- ���������� ���� �� ��������� �����������

	-- �������� ���������� ���� �� ���������, ���� < 4, ����������� ������� �� ����� ����������
	-- https://quikluacsharp.ru/quik-qlua/poluchenie-dannyh-iz-tablits-quik-v-qlua-lua/
	daysToDie = round(getParamEx(CLASS_CODE, SEC_CODE, "DAYS_TO_MAT_DATE").param_value, 0)
	--message(tostring(daysToDie))
	if daysToDie <= 4 then
		message("���������� ���� �� ��������� ����������� " .. SEC_CODE .. " ����� " .. tostring(daysToDie) .. ". ���������� �������� ���������� � ���������� ������ " .. scName)
		TGsend("���������� ���� �� ��������� ����������� " .. SEC_CODE .. " ����� " .. tostring(daysToDie) .. ". ���������� �������� ���������� � ���������� ������ " .. scName)
	end

	-- �������� ��� ���� �����������
	SEC_PRICE_STEP = getParamEx(CLASS_CODE, SEC_CODE, "SEC_PRICE_STEP").param_value

	-- �������� ������������ ��� ��� ��������, ���� 0 - �����
	lot = getLot(ACCOUNT, CLASS_CODE, SEC_CODE, lotPercent)
	if lot == 0 or lot == nil or lot == "" then
		--message ("�����_������_������. �������� ���. ������� ��� ��, �����")
		--TGsend(scName..". �������� ���. ������� ��� �� ��� ������ ��������� ������� �� �����, �����")
		--is_run=false
	end

	-- ������������� �������
	CreateTable()
	SetTableNotificationCallback(t_id, f_cb)

	while is_run do
		-- ����� �� ������� �� � �� �� �������
		-- ���� ����� ������� = ��������� �������� �������, �� ��� �� ���������� (�������) �������� �������
		----------- ��������� ������� ��������/�� ��������/������������� ----------------------
		local ServerTime = getInfoParam("SERVERTIME")
		--[[
		local SesStatus=getParamEx(CLASS_CODE, SEC_CODE,"STATUS").param_value
		-- local SesStatus=getParamEx(CLASS_CODE, SEC_CODE,"STATUS") -- ����� �������
		if SesStatus~=1 then
			-- ��������� ������� � ����-������
			message(scName.." c����� �������� ������ �� ���")
			TGsend(scName.." c����� �������� ������ �� ���")
			is_run=false
		end
		--]]
		--local ServerDate = getInfoParam("TRADEDATE") -- �-��� ��������� ������� ���� ������ os.date
		if (ServerTime == nil or ServerTime == "") then
			-- �������� �������� �� �������� ��������, ����-�������, �������� �� ��� ��������

			TGsend(scName .. ". ������ ��������� ������� �������")
			--message(scName.." ����� ������� �� ��������")
			is_run = false
		end

		--[[
		-- �������� �������� ������� (���� �������� ���� �������)
		if (IsWindowClosed(t_id)) then
			CreateTable(t_id)
		end
		--]]

		--if ServerTime <= tTime[2] then
			-- ���������, ������������ ��?
			-- message(type(ServerTime)) --string

		if ServerTime >= tTime[1] and "0"..ServerTime <= tTime[2] then -- ��� ����������
			--[[
			-- ���� ����� ���������� � 0 (07:00:00) - ������� �� ������������.
			--]]

			SetCell(t_id, 1, 0, "��� �� " .. tostring(tTime[2]))

			if inPosition == false then

				sleep(diffTime(ServerTime, tTime[2]) * 1000) -- ��������� �� ������� ���������� ���������, ���.
				SetCell(t_id, 1, 0, "�������")

			elseif inPosition == true then
				--close Position by MARKETPRICE
				-- ���� ��? ��� ������������� �������, ����� ����� �� ���������.
			end
			--SetCell(t_id,1,0,"��������") -- ����� �� ��������, ��� ������� �� ����
		end

		if ServerTime >= tTime[3] and ServerTime <= tTime[4] then
			SetCell(t_id, 1, 0, "��������� �� " .. tostring(tTime[4]))

			if inPosition == false then

				sleep(diffTime(tTime[3], tTime[4]) * 1000) -- ��������� �� ������� ���������� ���������, ���.
				SetCell(t_id, 1, 0, "�������")

			elseif inPosition == true then
				--close Position by MARKETPRICE
				-- ���� ��? ��� ������������� �������, ����� ����� �� ���������.
			end
			--SetCell(t_id,1,0,"��������") -- ����� �� ��������, ��� ������� �� ����
		end

		if ServerTime >= tTime[5] and ServerTime <= tTime[6] then

			SetCell(t_id, 1, 0, "������� " .. tostring(tTime[5]))

			if inPosition == false then

				sleep(diffTime(tTime[5], tTime[6]) * 1000) -- ��������� �� ������� ���������� ���������, ���.
				SetCell(t_id, 1, 0, "������� ")

			elseif inPosition == true then
				-- close Position by MARKETPRICE
				-- � ��� ����� ����� ������� �������,
				-- ����� ��� ��������� ������
			end
			--SetCell(t_id,1,0,"��������") -- ����� �� ��������, ��� ������� �� ����
		end

		if ServerTime >= tTime[7] and ServerTime <= tTime[8] then

			SetCell(t_id, 1, 0, "���� ")

			if inPosition == false then

				is_run = false -- ������� ���������
			elseif inPosition == true then
				TGsend(scName .. " ���������� �������� �������, ����� ���� �� ����������")

				-- �������������� �������� �������� �������!
				-- deleteAllProfits(ACCOUNT, CLASS_CODE, SEC_CODE)

				-- closeAll (ACCOUNT, CLASS_CODE, SEC_CODE) -- ������� ��������� ��������

				--[[
					-- �������� ������ � ������� �������
					pos=PosNowFunc(SEC_CODE, ACCOUNT)
					if pos~=0 then
						CorrectPos (pos, 0, SEC_CODE, ACCOUNT, CLASS_CODE, "", "", 0.02)
						deleteAllProfits(ACCOUNT, CLASS_CODE, SEC_CODE)
					end
					-- �������� ������ � ����-�������
					-- ��������� ����-������
					-- close Position by MARKETPRICE
					-- ����
				--]]
			end
		end
		--------------------------------------------------------------------------------------

		------------------------- ���� �������� ������� --------------------------------------
		local v1 = round(getParamEx(CLASS_CODE, SEC_CODE, "LAST").param_value or 0, 2) -- �������� ������ ��������
		sleep(slTime) -- ������������ �� (���� 30 ���.)
		v2 = round(getParamEx(CLASS_CODE, SEC_CODE, "LAST").param_value or 0, 2) -- �������� �������� ������ slTime ���
		local rslt = round(v2 - v1, 2) -- ����������� ������� ����� ������ � ������ ���������
		-- ���� ����� � ���� ���������� ������
		--logger(date1, tostring(os.date()), SEC_CODE, "*", rslt, " ", v2)

		if (v1 == 0 or v2 == 0) then
			message("������ ��������� ��������� ����.\n ���������")
			TGsend(scName .. ". ������ ��������� ��������� ����. ���������")
			DestroyTable(t_id)
			is_run = false
		end
		---------------------------------------------------------------------------------------

		--if rslt >= spread then  -- direct
		if rslt <= -spread then -- ���� ������� ������ - ��� ������� ��������� ����, ������ ���-�� ���������:)) ���� 0,08
			----------------------- ���� � short ----------------------------------------------------------
			TGsend(scName .. ". �������� �� " .. SEC_CODE .. ", ������� � ticks = " .. rslt .. ". ������ �� ������� �� " .. v2 .. ". ����� " .. getInfoParam("SERVERTIME"))
			-- ������� long! (���� ������ ���������� � ������ ������ - �������� ������� rslt <=-spread �� rslt >=spread)
			if inPosition == false then -- ���� �� ���� ����� ������� �� ����,
				enPrice = v2 --������ �������� �� ���� V2
				date1 = tostring(os.date())

				sl = enPrice - sloss -- stop Loss
				tp = enPrice + tprofit -- take Profit

				-- orderBuyMarket (SEC_CODE) -- ����� �������

				--[[
					info.chm -> ������ 6. ���������� ������ � ������� ������������...
					������ ����������. ������ tri-����� � �����������.

				--]]
				-- trans_id ���������� ������ �������.
				-- �������� ����������
				-- �������� ������������
				-- �������� ��������� ������ sl � tp. ���� ��� ��� ������?
				-- ����� ���������� � �������

				pDataTable(date1, SEC_CODE, "+", enPrice, sl, tp)

				inPosition = true -- �� ������� ��� �� � �������
				while inPosition do
					v2 = round(getParamEx(CLASS_CODE, SEC_CODE, "last").param_value, 2)
					sleep(1000)

					--if enPrice ��� ���� ������������ sl,tp � ����� �� �������
					if v2 <= sl then
						-- �������� sl
						-- orderSellMarket(SEC_CODE)

						------ ������� � ��� ���������� �������	------------------------
						logger(date1, tostring(os.date()), SEC_CODE, "+", "1", enPrice, v2)
						tickstemp = round((v2 - enPrice), 2) -- ������� ticks � ������
						ticks = ticks + tickstemp
						SetCell(t_id, 1, 6, tostring(ticks)) -- ��������� ������� � ������� �������� � �������
						pDataTable("��� �������", SEC_CODE, "", "", "", "")

						inPosition = false
					end

					if v2 >= tp then
						--�������� tp
						--������� ������
						tp = v2 + tprofit
						sl = v2 - sloss -- trailing new
						--sl=v2-tprofit+sttr -- ��� trailing stop
						-- ��� ���� �������� ������� ������� ������ (������ ����� � ����)

						-- pDataTable(date1, SEC_CODE, "+", enPrice, sl, tp) -- sl --> � sttr --��� ��� trailing, ������ �����������

						-- ������� trailing ����� �� �������� QUIK.
						-- ���� ��������� ����� �� tprofit, ������ ��������:
						---[[
							logger (date1, tostring (os.date()), SEC_CODE, "+", "1", enPrice, v2)
							tickstemp = round((v2 - enPrice), 2) -- ������� ticks � ������
							ticks = ticks + tickstemp
							SetCell(t_id, 1, 6, tostring(ticks)) -- ��������� ������� � ������� �������� � �������
							pDataTable("��� �������", SEC_CODE, "", "", "", "")
							inPosition = false
						--]]
					end
				end

				--str='w:\\_plus.bat'
				--tsend(str)
				-- elseif inPosition then -- ���� ��� � ������� � ����������� '+'
				-- ���������� ������, ����� ��������� sl � sttr
			end
		--elseif rslt <= -spread then -- direct
		elseif rslt >= spread then -- ���� 0,08 -- reverse
			TGsend(scName .. ". �������� �� " .. SEC_CODE .. ", ������� � ticks = " .. rslt .. ". ������ �� ������� �� " .. v2 .. ". ����� " .. getInfoParam("SERVERTIME"))

			if inPosition == false then -- ���� �� ���� ����� ������� �� ����,
				-- ������� short
				enPrice = v2 --������ �������� �� ���� V2
				date1 = tostring(os.date())

				sl = enPrice + sloss -- stop Loss
				tp = enPrice - tprofit -- take Profit

				-- orderSellMarket (id, SEC_CODE)
				-- �������� ������������
				-- orderSLBuy (id, SEC_CODE, sl)

				-- ����� ���������� � �������
				--message("-"..tostring(enPrice).." "..tostring(date1))
				pDataTable(date1, SEC_CODE, "-", enPrice, sl, tp)

				inPosition = true -- � �������
				while inPosition == true do
					v2 = round(getParamEx(CLASS_CODE, SEC_CODE, "last").param_value, 2)
					sleep(1000)

					if v2 >= sl then
						-- �������� sl
						-- ��������� ������������

						------ ������� � ��� ���������� �������	------------------------
						logger(date1, tostring(os.date()), SEC_CODE, "-", "1", enPrice, v2)
						tickstemp = tonumber(string.format("%.2f", round(enPrice - v2, 2))) -- ������� ticks � ������
						ticks = ticks + tickstemp
						SetCell(t_id, 1, 6, tostring(ticks)) -- ��������� ������� � ������� �������� � �������
						pDataTable("��� �������", SEC_CODE, "", "", "", "")

						inPosition = false
					end

					if v2 <= tp then
						--�������� tp
						--������� ������

						tp = v2 - tprofit
						sl = v2 + sloss -- trailing new
						--sl=v2+tprofit-sttr -- ��� trailing stop
						-- pDataTable(date1, SEC_CODE, "-", enPrice, sl, tp) -- sl -> sttr -- ��� ��� trailing, ������ �����������
						-- ��� ���� ��������� ������ ������ ������� (������ � ����)

						-- ���� ����� ����� �� tprofit, ������ ��������:
						---[[
						logger (date1, tostring (os.date()), SEC_CODE, "-", "1", enPrice, v2)
						tickstemp = tonumber(string.format("%.2f", round(enPrice - v2, 2))) -- ������� ticks � ������
						ticks = ticks + tickstemp
						SetCell(t_id, 1, 6, tostring(ticks)) -- ��������� ������� � ������� �������� � �������
						pDataTable("��� �������", SEC_CODE, "", "", "", "")
						inPosition=false
						--]]
					end
				end
			end
		end
	end
end

function OnStop()
	-- ������� ��� ���������� ������ (��� ������� �� ���������� ������, ����������� �����)
	--message("���������")
	if inPosition then
		--kill all orders
		message("�������� ���������� ������� �� " .. tostring(round(enPrice, 2) .. " " .. tostring(date1)))
	else
		is_run = false
	end
	-- ��������� ����
	--CSV:close()

	--message("���������� ticks = "..tostring(GetCell(t_id,1,6))) -- �������� �������� �������� ticks �� ��������� �������
	-- ��������� �������. ���� �� �������. ��������������� �� is_run
	DestroyTable(t_id)
end

function CreateTable()
	-- ������� �������� ������� � ������������
	local daysToDie = round(getParamEx(CLASS_CODE, SEC_CODE, "DAYS_TO_MAT_DATE").param_value, 0)

	t_id = AllocTable()
	-- ��������� 5 �������
	AddColumn(t_id, 0, "����", true, QTABLE_STRING_TYPE, 17)
	AddColumn(t_id, 1, "����������", true, QTABLE_STRING_TYPE, 15)
	AddColumn(t_id, 2, "�����������" .. "(" .. spread .. ")", true, QTABLE_STRING_TYPE, 17)
	AddColumn(t_id, 3, "���� �����", true, QTABLE_STRING_TYPE, 15)
	AddColumn(t_id, 4, "Stop Loss " .. "(" .. sloss .. ")", true, QTABLE_STRING_TYPE, 17)
	AddColumn(t_id, 5, "Take Profit " .. "(" .. tprofit .. ")", true, QTABLE_STRING_TYPE, 17)
	AddColumn(t_id, 6, "���������", true, QTABLE_STRING_TYPE, 15)
	-- �������
	--t = CreateWindow(t_id)
	CreateWindow(t_id)
	-- ���� ���������
	SetWindowCaption(t_id, "����� ������ " .. scName .. " / "
	.. tostring(slTime / 1000) .. " c. / " .. spread .. " ����� / "
	.. sloss .. " sl / " .. tprofit .. " tp / " .. SEC_CODE .. " / ���� ��: ".. daysToDie)
	-- ������������ ���� �������
	SetWindowPos(t_id, 430, 400, 800, 90) --x, y, dx, dy
	-- ��������� ������
	InsertRow(t_id, -1)
end

function pDataTable(date1, instrument, direction, entry_price, sloss, tprofit)
	-- �-��� ���������� �������
	-- ���� �����
	-- ����������
	-- �����������
	-- ���� �����
	-- ����-����
	-- ����-������

	--Clear(t_id)
	SetCell(t_id, 1, 0, tostring(date1))
	SetCell(t_id, 1, 1, tostring(instrument))
	SetCell(t_id, 1, 2, tostring(direction))
	SetCell(t_id, 1, 3, tostring(entry_price))
	SetCell(t_id, 1, 4, tostring(sloss))
	SetCell(t_id, 1, 5, tostring(tprofit))
	-- SetCell(t_id,1,6,tostring(result)) -- ��������� ������ �������� �� ������� pDataTable
end

--[[
function get_order_status(flags)
	local status
	local band = bit.band
	local tobit = bit.tobit
	if band(tobit(flags), 1) ~= 0 and band(tobit(flags), 2) == 0 then
		status = "active"
	end
	return status
end
--]]
function ProfitControl(posNow, account, classcode, seccode)
	-- ������� �������� ������-������. ���� �� ��, ����� ������ �� ������.
	-- ���� ���-�� �� ���, ������� ������, ���������� ����� ����-������.
	--
	local index = 0
	local row = 0
	local flag = nil
	local ProfCorrect = false
	local keyNumber = nil
	local count = 0
	local qty = nil
	local profitPrice = nil
	local buySell = ""
	local signPos = 0
	local EnterPrice = nil
	local profitPriceX = nil
	local profitPrice = nil
	local step = 0.01 -- ��� ���� ��� �����, ���� �������� �� �������
	local profit = 50 -- 50 ����� ����
	local prof_offset = 0.05 -- ��� �����
	local prof_spread = 0.01 -- ��� �����

	local function fn1(param1, param2, param3)
		if (param1 == account and param2 == classcode and param3 == seccode) then
			return true
		else
			return false
		end
	end

	EnterPrice = EnterPriceUni(posNow, account, classcode, seccode) -- ��������� �� ���� ����
	profitPrice = EnterPrice + SignFunc(posNow) * profit * step
	index = SearchItems("stop_orders", 0, getNumberOf("stop_ordersp") - 1, fn1, "account, sec_code, class_code")
	if (index ~= nil) then
		for i = 1, #index do
			row = getItem("stop_orders", index[i])
			flag = bit.band(row.flags, 1)
			if (flag > 0) then
				if (row.stop_order_type ~= 6 or ProfCorrect == true) then
					keyNumber = row.order_num
					deleteProfit(classcode, seccode, keyNumber)
					count = count + 1
				else
					qty = row.qty
					profitPriceX = row.condition_price -- ���������� ��������� �� ���� ���� ��� ������
					buySell = row.condition --(���� 4 - <=, ���� 5 >=)

					if (buySell == 4) then
						signPos = -1 -- ����-������ �� ������� ����� ��� ���� <0 (short)
					else --if (buySell == 5) then
						signPos = 1 -- ����-������ �� ������� ����� ��� ���� >0 (long)
					end

					if (signPos == SignFunc(posNow) and qty == math.abs(posNow) and profitPriceX == profitPrice) then
						ProfCorrect = true
					else
						ProfCorrect = false
						TGsend(scName .. ". ������� ���������� ����-������, ������")
						keyNumber = row.order_num
						deleteProfit(classcode, seccode, keyNumber)
						count = count + 1
					end
				end
			end
		end
		if (ProfCorrect == false and posNow ~= 0) then
			if (posNow > 0) then -- ���������� ������ �� �������
				buySell = "S"
			else
				buySell = "B"
			end
			NewStopProfit(account, classcode, seccode, buySell, math.abs(posNow), profitPrice, prof_offset, prof_spread)
		end
	end
end

function EnterPriceUni(posNow, account, classcode, seccode)
	--[[
		seccode ����� ��� ��� ���?
		��������� ������� ���� ������� �� �����������
	--]]
	local pn = posNow
	local sum = 0
	local index = 0
	local row = 0
	local direct = 0
	local price = nil
	local qty = nil
	local pnNext = nil

	if (posNow == 0) then
		return 0
	end

	local function fn1(param1, param2)
		if (param1 == account and param2 == classcode) then
			return true
		else
			return false
		end
	end

	index = SearchItems("trades", 0, getNumberOf("trades") - 1, fn1, "account, sec_code")

	if (index ~= nil) then
		for i = #index, 1, -1 do
			row = getItem("trades", index[i])
			if (bit.band(row.flags, 4) > 0) then -- ������ �� �������, ����� - �� �������
				direct = -1
			else
				direct = 1
			end

			price = row.price
			qty = row.qty
			pnNext = pn - direct * qty

			if (SignFunc(pnNext) ~= SignFunc(pn)) then
				sum = sum + direct * SignFunc(posNow) * price * math.min(qty, math.abs(pn)) -- ������� ������� ���� ������� ����� ����� ���������� �������
				return sum / math.abs(posNow)
			else
				sum = sum + direct * SignFunc(posNow) * price * qty -- ������� ������� ���� ������� �����
			end
			pn = pnNext
		end
	end
	return 0
end

function deleteAllProfits(account, classcode, seccode)
	local n = getNumberOf("stop_orders")
	local row = 0
	local i = 0
	local keyNumber = nil
	local count = 0

	for i = 0, n - 1 do
		row = getItem("stop_orders", i)
		if (row.account == account and row.class_code == classcode and row.sec_code == seccode) then
			if (bit.band(row.flags, 1) > 0) then
				keyNumber = row.order_num
				deleteProfit(classcode, seccode, keyNumber)
				count = count + 1 -- ����� ���������� ��������
			end
		end
	end
	return count
end

---[[
function deleteProfit(classcode, seccode, keyNumber)
	-- ������� �������� ������ �� ������ keyNumber
	local trans_id = "123456"
	local transaction = {
		["CLASSCODE"] = classcode,
		["SECCODE"] = seccode,
		["TRANS_ID"] = trans_id,
		["ACTION"] = "KILL_STOP_ORDER",
		["STOP_ORDER_KEY"] = tostring(keyNumber),
		["CLIENT_CODE"] = scName -- ����� ����������� �����������
	}
	local result = sendTransaction(transaction)
end

function NewStopProfit(account, classcode, seccode, buySell, qty, price, prof_offset, prof_spread)
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
		["CLIENT_CODE"] = scName, -- ����� ����������� �����������
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

--]]

function CorrectPos(posNow, posNeed, seccode, account, classcode, file, prevString, slip)
	local buySell = ""
	local price = 0
	local sDataString = ""
	local trans_id = "123456"
	local last = round(tonumber(getParamEx(classcode, seccode, "LAST").param_value), 2)
	local step = getParamEx(classcode, seccode, "SEC_PRICE_STEP").param_value

	local vol = posNeed - posNow
	if (vol == 0) then
		return 0
	end

	if (slip == 0 or slip == "") then
		slip = 0.01
	end

	if (vol > 0) then
		buySell = "B"
		price = last + slip * step
	else
		buySell = "S"
		price = last - slip * step
	end

	transaction = {
		["ACTION"] = "NEW_ORDER",
		["SECCODE"] = seccode,
		["ACCOUNT"] = account,
		["CLASSCODE"] = classcode,
		["OPERATION"] = buySell,
		["PRICE"] = tostring(price),
		["QUANTITY"] = tostring(math.abs(vol)),
		["TYPE"] = "L",
		["TRANS_ID"] = trans_id,
		["CLIENT_CODE"] = scName -- ����� ����������� �����������
	}
	local result = sendTransaction(transaction)

	if (file ~= nil or file ~= "") then
		sDataString = "������ ���������� = " .. result .. "; Pos = " .. tostring(posNow) .. "; "
	end
	for key, val in pairs(transaction) do
		sDataString = sDataString .. key .. "=" .. val .. "; "
	end

	if (prevString ~= nil or prevString ~= "") then
		sDataString = prevString .. sDataString
	end
	WriteToFile(file, sDataString)

	local count = 1
	sleep(100)
	for i = 1, 300 do
		local posNew = PosNowFunc(seccode, account)
		if (posNew == posNeed) then
			sDataString = scName .. ". ���������� ������ �� " .. tostring(count * 100) .. " ����"
			TGsend(sDataString)
			WriteToFile(file, sDataString)
			return 1
		end
		count = count + 1
		sleep(100)
	end
	sDataString = "�������� � �����������"
	WriteToFile(file, sDataString)
	return nil
end

function f_cb(t_id, msg, x, y)
	-- ������� ��������� ������� ������� (����������)
	-- SetTableNotificationCallback(t_id, f_cb) ���� � onInit, ���� � main (�� � ����)
	if (msg == QTABLE_LBUTTONDBLCLK) then
		if (x == 1 and y == 4) then -- ���� ������� ���� �� ������ ������, ��������� �������
			if inPosition == true then
				-- �������� ����-������,
				-- ���� ���� - �����
				-- �������� ������� �������.
				-- ��������� ����� ����-����� ��� ������� ������� ������� sl=v2-0,20
				message("��������� ���� = " .. tostring(v2)) -- ��������� sl=v2-0,20
			else
				message("��� �������� �������, ������ SL �����������")
			end
		elseif (x == 1 and y == 5) then
			if inPosition == true then
				-- �������� ����-������
				-- ���� ���� - �����
				-- �������� ������� �������
				-- ������� ������� ������� �� ���� bid ��� offer
				message("����� �� 5�� �������. �� take_profit") -- ������� ������� market �������
			else
				message("��� �������� �������, ������ ���������")
			end
		end
	end

	--[[
	--------------------- ������� ��������� ������� ������ �� ������� ������ ----------------------------
		-- ������� ��������� ������� ������� ���������
		local f_cb=function(t_id, msg, x, y)
			if (msg==QTABLE_LBUTTONDBLCLK) then
				if (x==1 and y==4) then -- ���� ������� ���� �� ������ ������, ������� �������
					message("��������� ���� = "..tostring(v2)) -- ��������� sl=v2-0,20
				elseif (x==1 and y==5) then
					message("����� �� 5�� �������. �� take_profit") -- ������� ������� market �������
				end
			end
		end
		SetTableNotificationCallback(t_id, f_cb) -- ��������� ������� �� ������ �������
		-----------------------------------------------------------------------------------------------------

--]]

	--[[
� onInit
function onInit()
	 SetTableNotificationCallback (tbl.t_id, f_cb)
end

-------------------------------�������------------------------------------------------------------------
 function   f_cb (t_id,msg,par1,par2)  --������� �� ������� ������
    if  (msg =  = QTABLE_CHAR)  and  (par2 =  =  19 )  then   --��������� � CSV ���� ������� ��������� ������� ����� ������ ���������� ������ Ctrl+S
      CSV(tbl)
    end

    if  (msg =  = QTABLE_CLOSE)  then   --�������� ����
      Stop()
    end

    if  (msg =  = QTABLE_VKEY)  and  (par2 =  =  116 )  then   --������� ��������������� ���������� ������� ��� ������� ������� Ctrl+F5
       for  SecCode  in   string.gmatch (SecList,  "([^,]+)" )  do   --���������� ������� �� �������.
         Calculate(Sec2row[SecCode], true )
          Highlight (tbl.t_id, Sec2row[SecCode], QTABLE_NO_INDEX,  RGB ( 255 , 0 , 0 ), QTABLE_DEFAULT_COLOR, INTERVAL)
       end

    end
 end

--]]
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
--[[
function tsend (str)
	os.execute(str)
end
--]]
function round(what, signs)
	-- ������� ���������� ����� what � ����������� ������ signs. ��������� �� ������ ���������, �� ��� ����� �����
	--
	--local formatted = string.format("%."..signs.."f",what*100/100)
	--[[ ��� ����� ������� ������
		local formatted = string.format("%." .. signs .. "f", what)
		return tonumber(formatted)
	--]]
	return tonumber(what) -- ������ ����� �� ���������� �� ���� ���������
end

--[[
function loggerinit(nFile)
		-- �������, ��� ��������� ��� ������/���������� ���� CSV � ��� �� �����, ��� ��������� ������ ������
		-- ������������ � OnInit
		-- ������ ����� ������������ � main -  logger (xxx)
	CSV = io.open(nFile, "a+")
	-- ������ � ����� �����, �������� ����� �������
	local Position = CSV:seek("end",0)
	-- ���� ���� ��� ������
	if Position == 0 then
		-- ������� ������ � ����������� ��������
		local Header = "����1;����2;��� ������;��������;����������;����_�����;����_������;Ticks;PnL\n"
		-- ��������� ������ ���������� � ����
		CSV:write(Header)
		-- ��������� ��������� � �����
		CSV:flush()
	end
end
--]]
function logger(date1, date2, instrument, direction, quantity, entry_price, exit_price)
	-- ������� ������������ ������.
	-- ������� ���� � ����������� ����������� ����������? a,b,c..z
	-- ����� ������ �������������� from a to z

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
		"����1;����2;��� ������;��������;����������;����_�����;����_������;Ticks;PnL;$;slTime;Spread;Sttr;Sloss;tProfit\n"
		-- ��������� ������ ���������� � ����
		CSV:write(Header)
		-- ��������� ��������� � �����
		CSV:flush()
		Position = CSV:seek("end", 0)
	end

	if Position ~= 0 then --��� � ��������� ������ csv �����
		-- ������� ������ � ������������
		-- "����;�����;��� ������;��������;����������;����_�����;����_������;PnL*���\n"
		if direction == "+" then
			x = tonumber(string.format("%.2f", exit_price - entry_price)) -- ������� ticks � ������
		elseif direction == "-" then
			x = tonumber(string.format("%.2f", entry_price - exit_price)) -- ������� ticks � ������
		else
			x = 0 -- ���� � direction ������ �� ������� ��� �����������
		end

		--xstr=string.gsub(tostring(x), "%.", ",") -- ������ � ������� ���������� ����� �� ������� ��� csv
		--entry_price_str=string.gsub(tostring(entry_price), "%.", ",") -- ������ ����� �� ������� � ���� ����_�����
		--exit_price_str=string.gsub(tostring(exit_price), "%.", ",") -- ������ ����� �� ������� � ���� ����_������

		pnlstr = tostring(x * tonumber(quantity) * kDollar) -- ��������� �� �������
		--pnlstr=string.gsub(pnlstr, "%.", ",") -- ������ ����� �� ������� � ���������� �� �������

		txt = tostring(date1) ..
			";" ..
			tostring(date2) ..
			";" ..
			tostring(instrument) ..
			";" ..
			tostring(direction) ..
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
			";" ..
			comma(kDollar) ..
			";" ..
			comma(slTime) ..
			";" ..
			comma(spread) .. ";" .. comma("-") .. ";" .. comma(sloss) .. ";" .. comma(tprofit) .. "\n"
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

function TGsend(mText)
	--
	-- �������� ��������� � ���������
	--
	--[[
	��� ��� � �� Token:
	1776852311:AAFD2JkJ5nvzBSBcdVEhGKJ-z490YI2Wk_4

	ID �������������:
	������� 1310951726
	���  527734323
	���� 484834503
	]]
	--curl https://api.telegram.org/bot%botToken%/sendMessage?chat_id=%chatID%^^^&text=%message%
	str = 'w:\\curl\\bin\\curl.exe -s -X POST https://api.telegram.org/bot1776852311:AAFD2JkJ5nvzBSBcdVEhGKJ-z490YI2Wk_4/sendMessage -d chat_id=527734323 -d text="' ..
		mText .. '"'

	--str='C:\\distr\\curl\\bin\\curl.exe -s -X POST https://api.telegram.org/bot1776852311:AAFD2JkJ5nvzBSBcdVEhGKJ-z490YI2Wk_4/sendMessage -d chat_id=527734323 -d text="'..mText..'"'
	--curl -s -X POST https://api.telegram.org/bot<�����>/sendMessage -d chat_id=<ID_����> -d text="������ �� ����"

	--os.execute(str) -- ����������������� ��� �������� ��������� � ��
end

function diffTime(time1, time2)
	-- ���������� ������� � �������� ����� time2-time1, ���� 0, ���� time2>time1
	-- time1 = "13:45:00"
	-- time2 = "14:06:00"
	-- result = diffTime(time1, time2) -- = 1260 ������ = 21 ������

	local dt1 = {}
	local dt2 = {}
	local dTime1 = 0
	local dTime2 = 0
	local result = 0

	dt1.hour, dt1.min, dt1.sec = string.match(time1, "(%d*):(%d*):(%d*)")
	for key, value in pairs(dt1) do
		dt1[key] = tonumber(value)
	end

	dt2.hour, dt2.min, dt2.sec = string.match(time2, "(%d*):(%d*):(%d*)")
	for key, value in pairs(dt2) do
		dt2[key] = tonumber(value)
	end

	--����*3600 + ������*60 + �������.
	dTime1 = dt1.hour * 3600 + dt1.min * 60 + dt1.sec
	dTime2 = dt2.hour * 3600 + dt2.min * 60 + dt2.sec
	result = dTime2 - dTime1

	if result <= 0 then
		return 0
	else
		return result
	end
end

--[[
function RoundForStep (num, nStep)
-- ������� ���������� �� ���� ����
-- �� ����������� �� qlua
-- ����� �� ��� �������?
-- �������������:

	if (nStep==nil or num==nil) then
		return nil
	elseif (nStep==0) then
		return num
	end

	local ost=num%nStep -- ���� ������� �� �������
	if (ost<nStep/2) then
		return (math.floor(num/nStep)*nStep) --���������� ����
	else
		return (math.ceil(num/nStep)*nStep) -- ���������� �����
	end

end
--]]

--[[

https://quikluacsharp.ru/qlua-osnovy/data-vremya-v-qlua-lua/
os.date � lua
--]]
--[[
����/����� � QLua(Lua) ����� ���� ������������ ���� � ���� ������, ��������� � �������� 1 ������ 1970 ����, ���� � ���� �������, ������� ��������� ����:

   year - ��� (������ �����)
   month - ����� (1 � 12)
   day - ���� (1 � 31)
   hour - ��� (0 � 23)
   min - ������ (0 � 59)
   sec - ������� (0 � 59)
   wday - ���� ������ (1 - 7), ����������� ������������� 1
   yday - ���� ����
   isdst - ���� �������� ������� �����, ��� boolean

���������� �������:

   os.clock() - ���������� ����� � �������� � ��������� �� ����������� � ������� ������� ����������, � ����� ������ QUIK. ������: 1544.801
   os.time() - ���������� ����� � ��������, ��������� � �������� 1 ������ 1970 ����, ����� ��������� ������������� �������, � �������� ���������, ��� ���������� ���������� ������� �����
   os.date() - ���������� ��������������� ����/�����, ������ ���������� ��������� ������, ������ ���������� ��������� ����� � ��������. ��������� �� �����������. ���� �� �������� 2-� ��������, ������� ������ ������� ����/����� ����������. ���� ������� ������� ������ ��� ����������, �� ��� ������ ������� ����/����� ���������� � ���� 03/22/15 22:28:11

� ������ ������� ����� ������������ ��������� �����:

%a   - ���� ������, ����. (����.) (������, Wed)
%A   - ���� ������, ��������� (����.) (������, Wednesday)
%b   - �����, ����. (����.) (������, Sep)
%B   - �����, ��������� (����.) (������, September)
%c   - ���� � ����� (��-���������) (������, 03/22/15 22:28:11)
%d   - ���� ������ (������, 22) [��������, 01-31]
%H   - ���, � 24-� ������� ������� (������, 23) [��������, 00-23]
%I   - ���, � 12-� ������� ������� (������, 11) [��������, 01-12]
%M   - ������ (������, 48) [��������, 00-59]
%m   - ����� (������, 09) [��������, 01-12]
%p   - ����� ����� "am", ��� "pm"
%S   - ������� (������, 10) [��������, 00-59]
%w   - ���� ������ (������, 3) [��������, 0-6, ������������� Sunday-Saturday]
%x   - ���� (������, 09/16/98)
%X   - ����� (������, 23:48:10)
%Y   - ���, 4 ����� (������, 2015)
%y   - ���, 2 ����� (������, 15) [00-99]
%%   - ������ "%"
*t   - ������ �������
!*t  - ������ ������� (�� ��������)
�������:
--]]
--[[
-- ����������� ������������ ����� � ��������
datetime = { year  = 2015,
             month = 03,
             day   = 22,
             hour  = 22,
             min   = 28,
             sec   = 11
           };
seconds = os.time(datetime); -- � seconds ����� �������� 1427052491

-- ����������� ����� � �������� � ���� ������� datetime
datetime = os.date("*t",seconds);

-- �������������� ������ ����/������� � ������� datetime
dt = {};
dt.day,dt.month,dt.year,dt.hour,dt.min,dt.sec = string.match("22/03/2015 22:28:11","(%d*)/(%d*)/(%d*) (%d*):(%d*):(%d*)");
for key,value in pairs(dt) do dt[key] = tonumber(value) end

-- � ��� ����� �������� ������� ����/����� ������� � ���� ������� datetime
dt = {};
dt.day,dt.month,dt.year,dt.hour,dt.min,dt.sec = string.match(getInfoParam('TRADEDATE')..' '..getInfoParam('SERVERTIME'),"(%d*).(%d*).(%d*) (%d*):(%d*):(%d*)")
for key,value in pairs(dt) do dt[key] = tonumber(value) end

--]]

--[[

--Buy(classCode, secCode, workSize, 'OpenLong') -- �������������
--Sell(classCode, secCode, lastPos, 'CloseLong') -- �������������


function send_order(client, class, seccode, account, operation, quantity, price)
	local trans_id = 0
	trans_id = get_trans_id()
	local trans_params = {
		CLIENT_CODE = client,
		CLASSCODE = class,
		SECCODE = seccode,
		ACCOUNT = account,
		TYPE = new_type,
		TRANS_ID = trans_id,
		OPERATION = operation,
		QUANTITY = tostring(quantity),
		PRICE = tostring(price),
		ACTION = "NEW_ORDER"
		}
	local res = sendTransaction(trans_params)
	return res
end
-----------------------------

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
-- ������� ������� ��� ����-������
function killStopOrders(seccode)
   local transaction,bs,res={},{},""
   for i=0,getNumberOf("stop_orders")-1 do
   	bs=getItem("stop_orders",i)
      if bit.band(bs.flags, 1)~=0 and bs.seccode==seccode then
         transaction.ACTION=tostring("KILL_STOP_ORDER")
         transaction.TRANS_ID=tostring(math.random(2000000000))
         transaction.CLASSCODE=tostring( bs.class_code )
         transaction.STOP_ORDER_KEY=tostring( bs.ordernum )

         if sendTr ==1 then
         	res=sendTransaction(transaction)
         end

         if res~="" then
         	message ( "killStopOrders() =     ".. tostring(res) ,3)
         end
      end
   end
end


--]]

--[[

������� �� ��������:
���� �� n-������ ������� ���� ���� ���� �� 2 ticks � ���� �� 2 ticks ������� ����,
�� �������� �� ������, ������� �� ������� �������
--]]

--[[

local SecCode = �LKU0�
local Quantity=1

function main()

while stopped == false do
	local Quotes = getQuoteLevel2(�SPBFUT�, SecCode)
	local Offer_Price = tonumber(Quotes.offer[1].price) -- ��������� ��� ask (offer)
	local Offer_Vol = tonumber(Quotes.offer[1].quantity)

	--�������� ����� ������
	local LimitOrderBuy = { �����}

	--������� ����� � ����

	if Offer_Vol>10 then
		message(Order)
		local Order = sendTransaction(LimitOrderBuy)
	end

	sleep (200)
end

���� ���������� ������� � ������ ������ ������� ������ 10, �� ���������� 1 ������ � ������ ������� �����������.
��� ��� ������ ����������� ��� ������������ �������, �� ��� ����������� ������������ while stopped == false do � sleep (200).
������ � ���, ��� ��� ����������� �������, ������ �������� ������� ������ �� 1 ��  ���� �� ��������� ������ (�����������).

������: ����� ����������� ����� ����� ��� ������������, ����� ����� ������� 1 ������ ������ ������� �����������?

--]]

--[[
map={[1]=10,[2]=15,[3]=44,[4]=18}
for i,value in ipairs(map) do
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

--[[
function WriteToFile(sFile, sDataString)
	local ServerTime=getInfoParam("SERVERTIME")
	local ServerDate=getInfoParam("TRADEDATE")

	sDataString=ServerDate..";"..ServerTime..";"..sDataString.."\n"
	local f=io.open (sFile,"r+")

	if (f == nil) then then
		f=io.open(sFile,"w")
	end

	if (f~=nil) then
		f:seek("end",0)
		f:write(sDataString)
		f:flush()
		f:close()
	end
end

--]]

--[[
function SignFunc(num)
--
-- ������� ����������� ����� �����
-- ���� ������ ���� = 1
-- ���� ������ ���� = -1
-- ���� ����� ���� = 0
--

	if (num > 0) then
		return 1
	elseif (num < 0) then
		return -1
	elseif (num == 0) then
		return 0
	end
--]]

--[[
--/*������������� ���������*/
NAME_OF_STRATEGY = 'Str1_' -- �������� ��������� (�� ����� 9 ��������!)
CLASS_CODE = "QJSIM" -- ��� ������ SPBFUT
SEC_CODE = "SBER" -- ��� ������ SiZ6 SiH7, SiM7, SiU7
ACCOUNT = "NL0011100043" -- ������������� ����� SPBFUT00355
CLIENT_CODE = NAME_OF_STRATEGY..SEC_CODE -- "��� �������"
QTY_LOTS = "1" -- ���-�� ��������� �����
FILE_LOG_NAME = "C:\\TRADING\\QUIK Junior\\Scripts\\Log.txt" -- ��� ���-�����

--/*������� ���������� ������ (������ �� �����)*/
g_price_step = 0 -- ��� ���� �����������
g_trans_id_entry = 110001 -- ������ ��������� ����� ID ���������� �� ����
g_trans_id_exit = 220001 -- ������ ��������� ����� ID ���������� �� �����
g_arrTransId_entry = {} -- ������ ID ���������� �� ����
g_arrTransId_exit = {} -- ������ ID ���������� �� �����
g_transId_del_order = "1234" -- ID ������ �� �������� ������ (�� ��������)
g_transId_del_stopOrder = "6789" -- ID ������ �� �������� ���� ������ (�� ��������)
g_currentPosition = 0 -- � �������? ������� ����� � ����� �����������
g_IsTrallingStop = false -- ��������� �� �������� ���� �� �������
g_stopOrderEntry_num= "" -- ����� ����-������ �� ���� � �������, �� �������� � ����� �����
g_stopOrderExit_num = "" -- ����� ����-������ �� ����� � �������, �� �������� � ����� �����
g_order_num = "" -- ����� ������ � �������, �� �������� � ����� �����
g_oldTrade_num = "" -- ����� ���������� ������������ ������
g_previous_time = os.time() -- ��������� � ���������� ������� ������� � ������� HHMMSS
isRun = true -- ���� ����������� ������ ������������ ����� � main

function OnInit()
   -- �������� ��� ���� �����������
    g_price_step = getParamEx(CLASS_CODE, SEC_CODE, "SEC_PRICE_STEP").param_value

    f = io.open(FILE_LOG_NAME, "a+") -- ��������� ����
    myLog("Initialization finished")
end
function main()
   g_trans_id_exit = g_trans_id_exit + 1
   g_arrTransId_exit[#g_arrTransId_exit+1] = g_trans_id_exit

   SendStopOrder("131.9", QTY_LOTS, "B", g_trans_id_exit) -- ��������� ���� �����
   sleep(2000)                                            -- ����� 2 �������
   DeleteStopOrder(g_stopOrderExit_num)                   -- ������� ����-�����

   while isRun do
      sleep(5000) -- ������������ ���� � ��������� 5���.
   end
end

-- ������� ���������� ���������� ���������� QUIK ��� ��������� �������
function OnStop()
   myLog("Script Stoped")
   f:close() -- ��������� ����
   isRun = false
end

function SendStopOrder(stopPrice, quantity, operation, trans_id)
   local offset=50 -- ������ ��� ���������������� ���������� ������ �� ����� (� ���-�� ����� ����)
   local price
   local direction

   if operation=="B" then
      price = stopPrice + g_price_step*offset
      direction = "5" -- �������������� ����-����. �5� - ������ ��� �����
   else
      price = stopPrice - g_price_step*offset
      direction = "4" -- �������������� ����-����. �4� - ������ ��� �����
   end
   --message("stopPrice"..stopPrice)
   --������ ���� ������
   local Transaction = {
                       ['ACTION'] = "NEW_STOP_ORDER",
                       ['PRICE'] = tostring(price),
                       ['EXPIRY_DATE'] = "TODAY",--"GTC", -- �� ������� ����� ������ ����-������ � ���������� �������, ����� �������� �� GTC
                       ['STOPPRICE'] = tostring(stopPrice),
                       ['STOP_ORDER_KIND'] = "SIMPLE_STOP_ORDER",
                       ['TRANS_ID'] = removeZero(tostring(trans_id)),
                       ['CLASSCODE'] = CLASS_CODE,
                       ['SECCODE'] = SEC_CODE,
                       ['ACCOUNT'] = ACCOUNT,
                       ['CLIENT_CODE'] = CLIENT_CODE, -- ����������� � ����������, ������� ����� ����� � �����������, ������� � �������
                       ['TYPE'] = "L",
                       ['OPERATION'] = tostring(operation),
                       ['CONDITION'] = direction, -- �������������� ����-����. ��������� ��������: �4� - ������ ��� �����, �5� � ������ ��� �����
                       ['QUANTITY'] = tostring(math.abs(quantity))
                       }
   local res = sendTransaction(Transaction)
   if string.len(res) ~= 0 then
      message('Error: '..res, 3)
      myLog("SendStopOrder(): Error "..res)
   else
      myLog("SendStopOrder(): "..EntryOrExit(trans_id).."; trans_id="..trans_id)
   end
end

function DeleteStopOrder(stopOrder_num)
   local Transaction = {
                       ['ACTION'] = "KILL_STOP_ORDER",
                       ['CLASSCODE'] = CLASS_CODE,
                       ['SECCODE'] = SEC_CODE,
                       ['ACCOUNT'] = ACCOUNT,
                       ['CLIENT_CODE'] = CLIENT_CODE,
                       ['TYPE'] = "L",
                       ['STOP_ORDER_KIND'] = "SIMPLE_STOP_ORDER",
                       ['TRANS_ID'] = g_transId_del_order, -- ID ��������� ����������
                       ['STOP_ORDER_KEY'] = tostring(stopOrder_num)
                       }

   local res = sendTransaction(Transaction)
   if string.len(res) ~= 0 then
      message('Error: '..res, 3)
      myLog("DeleteStopOrder(): fail "..res)
   else
      myLog("DeleteStopOrder(): "..stopOrder_num.." success ")
   end
end
-- ������/�������/�������� ����-�����
function OnStopOrder(stopOrder)
   -- ���� �� ��������� � ������, ������� �� �������
   if stopOrder.brokerref:find(CLIENT_CODE) == nil then return end

   local string state="_" -- ��������� ������
   --��� 0 (0x1) ������ �������, ����� �� �������
   if bit.band(stopOrder.flags,0x1)==0x1 then
      state="����-������ �������"
      if EntryOrExit(stopOrder.trans_id) == "Entry" then
         g_stopOrderEntry_num = stopOrder.order_num
      end
      if EntryOrExit(stopOrder.trans_id) == "Exit" then
         g_stopOrderExit_num = stopOrder.order_num
      end
   end
   if bit.band(stopOrder.flags,0x2)==0x1 or stopOrder.flags==26 then
      state="����-������ �����"
   end
   if bit.band(stopOrder.flags,0x2)==0x0 and bit.band(stopOrder.flags,0x1)==0x0 then
      state="����-����� ��������"
   end
   if bit.band(stopOrder.flags,0x400)==0x1 then
      state="����-������ ���������, �� ���� ���������� �������� ��������"
   end
   if bit.band(stopOrder.flags,0x800)==0x1 then
      state="����-������ ���������, �� �� ������ �������� �������"
   end
   if state=="_" then
      state="����� ������� ������="..tostring(stopOrder.flags)
   end
   myLog("OnStopOrder(): sec_code="..stopOrder.sec_code.."; "..EntryOrExit(stopOrder.trans_id)..";\t"..state..
         "; condition_price="..stopOrder.condition_price.."; transID="..stopOrder.trans_id.."; order_num="..stopOrder.order_num )
end
------------------------- ��������� �������--------------------
-- ������� ���������� � ��� ������� � �������� � �����
function myLog(str)
   if f==nil then return end

   local current_time=os.time()--tonumber(timeformat(getInfoParam("SERVERTIME"))) -- �������� � ���������� ������� ������� � ������� HHMMSS
   if (current_time-g_previous_time)>1 then -- ���� ������� ������ ��������� ����� 1 �������, ��� ����������
      f:write("\n") -- ��������� ������ ������ ��� �������� ������
   end
   g_previous_time = current_time

   f:write(os.date().."; ".. str .. ";\n")

   if str:find("Script Stoped") ~= nil then
      f:write("======================================================================================================================\n\n")
      f:write("======================================================================================================================\n")
   end
   f:flush() -- ��������� ��������� � �����
end
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
-- ���������� Entry ��� Exit � ����������� �� trans_id
function EntryOrExit(trans_id)
   if isArrayContain(g_arrTransId_entry, trans_id) then
      return "Entry"
   elseif isArrayContain(g_arrTransId_exit, trans_id) then
      return "Exit"
   elseif trans_id==g_transId_del_order then
      return "DeleteOrder"
   elseif trans_id==g_transId_del_stopOrder then
      return "DeleteStopOrder"
   else
      return "NoId"
   end
end

function isArrayContain(array, value)
   if #array < 1 then return end
      for i=1, #array do
         if array[i]==value then
         return true
      end
   end
   return false
end
--]]

--[[
������������� ��/29,3 � �������� �� ���-�� ���� �������. ��� ������ ����������� ���� � �������, ��� ������ ���������.
--]]

--[[
-- https://quikluacsharp.ru/quik-qlua/poluchenie-dannyh-iz-tablits-quik-v-qlua-lua/
-- ���������� ������ ������� "������� �� ���������� ������ (��������)", ���� ������� ������ ������� �� ����������� "RIH5"
for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do
   -- ���� ������ �� ������� ����������� � ������ ������� �� ����� ���� ��
   if getItem("FUTURES_CLIENT_HOLDING",i).sec_code == "RIH5" and getItem("FUTURES_CLIENT_HOLDING",i).totalnet ~= 0 then
      -- ���� ������� ������ ������� > 0, �� ������� ������� ������� (BUY)
      if getItem("FUTURES_CLIENT_HOLDING",i).totalnet > 0 then
         IsBuy = true;
         BuyVol = getItem("FUTURES_CLIENT_HOLDING",i).totalnet;	-- ���������� ����� � ������� BUY
      else   -- ����� ������� �������� ������� (SELL)
         IsSell = true;
         SellVol = math.abs(getItem("FUTURES_CLIENT_HOLDING",i).totalnet); -- ���������� ����� � ������� SELL
      end;
   end;
end;

--]]

--[[
https://quikluacsharp.ru/quik-qlua/poluchenie-dannyh-iz-tablits-quik-v-qlua-lua/
Status =  tonumber(getParamEx("SPBFUT",  "RIM5", "STATUS").param_value);
-- ������� ��������� � ������� ���������
if Status == 1 then message("RIM5 ���������"); else message("RIM5 �� ���������"); end;
������ ��������� ��������������� ����������, ������������ � ������� getParamEx()

   STATUS                  STRING   ������
   LOTSIZE                 NUMERIC  ������ ����
   BID                     NUMERIC  ������ ���� ������
   BIDDEPTH                NUMERIC  ����� �� ������ ����
   BIDDEPTHT               NUMERIC  ��������� �����
   NUMBIDS                 NUMERIC  ���������� ������ �� �������
   OFFER                   NUMERIC  ������ ���� �����������
   OFFERDEPTH              NUMERIC  ����������� �� ������ ����
   OFFERDEPTHT             NUMERIC  ��������� �����������
   NUMOFFERS               NUMERIC  ���������� ������ �� �������
   OPEN                    NUMERIC  ���� ��������
   HIGH                    NUMERIC  ������������ ���� ������
   LOW                     NUMERIC  ����������� ���� ������
   LAST                    NUMERIC  ���� ��������� ������
   CHANGE                  NUMERIC  ������� ���� ��������� � ���������� ������
   QTY                     NUMERIC  ���������� ����� � ��������� ������
   TIME                    STRING   ����� ��������� ������
   VOLTODAY                NUMERIC  ���������� ����� � ������������ �������
   VALTODAY                NUMERIC  ������ � �������
   TRADINGSTATUS           STRING   ��������� ������
   VALUE                   NUMERIC  ������ � ������� ��������� ������
   WAPRICE                 NUMERIC  ���������������� ����
   HIGHBID                 NUMERIC  ������ ���� ������ �������
   LOWOFFER                NUMERIC  ������ ���� ����������� �������
   NUMTRADES               NUMERIC  ���������� ������ �� �������
   PREVPRICE               NUMERIC  ���� ��������
   PREVWAPRICE             NUMERIC  ���������� ������
   CLOSEPRICE              NUMERIC  ���� ������� ��������
   LASTCHANGE              NUMERIC  % ��������� �� ��������
   PRIMARYDIST             STRING   ����������
   ACCRUEDINT              NUMERIC  ����������� �������� �����
   YIELD                   NUMERIC  ���������� ��������� ������
   COUPONVALUE             NUMERIC  ������ ������
   YIELDATPREVWAPRICE      NUMERIC  ���������� �� ���������� ������
   YIELDATWAPRICE          NUMERIC  ���������� �� ������
   PRICEMINUSPREVWAPRICE   NUMERIC  ������� ���� ��������� � ���������� ������
   CLOSEYIELD              NUMERIC  ���������� ��������
   CURRENTVALUE            NUMERIC  ������� �������� �������� ���������� �����
   LASTVALUE               NUMERIC  �������� �������� ���������� ����� �� �������� ����������� ���
   LASTTOPREVSTLPRC        NUMERIC  ������� ���� ��������� � ���������� ������
   PREVSETTLEPRICE         NUMERIC  ���������� ��������� ����
   PRICEMVTLIMIT           NUMERIC  ����� ��������� ����
   PRICEMVTLIMITT1         NUMERIC  ����� ��������� ���� T1
   MAXOUTVOLUME            NUMERIC  ����� ������ �������� ������ (� ����������)
   PRICEMAX                NUMERIC  ����������� ��������� ����
   PRICEMIN                NUMERIC  ���������� ��������� ����
   NEGVALTODAY             NUMERIC  ������ ������������ � �������
   NEGNUMTRADES            NUMERIC  ���������� ������������ ������ �� �������
   NUMCONTRACTS            NUMERIC  ���������� �������� �������
   CLOSETIME               STRING   ����� �������� ���������� ������ (��� �������� ���)
   OPENVAL                 NUMERIC  �������� ������� ��� �� ������ �������� ������
   CHNGOPEN                NUMERIC  ��������� �������� ������� ��� �� ��������� �� ��������� ��������
   CHNGCLOSE               NUMERIC  ��������� �������� ������� ��� �� ��������� �� ��������� ��������
   BUYDEPO                 NUMERIC  ����������� ����������� ��������
   SELLDEPO                NUMERIC  ����������� ����������� ����������
   CHANGETIME              STRING   ����� ���������� ���������
   SELLPROFIT              NUMERIC  ���������� �������
   BUYPROFIT               NUMERIC  ���������� �������
   TRADECHANGE             NUMERIC  ������� ���� ��������� � ���������� ������ (FORTS, �� ���, ����)
   FACEVALUE               NUMERIC  ������� (��� ����� ����)
   MARKETPRICE             NUMERIC  �������� ���� �����
   MARKETPRICETODAY        NUMERIC  �������� ����
   NEXTCOUPON              NUMERIC  ���� ������� ������
   BUYBACKPRICE            NUMERIC  ���� ������
   BUYBACKDATE             NUMERIC  ���� ������
   ISSUESIZE               NUMERIC  ����� ���������
   PREVDATE                NUMERIC  ���� ����������� ��������� ���
   DURATION                NUMERIC  �������
   LOPENPRICE              NUMERIC  ����������� ���� ��������
   LCURRENTPRICE           NUMERIC  ����������� ������� ����
   LCLOSEPRICE             NUMERIC  ����������� ���� ��������
   QUOTEBASIS              STRING   ��� ����
   PREVADMITTEDQUOT        NUMERIC  ������������ ��������� ����������� ���
   LASTBID                 NUMERIC  ������ ����� �� ������ ���������� ������� ������
   LASTOFFER               NUMERIC  ������ ����������� �� ������ ���������� ������
   PREVLEGALCLOSEPR        NUMERIC  ���� �������� ����������� ���
   COUPONPERIOD            NUMERIC  ������������ ������
   MARKETPRICE2            NUMERIC  �������� ���� 2
   ADMITTEDQUOTE           NUMERIC  ������������ ���������
   BGOP                    NUMERIC  ��� �� �������� ��������
   BGONP                   NUMERIC  ��� �� ���������� ��������
   STRIKE                  NUMERIC  ���� ������
   STEPPRICET              NUMERIC  ��������� ���� ����
   STEPPRICE               NUMERIC  ��������� ���� ���� (��� ����� ���������� FORTS � RTS Standard)
   SETTLEPRICE             NUMERIC  ��������� ����
   OPTIONTYPE              STRING   ��� �������
   OPTIONBASE              STRING   ������� �����
   VOLATILITY              NUMERIC  ������������� �������
   THEORPRICE              NUMERIC  ������������� ����
   PERCENTRATE             NUMERIC  �������������� ������
   ISPERCENT               STRING   ��� ���� ��������
   CLSTATE                 STRING   ������ ��������
   CLPRICE                 NUMERIC  ��������� ���������� ��������
   STARTTIME               STRING   ������ �������� ������
   ENDTIME                 STRING   ��������� �������� ������
   EVNSTARTTIME            STRING   ������ �������� ������
   EVNENDTIME              STRING   ��������� �������� ������
   MONSTARTTIME            STRING   ������ �������� ������
   MONENDTIME              STRING   ��������� �������� ������
   CURSTEPPRICE            STRING   ������ ���� ����
   REALVMPRICE             NUMERIC  ������� �������� ���������
   MARG                    STRING   �����������
   EXPDATE                 NUMERIC  ���� ���������� �����������
   CROSSRATE               NUMERIC  ����
   BASEPRICE               NUMERIC  ������� ����
   HIGHVAL                 NUMERIC  ������������ �������� (RTSIND)
   LOWVAL                  NUMERIC  ����������� �������� (RTSIND)
   ICHANGE                 NUMERIC  ��������� (RTSIND)
   IOPEN                   NUMERIC  �������� �� ������ �������� (RTSIND)
   PCHANGE                 NUMERIC  ������� ��������� (RTSIND)
   OPENPERIODPRICE         NUMERIC  ���� ������������� �������
   MIN_CURR_LAST           NUMERIC  ����������� ������� ����
   SETTLECODE              STRING   ��� �������� �� ���������
   STEPPRICECL             DOUBLE   ��������� ���� ���� ��� ��������
   STEPPRICEPRCL           DOUBLE   ��������� ���� ���� ��� ������������
   MIN_CURR_LAST_TI        STRING   ����� ��������� ����������� ������� ����
   PREVLOTSIZE             DOUBLE   ���������� �������� ������� ����
   LOTSIZECHANGEDAT        DOUBLE   ���� ���������� ��������� ������� ����
   CLOSING_AUCTION_PRICE   NUMERIC  ���� �������������� ��������
   CLOSING_AUCTION_VOLUME  NUMERIC  ���������� � ������� �������������� ��������
   LONGNAME                STRING   ������ �������� ������
   SHORTNAME               STRING   ������� �������� ������
   CODE                    STRING   ��� ������
   CLASSNAME               STRING   �������� ������
   CLASS_CODE              STRING   ��� ������
   TRADE_DATE_CODE         DOUBLE   ���� ������
   MAT_DATE                DOUBLE   ���� ���������
   DAYS_TO_MAT_DATE        DOUBLE   ����� ���� �� ���������
   SEC_FACE_VALUE          DOUBLE   ������� ������
   SEC_FACE_UNIT           STRING   ������ ��������
   SEC_SCALE               DOUBLE   �������� ����
   SEC_PRICE_STEP          DOUBLE   ����������� ��� ����
   SECTYPE                 STRING   ��� �����������
--]]
