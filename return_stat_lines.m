function statistical_lines = return_stat_lines( ...
    mode_string,p_table,main_label,sub_label,main_strings,sub_strings, ...
    y_ticks,y_spacing)

switch mode_string
    case '2way_LMM_with_grouping'
        n_main_effects = 3;
    case '2way_LMM_without_grouping'
        n_main_effects = 3;
    case 'one_way_ANOVA_with_grouping'
        n_main_effects = 1;
    otherwise
        error(sprintf('return_stat_lines does not work with: %s',mode_string));
end

% Variables
p_threshold = 0.05;
min_p_string = '0.001';
if (nargin<8)
    y_spacing = 0.1;
end

% Code

statistical_lines=[];

p_values = p_table.p(n_main_effects+1:end);
p_strings = p_table.tests(n_main_effects+1:end);

vi = find(p_values<p_threshold);

n_m = numel(main_strings);

switch mode_string
    case '2way_LMM_with_grouping'
        n_s = numel(sub_strings);
        
        if (numel(y_spacing)==1)
            y_spacing = y_spacing*[1:numel(vi)];
        end

        for i=1:length(vi)
            line_string = p_strings{vi(i)};
            temp_strings = textscan(line_string,'%s');
            temp_strings = temp_strings{:};
            
            sub_label = sub_label;
            
            if (strcmp(temp_strings{1},sub_label))
                mg1 = find(strcmp(main_strings,temp_strings{3}));
                mg2 = find(strcmp(main_strings,temp_strings{4}));

                sg1 = find(strcmp(sub_strings,temp_strings{2}));
                sg2 = sg1;
            else
                mg1 = find(strcmp(main_strings,temp_strings{2}));
                mg2 = mg1;

                sg1 = find(strcmp(sub_strings,temp_strings{3}));
                sg2 = find(strcmp(sub_strings,temp_strings{4}));
            end

            x1 = (mg1-1)*n_s + sg1;
            if (mg1>1)
                x1 = x1 + (mg1-1);
            end
            x2 = (mg2-1)*n_s + sg2;
            if (mg2>1)
                x2 = x2 + (mg2-1);
            end
            
            y=y_ticks(end)+(y_spacing(i)*(y_ticks(end)-y_ticks(1)));

            if (p_values(vi(i))<str2num(min_p_string))
                temp_string = sprintf('p < %s',min_p_string);
            else
                temp_string = sprintf('p = %.3f',p_values(vi(i)));
            end

            statistical_lines(i).data = {x1 x2 temp_string y 0};
        end
        
    case '2way_LMM_without_grouping'
        n_s = numel(sub_strings);

        for i=1:length(vi)
            line_string = p_strings{vi(i)};
            temp_strings = textscan(line_string,'%s');
            temp_strings = temp_strings{:};
            
            if (strcmp(temp_strings{1},sub_label))
                mg1 = find(strcmp(main_strings,temp_strings{3}));
                mg2 = find(strcmp(main_strings,temp_strings{4}));

                sg1 = find(strcmp(sub_strings,temp_strings{2}));
                sg2 = sg1;
            else
                mg1 = find(strcmp(main_strings,temp_strings{2}));
                mg2 = mg1;

                sg1 = find(strcmp(sub_strings,temp_strings{3}));
                sg2 = find(strcmp(sub_strings,temp_strings{4}));
            end


            x1 = (mg1-1)*n_s + sg1;
            if (mg1>1)
                x1 = x1 + (mg1-1);
            end
            x2 = (mg2-1)*n_s + sg2;
            if (mg2>1)
                x2 = x2 + (mg2-1);
            end

            y=y_ticks(end)+(i*y_spacing*(y_ticks(end)-y_ticks(1)));

            if (p_values(vi(i))<str2num(min_p_string))
                temp_string = sprintf('p < %s',min_p_string);
            else
                temp_string = sprintf('p = %.3f',p_values(vi(i)));
            end

            statistical_lines(i).data = {x1 x2 temp_string y 0};
        end        

    case 'one_way_ANOVA_with_grouping'
        
        for i=1:length(vi)
            line_string = p_strings{vi(i)};
            temp_strings = textscan(line_string,'%s');
            temp_strings = temp_strings{:};
            
            x1 = find(strcmp(sub_strings,temp_strings{1}));
            x2 = find(strcmp(sub_strings,temp_strings{2}));
            
            y = y_ticks(end) + (i*y_spacing*(y_ticks(end)-y_ticks(1)));
            
            if (p_values(vi(i))<str2num(min_p_string))
                temp_string = sprintf('p < %s',min_p_string);
            else
                temp_string = sprintf('p = %.3f',p_values(vi(i)));
            end
            
            statistical_lines(i).data = {x1 x2 temp_string y 0};
        end
        
    otherwise
end
            