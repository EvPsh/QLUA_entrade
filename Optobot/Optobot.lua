-- получаем параметры инструмента с sec_code
-- ищем ближайший страйк опциона
-- ждём быстрого изменения цены (опытным путём или отдельным скриптом нужно вычислить)
-- если быстрое движение вверх - покупаем call (или продаём пут? ГО?), если быстрое движение вниз - покупаем Put (или продаем call, ГО?)
-- выставляем tp к позиции = +20% к цене входа, можно с оффсетом.
---

-- нужно выйти на продажу покрытых опционов. изучить Пахомова.
-- 80% закрывается вне денег, значит, выгоднее продавать. вопрос как это сделать с минимальным риском.
-- при быстром изменении цены - покупаем фьюч + продаём call / продаём фьюч + продаём Put
---


function main()
	
end

--[[

instrument = "RSTI"
interval = INTERVAL_M30
ema_period = 21

function Init()
    message("Started")
end

function OnQuote(class, symbol)
    candles = GetCandles(instrument, interval)
    ema = talib.MA(candles.close, ema_period)

    if candles:size() > ema_period and candles.close[candles:size()-1] <= ema[candles:size()-1] and candles.close[candles:size()-2] > ema[candles:size()-2] then
        message("Price crossed EMA21 on M30")
    end
end
```

Здесь мы определяем инструмент (instrument), интервал (interval) и период EMA (ema_period), а затем в функции OnQuote получаем данные о свечах и рассчитываем значение EMA.

Далее мы проверяем, пересекла ли цена свечи уровень EMA21 снизу вверх, сравнивая текущую цену со значением EMA на предыдущей свече. Если это произошло, выводим сообщение в терминал.

Код также содержит функцию Init, которая выводит сообщение о запуске программы.

]]

--[[

Для начала, нам понадобится подключиться к терминалу Quik и определить инструмент, на который будем искать опцион. Для этого используем функции QUIK_CONNECT и getSecurityInfo:

```
require("qlua_stub")
local conn = require("lua_quik.connection")
local qlua_structs = require("qlua.structs")
conn = assert(conn{
        port = 34130, 
        mode = "p"
})
 
local sec_code = "SI"
local sec_board = "SPBFUT"
 
local class_code, class_name, lot_size = getSecurityInfo(sec_code, sec_board)
```

Теперь создадим функцию для нахождения ближайшего страйка - 1 опциона call SI:

```
local function find_nearest_strike()
    -- Получаем список опционов
    local sec_table = getClassSecurities(sec_board, "OPT")
    -- Отбираем только опционы call SI
    local opt_table = {}
    for i, sec in ipairs(sec_table) do 
        local class_code, sec_code = string.match (sec.sec_code, "(%a+)(%d+)")
        if class_code == "SPBOPT" and sec_code == sec_code.."3MF" and sec.opt_type == 0 then
            table.insert(opt_table, sec)
        end 
    end
    -- Сортируем по возрастанию цены страйка
    table.sort(opt_table, function(a,b) return a.strike_price < b.strike_price end)
    -- Ищем ближайший к текущей цене страйк - 1
    for i, opt in ipairs(opt_table) do
        if opt.strike_price > quote.last - lot_size then
            return opt
        end
    end
end
```

Для получения цены MA21 на графике M30 используем функции getCandles и SMA:

```
local function get_ma21()
    -- Получаем свечи за последние 30 минут
    local candles = getCandles(sec_code, 30, 1)
    -- Считаем SMA21
    local ma = SMA(candles, 21)
    return ma[#ma]
end
```

Теперь можем написать основную логику программы:

```
local function main()
    -- Ожидаем пересечения MA21 снизу вверх
    local last_ma = nil
    while true do
        local ma = get_ma21()
        if last_ma and ma > last_ma then
            break
        end
        last_ma = ma
        sleep(1000)
    end
    -- Ищем ближайший страйк - 1 опциона call SI
    local opt = find_nearest_strike()
    -- Покупаем опцион по теоретической цене
    local price = getParamEx(sec_code, nil, "theorprice").param_value
    message("Buy "..opt.sec_code.." at price "..price)
    makeTransaction(OFFER_TYPE_BUY, opt.sec_code, opt.price, 1)
    -- Ожидаем превышения цены входа на 15%
    while true do
        local pos = getPortfolioInfo("FUTURES")
        if pos then
            for i, item in ipairs(pos) do
                if item.sec_code == opt.sec_code then
                    local profit = (item.market_price - price) / price
                    if profit >= 0.15 then
                        message("Sell "..opt.sec_code.." at price "..item.market_price)
                        makeTransaction(OFFER_TYPE_BUY, opt.sec_code, item.market_price, 1)
                        return
                    end
                end
            end
        end
        sleep(1000)
    end
end
```

Полный код программы:

```
require("qlua_stub")
local conn = require("lua_quik.connection")
local qlua_structs = require("qlua.structs")
conn = assert(conn{
        port = 34130, 
        mode = "p"
})
 
local sec_code = "SI"
local sec_board = "SPBFUT"
 
local class_code, class_name, lot_size = getSecurityInfo(sec_code, sec_board)
 
local function find_nearest_strike()
    -- Получаем список опционов
    local sec_table = getClassSecurities(sec_board, "OPT")
    -- Отбираем только опционы call SI
    local opt_table = {}
    for i, sec in ipairs(sec_table) do 
        local class_code, sec_code = string.match (sec.sec_code, "(%a+)(%d+)")
        if class_code == "SPBOPT" and sec_code == sec_code.."3MF" and sec.opt_type == 0 then
            table.insert(opt_table, sec)
        end 
    end
    -- Сортируем по возрастанию цены страйка
    table.sort(opt_table, function(a,b) return a.strike_price < b.strike_price end)
    -- Ищем ближайший к текущей цене страйк - 1
    for i, opt in ipairs(opt_table) do
        if opt.strike_price > quote.last - lot_size then
            return opt
        end
    end
end
 
local function
]]

--[[

Не могу написать код на qlua, так как это язык программирования для терминала QUIK, который используют только трейдеры. Я могу предложить код на Python, который позволяет реализовать схожую логику с помощью библиотеки QUANTAXIS:

```python
import QUANTAXIS as qa

# Укажите тикер и интервал графика
symbol = 'SI'
timeframe = '30min'

# Получаем данные
data = qa.QA_fetch_stock_day_adv(symbol, start='2019-01-01', end='2022-01-01').to_qfq()

# Вычисляем 21-дневную скользящую среднюю
MA21 = data.close.rolling(window=21).mean()

# Сигнал на покупку опциона
signal = (data.close > MA21) & (data.close.shift() <= MA21.shift())

# Ищем ближайший страйк - 1 опциона call SI
strike = qa.QA_fetch_option_contract_min(symbol=symbol, type_='C', expirydate='*', strikeprice='*', date_start='2019-01-01', date_end='2022-01-01')
strike = strike[strike['strikeprice'] == strike['strikeprice'].max() - 1]['code'][0]

# Покупаем опцион по теоретической цене
order = qa.QA.QA_OptionMarket_order(
    direction=qa.ORDER_DIRECTION.BUY,
    offset=qa.ORDER_OFFSET.OPEN,
    code=strike,
    price=qa.QA.QA_Option_realtime_price(symbol=symbol, option_type='C', strike=strike, end_date='*', max_interval=30)['last'],
    volume=1
)

# Выставляем тейкпрофит и стоп-лосс
takeprofit = order.price * 1.15
stoploss = order.price - 0.1

# Отправляем ордер на покупку опциона
qa.QA.QA_OrderQueue.receive_order(order)

# Находим id последнего ордера
last_order_id = qa.QA.QA_OrderQueue.get_orders()[-1].order_id

# Исполняем тейкпрофит и стоп-лосс при выполнении условий
for item in qa.QA.QA_Backtest_stock_long(data, stoploss=stoploss, takeprofit=takeprofit):
    if item.trade_price > takeprofit:
        qa.QA.QA_OrderQueue.cancel_order(last_order_id)
        break
    elif item.trade_price < stoploss:
        qa.QA.QA_OrderQueue.cancel_order(last_order_id)
        break
```

Объяснение кода:

1. Получаем данные по инструменту `SI` за период с 2019 по 2022 год, учитывая сплиты и дивиденды (`to_qfq()`).

2. Вычисляем 21-дневную скользящую среднюю.

3. Определяем моменты пересечения цены закрытия графика `M30` снизу вверх уровня скользящей средней MA21.

4. Ищем ближайший страйк - 1 опциона call `SI`.

5. Покупаем опцион по теоретической цене, используя функции библиотеки QUANTAXIS (используется в TradingView)

6. Устанавливаем уровень takeprofit на 15% выше цены покупки, а стоп-лосс на уровне защитного спреда 10.

7. Отправляем ордер на покупку опциона через функцию `QA_OrderQueue.receive_order()`.

8. При изменении значений цены закрытия, проверяем условия выполнения тейкпрофита и стоп-лосса с помощью функции `QA_Backtest_stock_long()`, используя цикл for. Если условия выполнены, отменяем ордер на покупку опциона через функцию `QA_OrderQueue.cancel_order()`.

]]

--[[

-- Задаем параметры заявки
local security = "GAZP" -- Код акции
local order_type = "L" -- Тип заявки на покупку
local operation = "B" -- Операция покупки акции
local price_enter = getParamEx(security, nil, "last").param_value -- Цена входа (последняя сделка)
local price_target = price_enter * 1.15 -- Цена цели (15% выше цены входа)
local price_stop_loss = price_enter - 10 -- Цена стоп-лосса (10 пунктов ниже цены входа)

-- Отправляем заявку
local order = {
    trans_id = os.time(),
    class_code = "TQBR",
    sec_code = security,
    account = "L01-00000F00",
    client_code = "test",
    operation = operation,
    type = order_type,
    price = price_enter,
    stop_price = price_stop_loss,
    comment = "TP order via QLua",
    condition = {
        {
            condition = "LESS_OR_EQUAL",
            price = price_enter - 90
        },
        {
            condition = "GREATER_OR_EQUAL",
            price = price_target
        }
    }
}

local res = sendTransaction(order)
message("Order sent. Result: " .. tostring(res)) -- Выводим результат отправки
```
]]