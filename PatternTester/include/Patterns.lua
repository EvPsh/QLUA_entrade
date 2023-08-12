Mfunc = {
	LP1 = function (m)
	-- ������� LP1
	-- [1] - ������ ����� ������ �� ����� �������
	-- [2] - ������ ����� ������ �� ����� �������
	-- [3] - ������ ����� ������ �� ����� �������
	-- m.O[1] - ���� Open 1�� �����
	-- m.H[1] - ���� High 1�� �����
	-- m.L[1] - ���� Low 1�� �����
	-- m.�[1] - ���� Close 1�� �����
	-- m.V[1] - ����� 1�� �����
	-- ����� ���������� ������ - 3 ��. m.O[1], m.O[2], m.O[3]
	-- ����� ���������� �� ������ O, H, L, C, V � ���������� ������ ���� ������� ������
	---
	if m.O[3] > m.C[3] then                                   -- ���� ������ ��� ������
		if (m.O[2] > m.C[2]) then-- and m.V[2] > m.V[3]) then -- ���� ������ ��� ������ � ����� ����������
			if (m.O[1] < m.C[1] and m.H[1] > m.C[3]) then --and m.V[1] < m.V[2]) then -- ������	 ��� ������� � ������� ���� ����� ��� �������� �������� ���� � ������� ������ ��� � �������
				return "LP1", "1", ""
			end
		end
	end
	return nil, nil, nil
	end, 

    LP11 = function (m)
	if m.O[3] < m.C[3] then                                   -- ���� ������ ��� �������
		if (m.O[2] < m.C[2]) then-- and m.V[2] > m.V[3]) then -- ���� ������ ��� ��� ������� � ����� ����������
			if (m.O[1] > m.C[1] and m.H[1] < m.C[3]) then -- and m.V[1] < m.V[2]) then -- ������	 ��� ������ � ������� ���� ����� ��� �������� �������� ���� � ������� ������ ��� � �������
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
					if (m.C[1] < m.C[3]) then-- and m.V[1] > m.V[2]) then -- ������	 ��� ������� � ������� ���� ����� ��� �������� �������� ���� � ������� ������ ��� � �������
					return "LP21", "-1", ""
				end
			end
		end
		return nil, nil, nil
	end, 
	
	LP3 = function (m)
		if m.O[3] > m.C[3] then 							-- ���� ������ ��� ������
			if (m.O[2] > m.C[2] and m.V[2] < m.V[3]) then   -- ���� ������ ��� ������
				if (m.O[1] < m.C[1] and m.H[1] > m.H[3] and m.V[1] > m.V[2]) then -- ������	 ��� ������� � ������� ���� ����� ��� ������ �������� � ������� ������ ��� � �������
					return "LP3", "1", ""
				end
			end
		end
	return nil, nil, nil
	end,
	
	LP31 = function (m)
		if m.O[3] < m.C[3] then 							-- ���� ������ ��� ������
			if (m.O[2] < m.C[2] and m.V[2] < m.V[3]) then   -- ���� ������ ��� ������
				if (m.O[1] > m.C[1] and m.H[1] < m.H[3] and m.V[1] > m.V[2]) then -- ������	 ��� ������� � ������� ���� ����� ��� ������ �������� � ������� ������ ��� � �������
					return "LP31", "-1", ""
				end
			end
		end
	return nil, nil, nil
	end,
	
	LP4 = function (m)
		if m.O[3] > m.C[3] then -- ���� ������ ��� ������
			if (m.O[2] > m.C[2]) then-- and m.V[2] > m.V[3]) then -- ���� ������ ��� ������
				if (m.O[1] < m.C[1] and m.H[1] < m.H[2] and m.V[1] > m.V[2]) then -- ������ ��� ������� ������� ������ ������� ���� � ������� ������� ��� �� ������
					return "LP4", "1", ""
				end
			end
		end
	return nil, nil, nil
	end,
    
    LP41 = function (m)
		if m.O[3] < m.C[3] then -- ���� ������ ��� ������
			if (m.O[2] < m.C[2]) then-- and m.V[2] > m.V[3]) then -- ���� ������ ��� ������
				if (m.O[1] > m.C[1] and m.H[1] > m.H[2] and m.V[1] > m.V[2]) then -- ������ ��� ������� ������� ������ ������� ���� � ������� ������� ��� �� ������
					return "LP41", "-1", ""
				end
			end
		end
	return nil, nil, nil
	end,
	
	LP5 = function (m)
		if m.O[3] > m.C[3] then -- ���� ������ ��� ������
			if m.O[2] > m.C[2] then -- ���� ����j� ��� ������ (�������)
				if (m.O[1] < m.C[1] and m.H[1] > m.C[3] and m.V[1] > 1.5 * m.V[2]) then -- ������ ��� ������ �������� ������ ��������� ����� ������ ��� ���� ����
					return "LP5", "1", ""
				end
			end
		end
	return nil, nil, nil
	end,
    
    LP51 = function (m)
		if m.O[3] < m.C[3] then -- ���� ������ ��� ������
			if m.O[2] < m.C[2] then -- ���� ����j� ��� ������ (�������)
				if (m.O[1] > m.C[1] and m.H[1] < m.C[3] and m.V[1] > 1.5 * m.V[2]) then -- ������ ��� ������ �������� ������ ��������� ����� ������ ��� ���� ����
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

	PPR = function (m) -- ���� ��������
		if m.O[2] > m.C[2] then
			if m.O[1] < m.C[1] then
				return "PPR", "1", ""
			end
		end
	return nil, nil, nil
	end,

	FFF = function (m) -- ��� ��������
		if m.O[3] > m.C[3] then
			if (m.O[2] > m.C[2] and m.V[2] > m.V[3]) then 
				if (m.O[1] < m.C[1] and m.H[1] > m.H[2]) then
					return "FFF", "1", ""
				end
			end
		end
	return nil, nil, nil
	end,


---------------------- �������� ������� (Short) ------------------------------------------------

	FFF0 = function (m) -- ��� ��������
		if m.O[3] < m.C[3] then
			if (m.O[2] < m.C[2] and m.V[2] > m.V[3]) then 
				if (m.O[1] > m.C[1] and m.L[1] < m.L[2]) then
					return "_FFF", "-1", ""
				end
			end
		end
	return nil, nil, nil
	end,

	TEST = function (m) -- ��� ��������
	-- ���� ����� ������� ��� ���������� x, v � ��� ���������� ��������� � �����, ������������ ����� 
	-- ����� ���������� ������ - 3 ��. m.O[1], m.O[2], m.O[3]
	-- O, H, L, C, V
	-- �� ������ ��� ����� ������� ����� �������:
	--
		if m.O[3] < m.C[3] then
			return "TEST" .. tostring(m.O[1]) .. " / " .. tostring(m.V[1]), "1", ""
			-- ���� ��� (������ ���� ����������������, ��������� --, ������ ���� ����������������� (������ --))
			-- return "TEST ".. "10" .. " - ".. "20", "-1", ""
		end
	return nil, nil, nil
	end

	--TEST = function (m) -- ��� ��������
	-- ���� ����� ������� ��� ���������� x, v � ��� ���������� ��������� � �����, ������������ ����� 
	-- ����� ���������� ������ - 3 ��. m.O[1], m.O[2], m.O[3]
	-- O, H, L, C, V
	-- �� ������ ��� ����� ������� ����� �������:
	--
	--	if m.O[3] < m.C[3] then
	--		return "TEST " .. tostring(m.O[1]) .. " / " .. tostring(m.V[1]), "1", ""
			-- ���� ��� (������ ���� ����������������, ��������� --, ������ ���� ����������������� (������ --))
			-- return "TEST ".. "10" .. " - ".. "20", "-1", ""
	--	end
	--return nil, nil, nil
	--end
}
