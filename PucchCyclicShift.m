% computes cell-specific cyclic shift for PUCCH as described in 3GPP TS 36.211 V15.0.0 (2017-12)
% section 5.4

n_s = [0 1]; % slot id
l = 0:1:13; % symbol id
N_cell_Id = 2;
seqLength = 20;
N_Ul_symb = 7;
n_RS_Id = N_cell_Id; % virtual cell identity as described in section 5.5.1.5
c_init = n_RS_Id; % initialization for pseudo-random sequence

n_cell_Cs = zeros(length(n_s), length(l));
maxSeqIndex = 1 + 8*N_Ul_symb*n_s(end)+8*l(end)+7;

tic
c = GetGoldSeq(maxSeqIndex, c_init);
for nn = n_s
  for ll = l
    for ii=0:1:7
      seqIndex = 1 + 8*N_Ul_symb*nn+8*ll+ii;
      n_cell_Cs(nn, ll) = n_cell_Cs(nn, ll) + c(seqIndex);
    end
  end  
end
toc