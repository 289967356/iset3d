function thisR = piRecipeDefault(varargin)
% Helper  function to return a simple recipe for testing
%
% Syntax
%   thisR = piRecipeDefault(varargin)
%
% Inputs
%
% Optional key/val pairs
%   scene name - The PBRT scene
%     Currently only MacBethChecker (default) and SimpleScene
%   write      -  Call piWrite (default is true).  Writes into iset3d/local
%
% Outputs
%   thisR - the recipe
%
% See also
%  recipe

% Examples:
%{
   thisR = piRecipeDefault;
   scene = piRender(thisR,'render type','illuminant');
   sceneWindow(scene);
%}
%{
   thisR = piRecipeDefault('scene name','SimpleScene');
   scene = piRender(thisR);
   sceneWindow(scene); sceneSet(scene,'gamma',0.5);
%}
%{
   thisR = piRecipeDefault;
   scene = piRender(thisR,'render type','all');
   sceneWindow(scene);
%}
%{
   thisR = piRecipeDefault('scene name','SimpleScene');
   scene = piRender(thisR);
   scene = piRender(thisR,'render type','illuminant only');
%}
%{
   thisR = piRecipeDefault('scene name','SimpleScene');
   scene = piRender(thisR, 'render type', 'all');
   sceneWindow(scene); sceneSet(scene,'gamma',0.5);
%}

%%  Figure out the scene and whether you want to write it out

varargin = ieParamFormat(varargin);

p = inputParser;
p.addParameter('scenename','MacBethChecker',@ischar);
p.addParameter('write',true,@islogical);
p.parse(varargin{:});

sceneName = p.Results.scenename;
write     = p.Results.write;

%%
switch sceneName
    
    case 'MacBethChecker'
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end

    case 'SimpleScene'
        FilePath = fullfile(piRootPath,'data','V3',sceneName);
        fname = fullfile(FilePath,[sceneName,'.pbrt']);
        if ~exist(fname,'file'), error('File not found'); end
    otherwise
        error('Can not identify the scene, %s\n',sceneName);
end

%% Got the file, create the recipe

thisR = piRead(fname);
outFile = fullfile(piRootPath,'local',sceneName,[sceneName,'.pbrt']);
thisR.set('outputfile',outFile);

% Set for very low resolution, for testing
thisR.integrator.subtype = 'path';
thisR.set('pixelsamples', 16);
thisR.set('filmresolution', [320, 180]);

%% Save the recipe for the user
if write
    piWrite(thisR);
    fprintf('Recipe is written in iset3d/local.\n');
end

end

