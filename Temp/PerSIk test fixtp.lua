-- Параметры ------------------------------------------------------------------------------------
is_run = true
----------------------- настройка счетов, инструмента, временного интервала ---------------------

dofile(getScriptPath() .. "\\include\\PeachSI_settings.lua")
-- содержимое файла Peach_settings.lua
--SEC_CODE = "BRH2" --код инструмента/бумаги
--CLASS_CODE = "SPBFUT" --код класса инструмента/бумаги, если нужен фондовый рынок - вводить TQBR вместо SPBFUT
--ACCOUNT = "SPBFUT001dh" -- счет на срочном рынке

--[[
	это в ветке test
	git@github.com:EvPsh/QLUA_robot.git
	https://github.com/EvPsh/QLUA_robot.git
	-- сделать одной программой demo+trade чтобы не плодить несколько версий
--]]
----------------------------------------- Неизменяемые настройки параметров ----------------------------------
SEC_PRICE_STEP = 0 --0.01 шаг цены для инструмента
enPrice = nil -- цена входа
v2 = 0 -- последняя цена сделки (не локальная для передачи в таблицу по щелчку мыши)
date1 = "" -- дата и время входа в позицию
inPosition = false -- в позиции да/нет
t_id = nil -- идентификатор таблицы (числовое значение? = 0)
nFile = "" -- название создаваемого файла (по имени инструмента)
scName = "" -- название запускаемого скрипта
tTime = {
	"7:00:00", "9:10:00", -- время начала/окончания неторгового периода
	"13:45:00", "14:06:00", -- время начала/окончания неторгового периода
	"18:30:00", "19:08:00", -- время начала/окончания неторгового периода
	"23:30:00", "23:50:00" -- время начала/окончания неторгового периода
	-- по реверсу остановка на первом клиринге,
	-- дальше ждать 16:10. В промежутке между 14:00 и 16:10 не работаем
	}

---------------------------------------- Изменяемые настройки параметров робота-Персика --------------------
INTERVAL = INTERVAL_M1 -- временной интервал

lotPercent = 100 -- используем % свободных средства (в процентах) под торговлю
sloss = 100 -- 0.17 оптимальный sl
tprofit = 150 --25 ticks tp
--sttr = 0.03 -- для превращения sl в sttr
spread = 51 -- величина изменения цены, после которой будет выдаваться сигнал на вход/переворот позиции 0.08, 0.09
slTime = 30000 -- величина временного интервала между получением свечей 5000 --было 20000 (20 сек)
pFile = "w:\\temp" --путь, где будет создаваться файл
-------------------------------------------------------------------------------------------------

--corrTime=3 --Время МСК. C сервера время приходит без корректировки.

--[[
-- закрытие/открытие позиции из таблицы (super scalp)?

-- а если оттестировать идею раз в минуту смотреть разброс 8 ticks и вход в направлении
-- пробоя этих 8 ticks с tp=high-open или low-close за последние n свечей.

-- отправка данных в ТГ
-- проверка авторазброса (подбираемый автоматически sl <= x и авто spread) x = avg(o-c) или avg(h-l)

-- отправка транзакции
-- проверка срабатывания транзакции и количества лотов
--	-- если всё ок, то далее. Если не ок, тогда?
-- в сделке: выставка стоп-ордеров (с идентификацией, при совместной работе роботов, чтобы лишнего не сняли)
-- -- перестановка sl ордеров со снятием предыдущих
-- -- при срабатывании sl ордеров, проверка что позиция закрыта. только в этом случае мониторим рынок дальше.
-- --
-- в 23-30 закрытие позиций, снятие ордеров
-- три sl подряд = остановка до конца дня
-- двойной щелчок на инструменте - закрытие позиции по marketprice (взять из scalp)
-- двойной щелчок на sl - подтянуть sl = v2-0.2 с обработкой (sl должен быть меньше v2, иначе - выход)

https://smart-lab.ru/blog/762089.php

1.тренд
2.коррекция
3.диапазон.
1. Соотношение сделок прибыльных убыточных 55/45 (60/40 — идеально)
2. Соотношение тейк/стоплосс 1/1 минимум (1,2/1 уже лучше).

Получить данные о позициях при запуске робота-Персика.
ждать сигнала на вход
если направление позиции не сходится - закрыть позицию, встать в правильном направлении 8 минута урока 54 Qlua Parabolic
ждать сигнала на выход

сделать отдельную таблицу со сделками (параллельно с excel)
проверка работы quik. если не работает - выключаем основную таблицу (кидаем в ТГ статус отключения). Таблицу со сделками оставляем.

--]]
-------------------------------------------------------------------------------------------------
function stopProfit(result, what) -- доделать
	-- считаем количество ticks, передаём в stopProfit
	-- сравниваем с what,
	-- если больше what, ждём следующую сделку,
	-- если сделка закрыта в минус = стоп-трейд
	-- использование:
	--[[
		1. первый трейд интервал - с 10-00:
		до +50 центов (what)
		при наборе +50 центов ждём следующую сделку.
			при наборе -50 центов - стоп трейд до конца дня
				если сделка в плюс - ждём следующую сделку
				если сделка в минус - стоп трейд до второго трейд-интервала.
					если интервал зашёл на второй, но закончился до третьего - торгуем только трейтий, второй пропускаем.
			если 50 центов не набрано, а время заходит на второй трейд - второй и последующие интервалы не запускать

			второй трейд интервал - с 12-00
			при наборе -50 центов - стоп трейд до конца дня
			при наборе +50 центов ждём следующую сделку.
				если сделка в плюс - ждём следующую сделку
				если сделка в минус - стоп трейд
					если интервал зашёл на третий, третий пропускаем.
			если 50 центов не набрано, а время заходит на третий трейд - третий и последующие интервалы не запускать

			третий трейд интервал с 16-00 до 17-00
			при наборе -50 центов - стоп трейд до конца дня
			при наборе +50 центов - ждём следующую сделку
				если сделка в плюс - ждём следующую сделку
				если сделка в минус - стоп трейд

			четвертый трейд интервал с 17-00 до 19-00 -- проверить интервал
			при наборе -50 центов - стоп трейд до конца дня
			при наборе +50 центов - ждём следующую сделку
				если сделка в плюс - ждём следующую сделку
				если сделка в минус - стоп трейд
	-- ]]

	if result >= what then
		return true
	end
	return false
end

function threeTradesMinus(result, tCount) -- доделать! tCount - количество минусовых сделок (не более скольки)
	-- получаем сделки: вход, выход, считаем разницу между ними, передаём в ф-цию, можно передать +1, либо -1 для реализации условия срабатывания
	-- tradesCount - глобальная переменная, локально пока не придумать

	-- ф-ция threeMinusTrades: 3 сделки в минус подряд - стоп-трейд на день
	-- если сделка в плюс - ждём
	-- если сделка в минус, считаем до трёх
	-- вторая сделка в минус, третья - стоп трейд
	--
	--[[
	Получаем inPosition, если false - ждём дальше
	если true - ждём до тех пор, пока не станет false
		если результат +, ждём дальше
		если результат -, счётчик tradesCount прибавляем на 1
	tradesCount = tCount ? проверить, чтобы не влез в позицию
	если да - stopTrade
	--]]
	-- использование:
	--[[
		tradesCount = 0
	--]]
	if result < 0 then
		tradesCount = tradesCount + 1
	else
		-- додумать, если после одной отрицательной была положительная - сброс счётчика
		tradesCount = 0
	end

	if tradesCount == tCount then --tCount количество минусовых сделок подряд
		return true
	end
	return false
end

function PosNowFunc(account, seccode)
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

function OnInit()
	-- Получает доступ к свечам графика
	local Error = ""

	DS, Error = CreateDataSource(CLASS_CODE, SEC_CODE, INTERVAL)
	-- Проверка
	if DS == nil then
		message("ОШИБКА получения доступа к свечам! " .. Error)
		TGsend(scName .. ". ОШИБКА получения доступа к свечам! " .. Error)
		-- Завершает выполнение скрипта
		is_run = false
		return
	end
	scName = string.match(debug.getinfo(1).short_src, "\\([^\\]+)%.lua$") -- получение имени запущенного скрипта
	nFile = pFile .. "\\" .. tostring(SEC_CODE) .. "_" .. scName .. ".csv"
end

function getLot(account, classcode, seccode, ltPercent)
	--
	-- Функция получения возможного количества лотов,
	-- исходя из ГО и средств на счёте. возвращает числовое значение
	-- ltPercent = 100 -- использовать все свободные средства на счёте

	local lbuy = getParamEx(classcode, seccode, "BUYDEPO").param_value -- ГО покупателя
	local lsell = getParamEx(classcode, seccode, "SELLDEPO").param_value -- ГО продавца
	--local fMoney = getFuturesLimit(CLASS_CODE, ACCOUNT, 0, "SUR").cbplimit -- проверить если уже есть заблокированное ГО, выведет правильно сумму или нет
	--local fMoney = getDepo(account, classcode, seccode, "depo_current_balance").param_value
	local fMoney = getItem("futures_client_limits", 0).cbplimit
	--message("Средств на счёте "..tostring(fMoney))

	-- расчёт лота исходя из максимального ГО для инструмента.
	if fMoney == 0 or fMoney == "" or fMoney == nil then -- если данные по свободным средствам не получены
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
		Параметр Тип Описание
		depo_limit_locked_buy_value NUMBER Стоимость инструментов, заблокированных на покупку
		depo_current_balance NUMBER Текущий остаток по инструментам
		depo_limit_locked_buy NUMBER Количество лотов инструментов, заблокированных на покупку
		depo_limit_locked NUMBER Заблокированное Количество лотов инструментов
		depo_limit_available NUMBER Доступное количество инструментов
		depo_current_limit NUMBER Текущий лимит по инструментам
		depo_open_balance NUMBER Входящий остаток по инструментам
		depo_open_limit NUMBER Входящий лимит по инструментам
	--]]
end

function main()
	--sleep (10000) -- приостановка на 10 сек., чтобы сразу в "бой" не рвался
	local exPrice = 0 -- цена выхода из позиции
	local sl = 0 -- Стоп-Лосс
	local tp = 0 -- Тэйк-Профит
	local ticks = 0 -- Начальный результат (ticks)
	local tickstemp = 0 -- для хранения промежуточных значений ticks
	local pos = 0 -- позиция по инструменту
	local lot = 0 -- начальный лот, если 0 -> значит остановка
	local daysToDie = 0 -- количество дней до погашения инструмента

	-- получаем количество дней до погашения, если < 4, рекомендуем перейти на новый инструмент
	-- https://quikluacsharp.ru/quik-qlua/poluchenie-dannyh-iz-tablits-quik-v-qlua-lua/
	daysToDie = round(getParamEx(CLASS_CODE, SEC_CODE, "DAYS_TO_MAT_DATE").param_value, 0)
	--message(tostring(daysToDie))
	if daysToDie <= 4 then
		message("Количество дней до погашения инструмента " .. SEC_CODE .. " равно " .. tostring(daysToDie) .. ". Необходимо заменить инструмент в настройках робота " .. scName)
		TGsend("Количество дней до погашения инструмента " .. SEC_CODE .. " равно " .. tostring(daysToDie) .. ". Необходимо заменить инструмент в настройках робота " .. scName)
	end

	-- Получает ШАГ ЦЕНЫ ИНСТРУМЕНТА
	SEC_PRICE_STEP = getParamEx(CLASS_CODE, SEC_CODE, "SEC_PRICE_STEP").param_value

	-- получаем используемый лот для торговли, если 0 - выход
	lot = getLot(ACCOUNT, CLASS_CODE, SEC_CODE, lotPercent)
	if lot == 0 or lot == nil or lot == "" then
		--message ("Робот_Персик_Реверс. Нехватка ден. средств под ГО, выход")
		--TGsend(scName..". Нехватка ден. средств под ГО или ошибка получения средств на счёте, выход")
		--is_run=false
	end

	-- инициализация таблицы
	CreateTable()
	SetTableNotificationCallback(t_id, f_cb)

	while is_run do
		-- выбор по массиву от и до по времени
		-- если время сервера = нечетному элементу массива, то ждём до следующего (чётного) элемента массива
		----------- Отработка времени работаем/не работаем/останавливаем ----------------------
		local ServerTime = getInfoParam("SERVERTIME")
		--[[
		local SesStatus=getParamEx(CLASS_CODE, SEC_CODE,"STATUS").param_value
		-- local SesStatus=getParamEx(CLASS_CODE, SEC_CODE,"STATUS") -- вернёт таблицу
		if SesStatus~=1 then
			-- проверить позиции и стоп-ордера
			message(scName.." cейчас торговая сессия не идёт")
			TGsend(scName.." cейчас торговая сессия не идёт")
			is_run=false
		end
		--]]
		--local ServerDate = getInfoParam("TRADEDATE") -- ф-ция получения текущей даты торгов os.date
		if (ServerTime == nil or ServerTime == "") then
			-- получить сведения об открытых позициях, стоп-ордерах, обратить на это внимание

			TGsend(scName .. ". Ошибка получения времени сервера")
			--message(scName.." время сервера не получено")
			is_run = false
		end

		--[[
		-- проверка закрытия таблицы (если случайно была закрыта)
		if (IsWindowClosed(t_id)) then
			CreateTable(t_id)
		end
		--]]

		--if ServerTime <= tTime[2] then
			-- проверить, отрабатывает ли?
			-- message(type(ServerTime)) --string

		if ServerTime >= tTime[1] and "0"..ServerTime <= tTime[2] then -- так отработало
			--[[
			-- если время начинается с 0 (07:00:00) - позицию не отрабатывает.
			--]]

			SetCell(t_id, 1, 0, "Ждём до " .. tostring(tTime[2]))

			if inPosition == false then

				sleep(diffTime(ServerTime, tTime[2]) * 1000) -- остановка на разницу временного интервала, сек.
				SetCell(t_id, 1, 0, "Работаю")

			elseif inPosition == true then
				--close Position by MARKETPRICE
				-- надо ли? это промежуточный клиринг, здесь можно не закрывать.
			end
			--SetCell(t_id,1,0,"Ожидание") -- вышли из клиринга, ждём сигнала на вход
		end

		if ServerTime >= tTime[3] and ServerTime <= tTime[4] then
			SetCell(t_id, 1, 0, "Остановка до " .. tostring(tTime[4]))

			if inPosition == false then

				sleep(diffTime(tTime[3], tTime[4]) * 1000) -- остановка на разницу временного интервала, сек.
				SetCell(t_id, 1, 0, "Работаю")

			elseif inPosition == true then
				--close Position by MARKETPRICE
				-- надо ли? это промежуточный клиринг, здесь можно не закрывать.
			end
			--SetCell(t_id,1,0,"Ожидание") -- вышли из клиринга, ждём сигнала на вход
		end

		if ServerTime >= tTime[5] and ServerTime <= tTime[6] then

			SetCell(t_id, 1, 0, "Клиринг " .. tostring(tTime[5]))

			if inPosition == false then

				sleep(diffTime(tTime[5], tTime[6]) * 1000) -- остановка на разницу временного интервала, сек.
				SetCell(t_id, 1, 0, "Работаю ")

			elseif inPosition == true then
				-- close Position by MARKETPRICE
				-- а вот здесь лучше позиции закрыть,
				-- снять все связанные ордера
			end
			--SetCell(t_id,1,0,"Ожидание") -- вышли из клиринга, ждём сигнала на вход
		end

		if ServerTime >= tTime[7] and ServerTime <= tTime[8] then

			SetCell(t_id, 1, 0, "Стоп ")

			if inPosition == false then

				is_run = false -- таблица останется
			elseif inPosition == true then
				TGsend(scName .. " Необходимо закрытие позиции, через ночь не переносить")

				-- принудительное закрытие активных ордеров!
				-- deleteAllProfits(ACCOUNT, CLASS_CODE, SEC_CODE)

				-- closeAll (ACCOUNT, CLASS_CODE, SEC_CODE) -- вывести отдельной функцией

				--[[
					-- получаем данные о текущей позиции
					pos=PosNowFunc(SEC_CODE, ACCOUNT)
					if pos~=0 then
						CorrectPos (pos, 0, SEC_CODE, ACCOUNT, CLASS_CODE, "", "", 0.02)
						deleteAllProfits(ACCOUNT, CLASS_CODE, SEC_CODE)
					end
					-- получаем данные о стоп-ордерах
					-- закрываем стоп-ордера
					-- close Position by MARKETPRICE
					-- закр
				--]]
			end
		end
		--------------------------------------------------------------------------------------

		------------------------- сюда торговый паттерн --------------------------------------
		local v1 = round(getParamEx(CLASS_CODE, SEC_CODE, "LAST").param_value or 0, 2) -- получаем первое значение
		sleep(slTime) -- приостановка на (было 30 сек.)
		v2 = round(getParamEx(CLASS_CODE, SEC_CODE, "LAST").param_value or 0, 2) -- получаем значение спустя slTime сек
		local rslt = round(v2 - v1, 2) -- высчитываем разницу между первым и вторым значением
		-- сюда вывод в файл отладочные данные
		--logger(date1, tostring(os.date()), SEC_CODE, "*", rslt, " ", v2)

		if (v1 == 0 or v2 == 0) then
			message("Ошибка получения последней цены.\n Остановка")
			TGsend(scName .. ". Ошибка получения последней цены. Остановка")
			DestroyTable(t_id)
			is_run = false
		end
		---------------------------------------------------------------------------------------

		--if rslt >= spread then  -- direct
		if rslt <= -spread then -- если разница меньше - идёт быстрое изменение цены, значит что-то случилось:)) было 0,08
			----------------------- Вход в short ----------------------------------------------------------
			TGsend(scName .. ". Внимание на " .. SEC_CODE .. ", разница в ticks = " .. rslt .. ". Сигнал на покупку по " .. v2 .. ". Время " .. getInfoParam("SERVERTIME"))
			-- Позиция long! (если нужено переделать в прямую версию - поменять условия rslt <=-spread на rslt >=spread)
			if inPosition == false then -- если не было ранее сигнала на вход,
				enPrice = v2 --входим маркетом по цене V2
				date1 = tostring(os.date())

				sl = enPrice - sloss -- stop Loss
				tp = enPrice + tprofit -- take Profit

				-- orderBuyMarket (SEC_CODE) -- здесь покупка

				--[[
					info.chm -> раздел 6. Совместная работа с другими приложениями...
					Импорт транзакций. Формат tri-файла с параметрами.

				--]]
				-- trans_id необходимо задать вручную.
				-- отправка транзакции
				-- проверка срабатывания
				-- отправка связанной заявки sl и tp. Одна или две разных?
				-- вывод информации о позиции

				pDataTable(date1, SEC_CODE, "+", enPrice, sl, tp)

				inPosition = true -- то считаем что мы в позиции
				while inPosition do
					v2 = round(getParamEx(CLASS_CODE, SEC_CODE, "last").param_value, 2)
					sleep(1000)

					--if enPrice вот сюда срабатывание sl,tp и выход из позиции
					if v2 <= sl then
						-- сработал sl
						-- orderSellMarket(SEC_CODE)

						------ выводим в лог результаты позиции	------------------------
						logger(date1, tostring(os.date()), SEC_CODE, "+", "1", enPrice, v2)
						tickstemp = round((v2 - enPrice), 2) -- считаем ticks в центах
						ticks = ticks + tickstemp
						SetCell(t_id, 1, 6, tostring(ticks)) -- результат считаем и выводим отдельно в таблицу
						pDataTable("вне позиции", SEC_CODE, "", "", "", "")

						inPosition = false
					end

					if v2 >= tp then
						--сработал tp
						--снимаем ордера
						tp = v2 + tprofit
						sl = v2 - sloss -- trailing new
						--sl=v2-tprofit+sttr -- для trailing stop
						-- вот сюда выделить таблицу зеленым цветом (сделка пошла в плюс)

						-- pDataTable(date1, SEC_CODE, "+", enPrice, sl, tp) -- sl --> в sttr --это для trailing, убрать комментарий

						-- посылка trailing стопа из арсенала QUIK.
						-- если необходим выход по tprofit, убрать комменты:
						---[[
							logger (date1, tostring (os.date()), SEC_CODE, "+", "1", enPrice, v2)
							tickstemp = round((v2 - enPrice), 2) -- считаем ticks в центах
							ticks = ticks + tickstemp
							SetCell(t_id, 1, 6, tostring(ticks)) -- результат считаем и выводим отдельно в таблицу
							pDataTable("вне позиции", SEC_CODE, "", "", "", "")
							inPosition = false
						--]]
					end
				end

				--str='w:\\_plus.bat'
				--tsend(str)
				-- elseif inPosition then -- если уже в позиции в направлении '+'
				-- игнорируем сигнал, можем подтянуть sl в sttr
			end
		--elseif rslt <= -spread then -- direct
		elseif rslt >= spread then -- было 0,08 -- reverse
			TGsend(scName .. ". Внимание на " .. SEC_CODE .. ", разница в ticks = " .. rslt .. ". Сигнал на продажу по " .. v2 .. ". Время " .. getInfoParam("SERVERTIME"))

			if inPosition == false then -- если не было ранее сигнала на вход,
				-- позиция short
				enPrice = v2 --входим маркетом по цене V2
				date1 = tostring(os.date())

				sl = enPrice + sloss -- stop Loss
				tp = enPrice - tprofit -- take Profit

				-- orderSellMarket (id, SEC_CODE)
				-- проверка срабатывания
				-- orderSLBuy (id, SEC_CODE, sl)

				-- вывод информации о позиции
				--message("-"..tostring(enPrice).." "..tostring(date1))
				pDataTable(date1, SEC_CODE, "-", enPrice, sl, tp)

				inPosition = true -- в позиции
				while inPosition == true do
					v2 = round(getParamEx(CLASS_CODE, SEC_CODE, "last").param_value, 2)
					sleep(1000)

					if v2 >= sl then
						-- сработал sl
						-- проверяем срабатывание

						------ выводим в лог результаты позиции	------------------------
						logger(date1, tostring(os.date()), SEC_CODE, "-", "1", enPrice, v2)
						tickstemp = tonumber(string.format("%.2f", round(enPrice - v2, 2))) -- считаем ticks в центах
						ticks = ticks + tickstemp
						SetCell(t_id, 1, 6, tostring(ticks)) -- результат считаем и выводим отдельно в таблицу
						pDataTable("вне позиции", SEC_CODE, "", "", "", "")

						inPosition = false
					end

					if v2 <= tp then
						--сработал tp
						--снимаем ордера

						tp = v2 - tprofit
						sl = v2 + sloss -- trailing new
						--sl=v2+tprofit-sttr -- для trailing stop
						-- pDataTable(date1, SEC_CODE, "-", enPrice, sl, tp) -- sl -> sttr -- это для trailing, убрать комментарий
						-- вот сюда выделение зелёным цветом таблицы (сделка в плюс)

						-- если нужен выход по tprofit, убрать комменты:
						---[[
						logger (date1, tostring (os.date()), SEC_CODE, "-", "1", enPrice, v2)
						tickstemp = tonumber(string.format("%.2f", round(enPrice - v2, 2))) -- считаем ticks в центах
						ticks = ticks + tickstemp
						SetCell(t_id, 1, 6, tostring(ticks)) -- результат считаем и выводим отдельно в таблицу
						pDataTable("вне позиции", SEC_CODE, "", "", "", "")
						inPosition=false
						--]]
					end
				end
			end
		end
	end
end

function OnStop()
	-- функция при выключении робота (при нажатии на остановить скрипт, подвешивает поток)
	--message("Остановка")
	if inPosition then
		--kill all orders
		message("Остались незакрытми позиции по " .. tostring(round(enPrice, 2) .. " " .. tostring(date1)))
	else
		is_run = false
	end
	-- закрываем файл
	--CSV:close()

	--message("Количество ticks = "..tostring(GetCell(t_id,1,6))) -- получаем значение итоговое ticks из созданной таблицы
	-- закрываем таблицу. сюда не доходит. останавливается на is_run
	DestroyTable(t_id)
end

function CreateTable()
	-- функция создания таблицы с результатами
	local daysToDie = round(getParamEx(CLASS_CODE, SEC_CODE, "DAYS_TO_MAT_DATE").param_value, 0)

	t_id = AllocTable()
	-- Добавляет 5 колонок
	AddColumn(t_id, 0, "Дата", true, QTABLE_STRING_TYPE, 17)
	AddColumn(t_id, 1, "Инструмент", true, QTABLE_STRING_TYPE, 15)
	AddColumn(t_id, 2, "Направление" .. "(" .. spread .. ")", true, QTABLE_STRING_TYPE, 17)
	AddColumn(t_id, 3, "Цена входа", true, QTABLE_STRING_TYPE, 15)
	AddColumn(t_id, 4, "Stop Loss " .. "(" .. sloss .. ")", true, QTABLE_STRING_TYPE, 17)
	AddColumn(t_id, 5, "Take Profit " .. "(" .. tprofit .. ")", true, QTABLE_STRING_TYPE, 17)
	AddColumn(t_id, 6, "Результат", true, QTABLE_STRING_TYPE, 15)
	-- Создаем
	--t = CreateWindow(t_id)
	CreateWindow(t_id)
	-- Даем заголовок
	SetWindowCaption(t_id, "Робот Персик " .. scName .. " / "
	.. tostring(slTime / 1000) .. " c. / " .. spread .. " спрэд / "
	.. sloss .. " sl / " .. tprofit .. " tp / " .. SEC_CODE .. " / дней до: ".. daysToDie)
	-- Расположение окна таблицы
	SetWindowPos(t_id, 430, 400, 800, 90) --x, y, dx, dy
	-- Добавляет строку
	InsertRow(t_id, -1)
end

function pDataTable(date1, instrument, direction, entry_price, sloss, tprofit)
	-- ф-ция заполнения таблицы
	-- Дата входа
	-- Инструмент
	-- Направление
	-- Цена входа
	-- Стоп-Лосс
	-- Тэйк-Профит

	--Clear(t_id)
	SetCell(t_id, 1, 0, tostring(date1))
	SetCell(t_id, 1, 1, tostring(instrument))
	SetCell(t_id, 1, 2, tostring(direction))
	SetCell(t_id, 1, 3, tostring(entry_price))
	SetCell(t_id, 1, 4, tostring(sloss))
	SetCell(t_id, 1, 5, tostring(tprofit))
	-- SetCell(t_id,1,6,tostring(result)) -- Результат вводим отдельно от функции pDataTable
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
	-- функция контроля профит-ордера. Если всё ок, тогда ничего не делает.
	-- если что-то не так, снимает заявки, выставляет новый стоп-профит.
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
	local step = 0.01 -- шаг цены для нефти, либо получить из таблицы
	local profit = 50 -- 50 шагов цены
	local prof_offset = 0.05 -- для нефти
	local prof_spread = 0.01 -- для нефти

	local function fn1(param1, param2, param3)
		if (param1 == account and param2 == classcode and param3 == seccode) then
			return true
		else
			return false
		end
	end

	EnterPrice = EnterPriceUni(posNow, account, classcode, seccode) -- округлить до шага цены
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
					profitPriceX = row.condition_price -- желательно округлить до шага цены эту строку
					buySell = row.condition --(если 4 - <=, если 5 >=)

					if (buySell == 4) then
						signPos = -1 -- стоп-профит на покупку нужен при позе <0 (short)
					else --if (buySell == 5) then
						signPos = 1 -- стоп-профит на продажу нужен при позе >0 (long)
					end

					if (signPos == SignFunc(posNow) and qty == math.abs(posNow) and profitPriceX == profitPrice) then
						ProfCorrect = true
					else
						ProfCorrect = false
						TGsend(scName .. ". Неверно установлен стоп-профит, удаляю")
						keyNumber = row.order_num
						deleteProfit(classcode, seccode, keyNumber)
						count = count + 1
					end
				end
			end
		end
		if (ProfCorrect == false and posNow ~= 0) then
			if (posNow > 0) then -- выставляем заявку на продажу
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
		seccode нужен тут или нет?
		считается средняя цена позиции по инструменту
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
			if (bit.band(row.flags, 4) > 0) then -- заявка на продажу, иначе - на покупку
				direct = -1
			else
				direct = 1
			end

			price = row.price
			qty = row.qty
			pnNext = pn - direct * qty

			if (SignFunc(pnNext) ~= SignFunc(pn)) then
				sum = sum + direct * SignFunc(posNow) * price * math.min(qty, math.abs(pn)) -- считаем среднюю цену позиции входа после переворота позиции
				return sum / math.abs(posNow)
			else
				sum = sum + direct * SignFunc(posNow) * price * qty -- считаем среднюю цену позиции входа
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
				count = count + 1 -- время выполнения операции
			end
		end
	end
	return count
end

---[[
function deleteProfit(classcode, seccode, keyNumber)
	-- функция удаления заявок по номеру keyNumber
	local trans_id = "123456"
	local transaction = {
		["CLASSCODE"] = classcode,
		["SECCODE"] = seccode,
		["TRANS_ID"] = trans_id,
		["ACTION"] = "KILL_STOP_ORDER",
		["STOP_ORDER_KEY"] = tostring(keyNumber),
		["CLIENT_CODE"] = scName -- здесь указывается комментарий
	}
	local result = sendTransaction(transaction)
end

function NewStopProfit(account, classcode, seccode, buySell, qty, price, prof_offset, prof_spread)
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
		["CLIENT_CODE"] = scName, -- здесь указывается комментарий
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
		["CLIENT_CODE"] = scName -- здесь указывается комментарий
	}
	local result = sendTransaction(transaction)

	if (file ~= nil or file ~= "") then
		sDataString = "Отклик транзакции = " .. result .. "; Pos = " .. tostring(posNow) .. "; "
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
			sDataString = scName .. ". Транзакция прошла за " .. tostring(count * 100) .. " мсек"
			TGsend(sDataString)
			WriteToFile(file, sDataString)
			return 1
		end
		count = count + 1
		sleep(100)
	end
	sDataString = "Проблемы с транзакцией"
	WriteToFile(file, sDataString)
	return nil
end

function f_cb(t_id, msg, x, y)
	-- функция обработки нажатий таблицы (глобальная)
	-- SetTableNotificationCallback(t_id, f_cb) либо в onInit, либо в main (не в цикл)
	if (msg == QTABLE_LBUTTONDBLCLK) then
		if (x == 1 and y == 4) then -- если нажатие было на первой строке, четвертой колонке
			if inPosition == true then
				-- получить стоп-ордера,
				-- если есть - снять
				-- получить текущую позицию.
				-- выставить новый стоп-ордер при касании закрыть позицию sl=v2-0,20
				message("Последняя цена = " .. tostring(v2)) -- подтянуть sl=v2-0,20
			else
				message("Нет открытых позиций, нечего SL подтягивать")
			end
		elseif (x == 1 and y == 5) then
			if inPosition == true then
				-- получить стоп-ордера
				-- если есть - снять
				-- получить текущую позицию
				-- закрыть текущую позицию по цене bid или offer
				message("Робот на 5ой колонке. На take_profit") -- закрыть позицию market ордером
			else
				message("Нет открытых позиций, нечего закрывать")
			end
		end
	end

	--[[
	--------------------- функция обработки нажатий клавиш на таблице робота ----------------------------
		-- функция обработки нажатий таблицы локальная
		local f_cb=function(t_id, msg, x, y)
			if (msg==QTABLE_LBUTTONDBLCLK) then
				if (x==1 and y==4) then -- если нажатие было на первой строке, седьмой колонке
					message("Последняя цена = "..tostring(v2)) -- подтянуть sl=v2-0,20
				elseif (x==1 and y==5) then
					message("Робот на 5ой колонке. На take_profit") -- закрыть позицию market ордером
				end
			end
		end
		SetTableNotificationCallback(t_id, f_cb) -- обработка нажатия на ячейке таблицы
		-----------------------------------------------------------------------------------------------------

--]]

	--[[
в onInit
function onInit()
	 SetTableNotificationCallback (tbl.t_id, f_cb)
end

-------------------------------Колбэки------------------------------------------------------------------
 function   f_cb (t_id,msg,par1,par2)  --событие на нажатие клавиш
    if  (msg =  = QTABLE_CHAR)  and  (par2 =  =  19 )  then   --сохранить в CSV файл текущее состояние таблицы нужно нажать комбинацию клавиш Ctrl+S
      CSV(tbl)
    end

    if  (msg =  = QTABLE_CLOSE)  then   --закрытие окна
      Stop()
    end

    if  (msg =  = QTABLE_VKEY)  and  (par2 =  =  116 )  then   --функция принудительного обновления таблицы при нажатии клавиши Ctrl+F5
       for  SecCode  in   string.gmatch (SecList,  "([^,]+)" )  do   --перебираем опционы по очереди.
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
--[[
function tsend (str)
	os.execute(str)
end
--]]
function round(what, signs)
	-- функция округления числа what с количеством знаков signs. Округляет не совсем корректно, но для нефти пойдёт
	--
	--local formatted = string.format("%."..signs.."f",what*100/100)
	--[[ для нефти убираем скобки
		local formatted = string.format("%." .. signs .. "f", what)
		return tonumber(formatted)
	--]]
	return tonumber(what) -- сделал чтобы не исправлять по всей программе
end

--[[
function loggerinit(nFile)
		-- Создает, или открывает для чтения/добавления файл CSV в той же папке, где находится данный скрипт
		-- использовать в OnInit
		-- вторая часть использовать в main -  logger (xxx)
	CSV = io.open(nFile, "a+")
	-- Встает в конец файла, получает номер позиции
	local Position = CSV:seek("end",0)
	-- Если файл еще пустой
	if Position == 0 then
		-- Создает строку с заголовками столбцов
		local Header = "Дата1;Дата2;Код бумаги;Операция;Количество;Цена_входа;Цена_выхода;Ticks;PnL\n"
		-- Добавляет строку заголовков в файл
		CSV:write(Header)
		-- Сохраняет изменения в файле
		CSV:flush()
	end
end
--]]
function logger(date1, date2, instrument, direction, quantity, entry_price, exit_price)
	-- функция логгирования данных.
	-- сделать ввод с неизвестынм количеством аргументов? a,b,c..z
	-- вывод данных соответственно from a to z

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
		"Дата1;Дата2;Код бумаги;Операция;Количество;Цена_входа;Цена_выхода;Ticks;PnL;$;slTime;Spread;Sttr;Sloss;tProfit\n"
		-- Добавляет строку заголовков в файл
		CSV:write(Header)
		-- Сохраняет изменения в файле
		CSV:flush()
		Position = CSV:seek("end", 0)
	end

	if Position ~= 0 then --идём в последнюю строку csv файла
		-- Создает строку с результатами
		-- "Дата;Время;Код бумаги;Операция;Количество;Цена_входа;Цена_выхода;PnL*Лот\n"
		if direction == "+" then
			x = tonumber(string.format("%.2f", exit_price - entry_price)) -- считаем ticks в центах
		elseif direction == "-" then
			x = tonumber(string.format("%.2f", entry_price - exit_price)) -- считаем ticks в центах
		else
			x = 0 -- если в direction ничего не сказано про направление
		end

		--xstr=string.gsub(tostring(x), "%.", ",") -- замена в расчете результата точки на запятую для csv
		--entry_price_str=string.gsub(tostring(entry_price), "%.", ",") -- замена точки на запятую в цене Цене_входа
		--exit_price_str=string.gsub(tostring(exit_price), "%.", ",") -- замена точки на запятую в цене Цене_выхода

		pnlstr = tostring(x * tonumber(quantity) * kDollar) -- результат по позиции
		--pnlstr=string.gsub(pnlstr, "%.", ",") -- замена точки на запятую в результате по позиции

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

function TGsend(mText)
	--
	-- Отправка сообщений в Телеграмм
	--
	--[[
	мой бот в ТГ Token:
	1776852311:AAFD2JkJ5nvzBSBcdVEhGKJ-z490YI2Wk_4

	ID пользователей:
	Катюшка 1310951726
	Мой  527734323
	Ваня 484834503
	]]
	--curl https://api.telegram.org/bot%botToken%/sendMessage?chat_id=%chatID%^^^&text=%message%
	str = 'w:\\curl\\bin\\curl.exe -s -X POST https://api.telegram.org/bot1776852311:AAFD2JkJ5nvzBSBcdVEhGKJ-z490YI2Wk_4/sendMessage -d chat_id=527734323 -d text="' ..
		mText .. '"'

	--str='C:\\distr\\curl\\bin\\curl.exe -s -X POST https://api.telegram.org/bot1776852311:AAFD2JkJ5nvzBSBcdVEhGKJ-z490YI2Wk_4/sendMessage -d chat_id=527734323 -d text="'..mText..'"'
	--curl -s -X POST https://api.telegram.org/bot<ТОКЕН>/sendMessage -d chat_id=<ID_ЧАТА> -d text="Привет от бота"

	--os.execute(str) -- раскомментировать для отправки сообщений в ТГ
end

function diffTime(time1, time2)
	-- возвращает разницу в секундах между time2-time1, либо 0, если time2>time1
	-- time1 = "13:45:00"
	-- time2 = "14:06:00"
	-- result = diffTime(time1, time2) -- = 1260 секунд = 21 минута

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

	--часы*3600 + минуты*60 + секунды.
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
-- функция округления до шага цены
-- из видеоуроков по qlua
-- нужна ли эта фукнция?
-- использование:

	if (nStep==nil or num==nil) then
		return nil
	elseif (nStep==0) then
		return num
	end

	local ost=num%nStep -- ищем остаток от деления
	if (ost<nStep/2) then
		return (math.floor(num/nStep)*nStep) --округление вниз
	else
		return (math.ceil(num/nStep)*nStep) -- округление вверх
	end

end
--]]

--[[

https://quikluacsharp.ru/qlua-osnovy/data-vremya-v-qlua-lua/
os.date в lua
--]]
--[[
Дата/время в QLua(Lua) может быть представлено либо в виде секунд, прошедших с полуночи 1 января 1970 года, либо в виде таблицы, имеющей следующие поля:

   year - год (четыре цифры)
   month - месяц (1 – 12)
   day - день (1 – 31)
   hour - час (0 – 23)
   min - минуты (0 – 59)
   sec - секунды (0 – 59)
   wday - день недели (1 - 7), воскресенью соответствует 1
   yday - день года
   isdst - флаг дневного времени суток, тип boolean

Встроенные функции:

   os.clock() - возвращает время в секундах с точностью до миллисекунд с момента запуска приложения, в нашем случае QUIK. Пример: 1544.801
   os.time() - возвращает время в секундах, прошедших с полуночи 1 января 1970 года, может принимать вышеописанную таблицу, в качестве аргумента, без аргументов возвращает текущее время
   os.date() - возвращает форматированные дату/время, первым аргументом принимает формат, вторым аргументом принимает время в секундах. Аргументы не обязательны. Если не передать 2-й аргумент, функция вернет текущие дату/время компьютера. Если функцию вызвать вообще без аргументов, то она вернет текущие дату/время компьютера в виде 03/22/15 22:28:11

В строке формата можно использовать следующие опции:

%a   - день недели, сокр. (англ.) (пример, Wed)
%A   - день недели, полностью (англ.) (пример, Wednesday)
%b   - месяц, сокр. (англ.) (пример, Sep)
%B   - месяц, полностью (англ.) (пример, September)
%c   - дата и время (по-умолчанию) (пример, 03/22/15 22:28:11)
%d   - день месяца (пример, 22) [диапазон, 01-31]
%H   - час, в 24-х часовом формате (пример, 23) [диапазон, 00-23]
%I   - час, в 12-и часовом формате (пример, 11) [диапазон, 01-12]
%M   - минута (пример, 48) [диапазон, 00-59]
%m   - месяц (пример, 09) [диапазон, 01-12]
%p   - время суток "am", или "pm"
%S   - секунда (пример, 10) [диапазон, 00-59]
%w   - день недели (пример, 3) [диапазон, 0-6, соответствует Sunday-Saturday]
%x   - дата (пример, 09/16/98)
%X   - время (пример, 23:48:10)
%Y   - год, 4 цифры (пример, 2015)
%y   - год, 2 цифры (пример, 15) [00-99]
%%   - символ "%"
*t   - вернет таблицу
!*t  - вернет таблицу (по Гринвичу)
Примеры:
--]]
--[[
-- Представить произвольное время в секундах
datetime = { year  = 2015,
             month = 03,
             day   = 22,
             hour  = 22,
             min   = 28,
             sec   = 11
           };
seconds = os.time(datetime); -- в seconds будет значение 1427052491

-- Представить время в секундах в виде таблицы datetime
datetime = os.date("*t",seconds);

-- Преобразование строки даты/времени в таблицу datetime
dt = {};
dt.day,dt.month,dt.year,dt.hour,dt.min,dt.sec = string.match("22/03/2015 22:28:11","(%d*)/(%d*)/(%d*) (%d*):(%d*):(%d*)");
for key,value in pairs(dt) do dt[key] = tonumber(value) end

-- А так можно получить текущие дату/время сервера в виде таблицы datetime
dt = {};
dt.day,dt.month,dt.year,dt.hour,dt.min,dt.sec = string.match(getInfoParam('TRADEDATE')..' '..getInfoParam('SERVERTIME'),"(%d*).(%d*).(%d*) (%d*):(%d*):(%d*)")
for key,value in pairs(dt) do dt[key] = tonumber(value) end

--]]

--[[

--Buy(classCode, secCode, workSize, 'OpenLong') -- использование
--Sell(classCode, secCode, lastPos, 'CloseLong') -- использование


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
-- функция снимает все стоп-заявки
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

покупка по коридору:
если за n-свечей средняя цена была ниже на 2 ticks и выше на 2 ticks средней цены,
то покупаем по нижней, продаем по верхней границе
--]]

--[[

local SecCode = «LKU0»
local Quantity=1

function main()

while stopped == false do
	local Quotes = getQuoteLevel2(«SPBFUT», SecCode)
	local Offer_Price = tonumber(Quotes.offer[1].price) -- получение цен ask (offer)
	local Offer_Vol = tonumber(Quotes.offer[1].quantity)

	--отправка формы заявки
	local LimitOrderBuy = { ххххх}

	--условие входа в лонг

	if Offer_Vol>10 then
		message(Order)
		local Order = sendTransaction(LimitOrderBuy)
	end

	sleep (200)
end

Если количество лукойла в первой строке стакана больше 10, то покупается 1 бумага и работа скрипта завершается.
Так как скрипт срабатывает при определенном условии, то для перезапуска используется while stopped == false do и sleep (200).
Прикол в том, что при наступлении условия, скрипт начинает бомбить заявки по 1 шт  пока не кончаются деньги (виртуальные).

Вопрос: какой размыкатель цикла можно тут использовать, чтобы после покупки 1 бумаги работа скрипта завершилась?

--]]

--[[
map={[1]=10,[2]=15,[3]=44,[4]=18}
for i,value in ipairs(map) do
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
-- Функция определения знака числа
-- если больше нуля = 1
-- если меньше нуля = -1
-- если равна нулю = 0
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
--/*НАСТРАИВАЕМЫЕ ПАРАМЕТРЫ*/
NAME_OF_STRATEGY = 'Str1_' -- НАЗВАНИЕ СТРАТЕГИИ (не более 9 символов!)
CLASS_CODE = "QJSIM" -- Код класса SPBFUT
SEC_CODE = "SBER" -- Код бумаги SiZ6 SiH7, SiM7, SiU7
ACCOUNT = "NL0011100043" -- Идентификатор счета SPBFUT00355
CLIENT_CODE = NAME_OF_STRATEGY..SEC_CODE -- "Код клиента"
QTY_LOTS = "1" -- Кол-во торгуемых лотов
FILE_LOG_NAME = "C:\\TRADING\\QUIK Junior\\Scripts\\Log.txt" -- ИМЯ ЛОГ-ФАЙЛА

--/*РАБОЧИЕ ПЕРЕМЕННЫЕ РОБОТА (менять не нужно)*/
g_price_step = 0 -- ШАГ ЦЕНЫ ИНСТРУМЕНТА
g_trans_id_entry = 110001 -- Задает начальный номер ID транзакций на вход
g_trans_id_exit = 220001 -- Задает начальный номер ID транзакций на выход
g_arrTransId_entry = {} -- массив ID транзакций на вход
g_arrTransId_exit = {} -- массив ID транзакций на выход
g_transId_del_order = "1234" -- ID ордера на удаление заявки (не меняется)
g_transId_del_stopOrder = "6789" -- ID ордера на удаление стоп заявки (не меняется)
g_currentPosition = 0 -- в позиции? сколько лотов и какое направление
g_IsTrallingStop = false -- выставлен ли трейлинг стоп на сервере
g_stopOrderEntry_num= "" -- номер стоп-заявки на вход в системе, по которому её можно снять
g_stopOrderExit_num = "" -- номер стоп-заявки на выход в системе, по которому её можно снять
g_order_num = "" -- номер заявки в системе, по которому её можно снять
g_oldTrade_num = "" -- номер предыдущей обработанной сделки
g_previous_time = os.time() -- помещение в переменную времени сервера в формате HHMMSS
isRun = true -- Флаг поддержания работы бесконечного цикла в main

function OnInit()
   -- Получает ШАГ ЦЕНЫ ИНСТРУМЕНТА
    g_price_step = getParamEx(CLASS_CODE, SEC_CODE, "SEC_PRICE_STEP").param_value

    f = io.open(FILE_LOG_NAME, "a+") -- открывает файл
    myLog("Initialization finished")
end
function main()
   g_trans_id_exit = g_trans_id_exit + 1
   g_arrTransId_exit[#g_arrTransId_exit+1] = g_trans_id_exit

   SendStopOrder("131.9", QTY_LOTS, "B", g_trans_id_exit) -- Отправить стоп ордер
   sleep(2000)                                            -- через 2 секунды
   DeleteStopOrder(g_stopOrderExit_num)                   -- удалить стоп-ордер

   while isRun do
      sleep(5000) -- обрабатываем цикл с задержкой 5сек.
   end
end

-- функция вызывается терминалом ТЕРМИНАЛОМ QUIK при остановке скрипта
function OnStop()
   myLog("Script Stoped")
   f:close() -- Закрывает файл
   isRun = false
end

function SendStopOrder(stopPrice, quantity, operation, trans_id)
   local offset=50 -- отступ для гарантированного исполнения ордера по рынку (в кол-ве шагов цены)
   local price
   local direction

   if operation=="B" then
      price = stopPrice + g_price_step*offset
      direction = "5" -- Направленность стоп-цены. «5» - больше или равно
   else
      price = stopPrice - g_price_step*offset
      direction = "4" -- Направленность стоп-цены. «4» - меньше или равно
   end
   --message("stopPrice"..stopPrice)
   --Пошлем стоп заявку
   local Transaction = {
                       ['ACTION'] = "NEW_STOP_ORDER",
                       ['PRICE'] = tostring(price),
                       ['EXPIRY_DATE'] = "TODAY",--"GTC", -- на учебном серве только стоп-заявки с истечением сегодня, потом поменять на GTC
                       ['STOPPRICE'] = tostring(stopPrice),
                       ['STOP_ORDER_KIND'] = "SIMPLE_STOP_ORDER",
                       ['TRANS_ID'] = removeZero(tostring(trans_id)),
                       ['CLASSCODE'] = CLASS_CODE,
                       ['SECCODE'] = SEC_CODE,
                       ['ACCOUNT'] = ACCOUNT,
                       ['CLIENT_CODE'] = CLIENT_CODE, -- Комментарий к транзакции, который будет виден в транзакциях, заявках и сделках
                       ['TYPE'] = "L",
                       ['OPERATION'] = tostring(operation),
                       ['CONDITION'] = direction, -- Направленность стоп-цены. Возможные значения: «4» - меньше или равно, «5» – больше или равно
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
                       ['TRANS_ID'] = g_transId_del_order, -- ID УДАЛЯЮЩЕЙ транзакции
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
-- создан/изменен/сработал стоп-ордер
function OnStopOrder(stopOrder)
   -- Если не относится к роботу, выходит из функции
   if stopOrder.brokerref:find(CLIENT_CODE) == nil then return end

   local string state="_" -- состояние заявки
   --бит 0 (0x1) Заявка активна, иначе не активна
   if bit.band(stopOrder.flags,0x1)==0x1 then
      state="стоп-заявка создана"
      if EntryOrExit(stopOrder.trans_id) == "Entry" then
         g_stopOrderEntry_num = stopOrder.order_num
      end
      if EntryOrExit(stopOrder.trans_id) == "Exit" then
         g_stopOrderExit_num = stopOrder.order_num
      end
   end
   if bit.band(stopOrder.flags,0x2)==0x1 or stopOrder.flags==26 then
      state="стоп-заявка снята"
   end
   if bit.band(stopOrder.flags,0x2)==0x0 and bit.band(stopOrder.flags,0x1)==0x0 then
      state="стоп-ордер исполнен"
   end
   if bit.band(stopOrder.flags,0x400)==0x1 then
      state="стоп-заявка сработала, но была отвергнута торговой системой"
   end
   if bit.band(stopOrder.flags,0x800)==0x1 then
      state="стоп-заявка сработала, но не прошла контроль лимитов"
   end
   if state=="_" then
      state="Набор битовых флагов="..tostring(stopOrder.flags)
   end
   myLog("OnStopOrder(): sec_code="..stopOrder.sec_code.."; "..EntryOrExit(stopOrder.trans_id)..";\t"..state..
         "; condition_price="..stopOrder.condition_price.."; transID="..stopOrder.trans_id.."; order_num="..stopOrder.order_num )
end
------------------------- Сервисные функции--------------------
-- функция записывает в лог строчку с временем и датой
function myLog(str)
   if f==nil then return end

   local current_time=os.time()--tonumber(timeformat(getInfoParam("SERVERTIME"))) -- помещене в переменную времени сервера в формате HHMMSS
   if (current_time-g_previous_time)>1 then -- если текущая запись произошла позже 1 секунды, чем предыдущая
      f:write("\n") -- добавляем пустую строку для удобства чтения
   end
   g_previous_time = current_time

   f:write(os.date().."; ".. str .. ";\n")

   if str:find("Script Stoped") ~= nil then
      f:write("======================================================================================================================\n\n")
      f:write("======================================================================================================================\n")
   end
   f:flush() -- Сохраняет изменения в файле
end
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
-- Возвращает Entry или Exit в зависимости от trans_id
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
среднегодовую зп/29,3 и умножаем на кол-во дней отпуска. чем меньше праздничных дней в отпуске, тем больше отпускные.
--]]

--[[
-- https://quikluacsharp.ru/quik-qlua/poluchenie-dannyh-iz-tablits-quik-v-qlua-lua/
-- Перебирает строки таблицы "Позиции по клиентским счетам (фьючерсы)", ищет Текущие чистые позиции по инструменту "RIH5"
for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do
   -- ЕСЛИ строка по нужному инструменту И чистая позиция не равна нулю ТО
   if getItem("FUTURES_CLIENT_HOLDING",i).sec_code == "RIH5" and getItem("FUTURES_CLIENT_HOLDING",i).totalnet ~= 0 then
      -- ЕСЛИ текущая чистая позиция > 0, ТО открыта длинная позиция (BUY)
      if getItem("FUTURES_CLIENT_HOLDING",i).totalnet > 0 then
         IsBuy = true;
         BuyVol = getItem("FUTURES_CLIENT_HOLDING",i).totalnet;	-- Количество лотов в позиции BUY
      else   -- ИНАЧЕ открыта короткая позиция (SELL)
         IsSell = true;
         SellVol = math.abs(getItem("FUTURES_CLIENT_HOLDING",i).totalnet); -- Количество лотов в позиции SELL
      end;
   end;
end;

--]]

--[[
https://quikluacsharp.ru/quik-qlua/poluchenie-dannyh-iz-tablits-quik-v-qlua-lua/
Status =  tonumber(getParamEx("SPBFUT",  "RIM5", "STATUS").param_value);
-- Выводит сообщение о текущем состоянии
if Status == 1 then message("RIM5 торгуется"); else message("RIM5 не торгуется"); end;
Список возможных идентификаторов параметров, передаваемых в функцию getParamEx()

   STATUS                  STRING   Статус
   LOTSIZE                 NUMERIC  Размер лота
   BID                     NUMERIC  Лучшая цена спроса
   BIDDEPTH                NUMERIC  Спрос по лучшей цене
   BIDDEPTHT               NUMERIC  Суммарный спрос
   NUMBIDS                 NUMERIC  Количество заявок на покупку
   OFFER                   NUMERIC  Лучшая цена предложения
   OFFERDEPTH              NUMERIC  Предложение по лучшей цене
   OFFERDEPTHT             NUMERIC  Суммарное предложение
   NUMOFFERS               NUMERIC  Количество заявок на продажу
   OPEN                    NUMERIC  Цена открытия
   HIGH                    NUMERIC  Максимальная цена сделки
   LOW                     NUMERIC  Минимальная цена сделки
   LAST                    NUMERIC  Цена последней сделки
   CHANGE                  NUMERIC  Разница цены последней к предыдущей сессии
   QTY                     NUMERIC  Количество бумаг в последней сделке
   TIME                    STRING   Время последней сделки
   VOLTODAY                NUMERIC  Количество бумаг в обезличенных сделках
   VALTODAY                NUMERIC  Оборот в деньгах
   TRADINGSTATUS           STRING   Состояние сессии
   VALUE                   NUMERIC  Оборот в деньгах последней сделки
   WAPRICE                 NUMERIC  Средневзвешенная цена
   HIGHBID                 NUMERIC  Лучшая цена спроса сегодня
   LOWOFFER                NUMERIC  Лучшая цена предложения сегодня
   NUMTRADES               NUMERIC  Количество сделок за сегодня
   PREVPRICE               NUMERIC  Цена закрытия
   PREVWAPRICE             NUMERIC  Предыдущая оценка
   CLOSEPRICE              NUMERIC  Цена периода закрытия
   LASTCHANGE              NUMERIC  % изменения от закрытия
   PRIMARYDIST             STRING   Размещение
   ACCRUEDINT              NUMERIC  Накопленный купонный доход
   YIELD                   NUMERIC  Доходность последней сделки
   COUPONVALUE             NUMERIC  Размер купона
   YIELDATPREVWAPRICE      NUMERIC  Доходность по предыдущей оценке
   YIELDATWAPRICE          NUMERIC  Доходность по оценке
   PRICEMINUSPREVWAPRICE   NUMERIC  Разница цены последней к предыдущей оценке
   CLOSEYIELD              NUMERIC  Доходность закрытия
   CURRENTVALUE            NUMERIC  Текущее значение индексов Московской Биржи
   LASTVALUE               NUMERIC  Значение индексов Московской Биржи на закрытие предыдущего дня
   LASTTOPREVSTLPRC        NUMERIC  Разница цены последней к предыдущей сессии
   PREVSETTLEPRICE         NUMERIC  Предыдущая расчетная цена
   PRICEMVTLIMIT           NUMERIC  Лимит изменения цены
   PRICEMVTLIMITT1         NUMERIC  Лимит изменения цены T1
   MAXOUTVOLUME            NUMERIC  Лимит объема активных заявок (в контрактах)
   PRICEMAX                NUMERIC  Максимально возможная цена
   PRICEMIN                NUMERIC  Минимально возможная цена
   NEGVALTODAY             NUMERIC  Оборот внесистемных в деньгах
   NEGNUMTRADES            NUMERIC  Количество внесистемных сделок за сегодня
   NUMCONTRACTS            NUMERIC  Количество открытых позиций
   CLOSETIME               STRING   Время закрытия предыдущих торгов (для индексов РТС)
   OPENVAL                 NUMERIC  Значение индекса РТС на момент открытия торгов
   CHNGOPEN                NUMERIC  Изменение текущего индекса РТС по сравнению со значением открытия
   CHNGCLOSE               NUMERIC  Изменение текущего индекса РТС по сравнению со значением закрытия
   BUYDEPO                 NUMERIC  Гарантийное обеспечение продавца
   SELLDEPO                NUMERIC  Гарантийное обеспечение покупателя
   CHANGETIME              STRING   Время последнего изменения
   SELLPROFIT              NUMERIC  Доходность продажи
   BUYPROFIT               NUMERIC  Доходность покупки
   TRADECHANGE             NUMERIC  Разница цены последней к предыдущей сделки (FORTS, ФБ СПБ, СПВБ)
   FACEVALUE               NUMERIC  Номинал (для бумаг СПВБ)
   MARKETPRICE             NUMERIC  Рыночная цена вчера
   MARKETPRICETODAY        NUMERIC  Рыночная цена
   NEXTCOUPON              NUMERIC  Дата выплаты купона
   BUYBACKPRICE            NUMERIC  Цена оферты
   BUYBACKDATE             NUMERIC  Дата оферты
   ISSUESIZE               NUMERIC  Объем обращения
   PREVDATE                NUMERIC  Дата предыдущего торгового дня
   DURATION                NUMERIC  Дюрация
   LOPENPRICE              NUMERIC  Официальная цена открытия
   LCURRENTPRICE           NUMERIC  Официальная текущая цена
   LCLOSEPRICE             NUMERIC  Официальная цена закрытия
   QUOTEBASIS              STRING   Тип цены
   PREVADMITTEDQUOT        NUMERIC  Признаваемая котировка предыдущего дня
   LASTBID                 NUMERIC  Лучшая спрос на момент завершения периода торгов
   LASTOFFER               NUMERIC  Лучшее предложение на момент завершения торгов
   PREVLEGALCLOSEPR        NUMERIC  Цена закрытия предыдущего дня
   COUPONPERIOD            NUMERIC  Длительность купона
   MARKETPRICE2            NUMERIC  Рыночная цена 2
   ADMITTEDQUOTE           NUMERIC  Признаваемая котировка
   BGOP                    NUMERIC  БГО по покрытым позициям
   BGONP                   NUMERIC  БГО по непокрытым позициям
   STRIKE                  NUMERIC  Цена страйк
   STEPPRICET              NUMERIC  Стоимость шага цены
   STEPPRICE               NUMERIC  Стоимость шага цены (для новых контрактов FORTS и RTS Standard)
   SETTLEPRICE             NUMERIC  Расчетная цена
   OPTIONTYPE              STRING   Тип опциона
   OPTIONBASE              STRING   Базовый актив
   VOLATILITY              NUMERIC  Волатильность опциона
   THEORPRICE              NUMERIC  Теоретическая цена
   PERCENTRATE             NUMERIC  Агрегированная ставка
   ISPERCENT               STRING   Тип цены фьючерса
   CLSTATE                 STRING   Статус клиринга
   CLPRICE                 NUMERIC  Котировка последнего клиринга
   STARTTIME               STRING   Начало основной сессии
   ENDTIME                 STRING   Окончание основной сессии
   EVNSTARTTIME            STRING   Начало вечерней сессии
   EVNENDTIME              STRING   Окончание вечерней сессии
   MONSTARTTIME            STRING   Начало утренней сессии
   MONENDTIME              STRING   Окончание утренней сессии
   CURSTEPPRICE            STRING   Валюта шага цены
   REALVMPRICE             NUMERIC  Текущая рыночная котировка
   MARG                    STRING   Маржируемый
   EXPDATE                 NUMERIC  Дата исполнения инструмента
   CROSSRATE               NUMERIC  Курс
   BASEPRICE               NUMERIC  Базовый курс
   HIGHVAL                 NUMERIC  Максимальное значение (RTSIND)
   LOWVAL                  NUMERIC  Минимальное значение (RTSIND)
   ICHANGE                 NUMERIC  Изменение (RTSIND)
   IOPEN                   NUMERIC  Значение на момент открытия (RTSIND)
   PCHANGE                 NUMERIC  Процент изменения (RTSIND)
   OPENPERIODPRICE         NUMERIC  Цена предторгового периода
   MIN_CURR_LAST           NUMERIC  Минимальная текущая цена
   SETTLECODE              STRING   Код расчетов по умолчанию
   STEPPRICECL             DOUBLE   Стоимость шага цены для клиринга
   STEPPRICEPRCL           DOUBLE   Стоимость шага цены для промклиринга
   MIN_CURR_LAST_TI        STRING   Время изменения минимальной текущей цены
   PREVLOTSIZE             DOUBLE   Предыдущее значение размера лота
   LOTSIZECHANGEDAT        DOUBLE   Дата последнего изменения размера лота
   CLOSING_AUCTION_PRICE   NUMERIC  Цена послеторгового аукциона
   CLOSING_AUCTION_VOLUME  NUMERIC  Количество в сделках послеторгового аукциона
   LONGNAME                STRING   Полное название бумаги
   SHORTNAME               STRING   Краткое название бумаги
   CODE                    STRING   Код бумаги
   CLASSNAME               STRING   Название класса
   CLASS_CODE              STRING   Код класса
   TRADE_DATE_CODE         DOUBLE   Дата торгов
   MAT_DATE                DOUBLE   Дата погашения
   DAYS_TO_MAT_DATE        DOUBLE   Число дней до погашения
   SEC_FACE_VALUE          DOUBLE   Номинал бумаги
   SEC_FACE_UNIT           STRING   Валюта номинала
   SEC_SCALE               DOUBLE   Точность цены
   SEC_PRICE_STEP          DOUBLE   Минимальный шаг цены
   SECTYPE                 STRING   Тип инструмента
--]]
