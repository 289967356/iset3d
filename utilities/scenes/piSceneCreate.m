function scene = piSceneCreate(photons,varargin)
% Create a scene from radiance data
%
%    scene = piSceneCreate(photons,varargin)
%
% Required
%    photons - row x col x nwave data, computed by PBRT usually
%
% Key/values
%    fov         - horizontal field of view (deg)
%
% Return
%  An ISET scene structure
%
% Example:
%{
   sceneFile = '/home/wandell/pbrt-v2-spectral/pbrt-scenes/bunny.dat';
   photons = piReadDAT(outFile, 'maxPlanes', 31);
   scene = piSceneCreate(photons);
   ieAddObject(scene); sceneWindow;
%}
% BW, SCIENTSTANFORD, 2017

%% When the PBRT uses a pinhole, we treat the radiance data as a scene

p = inputParser;
p.KeepUnmatched = true;
p.addRequired('photons',@isnumeric);
p.addParameter('fov',40,@isscalar)               % Horizontal fov, degrees
p.addParameter('meanluminance',100,@isscalar);
p.addParameter('wavelength', 400:10:700, @isvector);

if length(varargin) > 1
    for i = 1:length(varargin)
        if ~(isnumeric(varargin{i}) || ...
                islogical(varargin{i}) || ...
                isobject(varargin{i}))
            varargin{i} = ieParamFormat(varargin{i});
        end
    end
else
    varargin =ieParamFormat(varargin);
end

p.parse(photons,varargin{:});

%% Sometimes ISET is not initiated. We need at least this

global vcSESSION
if ~isfield(vcSESSION,'SCENE')
    vcSESSION.SCENE = {};
end

%% Set the photons into the scene

patchSize = 8;
scene = sceneCreate('macbeth', patchSize, p.Results.wavelength);
scene = sceneSet(scene, 'wavelength', p.Results.wavelength);
scene = sceneSet(scene,'photons',photons);
[r,c] = size(photons(:,:,1)); depthMap = ones(r,c);

scene = sceneSet(scene,'depth map',depthMap);
scene = sceneSet(scene,'fov',p.Results.fov);
% scene = sceneAdjustLuminance(scene,p.Results.meanluminance); % ISETBIO uses this...

% Adjust other parameters
if ~isempty(varargin)
    for ii=1:2:length(varargin) 
        param = varargin{ii}; 
        if strcmp(param,'meanluminance') || strcmp(param,'fov')
            continue;
        end
        val = varargin{ii+1};
        scene = sceneSet(scene,param,val);
    end
end

end
