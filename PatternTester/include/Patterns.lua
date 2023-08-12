Mfunc = {
	LP1 = function (m)
	-- Паттерн LP1
	-- [1] - первая свеча справа от конца графика
	-- [2] - вторая свеча справа от конца графика
	-- [3] - третья свеча справа от конца графика
	-- m.O[1] - цена Open 1ой свечи
	-- m.H[1] - цена High 1ой свечи
	-- m.L[1] - цена Low 1ой свечи
	-- m.С[1] - цена Close 1ой свечи
	-- m.V[1] - объем 1ой свечи
	-- всего получаемых свечей - 3 шт. m.O[1], m.O[2], m.O[3]
	-- далее сравниваем по данным O, H, L, C, V и возвращаем данные если паттерн совпал
	---
	if m.O[3] > m.C[3] then                                   -- если третий бар продаж
		if (m.O[2] > m.C[2]) then-- and m.V[2] > m.V[3]) then -- если второй бар продаж и объем увеличился
			if (m.O[1] < m.C[1] and m.H[1] > m.C[3]) then --and m.V[1] < m.V[2]) then -- первый	 бар покупок с высотой бара болще чем закрытие третьего бара и обьемом меньше чем у второго
				return "LP1", "1", ""
			end
		end
	end
	return nil, nil, nil
	end, 

    LP11 = function (m)
	if m.O[3] < m.C[3] then                                   -- если третий бар покупок
		if (m.O[2] < m.C[2]) then-- and m.V[2] > m.V[3]) then -- если второй бар бар покупок и объем увеличился
			if (m.O[1] > m.C[1] and m.H[1] < m.C[3]) then -- and m.V[1] < m.V[2]) then -- первый	 бар продаж с высотой бара болще чем закрытие третьего бара и обьемом меньше чем у второго
				return "LP11", "-1", ""
			end
		end
	end
	return nil, nil, nil
	end,
	
    LP2 = function (m)
		if m.O[3] > m.C[3] then 
			if m.O[2] > m.C[2] then 
				if (m.O[1] < m.C[1]) then
					if (m.C[1] > m.C[3]) then --and m.V[1] > m.V[2]) then 
				return "LP2", "1", ""
				end
			end
		end
		return nil, nil, nil
    end,
	
	LP21 = function (m)
		if m.O[3] < m.C[3] then 
			if m.O[2] < m.C[2] then 
				if (m.O[1] > m.C[1]) then
					if (m.C[1] < m.C[3]) then-- and m.V[1] > m.V[2]) then -- первый	 бар покупок с высотой бара болще чем закрытие третьего бара и обьемом больше чем у второго
					return "LP21", "-1", ""
				end
			end
		end
		return nil, nil, nil
	end, 
	
	LP3 = function (m)
		if m.O[3] > m.C[3] then 							-- если третий бар продаж
			if (m.O[2] > m.C[2] and m.V[2] < m.V[3]) then   -- если второй бар продаж
				if (m.O[1] < m.C[1] and m.H[1] > m.H[3] and m.V[1] > m.V[2]) then -- первый	 бар покупок с высотой бара болще чем высота третьего и обьемом больше чем у второго
					return "LP3", "1", ""
				end
			end
		end
	return nil, nil, nil
	end,
	
	LP31 = function (m)
		if m.O[3] < m.C[3] then 							-- если третий бар продаж
			if (m.O[2] < m.C[2] and m.V[2] < m.V[3]) then   -- если второй бар продаж
				if (m.O[1] > m.C[1] and m.H[1] < m.H[3] and m.V[1] > m.V[2]) then -- первый	 бар покупок с высотой бара болще чем высота третьего и обьемом больше чем у второго
					return "LP31", "-1", ""
				end
			end
		end
	return nil, nil, nil
	end,
	
	LP4 = function (m)
		if m.O[3] > m.C[3] then -- если третий бар продаж
			if (m.O[2] > m.C[2]) then-- and m.V[2] > m.V[3]) then -- если второй бар продаж
				if (m.O[1] < m.C[1] and m.H[1] < m.H[2] and m.V[1] > m.V[2]) then -- первый бар покупок высотой больше второго бара и большим обьемом чем во втором
					return "LP4", "1", ""
				end
			end
		end
	return nil, nil, nil
	end,
    
    LP41 = function (m)
		if m.O[3] < m.C[3] then -- если третий бар продаж
			if (m.O[2] < m.C[2]) then-- and m.V[2] > m.V[3]) then -- если второй бар продаж
				if (m.O[1] > m.C[1] and m.H[1] > m.H[2] and m.V[1] > m.V[2]) then -- первый бар покупок высотой больше второго бара и большим обьемом чем во втором
					return "LP41", "-1", ""
				end
			end
		end
	return nil, nil, nil
	end,
	
	LP5 = function (m)
		if m.O[3] > m.C[3] then -- если третий бар продаж
			if m.O[2] > m.C[2] then -- если вторjй бак Продаж (покупок)
				if (m.O[1] < m.C[1] and m.H[1] > m.C[3] and m.V[1] > 1.5 * m.V[2]) then -- первый бар продаж закрытие меньше максимума обьем больше чем вдва раза
					return "LP5", "1", ""
				end
			end
		end
	return nil, nil, nil
	end,
    
    LP51 = function (m)
		if m.O[3] < m.C[3] then -- если третий бар продаж
			if m.O[2] < m.C[2] then -- если вторjй бак Продаж (покупок)
				if (m.O[1] > m.C[1] and m.H[1] < m.C[3] and m.V[1] > 1.5 * m.V[2]) then -- первый бар продаж закрытие меньше максимума обьем больше чем вдва раза
					return "LP51", "-1", ""
				end
			end
		end
	return nil, nil, nil
	end,
	
	SA1 = function(m)
		if m.O[2] > m.C[2] then
			local x = m.C[1] - m.C[2]
			local v = m.V[1] - m.V[2]
			local l1 = ((m.H[1] - m.L[1]) / 2 + m.L[1])
			local z = 0.01 * m.C[2]
			if (x > 0) then --and v > 0) then
				if (x < 0.01 * m.C[2] and m.C[1] > l1) then --m.O[1] < m.C[1] and v < 0.02 * m.V[1] and m.C[1] > l1) then
					return "SA1 " .. tostring(z) .. ", " .. tostring(x) .. ", " .. tostring(v)..", " .. tostring(l1), "-1", ""
				end
			end
		end
	return nil, nil, nil
	end,
    
    SA11 = function(m)
		if m.O[2] < m.C[2] then
			local x = m.C[2] - m.C[1]
			local v = m.V[2] - m.V[1]
			local l1 = ((m.L[1] - m.H[1]) / 2 + m.L[1])
			local z = 0.01 * m.C[2]
			if (x > 0) then --and v > 0) then
				if ( x < z and m.C[1] > l1) then -- m.O[1] < m.C[1] and v < 0.02 * m.V[1] and m.C[1] > l1) then
					return "SA11 " .. tostring(z) .. ", " .. tostring(x) .. ", " .. tostring(v)..", " .. tostring(l1), "-1", ""
				end
			end
		end
	return nil, nil, nil
	end,
	
	SA2 = function (m)
		if m.O[2] > m.C[2] then
			local x = m.C[1] - m.C[2]
			local z = 0.01 * m.C[2]
			if x > 0 then
				if (x < z and m.V[1] > m.V[2]) then
					return "SA2 " .. tostring(0.01 * m.C[1]) .. " / " .. tostring(x) .. " / " .. tostring(V[1]), "1", ""
				end
			end
		end
	return nil, nil, nil
	end,

	SA3 = function (m)
		if m.O[2] > m.C[2] then
			local x = m.C[1] - m.C[2]
			local z = 0.01 * m.C[2]
			if x > 0 then
				if (x < z and m.V[1] < m.V[2]) then
					return "SA3 " .. tostring(0.01 * m.C[1]).. " / " .. tostring(x), "1", ""
				end
			end
		end
	return nil, nil, nil
	end,

	PPR = function (m) -- надо подумать
		if m.O[2] > m.C[2] then
			if m.O[1] < m.C[1] then
				return "PPR", "1", ""
			end
		end
	return nil, nil, nil
	end,

	FFF = function (m) -- для проверки
		if m.O[3] > m.C[3] then
			if (m.O[2] > m.C[2] and m.V[2] > m.V[3]) then 
				if (m.O[1] < m.C[1] and m.H[1] > m.H[2]) then
					return "FFF", "1", ""
				end
			end
		end
	return nil, nil, nil
	end,


---------------------- обратные сигналы (Short) ------------------------------------------------

	FFF0 = function (m) -- для проверки
		if m.O[3] < m.C[3] then
			if (m.O[2] < m.C[2] and m.V[2] > m.V[3]) then 
				if (m.O[1] > m.C[1] and m.L[1] < m.L[2]) then
					return "_FFF", "-1", ""
				end
			end
		end
	return nil, nil, nil
	end,

	TEST = function (m) -- для проверки
	-- если нужно вывести две переменные x, v и эти переменные относятся к барам, используемым здесь 
	-- всего получаемых свечей - 3 шт. m.O[1], m.O[2], m.O[3]
	-- O, H, L, C, V
	-- то сейчас это можно сделать таким образом:
	--
		if m.O[3] < m.C[3] then
			return "TEST" .. tostring(m.O[1]) .. " / " .. tostring(m.V[1]), "1", ""
			-- либо так (строку выше закомментировать, используя --, строку ниже раскомментировать (убрать --))
			-- return "TEST ".. "10" .. " - ".. "20", "-1", ""
		end
	return nil, nil, nil
	end

	--TEST = function (m) -- для проверки
	-- если нужно вывести две переменные x, v и эти переменные относятся к барам, используемым здесь 
	-- всего получаемых свечей - 3 шт. m.O[1], m.O[2], m.O[3]
	-- O, H, L, C, V
	-- то сейчас это можно сделать таким образом:
	--
	--	if m.O[3] < m.C[3] then
	--		return "TEST " .. tostring(m.O[1]) .. " / " .. tostring(m.V[1]), "1", ""
			-- либо так (строку выше закомментировать, используя --, строку ниже раскомментировать (убрать --))
			-- return "TEST ".. "10" .. " - ".. "20", "-1", ""
	--	end
	--return nil, nil, nil
	--end
}
