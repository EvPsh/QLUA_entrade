SEC_CODE = "CNYRUB" --��� �����������/������
CLASS_CODE = "SPBFUT" --��� ������ �����������/������, ���� ����� �������� ����� - ������� TQBR ������ SPBFUT
ACCOUNT = "SPBFUT00479" -- ���� �� ������� �����
--ACCOUNT = "01695" -- ���� �� ����� ����
--ACCOUNT = "01695FX" -- ���� �� �������� ����� 



function msg(txt) -- ������� ������ ��������� � QUIK
	message(tostring(txt))
end

function get_account() -- ���������� ��� ������ ��� ACCOUNT
	for i = 0, getNumberOf("client_codes") - 1 do
		local n = getItem("client_codes", i)  -- ���������� ������ ���������� ���������� ��� � �������� i, ��� i ����� ��������� �������� �� 0 �� getNumberOf("client_codes") - 1
		msg(n)
	end	
end	
