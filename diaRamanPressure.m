%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Name and Surname: DRICHE idir                                              %%
%% Purpose of the code: Create a graphical interface to evaluate hydrostatic  %%
%% pressure based on the Raman signal of a diamond anvil                      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

### Copyright 2024 Idir Driche, Université de lille, France
### under the supervision of Sébastien MERKEL

### This work is a part of ERC hotcores project that has received funding from the European Research Council (ERC)
### under the grant agreement No 101054994.
### https://erc-hotcores.univ-lille.fr/

### This program is free software: you can redistribute it and/or modify it
### under the terms of the GNU General Public License as published by the Free
### Software Foundation, either version 3 of the License, or (at your option) any later version.

### This program is distributed in the hope that it will be useful, but WITHOUT ANY
### WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
### PARTICULAR PURPOSE. See the GNU General Public License for more details.

### You should have received a copy of the GNU General Public License along with this program.
### If not, see <https://www.gnu.org/licenses/>.


function interface_graphic()
    pkg load optim
    %%% to create the main figure
    fig = figure('Name', 'Data Analysis', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);

    %%% Button to load data
    uicontrol('Style', 'pushbutton', 'String', 'Load Data', ...
              'Position', [50, 550, 150, 50], 'Callback', @load_data);

    %%%%%%%%%%% Text area to enter reference value
    uicontrol('Style', 'text', 'String', '     Reference Value ', ...
              'Position', [500, 450, 150, 30], 'HorizontalAlignment', 'left');
    valeur_ref = uicontrol('Style', 'edit', 'Position', [670, 450, 150, 30]);

    uicontrol('Style', 'text', 'String', '  cm-1', ...
              'Position', [840, 450, 47, 30], 'HorizontalAlignment', 'left');


    uicontrol('Style', 'text', 'String', '    Designed by : Idir DRICHE - idir.driche.etu@univ-lille.fr ', ...
              'Position', [1000, 5, 340, 22], 'HorizontalAlignment', 'left');


    %%% Text area to display found value (lambda_peak)
    uicontrol('Style', 'text', 'String', '     Found Value ', ...
              'Position', [500, 400, 150, 30], 'HorizontalAlignment', 'left');
    valeur_trouvee = uicontrol('Style', 'edit', 'Position', [670, 400, 150, 30]);

     uicontrol('Style', 'text', 'String', '  cm-1', ...
              'Position', [840, 400, 47, 30], 'HorizontalAlignment', 'left');


    % Zone of text to enter reference value
    uicontrol('Style', 'edit', 'String', ["For the proper functioning of the program, you must follow the following steps:\n" ...
                                          "1) Load the data.\n" ...
                                          "2) Apply the smoothing order.\n" ...
                                          "3) Calculate the derivative of the smoothed data.\n" ...
                                          "4) Select the interval where the peak is located.\n" ...
                                          "5) Once the interval is selected, the Gaussian is automatically applied and the measured value is displayed.\n" ...
                                          "6) Enter the reference value.\n" ...
                                          "7) Click on the [Calculate Pressure] button to display the pressure value."], ...
              'Position', [1030, 370, 300, 220], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10, ...
              'Max', 2, ...
              'Enable', 'inactive', ...
              'BackgroundColor', [0, 1, 0]);

    %%%% Button to calculate pressure
    uicontrol('Style', 'pushbutton', 'String', 'Calculate Pressure of the cell ', ...
              'Position', [400, 350, 250, 30], 'Callback', @calculate_pressure);

    uicontrol('Style', 'text', 'String', '   GPa', ...
              'Position', [840, 350, 47, 30], 'HorizontalAlignment', 'left');

    %%% Displaying the result
    result_text = uicontrol('Style', 'text', 'String', '', ...
                            'Position', [670, 350, 150, 30], 'HorizontalAlignment', 'center', 'FontSize', 11);

    %%%%%%%%%%% Text area to enter the smoothing order
    ordre_de_lissage = uicontrol('Style', 'edit', 'Position', [245, 450, 40, 40]);

    %%%% Button to apply smoothing
    uicontrol('Style', 'pushbutton', 'String', 'Apply Smoothing', ...
              'Position', [30, 450, 200, 40], 'Callback', @apply_smoothing);

    %%%%%%%%%  Button to calculate the derivative of the smoothed data
    uicontrol('Style', 'pushbutton', 'String', 'Calculate derivative of smoothed data', ...
              'Position', [860, 320, 260, 20], 'Callback', @dI_dlambda_callback);

    %%% Axes for the plots
    ax1 = axes('Parent', fig, 'Position', [0.1, 0.1, 0.35, 0.35]);
    ax2 = axes('Parent', fig, 'Position', [0.55, 0.1, 0.35, 0.35]);

    %%% Global variables
    global data lambda I dI_dlambda lambda_peak I_smooth;

    %%% Function to load data
    function load_data(~, ~)
        [filename, pathname] = uigetfile('*.txt', 'Select data file');
        if isequal(filename, 0) || isequal(pathname, 0)
            disp('No file selected');
            return;
        end

        % Read data from selected file
        data = load(fullfile(pathname, filename));

        % Separate data into wavelength (lambda) and intensity (I) vectors
        lambda = data(:, 1);
        I = data(:, 2);

        % Plot raw data on the graph
        axes(ax1);
        plot(lambda, I, 'y');
        legend('Raw Data');
        title('Intensity vs. Raman Shift');
        xlabel('Raman shift (cm-1)');
        ylabel('Intensity(cnt)');
        grid on;
    end

    % Function to apply smoothing
    function apply_smoothing(~, ~)
        % Check if data is available
        if isempty(I)
            errordlg('Please load data before applying smoothing.', 'Error');
            return;
        end

        % Get the smoothing order specified by the user
        order = str2double(get(ordre_de_lissage, 'String'));
        if isnan(order) || order <= 0
            errordlg('Please enter a valid smoothing order.', 'Error');
            return;
        end

        % Apply smoothing
        I_smooth = movmean(I, order);

        % Plot raw and smoothed data on the same graph
        axes(ax1);
        plot(lambda, I, 'y', lambda, I_smooth, 'k');
        legend('Raw Data', 'Smoothed Data');
        title('Intensity vs Raman Shift');
        xlabel('Raman shift (cm-1)');
        ylabel('Intensity(cnt)');
        grid on;
    end

    % Function to calculate derivative of smoothed data
    function dI_dlambda_callback(~, ~)
        % Check if smoothed data is available
        if isempty(I_smooth)
            errordlg('Please load and apply smoothing order before calculating derivative.', 'Error');
            return;
        end

        % Calculate derivative of intensity
        dI_dlambda = gradient(I_smooth, lambda);

        % Plot derivative of intensity vs wavelength
        axes(ax2);
        plot(lambda, dI_dlambda, 'r');
        title('Intensity Derivative vs Raman Shift');
        xlabel('Raman shift (cm-1)');
        ylabel('Intensity (cnt)');
        grid on;

        % Use ginput to select a data range on the second subplot
        disp('Click on two points to select a data range on the derivative graph.');
        disp('Press Enter after each click.');

        % Selecting the first point of the range
        [x1, ~] = ginput(1);
        hold on;
        plot(x1 * [1 1], [min(dI_dlambda) max(dI_dlambda)], 'r--');

        % Selecting the second point
        [x2, ~] = ginput(1);
        plot(x2 * [1 1], [min(dI_dlambda) max(dI_dlambda)], 'r--');
        hold off;

        % Determine indices corresponding to the selected range
        idx = find(lambda >= min(x1, x2) & lambda <= max(x1, x2));

        % Extract sub-vectors for the selected range
        lambda_sel = lambda(idx);
        dI_dlambda_sel = dI_dlambda(idx);

        % Gaussian fit on the selected range
        gaussian = @(p, x) p(1) * exp(-((x - p(2)) / p(3)).^2);
        p_initial = [max(dI_dlambda_sel), mean(lambda_sel), std(lambda_sel)];
        p_optim = lsqcurvefit(gaussian, p_initial, lambda_sel, dI_dlambda_sel);

        % Calculate fitted Gaussian
        dI_dlambda_fit = gaussian(p_optim, lambda_sel);

        % Plot fitted curve
        axes(ax2);
        hold on;
        plot(lambda_sel, dI_dlambda_fit, 'g', 'LineWidth', 2);
        plot(p_optim(2), gaussian(p_optim, p_optim(2)), 'ko', 'MarkerFaceColor', 'y'); % Adding marker for Gaussian peak
        legend('Intensity Derivative', 'Selected Range');
        title('Intensity Derivative with Gaussian Fit');
        xlabel('Raman shift (cm-1)');
        ylabel('Intensity (cnt)');
        grid on;
        hold off;

        % Display peak abscissa
        lambda_peak = p_optim(2);
        disp(['The peak of the fitted Gaussian is at wavelength ', num2str(lambda_peak), ' nm']);

        % Display lambda_peak in the "Found Value" text area
        set(valeur_trouvee, 'String', num2str(lambda_peak));
    end

    % Function to calculate pressure
    function calculate_pressure(~, ~)
        K0 = 547;           % Linear coefficient
        K0_prime = 3.75;    % Non-linear coefficient

        % Read reference and found values
        nu_zero = str2double(get(valeur_ref, 'String'));
        nu = str2double(get(valeur_trouvee, 'String'));

        % Check if values are valid
        if isnan(nu_zero) || isnan(nu)
            errordlg('Please enter valid numeric values.', 'Error');
            return;
        end

        % Calculate pressure
        pressure = K0 * ((nu - nu_zero) / nu_zero) * (1 + (1/2) * (K0_prime - 1) * ((nu - nu_zero) / nu_zero));
        % Display result
        set(result_text, 'String', num2str(pressure));
    end

end

% Call the function to create the graphical interface
interface_graphic();


