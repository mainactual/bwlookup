function mylookuptest
%=========================================================================
%
%  Copyright mainactual
%
%  Licensed under the Apache License, Version 2.0 (the "License");
%  you may not use this file except in compliance with the License.
%  You may obtain a copy of the License at
%
%         http://www.apache.org/licenses/LICENSE-2.0.txt
%
%  Unless required by applicable law or agreed to in writing, software
%  distributed under the License is distributed on an "AS IS" BASIS,
%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%  See the License for the specific language governing permissions and
%  limitations under the License.
%
%=========================================================================


%
% Test bwlookup against MATLAB's bwmorph/bwlookup
%

% Clean up
clc;clear;close all;
%
% Set up the program
%
pathname = []; % TODO
prgname = 'mylookup.exe';
srcname = 'src.png';
dstname = 'dst.png';
lutname = 'lut.png';

%
% Load image
%
%bw = uint8( imread( 'TODO' )>127 );
bw = uint8(imread( 'circles.png' ));

execommand = [
    pathname,prgname,' ',...
    pathname,srcname,' ',...
    pathname,lutname,' ',...
    pathname,dstname ];


% Save image for test
imwrite( bw, [pathname,srcname] );

%
% Round 1: test the program
%
imwrite( ones(512,1,'uint8'), [pathname, lutname], 'png' );
status1 = system( execommand );
imwrite( ones(256,1,'uint8'), [pathname, lutname], 'png' );
status2 = system( execommand );
if ( status1 == 0 && status2 ~= 0 )
    ; % good to go
else
    error('error');
end

%
% Round 2: test against presets 
%
op = {
    'bothat',...
    'branchpoints',...
    'bridge',...
    'clean',...
    'close',...
    'diag',...
    'dilate',...
    'endpoints',...
    'erode',...
    'fatten',...
    'fill',...
    'hbreak',...
    'majority',...
    'perim4',...
    'perim8',...
    'open',...
    'remove',...
    'shrink',...
    'skeleton',...
    'spur',...
    'thicken',...
    'thin',...
    'tophat'};

succeeded = 0;
failed = 0;
skipped = 0;

for i = op
    % apply bwmorph
    o = cell2mat( i );
    disp( o );
    [bwout, lut] = bwmorph( bw, o, 1);
    if ( isempty( lut ) || length( lut ) ~= 512 )
        skipped = skipped+1;
        continue;
    end
    lut = uint8( lut );
    bwout = uint8( bwout );
    imwrite( lut, [pathname, lutname], 'png' );
    status = system( execommand );
    if ( status ~= 0 )
        error('status!=0');
    end
    bwext = uint8( imread( [pathname,dstname] ) );
    if ( isequal( bwext, bwout ) )
        succeeded = succeeded + 1;
    else
        % if bwmorph failed, test against bwlookup too
        bwout2 = uint8( bwlookup( bw, lut ) );
        if ( isequal( bwout2, bwext ) )
            % if bwlookup works, then this is not a lookup error!
            skipped = skipped + 1;
        else
            failed = failed + 1;
        end
    end
end
%
% Round 3: test against a random lut
%
for i = 1:length(op)
    lut = uint8(rand(512,1)>0.5);
    bwout = uint8( bwlookup( bw, lut ) );
    imwrite( lut, [pathname, lutname], 'png' );
    status = system( execommand );
    if ( status ~= 0 )
        error('status!=0');
    end
    bwext = uint8( imread( [pathname,dstname] ) );
    if ( isequal( bwext, bwout ) )
        succeeded = succeeded + 1;
    else
        failed = failed + 1;
    end
end

disp( '*****' );
disp( ['Succeeded ', num2str( succeeded ) ] );
disp( ['Failed ', num2str( failed ) ] );
disp( ['Skipped ', num2str( skipped ) ] );
disp( '*****' );


