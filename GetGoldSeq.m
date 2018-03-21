function [ c_o ] = GetGoldSeq( len_i, c_init_i )
%GETGOLDSEQ Generates pseudo-random length-31 Gold Sequence
%   According to 3GPP TS 36.211 V15.0.0 (2017-12) Section 7.2
  Nc = 1600;
  x1 = zeros(1, 31);
  x1(1) = 1;
  x2 = fliplr(Int2Bits(c_init_i));
  x2 = [zeros(1, 31-size(x2,2)) x2];
  c_o = zeros(1,len_i);
  for nn = 1:len_i
    c_o(nn) = mod(GetX1(nn+Nc+1, x1)+GetX2(nn+Nc+1, x2),2);
  end
% Let's generate only last element for sake of computation time
%   c_o = mod(GetX1(len_i+Nc+1, x1)+GetX2(len_i+Nc+1, x2),2);
end

function [ x1_o ] = GetX1( n_i, x1_i )
  if n_i > 31
    x1_o = mod(GetX1(n_i-31+3, x1_i)+GetX1(n_i-31, x1_i), 2);
  else
    x1_o = x1_i(n_i);
  end  
end

function [ x2_o ] = GetX2( n_i, x2_i )
  if n_i > 31
    x2_o = mod(GetX2(n_i-31+3, x1_i)+GetX2(n_i-31+2, x1_i)+ ...
      GetX2(n_i-31+1, x1_i)+GetX2(n_i-31, x1_i), 2);
  else
    x2_o = x2_i(n_i);
  end  
end