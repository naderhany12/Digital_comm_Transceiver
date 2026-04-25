% ==========================================
% EXPORT ALL OPEN FIGURES TO A FOLDER (PNG ONLY)
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
        title_str = '';
        
        % 1. Try to find an overarching sgtitle first
        sg = findall(fig, 'Tag', 'sgtitle');
        if ~isempty(sg) && ~isempty(sg.String)
            title_str = sg.String;
            if iscell(title_str)
                title_str = title_str{1}; 
            end
        else
            % 2. Fallback: find the first available axes title
            ax = findall(fig, 'type', 'axes');
            for a = 1:length(ax)
                if ~isempty(ax(a).Title.String)
                    title_str = ax(a).Title.String;
                    if iscell(title_str)
                        title_str = title_str{1}; 
                    end
                    break;
                end
            end
        end
        
        % 3. If no title exists at all, default to Figure number
        if isempty(title_str)
            title_str = sprintf('Figure_%02d', fig.Number);
        end
        
        % --- SANITIZE FILENAME ---
        % Fix common LaTeX terms in your specific titles
        safe_name = strrep(title_str, '\tau', 'tau');
        
        % Replace illegal Windows file characters (\ / : * ? " < > |) with an underscore
        safe_name = regexprep(safe_name, '[\\/*?:"<>|\[\]]', '_');
        
        % Replace spaces with underscores for a cleaner file name
        safe_name = regexprep(strtrim(safe_name), '\s+', '_');
        
        % Remove double underscores if any were created
        safe_name = regexprep(safe_name, '_+', '_');
        
        % Generate the final path
        filename_png = fullfile(export_folder, sprintf('%s.png', safe_name));
        
        % Save as a high-resolution PNG
        exportgraphics(fig, filename_png, 'Resolution', 300);
        
        fprintf('  -> Saved: %s.png\n', safe_name);
    end
    
    fprintf('All figures exported successfully.\n');
end