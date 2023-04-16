-- �������� ��������� ����������� � sec_code
-- ���� ��������� ������ �������
-- ��� �������� ��������� ���� (������� ���� ��� ��������� �������� ����� ���������)
-- ���� ������� �������� ����� - �������� call (��� ������ ���? ��?), ���� ������� �������� ���� - �������� Put (��� ������� call, ��?)
-- ���������� tp � ������� = +20% � ���� �����, ����� � ��������.
---

-- ����� ����� �� ������� �������� ��������. ������� ��������.
-- 80% ����������� ��� �����, ������, �������� ���������. ������ ��� ��� ������� � ����������� ������.
-- ��� ������� ��������� ���� - �������� ���� + ������ call / ������ ���� + ������ Put
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

����� �� ���������� ���������� (instrument), �������� (interval) � ������ EMA (ema_period), � ����� � ������� OnQuote �������� ������ � ������ � ������������ �������� EMA.

����� �� ���������, ��������� �� ���� ����� ������� EMA21 ����� �����, ��������� ������� ���� �� ��������� EMA �� ���������� �����. ���� ��� ���������, ������� ��������� � ��������.

��� ����� �������� ������� Init, ������� ������� ��������� � ������� ���������.

]]

--[[

��� ������, ��� ����������� ������������ � ��������� Quik � ���������� ����������, �� ������� ����� ������ ������. ��� ����� ���������� ������� QUIK_CONNECT � getSecurityInfo:

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

������ �������� ������� ��� ���������� ���������� ������� - 1 ������� call SI:

```
local function find_nearest_strike()
    -- �������� ������ ��������
    local sec_table = getClassSecurities(sec_board, "OPT")
    -- �������� ������ ������� call SI
    local opt_table = {}
    for i, sec in ipairs(sec_table) do 
        local class_code, sec_code = string.match (sec.sec_code, "(%a+)(%d+)")
        if class_code == "SPBOPT" and sec_code == sec_code.."3MF" and sec.opt_type == 0 then
            table.insert(opt_table, sec)
        end 
    end
    -- ��������� �� ����������� ���� �������
    table.sort(opt_table, function(a,b) return a.strike_price < b.strike_price end)
    -- ���� ��������� � ������� ���� ������ - 1
    for i, opt in ipairs(opt_table) do
        if opt.strike_price > quote.last - lot_size then
            return opt
        end
    end
end
```

��� ��������� ���� MA21 �� ������� M30 ���������� ������� getCandles � SMA:

```
local function get_ma21()
    -- �������� ����� �� ��������� 30 �����
    local candles = getCandles(sec_code, 30, 1)
    -- ������� SMA21
    local ma = SMA(candles, 21)
    return ma[#ma]
end
```

������ ����� �������� �������� ������ ���������:

```
local function main()
    -- ������� ����������� MA21 ����� �����
    local last_ma = nil
    while true do
        local ma = get_ma21()
        if last_ma and ma > last_ma then
            break
        end
        last_ma = ma
        sleep(1000)
    end
    -- ���� ��������� ������ - 1 ������� call SI
    local opt = find_nearest_strike()
    -- �������� ������ �� ������������� ����
    local price = getParamEx(sec_code, nil, "theorprice").param_value
    message("Buy "..opt.sec_code.." at price "..price)
    makeTransaction(OFFER_TYPE_BUY, opt.sec_code, opt.price, 1)
    -- ������� ���������� ���� ����� �� 15%
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

������ ��� ���������:

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
    -- �������� ������ ��������
    local sec_table = getClassSecurities(sec_board, "OPT")
    -- �������� ������ ������� call SI
    local opt_table = {}
    for i, sec in ipairs(sec_table) do 
        local class_code, sec_code = string.match (sec.sec_code, "(%a+)(%d+)")
        if class_code == "SPBOPT" and sec_code == sec_code.."3MF" and sec.opt_type == 0 then
            table.insert(opt_table, sec)
        end 
    end
    -- ��������� �� ����������� ���� �������
    table.sort(opt_table, function(a,b) return a.strike_price < b.strike_price end)
    -- ���� ��������� � ������� ���� ������ - 1
    for i, opt in ipairs(opt_table) do
        if opt.strike_price > quote.last - lot_size then
            return opt
        end
    end
end
 
local function
]]

--[[

�� ���� �������� ��� �� qlua, ��� ��� ��� ���� ���������������� ��� ��������� QUIK, ������� ���������� ������ ��������. � ���� ���������� ��� �� Python, ������� ��������� ����������� ������ ������ � ������� ���������� QUANTAXIS:

```python
import QUANTAXIS as qa

# ������� ����� � �������� �������
symbol = 'SI'
timeframe = '30min'

# �������� ������
data = qa.QA_fetch_stock_day_adv(symbol, start='2019-01-01', end='2022-01-01').to_qfq()

# ��������� 21-������� ���������� �������
MA21 = data.close.rolling(window=21).mean()

# ������ �� ������� �������
signal = (data.close > MA21) & (data.close.shift() <= MA21.shift())

# ���� ��������� ������ - 1 ������� call SI
strike = qa.QA_fetch_option_contract_min(symbol=symbol, type_='C', expirydate='*', strikeprice='*', date_start='2019-01-01', date_end='2022-01-01')
strike = strike[strike['strikeprice'] == strike['strikeprice'].max() - 1]['code'][0]

# �������� ������ �� ������������� ����
order = qa.QA.QA_OptionMarket_order(
    direction=qa.ORDER_DIRECTION.BUY,
    offset=qa.ORDER_OFFSET.OPEN,
    code=strike,
    price=qa.QA.QA_Option_realtime_price(symbol=symbol, option_type='C', strike=strike, end_date='*', max_interval=30)['last'],
    volume=1
)

# ���������� ���������� � ����-����
takeprofit = order.price * 1.15
stoploss = order.price - 0.1

# ���������� ����� �� ������� �������
qa.QA.QA_OrderQueue.receive_order(order)

# ������� id ���������� ������
last_order_id = qa.QA.QA_OrderQueue.get_orders()[-1].order_id

# ��������� ���������� � ����-���� ��� ���������� �������
for item in qa.QA.QA_Backtest_stock_long(data, stoploss=stoploss, takeprofit=takeprofit):
    if item.trade_price > takeprofit:
        qa.QA.QA_OrderQueue.cancel_order(last_order_id)
        break
    elif item.trade_price < stoploss:
        qa.QA.QA_OrderQueue.cancel_order(last_order_id)
        break
```

���������� ����:

1. �������� ������ �� ����������� `SI` �� ������ � 2019 �� 2022 ���, �������� ������ � ��������� (`to_qfq()`).

2. ��������� 21-������� ���������� �������.

3. ���������� ������� ����������� ���� �������� ������� `M30` ����� ����� ������ ���������� ������� MA21.

4. ���� ��������� ������ - 1 ������� call `SI`.

5. �������� ������ �� ������������� ����, ��������� ������� ���������� QUANTAXIS (������������ � TradingView)

6. ������������� ������� takeprofit �� 15% ���� ���� �������, � ����-���� �� ������ ��������� ������ 10.

7. ���������� ����� �� ������� ������� ����� ������� `QA_OrderQueue.receive_order()`.

8. ��� ��������� �������� ���� ��������, ��������� ������� ���������� ����������� � ����-����� � ������� ������� `QA_Backtest_stock_long()`, ��������� ���� for. ���� ������� ���������, �������� ����� �� ������� ������� ����� ������� `QA_OrderQueue.cancel_order()`.

]]

--[[

-- ������ ��������� ������
local security = "GAZP" -- ��� �����
local order_type = "L" -- ��� ������ �� �������
local operation = "B" -- �������� ������� �����
local price_enter = getParamEx(security, nil, "last").param_value -- ���� ����� (��������� ������)
local price_target = price_enter * 1.15 -- ���� ���� (15% ���� ���� �����)
local price_stop_loss = price_enter - 10 -- ���� ����-����� (10 ������� ���� ���� �����)

-- ���������� ������
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
message("Order sent. Result: " .. tostring(res)) -- ������� ��������� ��������
```
]]