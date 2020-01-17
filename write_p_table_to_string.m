function p_string = write_p_table_to_string(t);

min_p_string = '0.001';

r = numel(t.tests);
p_string = '';
for i=1:r
    if (t.p(i)<str2num(min_p_string))
        p_string = sprintf('%s%s, p < %s', ...
            p_string,t.tests{i},min_p_string);
    else
        p_string = sprintf('%s%s, p = %.3f', ...
            p_string,t.tests{i},t.p(i));
    end
    p_string = sprintf('%s\n',p_string);
end
