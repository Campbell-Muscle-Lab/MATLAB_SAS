function out = run_sas_model(varargin);

default_sas_file_string = 'sas_code\sas_code.sas';
default_sas_command_line = ...
    '"c:\program files\sashome\sasfoundation\9.4\sas.exe"';

p = inputParser;
addOptional(p,'excel_file_string','');
addOptional(p,'excel_sheet','Sheet1');
addOptional(p,'test_type','');
addOptional(p,'test_variable','');
addOptional(p,'factor_1','factor_1');
addOptional(p,'factor_2','factor_2');
addOptional(p,'grouping','tag');
addOptional(p,'results_file_string','');
addOptional(p,'results_type','pdf');
addOptional(p,'sas_file_string',default_sas_file_string);
addOptional(p,'sas_command_line',default_sas_command_line);
addOptional(p,'calling_path_string','');

parse(p,varargin{:});

% Code
switch p.Results.test_type
    case 'one_way_with_grouping'
        sas_template_file_string = ...
            'templates\sas_template_one_way_with_grouping.sas';
    case 'two_way_with_grouping'
        sas_template_file_string = ...
            'templates\sas_template_two_way_with_grouping.sas';
    case 'two_way_without_grouping'
        sas_template_file_string = ...
            'templates\sas_template_two_way_without_grouping.sas';
    otherwise
        sas_template_file_string = '';
end

% Now set some file names
% Try to cope with relative paths
temp_string=p.Results.excel_file_string;
if (temp_string(2)~=':')
    excel_file_string = fullfile(p.Results.calling_path_string, ...
                        p.Results.excel_file_string);
else
    excel_file_string = p.Results.excel_file_string;
end

temp_string = p.Results.results_file_string;
if (temp_string(2)~=':')
    results_file_string = fullfile(p.Results.calling_path_string, ...
            sprintf('%s.%s', ...
                p.Results.results_file_string,p.Results.results_type));
else
    results_file_string = sprintf('%s.%s', ...
        p.Results.results_file_string,p.Results.results_type);
end

switch p.Results.results_type
    case 'pdf'
        sas_ods_string_1 = sprintf( ...
            'ods pdf file="%s";',results_file_string);
        sas_ods_string_2 = sprintf('ods pdf close;');
    case 'html'
        sas_ods_string_1 = sprintf( ...
            'ods html file="%s";',results_file_string);
        sas_ods_string_2 = sprintf('ods html close;');
end

% Load file and replace

% Get the path to the templates
temp_string = mfilename('fullpath');
dir_string = fileparts(temp_string);

sas_template_file_string = fullfile(dir_string,sas_template_file_string);

in_file = fopen(sas_template_file_string,'r');
sas_text = char(fread(in_file))';
fclose(in_file);

sas_text = strrep(sas_text,'#excel_file_string', ...
            excel_file_string);
sas_text = strrep(sas_text,'#excel_sheet', ...
            p.Results.excel_sheet);
sas_text = strrep(sas_text,'#results_file_string', ...
            p.Results.results_file_string);
sas_text = strrep(sas_text,'#test_variable', ...
            p.Results.test_variable);
sas_text = strrep(sas_text,'#factor_1', ...        
            p.Results.factor_1);
sas_text = strrep(sas_text,'#factor_2', ...        
            p.Results.factor_2);
sas_text = strrep(sas_text,'#grouping', ...        
            p.Results.grouping);
sas_text = strrep(sas_text,'#ods_string_1',sas_ods_string_1);
sas_text = strrep(sas_text,'#ods_string_2',sas_ods_string_2);    
        
% Output

% Create the sas code in the directory of the function
% that called this m file
sas_file_string = fullfile(p.Results.calling_path_string, ...
    p.Results.sas_file_string)

% Open the sas file for writing
out_file = fopen(sas_file_string,'w');
fprintf(out_file,'%s',sas_text);
fclose(out_file);

% Construct a command line
command_string = p.Results.sas_command_line;
command_string = sprintf('%s -sysin %s',command_string,sas_file_string);

% Run command
[status,cmdout] = system(command_string);
disp(sprintf('Results written to %s',results_file_string));

% Store results
out.sas_file_string = sas_file_string;
out.results_file_string = results_file_string;


