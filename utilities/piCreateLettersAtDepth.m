function recipe = piCreateLettersAtDepth(varargin)
%CREATELETTERSATDEPTH 
% Create a recipe for a scene that consists of three letters (A,B,C) placed
% at different distances away from the camera. The backdrop consists of a
% checkerboard wall and ground. The letters area always placed +/- 10
% degrees away from the optical axis. 

% OPTIONAL input parameter/val
%   Adist - distance from the camera to the letter A in meters
%   Bdist - distance from the camera to the letter B in meters
%   Cdist - distance from the camera to the letter C in meters
%   illumination - illumination of the scene (infinite light) as as SPD
%                filename.

% RETURN
%   recipe - recipe for this created scene

%% Parse inputs
parser = inputParser();
parser.addParameter('Adist',0.1, @isnumeric);
parser.addParameter('Bdist',0.2, @isnumeric);
parser.addParameter('Cdist',0.3, @isnumeric);
parser.addParameter('illumination', 'EqualEnergy.spd', @ischar);

parser.parse(varargin{:});
Adist = parser.Results.Adist;
Bdist = parser.Results.Bdist;
Cdist = parser.Results.Cdist;
illumination = parser.Results.illumination;

%% Read in base scene
scenePath = fullfile(piRootPath,'data','V3','lettersAtDepth');
sceneName = 'lettersAtDepth.pbrt';

recipe = piRead(fullfile(scenePath,sceneName),'version',3);

%% Calculate x-locations of the letters, given their depth

% "A" will be 7 degrees to the left
Ax = -1*tand(6)*Adist ;

% "B" will be in the center
Bx = 0;

% "C" will be 7 degrees to the right
Cx = tand(4)*Cdist ;


%% Make adjustments to the letters

for ii = 1:length(recipe.assets)
    
    if strcmp(recipe.assets(ii).name,'A')
        % Doesn't work! Why?
        recipe.assets(ii).position(1) = Ax;
        recipe.assets(ii).position(3) = Adist;
    end
    
    if strcmp(recipe.assets(ii).name,'B')
        recipe.assets(ii).position(1) = Bx;
        recipe.assets(ii).position(3) = Bdist;
    end
    
    if strcmp(recipe.assets(ii).name,'C')
        recipe.assets(ii).position(1) = Cx;
        recipe.assets(ii).position(3) = Cdist;
    end
    
end
%}
%% Make adjustments to the light

% Check illumination file
[~,n,e] = fileparts(illumination);
illumName = [n e];

if(~exist(fullfile(scenePath,illumName),'file'))
    Warning(['%s SPD file does not exist in the scene folder. You will'...
        'need to copy it manually into your working folder!'],illumName)
end
recipe = piWorldFindAndReplace(recipe,'EqualEnergy.spd',illumName);


end
