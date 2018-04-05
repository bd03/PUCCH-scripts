function [ c_o ] = GetGoldSeq( index_i, c_init_i )
%GETGOLDSEQ Returns the pseudo-random length-31 Gold Sequence value for index_i
%   According to 3GPP TS 36.211 V15.0.0 (2017-12) Section 7.2
%   First initialize with defined values
%   Expand large index values into smaller values until they are reduced to basic values i.e. 0,...,30
%   Remove any duplicate entries immediately

  %% init
  Nc = 1600;
  x1 = zeros(1, 31);
  x1(1) = 1;
  x2 = de2bi(c_init_i);
  x2 = [zeros(1, 31-size(x2,2)) x2];
  
  x1Indices = [index_i+Nc];
  x2Indices = [index_i+Nc];
  while any(x1Indices>30)
    x1Indices = GetX1Indices(x1Indices);
  end
  while any(x2Indices>30)
    x2Indices = GetX2Indices(x2Indices);
  end
  x1Indices = x1Indices + 1;
  x2Indices = x2Indices + 1;
  
  c_o = mod(sum(x1(x1Indices))+sum(x2(x2Indices)), 2);  
end

function [ set_o ] = GetX1Indices( set_i )
%   Detailed explanation goes here
  set_o = set_i;
  for ii=1:length(set_i)
    if set_o(ii) > 30
      id1 = set_i(ii)-31+3;
      dupId = find(set_o == id1);
      if dupId
        set_o(dupId) = -1;
      else
        set_o(end+1) = id1;
      end
      id2 = set_i(ii)-31;
      dupId = find(set_o == id2);
      if dupId
        set_o(dupId) = -1;
      else
        set_o(end+1) = id2;
      end
      set_o(ii) = -1;
    end    
  end
  set_o(find(set_o==-1)) = [];
end

function [ set_o ] = GetX2Indices( set_i )
%   Detailed explanation goes here
  set_o = set_i;
  for ii=1:length(set_i)
    if set_o(ii) > 30
      id1 = set_i(ii)-31+3;
      dupId = find(set_o == id1);
      if dupId
        set_o(dupId) = -1;
      else
        set_o(end+1) = id1;
      end      
      id2 = set_i(ii)-31+2;
      dupId = find(set_o == id2);
      if dupId
        set_o(dupId) = -1;
      else
        set_o(end+1) = id2;
      end      
      id3 = set_i(ii)-31+1;
      dupId = find(set_o == id3);
      if dupId
        set_o(dupId) = -1;
      else
        set_o(end+1) = id3;
      end      
      id4 = set_i(ii)-31;
      dupId = find(set_o == id4);
      if dupId
        set_o(dupId) = -1;
      else
        set_o(end+1) = id4;
      end
      set_o(ii) = -1;
    end
  end
  set_o(find(set_o==-1)) = [];
end