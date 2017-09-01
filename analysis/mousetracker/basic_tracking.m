[backgroundVideo,backgroundPath] = uigetfile('*.*','Choose Background Video');

V = loadVideo([backgroundPath backgroundVideo],'ConvertToGrayscale',true,'Binning',[240 320]);

mV = mean(V,3);
sV = std(V,[],3);

[mouseVideo,mousePath] = uigetfile('*.*','Choose video what where the mice are running around and shit');

V = loadVideo([mousePath mouseVideo],'ConvertToGrayscale',true,'Binning',[240 320],'BackgroundImage',mV,'Scaling',sV,'MaxFrames',1000);

figure
imagesc(mV);
colormap(gray)
title('Outline arena');
roi = imfreehand;
mask = createMask(roi);

close(gcf);

minBlobSize = input('How big is the smallest mouse in pixels?');

%%

[X,Y,d] = trackBlobs(V,'Mask',mask,'MinBlobSize',minBlobSize,'Threshold',@(I) abs(I) > 50);

disp('Total distance travelled by all blobs (in pixels):');
disp(d);

figure;
plot(X,Y);