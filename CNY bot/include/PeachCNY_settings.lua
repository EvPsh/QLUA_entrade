SEC_CODE = "CNYRUB" --код инструмента/бумаги
CLASS_CODE = "SPBFUT" --код класса инструмента/бумаги, если нужен фондовый рынок - вводить TQBR вместо SPBFUT
ACCOUNT = "SPBFUT00479" -- счет на срочном рынке
--ACCOUNT = "01695" -- счет на рынке ММВБ
--ACCOUNT = "01695FX" -- счет на валютном рынке 



function msg(txt) -- функция вывода сообщений в QUIK
	message(tostring(txt))
end

function get_account() -- возвращает все данные для ACCOUNT
	for i = 0, getNumberOf("client_codes") - 1 do
		local n = getItem("client_codes", i)  -- возвращает строку содержащую клиентский код с индексом i, где i может принимать значения от 0 до getNumberOf("client_codes") - 1
		msg(n)
	end	
end	
