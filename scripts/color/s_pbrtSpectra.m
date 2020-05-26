%% s_pbrtSpectralFunctions
%
% Analyze the relationship between RGB and the spectral reflectance
% functions generated by PBRT 
%
% The find the three basis functions that can be used by PBRT with RGB data
% and the basis function model implementedy by Zheng Lyu.
%
% Wandell, March 26, 2020
%
% See also
%  pbrtRGB2Reflectance
%

%% Make a wide range of RGB values

s = 0:0.1:1;
[R,G,B] = meshgrid(s,s,s);
RGB = [R(:),G(:),B(:)];
nSamples = size(RGB,1);

%% Calculate the PBRT reflectance spectra

wave = 400:1:770;
reflectance = zeros(numel(wave),nSamples);
for ii=1:nSamples
    reflectance(:,ii) = pbrtRGB2Reflectance(RGB(ii,:),'wave',wave);
end

%%  These are the spectra as we cycle through RGB

ieNewGraphWin;
mesh(1:nSamples,wave,reflectance);
xlabel('RGB'); ylabel('wave')
colormap(jet)

%%  What are the basis functions?

% Here are the basis functions
[Basis,S,V] = svd(reflectance);
plot(wave,Basis(:,1:3)); xaxisLine;
% R = U*S*V';
% mesh(1:nSamples,wave,R);

%% The 3D approximation to their curves
T = S;
for ii=4:31
    T(ii,ii) = 0;
end

ieNewGraphWin;
mesh(1:nSamples,wave,reflectance);
xlabel('RGB'); ylabel('wave')
colormap(jet); title('Original')

% Here are the equivalent RGB weights for these basis functions
wgts = T*V';
wgts = wgts(1:3,:);

eReflectance = Basis(:,1:3)*wgts;
ieNewGraphWin;
mesh(1:nSamples,wave,eReflectance);
xlabel('RGB'); ylabel('wave')
colormap(jet); title('Approximation')

%% What is the relationship between the wgts and RGB?
%  wgts = L*RGB'

L = wgts*pinv(RGB');

% If we start with RGB and we want to make a reflectance function that is
% (a) within the 3-dimensional representation that PBRT uses, and (b)
% converts the RGB into the right set of weights, then we would do this

% Start with the RGB and apply L to get the eWgts
eWgts = L*RGB';

% This is how close they would match
plot(eWgts(:),wgts(:),'.');
identityLine; grid on

%% If you were starting with RGB, you would do this

eReflectance = (Basis(:,1:3)*L)*RGB';

ieNewGraphWin;
mesh(1:nSamples,wave,eReflectance); 
xlabel('RGB'); ylabel('wave')
colormap(jet); title('3D Approx and linear weight approx')

ieNewGraphWin;
plot(wave,Basis(:,1:3)*L); xaxisLine;
grid on
xlabel('Wave'); 

%% Save basis functions (but clipped at zero)

pbrtBasis = Basis(:,1:3)*L;
pbrtBasis = max(0,pbrtBasis);
ieNewGraphWin;
plot(wave,pbrtBasis,'linewidth',2); xaxisLine;
grid on
xlabel('Wave'); ylabel('Reflectance')

fname = fullfile(piRootPath,'data','basisFunctions','pbrtReflectance');
ieSaveSpectralFile(wave,pbrtBasis,...
    'Estimated PBRT rgb 2 reflectance from s_pbrtSpectra',...
    fname);

%% END
    