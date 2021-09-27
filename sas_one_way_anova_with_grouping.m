function out = sas_one_way_anova_with_grouping(varargin)

% Parse params
p = inputParser;
addOptional(p,'excel_file_string','');
addOptional(p,'excel_sheet','Sheet1');
addOptional(p,'factor_1','');
addOptional(p,'grouping','tag');
addOptional(p,'test_variable','');
addOptional(p,'results_file_string','');
addOptional(p,'results_type','html');
addOptional(p,'calling_path_string','');
addOptional(p,'tidy_low_concentrations_in_SAS',0);

parse(p,varargin{:});

% Test type
test_type = 'one_way_with_grouping';

% Code

% Deduce the calling function to help with paths
if (isempty(p.Results.calling_path_string))
    st=dbstack('-completenames');
    calling_function=st(2).file;
    calling_path_string=fileparts(calling_function);
else
    calling_path_string = p.Results.calling_path_string;
end

% Code
out = run_sas_model( ...
    'excel_file_string',p.Results.excel_file_string, ...
    'excel_sheet',p.Results.excel_sheet, ...
    'test_type',test_type, ...
    'factor_1',p.Results.factor_1, ...
    'grouping',p.Results.grouping, ...
    'test_variable',p.Results.test_variable, ...
    'results_file_string',p.Results.results_file_string, ...
    'results_type',p.Results.results_type, ...
    'calling_path_string',calling_path_string);

if (p.Results.tidy_low_concentrations_in_SAS)
    tidy_low_concentrations_in_SAS_output( ...
        sprintf('%s.%s', ...
            p.Results.results_file_string, ...
            p.Results.results_type));
end

% Scrape html for p values
if (strcmp(p.Results.results_type,'html'))
    
    % First get main effects
    tag_string = 'Type III Tests of Fixed Effects';
    table_strings = pull_table_strings_from_html( ...
        out.results_file_string,tag_string,11);
    
    out.p_table.tests{1}=table_strings{7};
    out.p_table.p(1) = convert_p_string_to_number(table_strings{11});
    
    % Pull post-hoc tests

    % Look for factor_1 entries
    d = read_structure_from_excel( ...
            'filename',p.Results.excel_file_string, ...
            'sheet',p.Results.excel_sheet, ...
            'treat_NaNs_as_strings',1);
    f1_strings = unique(d.(p.Results.factor_1))
    
    counter=numel(out.p_table.tests);
    tag_string = sprintf('Adjustment for Multiple Comparisons');
    temp_strings = pull_table_strings_from_html( ...
        out.results_file_string,tag_string, ...
            8+8*nchoosek(numel(f1_strings),2));
    for f1=1:nchoosek(numel(f1_strings),2)
        counter=counter+1;
        out.p_table.tests{counter} = sprintf('%s %s', ...
            temp_strings{9+(f1-1)*8},temp_strings{10+(f1-1)*8});
        out.p_table.p(counter) = ...
            convert_p_string_to_number(temp_strings{16+(f1-1)*8});
    end
   
    % Transpose structure
    out.p_table.tests = out.p_table.tests';
    out.p_table.p = out.p_table.p';
    out.p_table = struct2table(out.p_table);
    out.f1_strings = f1_strings;
end
