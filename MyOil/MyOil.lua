function texst()
-- -= ������� 1 =-
-- ���������� 1�� �����
-- ���������� �� ������, ���� ����� ������, ���������� ������
-- ���� ������ ����� ������ ������, ���������� ������
-- ���� ��������� ����� �� ������ ������ �������, ���������� ��������� �����

-- -= ������� 2 =-
-- ���� ������� 1 = true, ���������� ����������� �����
-- ���� P1close < P2close < P3close = ���� � SHORT
-- ���� P1close > P2close > P3close = ���� � LONG
-- ���� �� ����� ����� �� ���� ��������
-- ���� ������� tp?





for i = 3, ab do
-- -= ������� 1 =-
    if CDbl(Cells(i, 10)) > CDbl(Cells(i - 1, 10)) and CDbl(Cells(i - 1, 10)) > CDbl(Cells(i - 2, 10)) and CDbl(Cells(i + 1, 10)) < CDbl(Cells(i, 10)) then
        if HL(CDbl(Cells(i - 2, 9)), CDbl(Cells(i - 2, 6))) = True then
            if HL(CDbl(Cells(i - 1, 9)), CDbl(Cells(i - 1, 6))) = True then
                if HL(CDbl(Cells(i, 9)), CDbl(Cells(i, 6))) = True then
                    Cells(i + 2, 12) = "������� �� open" -- ���� �� 5�� �����
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
    