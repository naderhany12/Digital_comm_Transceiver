% ==========================================
% EXPORT ALL OPEN FIGURES TO A FOLDER
% ==========================================
export_folder = 'Signaling_Plots'; % Define your desired folder name here

% Create the directory if it doesn't exist
if ~exist(export_folder, 'dir')
    mkdir(export_folder);
end

% Get handles for all currently open figures
all_figs = findall(0, 'Type', 'figure');

if isempty(all_figs)
    fprintf('No figures found to export.\n');
else
    fprintf('Exporting %d figures to folder "%s"...\n', length(all_figs), export_folder);
    
    % Loop through each figure and save it
    for i = 1:length(all_figs)
        fig = all_figs(i);
        
        % Generate a standardized filename using the figure's number
        filename_png = fullfile(export_folder, sprintf('Figure_%02d.png', fig.Number));
        filename_fig = fullfile(export_folder, sprintf('Figure_%02d.fig', fig.Number));
        
        % Save as a high-resolution PNG (Requires MATLAB R2020a or newer)
        exportgraphics(fig, filename_png, 'Resolution', 300);
        
        % Save as a standard MATLAB .fig file for future editing
        savefig(fig, filename_fig);
        
        fprintf('  -> Saved Figure %d\n', fig.Number);
    end
    fprintf('All figures exported successfully.\n');
end