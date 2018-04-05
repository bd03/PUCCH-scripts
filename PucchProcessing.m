%% Script that simulates a simplified version of LTE PUCCH acc. to 36.211
% bd03 - 2018/4/4
% Assumptions:
% - PUCCH Format 1a without SR
% - normal cyclic prefix
% - numOfAntennaPorts = 1 so ~P is usually dropped from notation
% - delta_PUCCH_shift = 1
% - no mixed RBs
% --> N_(1)_cs = 0
% ----> n_(1,~p)_PUCCH >= c*N_(1)_cs / delta_PUCCH_shift)
% - n_PUCCH_ID is not configured % see 5.5.1.5
% ---> N_RS_ID = N_cell_ID 
% - No SRS (no shortened PUCCH)
clear all

%% Config
numOfAckBits = 1;
PucchResourceIndex = 0; % n_(1,~p)_PUCCH
numOfSlots = 2; % #n_s
N_cell_ID = 10;

% Constants
N_PUCCH_seq = 12;
N_RB_sc = 12;
delta_PUCCH_shift=1;
numOfAntennaPorts = 1; % P
numOfSymbolsPerSlot = 7; % #l = N_UL_symb w normal CP

%% Init and Derivation
numSymbols = numOfAckBits; % For BPSK numBits=numSyms
cyclicShift = zeros(numOfSlots, numOfSymbolsPerSlot); % n_cell_cs
for kk=1:numOfSlots
  slotId = kk-1;
  for jj=1:numOfSymbolsPerSlot
    symbolId=jj-1;
    for ii=0:7
      seqIndex = 8 * numOfSymbolsPerSlot * slotId + 8 * symbolId + ii;
      cyclicShift(kk,jj) = cyclicShift(kk,jj) + GetGoldSeq(seqIndex, N_cell_ID) * 2^ii;
    end
  end
end
nPrime = zeros(numOfSlots, 1); %n
c = 3; % normal CP assumed
for ii=1:numOfSlots
  if mod(ii-1,2) == 0
    nPrime(ii) = mod(PucchResourceIndex, c * N_RB_sc/delta_PUCCH_shift);
  else
    nPrime(ii) = mod(c*(nPrime(ii-1)+1), c * N_RB_sc/delta_PUCCH_shift)-1;
  end
end
nPrime=repmat(nPrime,1,7); %% making ready for matrix-wise computation
Nprime = N_RB_sc; % N', Assuming no mixed RB
n_oc = floor(nPrime*delta_PUCCH_shift/Nprime);
% n_cs = zeros(numOfSlots, numOfSymbolsPerSlot);
n_cs = mod(cyclicShift + ...
  mod(nPrime*delta_PUCCH_shift + ...
    mod(n_oc, delta_PUCCH_shift)... % Always 0 for delta_PUCCH_shift = 1
    , Nprime)...
  , N_RB_sc);
% alpha = zeros(numOfSlots, numOfSymbolsPerSlot);
alpha = 2*pi*n_cs/N_RB_sc; % The antenna-port specific cyclic shift 
% for now let's use same seq for all symbols --> must be corrected!!!!
sequence = ReferenceSignalGenerator(alpha(1,1), N_cell_ID);
sequence = repmat(sequence, numSymbols, 1);

N_PUCCH_SF=4; % normal PUCCH (not shortened)
scrambler = zeros(numOfSlots,1);
for ii=1:numOfSlots
  if mod(nPrime(ii),2) == 0
    scrambler(ii) = 1;
  else
    scrambler(ii) = exp(j*pi/2);
  end
end
orthSeqList = [1, 1, 1, 1; 1, -1, 1, -1; 1, -1, -1, 1]; % N_PUCCH_SF=4 assumed
ortSeq = orthSeqList(n_oc+1); % w_(n_p_oc)

%% bit generation
ackBits = rand(numOfAckBits,1)>0.5; % b(0),...,b(M_bit-1)

%% Modulation
% BPSK Modulation for Format 1a acc. to 36.211 Table 5.4.1-1
symbols = -1*sign(ackBits - 0.5); % d(0),...,d(M_sym-1)

%% Multiplication with cyclically shifted sequence
y = zeros(numSymbols, N_PUCCH_seq);
for ii=1:numSymbols
  y(ii,:) = (1/sqrt(numOfAntennaPorts))*symbols(ii)*sequence(ii,:);
end

%% Scrambling, block-wise spreading
z = zeros(numSymbols, N_PUCCH_SF*N_PUCCH_seq + (N_PUCCH_SF-1)*N_PUCCH_seq + N_PUCCH_seq);
for ii=1:numSymbols
  for mm=1:N_PUCCH_SF
    for mPrime=0:1
      z(ii,mPrime*N_PUCCH_SF*N_PUCCH_seq+(mm-1)*N_PUCCH_seq+(1:N_PUCCH_seq)) ...
        = scrambler(1)*ortSeq(mm)*y(ii,:);
    end
  end
end