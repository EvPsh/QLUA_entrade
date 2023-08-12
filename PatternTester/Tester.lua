-- Скрипт поиска сигналов на графиках с метками
-- с последующим отображением на графиках, в таблице, сообщениях найденных паттернов
-- Telegram @JJ_FXE 
---

dofile(getScriptPath() .. "\\include\\Parameters.lua")   -- параметры, устанавливаются вручную
dofile(getScriptPath() .. "\\include\\Patterns.lua")        -- паттерны VSA для перебора

is_run = true           -- флаг работы скрипта
CorrTime = 3            -- Время МСК. C сервера время приходит без корректировки.
Cbars = 3               -- сколько свечей надо вывести
ds = {}                 -- data source для получения данных свечей
Classcode = "SPBFUT"    -- код класса инструмента/бумаги, если нужен фондовый рынок - вводить TQBR вместо SPBFUT. Пока не используется.
SlTime = 0.1            -- время приостановки для проверки сигналов на графике, в минутах (0.1 = 6 секунд, 0.5 = 30 секунд, 1 = 1 минута и т.д.)

Bars = {                -- массив данных баров
        ["O"] = {},     -- массив свечей по количеству Cbars
        ["H"] = {},
        ["L"] = {},
        ["C"] = {},
        ["V"] = {},
        ["T"] = {}
    }

nFile = ""              -- название создаваемого файла (по имени инструмента)
scName = ""             -- название запускаемого скрипта

function OnInit()
    --инициализация
    scName = "PatternTester" -- string.match(debug.getinfo(1).short_src, "\\([^\\]+)%.lua$") -- получение имени запущенного скрипта
    nFile = getScriptPath() .. "\\" .. scName .. ".csv"

--[[
    scName = string.match(debug.getinfo(1).short_src, "\\([^\\]+)%.lua$") -- получение имени запущенного скрипта
	nFile = getScriptPath() .. "\\" .. scName .. ".csv"
--]]
end
-- https://quikluacsharp.ru/quik-qlua/poluchenie-v-qlua-lua-dannyh-iz-grafikov-i-indikatorov/
-- function CreateDS() -- старый вариант через DS
-- local i
--     for i, _ in pairs(tInstr) do
--         ds[i] = {}
        
--         -- tInstr[i][1] -- название инструмента
--         -- tInstr[i][2] -- метка инструмента
--         -- tInstr[i][3] -- интервал

--         --msg(tInstr[i][1] .. " +++ " .. tInstr[i][2] .. " +++ " ..tInstr[i][3] .." i = " .. i)

--         ds[i], error = CreateDataSource(Classcode, tInstr[i][1], tInstr[i][3])   -- создаем источник данных для получения свечей
--         ds[i]:SetEmptyCallback()
--         --repeat sleep(1000) until ds[i]:Size() ~= 0 -- делаем задержку, если свечи не получены

--         if  ds[i] == nil then
--             msg("Ошибка получения доступа к данным!\n" .. tostring(error))
--             OnStop()
--         end
--     end
-- end


function OnStop() -- действия при остановке скрипта
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
    CreateTable() -- создаём таблицу
    SetTableNotificationCallback(t_id, f_cb) -- добавляем callback обработки

	-- LoadInTable(nFile, t_id)

    while is_run do
        for i, _ in pairs(tInstr) do
            ds[i] = {}
            ds[i] = getNumCandles(tInstr[i][2])
                -- msg(ds[i] .. " количество свечей: " .. tInstr[i][2] .. ": i = " .. i) -- для проверки получения данных

            if ds[i] == 0 or ds[i] == nil then
                -- i = nil -- если tag не поставлен, убираем элемент массива
                msg("Не получено данных с графика.\nили нет метки " .. tostring(tInstr[i][2]) .. "\nГрафик инструмента " .. tostring(tInstr[i][1]) .. "\nОстановка")
                OnStop()
                return -- это для прерывания цикла на текущем моменте, а не в конце.
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
    -- classcode - пока не используется. На будущее - для выставления заявки
    -- tinstr - метка графика
    -- size - количество полученных свечей
    -- cbars - количествой свечей для отбора
    --- 

    local t = nil 		-- таблица, содержащая запрашиваемые свечки, 
    local l = nil 		-- легенда графика
    
    t, _, l = getCandlesByIndex(tinstr, 0, size - cbars, cbars)
    	-- msg("n = " .. n)
    -- size - cbars - № свечи с которого смотреть (слева-направо),
    -- cbars - количество свечей, которые необходимо на просмотр
    
    -- t, n, l = ....
    -- t – таблица, содержащая запрашиваемые свечки,
    -- n – количество свечек в таблице t,
    -- l – легенда (подпись) графика.
	
	local m = getLinesCount(tinstr)		-- получаем количество линий с графика
    if m ~= 1 then
        msg("Количество линий на графике = " .. l .. " (" .. tinstr ..")" .. " цены <> 1")
        OnStop()
        return
    end

        -- msg ("size - cbars " .. size .. "/" .. cbars)
        -- for i, _ in pairs(t) do
        --     msg(t[i].high .. " = t[i].high, i = " .. i)
        -- end

    local n = getNumCandles(tinstr)
	 	-- msg("n = " .. n .. " / Size = ".. size) -- для проверки

    if n > size then -- вот здесь проверка на изменение количества свечей
        -- если количество свечей увеличилось, то кидаем на отсмотр
        local x = 1
        for i = cbars - 1, 0, -1 do 		-- массив от 0 до 2. 3 бар (слева -> направо) = 1 бару (справа -> налево)
            Bars.O[x] = t[i].open 			-- Получить значение Open для указанной свечи (цена открытия свечи)
                -- msg("test t[i].open " .. t[i].open)
                -- msg("test Bars.O[i] " .. Bars.O[x] .. " x = " .. x)

            Bars.H[x] = t[i].high 			-- Получить значение High для указанной свечи (наибольшая цена свечи)
            Bars.L[x] = t[i].low 			-- Получить значение Low для указанной свечи (наименьшая цена свечи)
            Bars.C[x] = t[i].close 			-- Получить значение Close для указанной свечи (цена закрытия свечи)
            Bars.V[x] = t[i].volume 		-- Получить значение Volume для указанной свечи (объем сделок в свече)
            Bars.T[x] = t[i].datetime 		-- Получить значение datetime для указанной свечи
            								-- Где i - индекс свечи от 0 до n-1
            x = x + 1
        end
        x = x - 1 -- возврат к значению up массива
	        --[[
	            for k = 1, #Bars.O do -- для проверки
	                msg("k = " .. k .. " #Bars = " .. #Bars.H)
	                msg("Bars.O[i] " .. k .. "/" .. tostring(Bars.O[k]))
	                msg("Bars.H[i] " .. k .. "/"  .. tostring(Bars.H[k]))
	                msg("Bars.L[i] " .. k .. "/"  .. tostring(Bars.L[k]))
	                msg("Bars.C[i] " .. k .. "/"  .. tostring(Bars.C[k]))
	            end
	        --]]

        local sTime = tostring(os.time(Bars.T[1])) -- было без tostring
        local datetime = os.date("!*t", sTime)

        sTime = StrText(datetime.hour + CorrTime) .. StrText(datetime.min) .. StrText(datetime.sec) -- возвращаем время в виде HHMMSS
        local date = StrText(datetime.year) .. StrText(datetime.month) .. StrText(datetime.day) -- возвращаем дату в виде YYYYMMDD

        -- для вставки значений в таблицу
        local tableTime = StrText(datetime.hour + CorrTime) .. ":" .. StrText(datetime.min) .. ":" .. StrText(datetime.sec) -- возвращаем время в виде HH:MM:SS
        local tableDate = StrText(datetime.year) .. "-" .. StrText(datetime.month) .. "-" .. StrText(datetime.day) -- возвращаем дату в виде YYYY-MM-DD
        
            --[[ -- проверочные данные
                -- msg("sTime " .. sTime)
                -- msg("date " .. date)

                -- for i, _ in pairs(tinstr) do
                --     msg(Bars.O[i] .." ++++ " .. i) -- для проверки, не удалять, иначе потом непонятно будет
                -- end
            --]]

        local res1, res2, res3 = Pattern(Bars, Mfunc) --res1 - сигнал графика, res2 - nil, res3 - nil на развитие
        if res1 ~= nil then
            --local lab_id = insLabel(tinstr, res1, res2, date, sTime, Bars.O[x]) -- lab_id - идентификатор метки на графике, для удаления с графика
               -- msg("tInstr " .. res1) -- todo
           
            local lab_id = insLabel(tinstr, res1, res2, date, sTime, Bars.O[1]) -- lab_id - идентификатор метки на графике, для удаления с графика
            -- https://forum.quik.ru/forum10/topic118/

            local nstr = PutIn(t_id, tinstr, getTimeFrame(Bars), res1, tableDate, tableTime, "Сигнал", lab_id, res2)
            lightAllTable(t_id, res2, tonumber(nstr))
            --msg("Получен сигнал: " .. res1 .. ".\nГрафик: " .. tinstr)
            WriteToFile(nFile, t_id)
        end
    end
end

-- dopfunc.lua --

function msg(txt) -- сообщение
-- ф-ция вывода сообщений
-- данные приводятся к строке, выводится сообщение с треугольником '!'
---
    message(tostring(txt), 2)
end

function pse(tMin) -- пауза в минутах
-- ф-ция остановки
-- данные приводятся к числу (на всякий случай)
---
    sleep(round(tonumber(tMin) * 1000 * 60), 0)
    --msg("-- " .. round(tonumber(tMin) * 1000 * 60), 0)
end

function Gsize(m)
-- вычисляем размерность массива m
-- на вход - массив, на выходе number количество элементов
---
    local count = 0
    for _, _ in pairs(m) do
        count = count + 1
    end
    return count
end

function round(number, znaq) -- функция округления числа num до знаков znaq
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

function insLabel (idnt, lText, sgl, lDate, lTime, y) -- Ф-ция установки метки на графике
-- idnt идентификатор графика
-- lText - текст метки
-- sgl - сигнал вверх, вниз. метка либо зеленым, либо красным.
-- lDate - дата в формате YYYYMMDD (string)
-- lTime - время в формате HHMMSS (string)
-- y - ставим метку на уровне цены
---

local signal = tonumber(sgl)

local lParams = {}
    lParams.DATE = tostring(lDate)
    lParams.TIME = tostring(lTime)

    lParams.YVALUE = tostring(y)
    lParams.ALIGNMENT = RIGHT -- LEFT -- LEFT, RIGHT, TOP, BOTTOM
    lParams.FONT_FACE_NAME = "Arial"
    lParams.FONT_HEIGHT = 9
    
    if signal > 0 then -- если сигнал больше 0, метка long
        lParams.R = 0
        lParams.G = 125
        lParams.B = 255
    else
        lParams.R = 255 -- если сигнал меньше 0, метка short
        lParams.G = 0
        lParams.B = 0
    end


    lParams.TRANSPARENCY = 10
    lParams.TRANSPARENT_BACKGROUND = 1 -- Прозрачность фона. «0» – отключена, «1» – включена

    lParams.TEXT = tostring(lText)
    --lParams.HINT = "Это всплывающая подсказка"

    local lab_id = AddLabel(idnt, lParams)
    return lab_id

    --[[
        https://luaq.ru/GetLabelParams.html

        BOOLEAN DelLabel(STRING chart_tag, NUMBER label_id)
        BOOLEAN DelAllLabels(STRING chart_tag)
        BOOLEAN SetLabelParams(STRING chart_tag, NUMBER label_id, TABLE label_params)

        Команда позволяет получить параметры метки. Функция возвращает таблицу с параметрами метки.
        В случае неуспешного завершения функция возвращает «nil».
        Наименование параметров метки в возвращаемои? таблице указаны в нижнем регистре, и все значения имеют тип – STRING.
            TABLE GetLabelParams(STRING chart_tag, NUMBER label_id)
                chart_tag – тег графика, к которому привязывается метка;
                label_id – идентификатор метки.

        https://www.tutorialspoint.com/lua/lua_environment.htm
    --]]

end

function CreateTable() -- функция создания таблицы с результатами

    t_id = AllocTable()
    -- Добавляем колонки
    AddColumn(t_id, 0, "Инструмент", true, QTABLE_STRING_TYPE, 17)
    AddColumn(t_id, 1, "Интервал, мин.", true, QTABLE_STRING_TYPE, 17)
    AddColumn(t_id, 2, "Сигнал", true, QTABLE_STRING_TYPE, 17)
    AddColumn(t_id, 3, "Дата", true, QTABLE_STRING_TYPE, 15)
    AddColumn(t_id, 4, "Время", true, QTABLE_STRING_TYPE, 15)
    AddColumn(t_id, 5, "Комм./Сохр.", true, QTABLE_STRING_TYPE, 17)
    AddColumn(t_id, 6, "Идент метки", true, QTABLE_STRING_TYPE, 0)  -- делаем невидимым колонку таблицы
    AddColumn(t_id, 7, "UpDown", true, QTABLE_STRING_TYPE, 0)       -- делаем невидимым колонку таблицы
   
   -- Создаем
    CreateWindow(t_id)
    
    -- Даем заголовок
    local n = Gsize(Mfunc)
    SetWindowCaption(t_id, "Сигналы VSA 1.5 (" .. tostring(n) .. EndOfWord(n, " паттерн") .. ")" )
    
    -- Расположение окна таблицы
    SetWindowPos(t_id, 0, 0, 650, 320) --x, y, dx, dy

    -- Добавляет строку
    -- InsertRow(t_id, -1)
end

function EndOfWord(n, txt)
-- ф-ция добавляет окончание слова
-- пример EndOfWord(4, "сигнал") -> '4 сигнала'
-- n - число, number
-- txt - текст, которому нужно добавить окончание, string
---

local en1 = ""
local en2 = "а"
local en3 = "ов"

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

function PutIn(t_id, tinstr, inter, signal, date, time, comment, lab_id, updown) -- ф-ция заполнения таблицы
    -- ф-ция заполнения таблицы
    -- идентификатор таблицы
    -- Инструмент
    -- Интервал
    -- Сигнал
    -- Дата
    -- Время
    -- Комментарий
    -- Идентификатор метки - lab_id (для удаления сигнала с графика). должен быть number. перевожу при удалении
    ---
    
    InsertRow(t_id, -1)
    local rows, _ = GetTableSize(t_id)
    -- _ - cols - количество колонок
    
    SetCell(t_id, rows, 0, tostring(tinstr))	-- код графика (инструмента)
    SetCell(t_id, rows, 1, tostring(inter)) 	-- Промежуток
    SetCell(t_id, rows, 2, tostring(signal)) 	-- вид сигнала
    SetCell(t_id, rows, 3, tostring(date))		-- дата сигнала
    SetCell(t_id, rows, 4, tostring(time))		-- время сигнала
    SetCell(t_id, rows, 5, tostring(comment))	-- комментарий
    SetCell(t_id, rows, 6, tostring(lab_id))	-- метка графика (для удаления с графика по щелчку мыши)
    SetCell(t_id, rows, 7, tostring(updown))    -- направление (вверх, вниз) для раскраски таблицы при загрузке из файла
    
    return rows -- возвращаем номер ряда для его последующей подсветки в таблице

end

function getTimeFrame(m) -- получаем таймфрейм из разницы между свечами
-- на вход массив свечей
-- из него получаем две даты свечей
-- кидаем их в сравнение
-- возвращаем интервал
---
    local sTime = tostring(os.time(m.T[1]))
    local datetime = os.date("!*t", sTime)
    local time1 = StrText(datetime.hour) .. ":" .. StrText(datetime.min) .. ":" .. StrText(datetime.sec) -- возвращаем время в виде HH:MM:SS

    sTime = tostring(os.time(m.T[2]))
    datetime = os.date("!*t", sTime)
    local time2 = StrText(datetime.hour) .. ":" .. StrText(datetime.min) .. ":" .. StrText(datetime.sec) -- возвращаем время в виде HH:MM:SS

    return string.format("%u", diffTime(time2, time1)) -- возвращаем только число без '.0'
end

function f_cb(t_id, msge, x, y)
-- функция обработки нажатий таблицы (глобальная)
-- SetTableNotificationCallback(t_id, f_cb) либо в onInit, либо в main (не в цикл)
---
    if (msge == QTABLE_LBUTTONDBLCLK) then

        -- if (y == 0 and x ~= 0) then  -- нажатие на 1ой колонке
        if (x ~= 0) then                -- в любом месте строки (не только в 1ой колонке)
                -- msg("x = " .. tostring(x)) -- для проверки вывода в таблицу
             local lab_id = GetCell(t_id, x, 6).image -- 6 колонка - ширина колонки 0, идентификатор метки (не для вывода, для удаления с графика)
                --msg("lab_id " .. tostring(lab_id))
             
             local ident = GetCell(t_id, x, 0).image -- 0 - метка графика инструмента
                --msg("ident " .. tostring(ident))
             
             DelLabel(ident, tonumber(lab_id)) -- удаляем не только сигнал, но и метку на графике
             DeleteRow(t_id, x) -- удаляем ряд из таблицы
             msg("Удалил сигнал")
             WriteToFile(nFile, t_id)
             -- lab_id, ident = nil, nil
        end

        if (x == 0 and y == 5) then -- если нажатие было на первой строке, четвертой колонке
            WriteToFile(nFile, t_id)
            msg("Файл сохранен в\n" .. nFile)
        end

        if (x == 0 and y == 0) then -- если нажатие было на первой строке, первой колонке
			--LoadInTable(nFile, t_id)
        end

        if (x == 0 and y == -1) then -- если нажатие было на первой строке, нулевой колонке 
            local rows, _ = GetTableSize(t_id) -- номер строки с 1 до x, номер колонки с 0 до n-1
            
            for i = rows, 1, -1 do
                local lab_id = GetCell(t_id, i, 6).image -- 6 колонка - ширина колонки 0, идентификатор метки (не для вывода, для удаления с графика)
                local ident = GetCell(t_id, i, 0).image -- 0 - метка графика инструмента
                DelLabel(ident, tonumber(lab_id)) -- удаляем не только сигнал, но и метку на графике
                DeleteRow(t_id, i) -- удаляем ряд из таблицы
            end
        end

        -- if  (msge == QTABLE_CHAR)  and  (y == 19)  then   
        --     msg("сохранить в CSV файл текущее состояние таблицы нужно нажать комбинацию клавиш Ctrl+S")
        --     --CSV(tbl)
        -- end
       
        -- if  (x == 0 and y == 1)  then   
        -- покупка по левой кнопке
        -- продажа по правой кнопке
        -- takeprofit по средней кнопке?

        -- end


        -- if  (msge == QTABLE_CLOSE)  then   --закрытие окна?
        --     OnStop()
        -- end

    end
    
    if (msge == QTABLE_CLOSE)  then   --закрытие окна. было в предыдущем и работало. надо ли здесь?
        OnStop()
        -- https://luaq.ru/SetTableNotificationCallback.html
    end

    -- if (msge == QTABLE_LBUTTONDOWN) then -- одиночный клик левой мышкой
    --     if (x ~= 0 and y == 1) then -- если нажатие было не на первой строке, но на первой колонке
    --         msg("Нажата левая кнопка мыши\n") --todo
    --     end
    -- end

    -- if (msge == QTABLE_RBUTTONDOWN) then -- одиночный клик правой мышкой
    --     if (x ~= 0 and y == 1) then -- если нажатие было не на первой строке, но на первой колонке
    --         msg("Нажата правая кнопка мыши\n") --todo
    --     end
    -- end


end
    --[[

    -------------------------------Колбэки------------------------------------------------------------------
    function   f_cb (t_id,msg,par1,par2)  --событие на нажатие клавиш
        if  (msg == QTABLE_CHAR)  and  (par2 =  =  19 )  then   --сохранить в CSV файл текущее состояние таблицы нужно нажать комбинацию клавиш Ctrl+S
        CSV(tbl)
        end

        if  (msg == QTABLE_CLOSE)  then   --закрытие окна
        Stop()
        end

        if  (msg == QTABLE_VKEY)  and  (par2 =  =  116 )  then   --функция принудительного обновления таблицы при нажатии клавиши Ctrl+F5
        for  SecCode  in   string.gmatch (SecList,  "([^,]+)" )  do   --перебираем опционы по очереди.
            Calculate(Sec2row[SecCode], true )
            Highlight (tbl.t_id, Sec2row[SecCode], QTABLE_NO_INDEX,  RGB ( 255 , 0 , 0 ), QTABLE_DEFAULT_COLOR, INTERVAL)
        end

        end
    end

    --]]


function LoadInTable(nFile, t_id)
-- Загрузка в таблицу из файла массива
---
    local n
    local v = {}

	v = LoadFromFile(nFile)
	if  v == nil then return end

	for i = 2, #v, 1 do -- первую строку пропускаем
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
-- загружаем список из файла
-- вывод в массив varr типа string по строкам
-- varr[i ... n] = строка из файла i ... n 
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
        msg("Не могу открыть файл:\n" .. nfile)
        return nil
    end
end
    
function WriteToFile(nfile, t_id) 
-- ф-ция записи таблицы t_id в файл nfile
-- если файла нет - создаём, 
-- если файл есть - дописываем в конце
---
    
    local CSV = io.open(nfile, "w") -- "a+"
    local position = CSV:seek("end", 0)
    local txt = "" --для вывода в файл
    
    if position == 0 then -- обработка ошибки пустого файла
        local header = "Инструмент;Промежуток;Сигнал;Дата;Время;Комментарий;Идент(не удалять);UpDown(не удалять);\n"
        CSV:write(header)
        CSV:flush()
        position = CSV:seek("end", 0)
    end

    local rows, col = GetTableSize(t_id) -- номер строки с 1 до x, номер колонки с 0 до n-1
        -- msg("rows, col " .. tostring(rows) .. "/" .. tostring(col)) -- todo
    
    
    if rows ~= 0 then
        for i = 1, rows do -- номер строк с "1"
            for j = 0, col - 1 do -- номер колонок с "0" до n - 1
                txt = txt .. tostring(GetCell(t_id, i, j).image) .. ";" -- .image - это строковое значение, .value - это number
            end            
            txt = txt .. "\n"
            CSV:write(txt)
            txt = "" -- обнуляем строку, пишем следующий ряд в файл
        end
        -- Сохраняет изменения в файле
        CSV:flush()
    end 
    -- закрываем файл
    CSV:close()    

    -- else
    --  --message("Ошибка создания файла ")
    -- end
end

function Pattern(m, mfunc) -- сверка функций с массивом данных свечей
-- На вход получаем массив m, mfunc = {LP1, SPA1, .. , PPR} - внутри массива функции.
-- m.O = {1, 2, .. , cBars} -- цены Open
-- m.H = {1, 2, .. , cBars} -- цены High
-- m.[..] = {1, 2, .. , cBars} -- и т.д. (O, H, L, C, V, T)
-- обрабатываем его в соответствии с паттернами, возвращаем данные для таблицы, для значка на график
---

    for key, _ in pairs(mfunc) do
        local res1, res2, res3 = mfunc[key](m)
        if  res1 ~= nil then
            do return res1, res2, res3 end  -- проверить срабатывание
            break                           -- проверить срабатывание
        end
    end
end

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

function comma(what) -- замена  '.' на ','
    -- функция меняет '.' на ',' в what и возвращает текстовое значение
    -- используется в csv для получения правильного числа (пример 50.50 -> 50,50)
    ---
    local xstr = string.gsub(tostring(what), "%.", ",")
    return tostring(xstr)
end


function diffTime(time1, time2)
-- возвращает разницу в минутах между time2-time1; либо 0, если time1 > time2
-- time1 = "14:00:00"
-- time2 = "14:05:00"
-- result = diffTime(time1, time2) -- = 300 секунд
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

    --часы*3600 + минуты*60 + секунды.
    dTime1 = dt1.hour * 3600 + dt1.min * 60 + dt1.sec
    dTime2 = dt2.hour * 3600 + dt2.min * 60 + dt2.sec
    result = (dTime2 - dTime1)

    if result <= 0 then
        return 0
    else
        return result / 60
    end
end

function lightAllTable(t_id, sgl, x) -- раскраска строки цветом
	-- Подсветка строки таблицы
	-- раскраска строки (если signal меньше ноля = розовым, если больше = зеленым) приходит string, преобразовать в number
	-- t_id идентификатор передаваемой таблицы
	-- x - номер выделяемой строки number
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


    Суть проста- я хотел бы чтобы LUA скрипт каждый день мне выгружал свечи минутки по нужному инструменту в файл. И "дозаписывал" этот файл.
    Идеально было бы например в Excel или базу данных.
    Но для начала хотя бы в txt файл.

    Плюс к этому было бы хорошо, чтобы он и внутри себя имел массив свечей минуток. Ну т.е нажал кнопку "загрузить", и дальше можно внутри скрипта увидеть таблицу минуток и с ней работать.
    Пока не могу понять с какой стороны подойти к этому вопросу.
    Хотя бы как из Quik в LUA забрать значения свечек минуток сразу?

    2kalikazandr2015-04-29 18:16:12 (2015-04-29 18:26:25 отредактировано kalikazandr)
    Member
    Неактивен
    Зарегистрирован: 2014-09-10
    Сообщений: 371
    slkumax пишет:
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

    3slkumax2015-04-29 18:28:52
    Member
    Неактивен
    Зарегистрирован: 2013-06-13
    Сообщений: 68
    kalikazandr пишет:
    slkumax пишет:
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
