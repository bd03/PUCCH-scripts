%% Determines the PRB indices in which PUCCH transmission is carried out.

% Supported Parameters
SupportedPucchFormats = {'1', '1a', '1b'};

% Selected Parameters
PucchFormat = '1a';

% Derived Parameters
switch PucchFormat
  case '1'
    M_bit=0;
  case '1a'
    M_bit=1;
  case '1b'
    M_bit=2;
end






n_PRB

