function texst()
-- -= условие 1 =-
-- запоминаем 1ую свечу
-- сравниваем со второй, если объем больше, запоминаем вторую
-- если третья свеча больше второй, запоминаем третью
-- если четвертая свеча по объему меньше третьей, запоминаем четвертую свечу

-- -= условие 2 =-
-- если условие 1 = true, определяем направление входа
-- если P1close < P2close < P3close = вход в SHORT
-- если P1close > P2close > P3close = вход в LONG
-- вход на пятой свече по цене открытия
-- куда ставить tp?





for i = 3, ab do
-- -= условие 1 =-
    if CDbl(Cells(i, 10)) > CDbl(Cells(i - 1, 10)) and CDbl(Cells(i - 1, 10)) > CDbl(Cells(i - 2, 10)) and CDbl(Cells(i + 1, 10)) < CDbl(Cells(i, 10)) then
        if HL(CDbl(Cells(i - 2, 9)), CDbl(Cells(i - 2, 6))) = True then
            if HL(CDbl(Cells(i - 1, 9)), CDbl(Cells(i - 1, 6))) = True then
                if HL(CDbl(Cells(i, 9)), CDbl(Cells(i, 6))) = True then
                    Cells(i + 2, 12) = "Продажа по open" -- вход на 5ой свече
                end
            end
        end
    end
end

end 

function HL(x As Double, y As Double)
    if x - y >= 0 then return true
    else return false
    end
end
    