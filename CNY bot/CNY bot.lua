
------------------------------------------ Настройки робота-Абрикоса -------------------------------------------------
--- идея торговли с 19-10 до 22-00 по МСК, когда цена уходит в range (+/- 1 ticks)
--- задаём начальную цену на 19-10 для покупки и верхнюю цену, покупаем по нижней границе, tp + 1 tick, по tp переворачиваем позицию + 1 tick
---

SEC_CODE = "CRU2" --код инструмента/бумаги
CLASS_CODE = "SPBFUT" --код класса инструмента/бумаги, если нужен фондовый рынок - вводить TQBR вместо SPBFUT
ACCOUNT = "SPBFUT00xx" -- счет на срочном рынке

lot = 1 -- начальный лот
tprofit = 0.02 -- 0.02 оптимальный tp
spread = 0.00 -- величина изменения цены, после которой будет выдаваться сигнал на вход/переворот позиции 0.08, 0.09
price = 8.90
--enPriceShort = 9.90 --enPriceLong + 0.01

----------------------------------------------------------------------------------------------------------------------

is_run = true
--inPosition = false
date1 = "" -- дата и время входа в позицию
t_id = nil -- идентификатор таблицы (числовое значение? = 0)
nFile = "" -- название создаваемого файла (по имени инструмента)
scName = "" -- название запускаемого скрипта

function OnInit()
    local pFile = "w:\\temp" --путь, где будет создаваться файл
	-- Получает доступ к свечам графика
	local Error = ""

	DS, Error = CreateDataSource(CLASS_CODE, SEC_CODE, INTERVAL_M1)
	-- Проверка
	if DS == nil then
		message("ОШИБКА получения доступа к свечам! " .. Error)
		TGsend(scName .. ". ОШИБКА получения доступа к свечам! " .. Error)
		is_run = false
		return
	end
	scName = string.match(debug.getinfo(1).short_src, "\\([^\\]+)%.lua$") -- получение имени запущенного скрипта
	nFile = pFile .. "\\" .. tostring(SEC_CODE) .. "_" .. scName .. ".csv"
end

function OnStop()
	-- функция при выключении робота (при нажатии на остановить скрипт, подвешивает поток)
	--message("Остановка")
	DestroyTable(t_id)
	if inPosition then
		--kill all orders
		--message("Остались незакрытми позиции по " .. tostring(round(enPrice, 2) .. " " .. tostring(date1)))
	else
		is_run = false
	end
	-- закрываем файл
	--CSV:close()
end

function daysToDie(CLASS_CODE, SEC_CODE)
    local days = 0
    days = round(getParamEx(CLASS_CODE, SEC_CODE, "DAYS_TO_MAT_DATE").param_value, 0)
	
    if days <= 4 then
		message("Количество дней до погашения инструмента " .. SEC_CODE .. " равно " .. tostring(days) 
        .. ". Необходимо заменить инструмент в настройках робота " .. scName)

		--TGsend("Количество дней до погашения инструмента " .. SEC_CODE .. " равно " .. tostring(daysToDie) .. ". Необходимо заменить инструмент в настройках робота " .. scName)
	end
end

function main()

    local ticks = 0 -- Начальный результат (ticks)
	--local tickstemp = 0 -- для хранения промежуточных значений ticks
	local inPosition = false -- флаг в позиции/нет
	local numDeals = 0 -- количество сделок за торговую сессию
    --local ql2 -- таблица стакана
    --local tp = 0 -- цена выхода
    
    daysToDie(CLASS_CODE, SEC_CODE) -- проверяем количество дней до конца инструмента
    CreateTable()

	lot = getLot(ACCOUNT, CLASS_CODE, SEC_CODE, 80) -- используемый лот = 50% от депозита
	--message(tostring(lot).." - используемый лот")

    while is_run do
        
        --[[
            добавить временной диапазон торговли (до 19-20 не торговать), выход после 22-00
            добавить флаг только long, только short, reverse mode (при достижении tp разворот позиции)
            добавить проверку плотности стакана (если среднее количество лотов в стакане на bid больше чем на ask - значит работаем от покупки, 
            цена входа - найти первый большой bid > 1000, цена входа = большой bid + 1
            проверить по видеоурокам вход/выход в позицию
        --]]

            if inPosition == false then -- если не было ранее сигнала на вход,
                date1 = tostring(os.date())
                
				-------------------------- вход в позицию long + TakeProfit + stop-loss ---------------------------------
				BuyAsk(ACCOUNT, CLASS_CODE, SEC_CODE, price, lot)
					if CheckPosition(lot) == false then
						message(scName .. ". ОШИБКА ТРАНЗАКЦИИ ПРИ ПОКУПКЕ!")
						--TGsend(scName .. ". ОШИБКА ТРАНЗАКЦИИ ПРИ ПОКУПКЕ!")
						is_run = false
					end
				
				inPosition = true
				while inPosition do
					message(tostring(trans_reply.status))
					
					if trans_reply.status == 3 then
						inPosition = false
					end
		
					sleep(1000) -- убрать
				end
				is_run = false -- убрать

				SellBid(ACCOUNT, CLASS_CODE, SEC_CODE, price, lot)
					if CheckPosition(lot) == false then
						message(scName .. ". ОШИБКА ТРАНЗАКЦИИ ПРИ ПРОДАЖЕ!")
						--TGsend(scName .. ". ОШИБКА ТРАНЗАКЦИИ ПРИ ПОКУПКЕ!")
						is_run = false
					end
				--SLTPorder(ACCOUNT, CLASS_CODE, SEC_CODE, "S", lot, tp, 0, 0, spread)
				
				----------------------------------------------------------------------------------------------------

            end
		end
end
--[[
    inPosition = true -- то считаем что мы в позиции
    numDeals = numDeals + 1
    SetCell(t_id, 1, 5, tostring(numDeals)) -- количество сделок выводим отдельно в таблицу

    while inPosition do
        sleep(1000)

        ------ выводим в лог результаты позиции	------------------------
        
        tickstemp = round((v2 - enPrice), 2) * 100 -- считаем ticks в центах
        ticks = ticks + tickstemp
        SetCell(t_id, 1, 6, tostring(ticks)) -- результат считаем и выводим отдельно в таблицу

        pDataTable("вне позиции", SEC_CODE, "", "", "", "")
        lightTable(tickstemp, 1, 6) -- раскраска сделки (если меньше ноля = розовым, если больше = зеленым)
        lightAllTable(ticks) -- раскраска строки

        inPosition = false
    end
--]]







    
    -- проверка сработал ли ордер
    -- если сработал inPosition = true
    -- ждём 5 сек
    -- мы в позиции?
    -- если да, ждём пока не выйдем
    -- если не в позиции 
        -- проверяем в диапазоне ли сейчас цена
        --если ниже - покупаем, если выше - продаём.
    -- отправляем транзакцию с tp
    -- ждём выхода из позиции

	
	

	-- QuoteStr = tostring(ql2.bid[tonumber(ql2.bid_count)].price) -- 1 - нижняя цена, bid_count - верхняя цена слева стакана
	-- 	message(tostring(QuoteStr))
	
	-- QuoteStr = tostring(ql2.offer[1].price) --0 - nil, 1 - 1 цена справа стакана, tonumber(ql2.offer_count) - последняя цена справа стакана (нижняя)
	-- 	message(tostring(QuoteStr))


--                 if v2 >= tp then
--                     --сработал tp
--                     --снимаем ордера
--                     tp = v2 + tprofit
--                     sl = v2 - sloss -- trailing new
--                     --sl=v2-tprofit+sttr -- для trailing stop
--                     -- вот сюда выделить таблицу зеленым цветом (сделка пошла в плюс)

--                     pDataTable(date1, SEC_CODE, "+", enPrice, sl, tp) -- sl --> в sttr

--                     -- посылка trailing стопа из арсенала QUIK.
--                     -- если необходим выход по tprofit, убрать комменты:
--                     --[[
--                         logger (date1, tostring (os.date()), SEC_CODE, "+", lot, enPrice, v2)
--                         tickstemp = round((v2 - enPrice), 2) * 100 -- считаем ticks в центах
--                         ticks = ticks + tickstemp
--                         SetCell(t_id, 1, 6, tostring(ticks)) -- результат считаем и выводим отдельно в таблицу
--                         pDataTable("вне позиции", SEC_CODE, "", "", "", "")
--                         inPosition = false
--                     --]]
--                 end
--             end

--             -- elseif inPosition then -- если уже в позиции в направлении '+'
--             -- игнорируем сигнал, можем подтянуть sl в sttr
--         end

--     elseif rslt >= spread then -- для reverse mode
--     -- elseif rslt <= -spread then -- для direct mode

--         TGsend(scName .. ". Внимание на " .. SEC_CODE
--         .. ", разница в ticks = " .. rslt .. ". Сигнал на продажу по "
--         .. v2 .. ". Время " .. getInfoParam("SERVERTIME"))

--         if inPosition == false then -- если не было ранее сигнала на вход,
--             -- позиция short
--             enPrice = v2 --входим маркетом по цене V2
--             date1 = tostring(os.date())

--             sl = enPrice + sloss -- stop Loss
--             tp = enPrice - tprofit -- take Profit

--             if tradeFlag == true then
--                 -- orderSellMarket (id, SEC_CODE)
--                 -- проверка срабатывания
--                 -- orderSLBuy (id, SEC_CODE, sl)

--                 -- enPrice = getInfoParam(xxx).param_value  -- получаем цену входа

--                 -- trans_id необходимо задать вручную.
--                 -- отправка транзакции
--                 -- проверка срабатывания
--                 -- отправка связанной заявки sl и tp. Одной заявкой
--                 -- вывод информации о позиции
--             end

--             -- вывод информации о позиции
--             --message("-"..tostring(enPrice).." "..tostring(date1))
--             pDataTable(date1, SEC_CODE, "-", enPrice, sl, tp)

--             inPosition = true -- в позиции
--             numDeals = numDeals + 1 -- количество сделок стало на 1 больше
--             SetCell(t_id, 1, 7, tostring(numDeals)) -- количество сделок выводим отдельно в таблицу

--             while inPosition == true do
--                 v2 = round(getParamEx(CLASS_CODE, SEC_CODE, "last").param_value, 2)
--                 sleep(1000)

--                 if v2 >= sl then
--                     -- сработал sl
--                     -- проверяем срабатывание

--                     ------ выводим в лог результаты позиции	------------------------
--                     logger(date1, tostring(os.date()), SEC_CODE, "-", lot, enPrice, v2)
--                     tickstemp = tonumber(string.format("%.2f", round(enPrice - v2, 2))) * 100 -- считаем ticks в центах
--                     ticks = ticks + tickstemp
--                     SetCell(t_id, 1, 6, tostring(ticks)) -- результат считаем и выводим отдельно в таблицу

--                     pDataTable("вне позиции", SEC_CODE, "", "", "", "")
--                     lightTable(tickstemp, 1, 6) -- раскраска сделки (если меньше ноля = розовым, если больше = зеленым)
--                     lightAllTable(ticks) -- раскраска строки

--                     inPosition = false
--                 end

--                 if v2 <= tp then
--                     --сработал tp
--                     --снимаем ордера

--                     tp = v2 - tprofit
--                     sl = v2 + sloss -- trailing new
--                     --sl=v2+tprofit-sttr -- для trailing stop
--                     pDataTable(date1, SEC_CODE, "-", enPrice, sl, tp) -- sl -> sttr
--                     -- вот сюда выделение зелёным цветом таблицы (сделка в плюс)

--                     -- если нужен выход по tprofit, убрать комменты:
--                     --[[
--                     logger (date1, tostring (os.date()), SEC_CODE, "-", lot, enPrice, v2)
--                     tickstemp = tonumber(string.format("%.2f", round(enPrice - v2, 2))) * 100 -- считаем ticks в центах
--                     ticks = ticks + tickstemp
--                     SetCell(t_id, 1, 6, tostring(ticks)) -- результат считаем и выводим отдельно в таблицу
--                     pDataTable("вне позиции", SEC_CODE, "", "", "", "")
--                     inPosition=false
--                     --]]
--                 end
--             end
--         end
--     end
-- end

function PosNowFunc(account, seccode) -- вспомогательная ф-ция к CheckPosition
	-- Определение текущей позиции по инструменту seccode счета account
	-- по ф-ции можно сверять все ли заявки исполнены
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
	-- функция создания таблицы с результатами
	local days = round(getParamEx(CLASS_CODE, SEC_CODE, "DAYS_TO_MAT_DATE").param_value, 0)

	t_id = AllocTable()
	-- Добавляем колонки
	AddColumn(t_id, 0, "Дата", true, QTABLE_STRING_TYPE, 25)
	AddColumn(t_id, 1, "Инструмент", true, QTABLE_STRING_TYPE, 15)
	AddColumn(t_id, 2, "Лот" .. "(" .. spread .. ")", true, QTABLE_STRING_TYPE, 15)
	AddColumn(t_id, 3, "Цена входа", true, QTABLE_STRING_TYPE, 15)
	--AddColumn(t_id, 4, "Stop Loss " .. "(" .. sloss .. ")", true, QTABLE_STRING_TYPE, 17)
	AddColumn(t_id, 4, "Take Profit " .. "(" .. tprofit .. ")", true, QTABLE_STRING_TYPE, 17)
	AddColumn(t_id, 5, "Результат", true, QTABLE_STRING_TYPE, 14)
	AddColumn(t_id, 6, "Кол-во сделок", true, QTABLE_STRING_TYPE, 14)
	-- Создаем
	--t = CreateWindow(t_id)
	CreateWindow(t_id)
	-- Даем заголовок
	SetWindowCaption(t_id, "Робот Абрикос " .. scName .. " / " .. spread .. " спрэд / "
	.. tprofit .. " tp / " .. SEC_CODE .. " / дней до: ".. days)
	-- Расположение окна таблицы
    SetWindowPos(t_id, 0, 820, 760, 90) --x, y, dx, dy
	-- Добавляет строку
	InsertRow(t_id, -1)
end

function pDataTable(date1, instrument, direction, entry_price, tprofit, result, numDeals) -- ф-ция заполнения таблицы
	-- ф-ция заполнения таблицы
	-- Дата входа
	-- Инструмент
	-- Направление
	-- Цена входа
	-- Стоп-Лосс
	-- Тэйк-Профит
	-- количество сделок за торговую сессию
	---

	--Clear(t_id)
	SetCell(t_id, 1, 0, tostring(date1))
	SetCell(t_id, 1, 1, tostring(instrument))
	SetCell(t_id, 1, 2, tostring(direction))
	SetCell(t_id, 1, 3, tostring(entry_price))
	--SetCell(t_id, 1, 4, tostring(sloss))
	SetCell(t_id, 1, 4, tostring(tprofit))
    SetCell(t_id, 1, 5, tostring(result)) -- Результат вводим отдельно от функции pDataTable
	SetCell(t_id, 1, 6, tostring(numDeals)) -- отдельное заполнение
	
end

function logger(date1, date2, instrument, quantity, entry_price, exit_price)
	-- функция логгирования данных.
	-- сделать ввод с неизвестынм количеством аргументов? a,b,c..z
		-- тогда нужно закидывать arr() на вход
		-- вывод данных соответственно from arr(1) to #arr()
	--

	-- direction и quantity можно объединить в один столбец quantity, в него передавать '+1' или '-1'

	CSV = io.open(nFile, "a+")
	local Position = CSV:seek("end", 0)
	local x = 0 -- exit_price-entry_price или наоборот
	local txt = "" --для вывода в файл
	local pnlstr = ""

	--в logger выводим дата, время_входа, время_выхода, инструмент, направление, лот, цена_входа, цена_выхода, PnL, H, L, разница (-) O-H, L-O (если вход в (+) H-O, O-L)

	local kDollar = round(getParamEx(CLASS_CODE, SEC_CODE, "STEPPRICE").param_value, 3) -- получаем стоимость шага цены с округлением до трёх знаков. было STEPPRICET
	-- Если файл не пустой
	-- проверить инициализацию файла в пределах одной функции
	if Position == 0 then
		-- обработка ошибки пустого файла
		-- Создает строку с заголовками столбцов
		local Header =
		"Дата1;Дата2;Код бумаги;Количество;Цена_входа;Цена_выхода;Ticks;PnL\n"
		-- Добавляет строку заголовков в файл
		CSV:write(Header)
		-- Сохраняет изменения в файле
		CSV:flush()
		Position = CSV:seek("end", 0)
	end

	if Position ~= 0 then --идём в последнюю строку csv файла
		-- Создает строку с результатами
		-- "Дата;Время;Код бумаги;Операция;Количество;Цена_входа;Цена_выхода;PnL*Лот\n"
		if quantity > 0  then
			x = tonumber(string.format("%.2f", exit_price - entry_price)) * 100 -- считаем ticks в центах
		elseif quantity < 0 then
			x = tonumber(string.format("%.2f", entry_price - exit_price)) * 100 -- считаем ticks в центах
		else
			x = 0 -- если в direction ничего не сказано про направление
		end

		--xstr=string.gsub(tostring(x), "%.", ",") -- замена в расчете результата точки на запятую для csv
		--entry_price_str=string.gsub(tostring(entry_price), "%.", ",") -- замена точки на запятую в цене Цене_входа
		--exit_price_str=string.gsub(tostring(exit_price), "%.", ",") -- замена точки на запятую в цене Цене_выхода

		pnlstr = tostring(x * math.abs(tonumber(quantity)) * kDollar) -- результат по позиции
		--pnlstr=string.gsub(pnlstr, "%.", ",") -- замена точки на запятую в результате по позиции

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

		-- Добавляет строку результатов в файл
		CSV:write(txt)

		-- Сохраняет изменения в файле
		CSV:flush()

		-- закрываем файл
		CSV:close()
	else
		--message("Ошибка создания файла ")
	end
end

function comma(what)
	-- функция меняет '.' на ',' в what и возвращает текстовое значение
	local xstr = string.gsub(tostring(what), "%.", ",")
	return tostring(xstr)
end

function round(what, signs)
	-- функция округления числа what с количеством знаков signs. Округляет не совсем корректно, но для нефти пойдёт
	--
	--local formatted = string.format("%."..signs.."f",what*100/100)
	local formatted = string.format("%." .. signs .. "f", what)
	return tonumber(formatted)
end

function BuyAsk(account, classcode, seccode, price, size)
	-- функция для покупки ордером
	-- покупаем по цене ask
	---

	--local ql2
	local trans_id = "300"
	--local best_offer = getParamEx(classcode, seccode, "offer").param_value
	--local best_offer = 0

	--ql2 = getQuoteLevel2(classcode, seccode)
	--best_offer = tonumber(ql2.offer[1].price) --0 - nil, 1 - 1 цена справа стакана на покупку (long pos), tonumber(ql2.offer_count) - последняя цена справа стакана (нижняя)
	--price = tostring(ql2.bid[tonumber(ql2.bid_count)].price) -- 1 - нижняя цена, bid_count - верхняя цена слева стакана на продажу (short pos)
	
	if price == 0 then
		message("Ошибка получения последней цены.\n Остановка")
		--TGsend(scName .. ". Ошибка получения последней цены. Остановка")
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
		message (scName .. ". Ошибка отправки транзакции на покупку. Остановка")
		--TGsend(scName .. ". Ошибка отправки транзакции на покупку. Остановка")
		is_run = false
	end
end

function CheckPosition(lot)
	-- функция проверки открытых позиций = необходимому лоту. true/false

	local count = 1
	local posNew = 0

	sleep(100)
	for i = 1, 300 do
		posNew = math.abs(PosNowFunc(ACCOUNT, SEC_CODE))
		if posNew == lot then
			--TGsend(scName.. ". Транзакция прошла за "..tostring(count*100).." мсек")
			message(scName.. ". Транзакция прошла за "..tostring(count*100).." мсек")
			return true
		end
		count = count + 1
		sleep(100)
	end
	return false
end

-- function SLTPorder(account, classcode, seccode, buySell, qty, tprice, slprice, prof_offset, prof_spread)
-- 	-- функция установки стоп-профит ордеров со спрэдом и отступом
-- 	-- trans_id сделать глобальной, покупка + выставление ордера должны быть с одним номером
-- 	-- buySell ="B" -- или "S" покупка/продажа
-- 	-- qty - количество лотов
-- 	-- tprice - take Profit цена
-- 	-- slprice - stop Loss цена
-- 	-- prof_offset - отступ
-- 	-- prof_spread - защитный спрэд

-- 	local stprice = 0 -- цена стоп-ордера для выхода из позиции по stop-loss

-- 	if buySell == "B" then
-- 		stprice = slprice - prof_spread
-- 	elseif buySell == "S" then
-- 		stprice = slprice + prof_spread
-- 	else
-- 		TGsend(scName .. ". Неверно указано направление ордера TakeProfit & StopLoss. Остановка")
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
-- 		["PRICE"] = tostring(slprice), -- цена SL при касании
-- 		["STOPPRICE"] = tostring(tprice), -- установка TP
-- 		["STOP_ORDER_KIND"] = "TAKE_PROFIT_AND_STOP_LIMIT_ORDER",
-- 		["OFFSET"] = tostring(prof_offset), -- отступ от цены
-- 		["OFFSET_UNITS"] = "PRICE_UNITS",
-- 		["SPREAD"] = tostring(prof_spread), -- защитный спрэд
-- 		["SPREAD_UNITS"] = "PRICE_UNITS",
-- 		["MARKET_TAKE_PROFIT"] = "NO",
-- 		["STOPPRICE2"] = tostring(stprice), -- Sl price
-- 		["EXPIRY_DATE"] = "TODAY",
-- 		["MARKET_STOP_LIMIT"] = "NO" --? YES
-- 	}
-- 	local result = sendTransaction(transaction)
-- end


-- function TransOpenPos()
-- 	-- Выставляет заявку на открытие позиции
-- 	-- Получает ID для следующей транзакции
-- 	trans_id = trans_id + 1
-- 	-- Заполняет структуру для отправки транзакции
-- 	local Transaction={
-- 	  ['TRANS_ID']  = tostring(trans_id),   -- Номер транзакции
-- 	  ['ACCOUNT']   = ACCOUNT,              -- Код счета
-- 	  ['CLASSCODE'] = CLASS_CODE,           -- Код класса
-- 	  ['SECCODE']   = SEC_CODE,             -- Код инструмента
-- 	  ['ACTION']    = 'NEW_ORDER',          -- Тип транзакции ('NEW_ORDER' - новая заявка)
-- 	  ['OPERATION'] = 'B',                  -- Операция ('B' - buy, или 'S' - sell)
-- 	  ['TYPE']      = 'L',                  -- Тип ('L' - лимитированная, 'M' - рыночная)
-- 	  ['QUANTITY']  = '1',                  -- Количество
-- 	  ['PRICE']     = tostring(OpenPrice)   -- Цена
-- 	}
-- 	-- Отправляет транзакцию
-- 	local Res = sendTransaction(Transaction)
-- 	if Res ~= '' then message('TransOpenPos(): Ошибка отправки транзакции: '..Res) else message('TransOpenPos(): Транзакция отправлена') end
--   end
   
--   -- Функция вызывается терминалом, когда с сервера приходит новая информация о транзакциях
  function OnTransReply(trans_reply)
	
	local ticks = 0
	local numDeals = 0
	
	-- Если пришла информация по нашей транзакции
	 if trans_reply.trans_id == trans_id then
	
		-- Если данный статус уже был обработан, выходит из функции, иначе запоминает статус, чтобы не обрабатывать его повторно
		if trans_reply.status == LastStatus then
			return
		else
			message(tostring(trans_reply.status))
			LastStatus = trans_reply.status
		end

		if trans_reply.status == 3 then -- если транзакция выполнена
			ticks = ticks + tprofit
			numDeals = numDeals + 1
			pDataTable(date1, SEC_CODE, lot, price, tprofit, ticks, numDeals)
			logger(date1, tostring(os.date()), trans_reply.sec_code, lot, trans_reply.price, tprofit) -- исправить при записи в файл

			lot = -lot

		end


                
                

		-- Выводит в сообщении статусы выполнения транзакции
		-- if       trans_reply.status == 0    then message('OnTransReply(): Транзакция отправлена серверу') 
		-- elseif   trans_reply.status == 1    then message('OnTransReply(): Транзакция получена на сервер QUIK от клиента') 
		-- elseif   trans_reply.status == 2    then message('OnTransReply(): Ошибка при передаче транзакции в торговую систему. Так как отсутствует подключение шлюза Московской Биржи, повторно транзакция не отправляется') 
		-- elseif   trans_reply.status == 3    then message('OnTransReply(): ТРАНЗАКЦИЯ ВЫПОЛНЕНА !!!') 
		-- elseif   trans_reply.status == 4    then message('OnTransReply(): Транзакция не выполнена торговой системой. Более подробное описание ошибки отображается в поле «Сообщение» (trans_reply.result_msg)') 
		-- elseif   trans_reply.status == 5    then message('OnTransReply(): Транзакция не прошла проверку сервера QUIK по каким-либо критериям. Например, проверку на наличие прав у пользователя на отправку транзакции данного типа') 
		-- elseif   trans_reply.status == 6    then message('OnTransReply(): Транзакция не прошла проверку лимитов сервера QUIK') 
		-- elseif   trans_reply.status == 10   then message('OnTransReply(): Транзакция не поддерживается торговой системой') 
		-- elseif   trans_reply.status == 11   then message('OnTransReply(): Транзакция не прошла проверку правильности электронной цифровой подписи') 
		-- elseif   trans_reply.status == 12   then message('OnTransReply(): Не удалось дождаться ответа на транзакцию, т.к. истек таймаут ожидания. Может возникнуть при подаче транзакций из QPILE') 
		-- elseif   trans_reply.status == 13   then message('OnTransReply(): Транзакция отвергнута, так как ее выполнение могло привести к кросс-сделке (т.е. сделке с тем же самым клиентским счетом)')
		-- end
	 end
  end

  function SellBid(account, classcode, seccode, price, size)
	-- функция для продажи ордером
	-- продаем по цене bid
	-- либо переделать на market ордер (сделать одну ф-цию купли/продажи инструмента)

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
		["CLIENT_CODE"] = account -- здесь указывается комментарий
	}
	local res = sendTransaction(transaction)

	if #res ~= 0 then
		--TGsend(scName .. ". Ошибка отправки транзакции на продажу. Остановка")
		message (scName .. ". Ошибка отправки транзакции на продажу. Остановка")
		is_run = false
	end
end

function getLot(account, classcode, seccode, ltPercent)
	--function getLot(account, classcode, seccode, ltPercent)
	--
	-- Функция получения возможного количества лотов,
	-- исходя из ГО и средств на счёте. возвращает числовое значение
	-- ltPercent = 100 -- использовать все свободные средства на счёте

	local lbuy = tonumber(getParamEx(classcode, seccode, "BUYDEPO").param_value) -- ГО покупателя
	local lsell = tonumber(getParamEx(classcode, seccode, "SELLDEPO").param_value) -- ГО продавца
	
	local fMoney = getItem("futures_client_limits", 0).cbplimit
	--message("Средств на счёте "..tostring(fMoney))
	
	local vm1 = getFuturesLimit(classcode, account, 0, "SUR").varmargin -- получаем вар. маржу до клиринга
	message(tostring(vm1))
	local vm2 = getFuturesLimit(classcode, account, 0, "SUR").accruedint --получаем вар. маржу после клиринга
	message(tostring(vm1).."----")
	-- получить позицию вар.маржи и, если она отрицательная, то вычесть из fMoney; если положительная, то ничего не делать.
	if vm1 < 0 then
		if vm2 < 0 then
			fMoney = fMoney + vm1 + vm2
			message(tostring(fMoney.."условие"))
		end
		fMoney = fMoney - vm1
		message(tostring(fMoney.."условие 2"))
	else
		message(tostring(fMoney.."условие 3")) -- доделать
	end
	is_run = false

	-- расчёт лота исходя из максимального ГО для инструмента.
	if fMoney == 0 or fMoney == "" or fMoney == nil then -- если данные по свободным средствам не получены
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
