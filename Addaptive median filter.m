classdef Assignment3_part_2_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        AddValuefrom0100Label     matlab.ui.control.Label
        ApplyAdaptiveMedianFilterButton  matlab.ui.control.Button
        AddNoisetoimageButton     matlab.ui.control.Button
        NoiseValueEditField       matlab.ui.control.NumericEditField
        NoiseValueEditFieldLabel  matlab.ui.control.Label
        UploadImageButton         matlab.ui.control.Button
        UIAxes3                   matlab.ui.control.UIAxes
        UIAxes2                   matlab.ui.control.UIAxes
        UIAxes                    matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: UploadImageButton
        function UploadImageButtonPushed(app, event)
            global img; 
            [filename, pathname] = uigetfile('*.*', 'Pick an Image');
            filename=strcat(pathname,filename);
            img=imread(filename);
            imshow(img,'Parent',app.UIAxes);
        end

        % Button pushed function: AddNoisetoimageButton
        function AddNoisetoimageButtonPushed(app, event)
            global img;
            [m, n]=size(img);            %m,n is the number of rows and columns of the image
            noise_value = app.NoiseValueEditField.Value / 100;
            img=imnoise(img,'salt & pepper',noise_value);
            imshow(img,'Parent',app.UIAxes2);
        end

        % Value changed function: NoiseValueEditField
        function NoiseValueEditFieldValueChanged(app, event)

        end

        % Button pushed function: ApplyAdaptiveMedianFilterButton
        function ApplyAdaptiveMedianFilterButtonPushed(app, event)
            global img;
            [m, n]=size(img);            %m,n is the number of rows and columns of the image
            %% Image edge extension
            %In order to ensure that the pixels at the edge can be collected，The original image must be pixel extended。
            %The maximum filter window generally set is 7，So you only need to expand 3 pixels up, down, left and right to collect edge pixels.。
            Nmax=3;        %Determine the maximum outward expansion to 3 pixels，That is, the maximum window is 7*7
            imgn=zeros(m+2*Nmax,n+2*Nmax);      %Create a new all-0 matrix of expanded size
            imgn(Nmax+1:m+Nmax,Nmax+1:n+Nmax)=img;  %Cover the original image in the middle of imgn
            %Start to expand out below，That is, copy the pixels at the edge outward
            imgn(1:Nmax,Nmax+1:n+Nmax)=img(1:Nmax,1:n);                 %Extend the upper boundary
            imgn(1:m+Nmax,n+Nmax+1:n+2*Nmax)=imgn(1:m+Nmax,n+1:n+Nmax);    %Extend the right boundary
            imgn(m+Nmax+1:m+2*Nmax,Nmax+1:n+2*Nmax)=imgn(m+1:m+Nmax,Nmax+1:n+2*Nmax);    %Extend the lower boundary
            imgn(1:m+2*Nmax,1:Nmax)=imgn(1:m+2*Nmax,Nmax+1:2*Nmax);       %Extend the left boundary
            
            re=imgn;        %Expanded image
            
            %% Get the median value that is not a noise point
            for i=Nmax+1:m+Nmax
                for j=Nmax+1:n+Nmax
                    r=1;                %Initial outward expansion by 1 pixel，That is, the filter window size is 3
                    while r~=Nmax+1    %When the filter window is less than or equal to 7（The outward expansion element is less than 4 pixels）
                        W=imgn(i-r:i+r,j-r:j+r);
                        W=sort(W(:));           %Sort the gray values in the window，The sorting result is a one-dimensional array
                        Imin=min(W(:));         %Minimum gray value
                        Imax=max(W(:));         %Maximum gray value
                        Imed=W(ceil((2*r+1)^2/2));      %Grayscale intermediate value
                        if Imin<Imed && Imed<Imax       %If the value in the current window is not a noise point，Then use the median value of this time as the replacement value
                           break;
                        else
                            r=r+1;              %Otherwise expand the window，Continue to judge，Find the median value that is not a noise point
                        end          
                    end
                    
             %% Determine whether the center pixel in the current window is noise，Yes, just replace it with the median value obtained earlier，Otherwise, do not replace       
                    if Imin<imgn(i,j) && imgn(i,j)<Imax         %If the current pixel is not noise，Original value output
                        re(i,j)=imgn(i,j);
                    else                                        %Otherwise, output the median value of the neighborhood
                        re(i,j)=Imed;
                    end
                end
            end
            %Shows the result of the image with salt and pepper noise after passing the adaptive median filter
            a = re(Nmax+1:m+Nmax,Nmax+1:n+Nmax);
            imshow(a, [] , 'Parent',app.UIAxes3);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 928 602];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Orignal image')
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.Position = [134 390 264 191];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Noise Image Salt & paper')
            app.UIAxes2.XTick = [];
            app.UIAxes2.YTick = [];
            app.UIAxes2.Position = [614 377 301 204];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.UIFigure);
            title(app.UIAxes3, 'Result image')
            app.UIAxes3.XTick = [];
            app.UIAxes3.YTick = [];
            app.UIAxes3.Position = [307 71 339 230];

            % Create UploadImageButton
            app.UploadImageButton = uibutton(app.UIFigure, 'push');
            app.UploadImageButton.ButtonPushedFcn = createCallbackFcn(app, @UploadImageButtonPushed, true);
            app.UploadImageButton.Position = [29 475 100 23];
            app.UploadImageButton.Text = 'Upload Image';

            % Create NoiseValueEditFieldLabel
            app.NoiseValueEditFieldLabel = uilabel(app.UIFigure);
            app.NoiseValueEditFieldLabel.HorizontalAlignment = 'right';
            app.NoiseValueEditFieldLabel.Position = [422 497 69 22];
            app.NoiseValueEditFieldLabel.Text = 'Noise Value';

            % Create NoiseValueEditField
            app.NoiseValueEditField = uieditfield(app.UIFigure, 'numeric');
            app.NoiseValueEditField.ValueChangedFcn = createCallbackFcn(app, @NoiseValueEditFieldValueChanged, true);
            app.NoiseValueEditField.Position = [506 497 100 22];

            % Create AddNoisetoimageButton
            app.AddNoisetoimageButton = uibutton(app.UIFigure, 'push');
            app.AddNoisetoimageButton.ButtonPushedFcn = createCallbackFcn(app, @AddNoisetoimageButtonPushed, true);
            app.AddNoisetoimageButton.Position = [442 434 144 50];
            app.AddNoisetoimageButton.Text = 'Add Noise to image';

            % Create ApplyAdaptiveMedianFilterButton
            app.ApplyAdaptiveMedianFilterButton = uibutton(app.UIFigure, 'push');
            app.ApplyAdaptiveMedianFilterButton.ButtonPushedFcn = createCallbackFcn(app, @ApplyAdaptiveMedianFilterButtonPushed, true);
            app.ApplyAdaptiveMedianFilterButton.Position = [51 171 180 54];
            app.ApplyAdaptiveMedianFilterButton.Text = 'Apply Adaptive Median Filter';

            % Create AddValuefrom0100Label
            app.AddValuefrom0100Label = uilabel(app.UIFigure);
            app.AddValuefrom0100Label.Position = [442 529 146 22];
            app.AddValuefrom0100Label.Text = 'Add Value from ( 0-100 %)';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Assignment3_part_2_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end