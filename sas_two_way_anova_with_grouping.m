function out = sas_two_way_anova_with_grouping(varargin)

% Parse params
p = inputParser;
addOptional(p,'excel_file_string','');
addOptional(p,'excel_sheet','Sheet1');
addOptional(p,'factor_1','');
addOptional(p,'factor_2','');
addOptional(p,'grouping','tag');
addOptional(p,'test_variable','');
addOptional(p,'results_file_string','');
addOptional(p,'results_type','html');
addOptional(p,'treat_f2_numbers_as_strings',1);
addOptional(p,'f2_numbers_as_strings_decimal_places',8);
addOptional(p,'calling_path_string','');
addOptional(p,'tidy_low_concentrations_in_SAS',0);

parse(p,varargin{:});

% Test type
test_type = 'two_way_with_grouping';

% Code

% Deduce the calling function to help with paths
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
        'factor_2',p.Results.factor_2, ...
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
        out.results_file_string,tag_string,21);
    
    out.p_table.tests{1}=table_strings{7};
    out.p_table.p(1)=convert_p_string_to_number(table_strings{11});
    
    out.p_table.tests{2}=table_strings{12};
    out.p_table.p(2)=convert_p_string_to_number(table_strings{16});
    
    out.p_table.tests{3}=table_strings{17};
    out.p_table.p(3)=convert_p_string_to_number(table_strings{21});
    
    % Pull post-hoc tests
       
    % First look for factor_1 and factor_2 entries
    d = read_structure_from_excel( ...
            'filename',p.Results.excel_file_string, ...
            'sheet',p.Results.excel_sheet, ...
            'debug_mode',1);
    f1_strings = unique(d.(p.Results.factor_1))
    f2_strings = unique(d.(p.Results.factor_2));
    if (p.Results.treat_f2_numbers_as_strings)
        if (isnumeric(f2_strings))
            for i=1:numel(f2_strings)
                switch f2_strings(i)
                    case 1e-8
                        temp{i}='1E-8';
                    case 1e-7
                        temp{i}='1E-7';
                    case 1e-6
                        temp{i}='1E-6';
                    case 1e-5
                        temp{i}='0.00001';
                    case 5e-5
                        temp{i}='0.00005';
                    otherwise
                        format_string = sprintf('%%.%.0ff', ...
                            p.Results.f2_numbers_as_strings_decimal_places);
                        temp{i}=sprintf(format_string,f2_strings(i));
                end
            end
            f2_strings = temp
        end
    end
    
    counter=numel(out.p_table.tests);
    for f1=1:numel(f1_strings)
        tag_string = sprintf('%s %s',p.Results.factor_1,f1_strings{f1});
        temp_strings = pull_table_strings_from_html( ...
            out.results_file_string,tag_string, ...
                [8 nchoosek(numel(f2_strings),2)]);
        for f2=1:nchoosek(numel(f2_strings),2)
            counter=counter+1;
            out.p_table.tests{counter} = sprintf('%s %s %s %s', ...
                p.Results.factor_1,f1_strings{f1}, ...
                temp_strings{f2,1},temp_strings{f2,2});
            out.p_table.p(counter) = convert_p_string_to_number( ...
                                        temp_strings{f2,8});
        end
    end
    
    counter=numel(out.p_table.tests);
    for f2=1:numel(f2_strings)
        tag_string = sprintf('%s %s',p.Results.factor_2,f2_strings{f2});
        temp_strings = pull_table_strings_from_html( ...
            out.results_file_string,tag_string, ...
            [8 nchoosek(numel(f1_strings),2)]);
        for f1=1:nchoosek(numel(f1_strings),2)
            counter=counter+1;
            out.p_table.tests{counter} = sprintf('%s %s %s %s', ...
                p.Results.factor_2,f2_strings{f2}, ...
                temp_strings{f1,1},temp_strings{f1,2});
            out.p_table.p(counter) = convert_p_string_to_number( ...
                                        temp_strings{f1,8});
        end
    end
    
    % Transpose structure
    out.p_table.tests = out.p_table.tests';
    out.p_table.p = out.p_table.p';
    out.p_table = struct2table(out.p_table);
end
