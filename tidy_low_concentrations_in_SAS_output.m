function tidy_low_concentrations_in_SAS_output(file_string);

temp_file_string = 'temp.html';

in_file = fopen(file_string,'r');
out_file = fopen(temp_file_string,'w');
while ~feof(in_file)
    lin = fgetl(in_file);
    lin = strrep(lin,'1E-8','1e-08');
    lin = strrep(lin,'9.9999999999999995E-7','1e-06');
    lin = strrep(lin,'9.9999999999999995E-8','1e-07');
    fprintf(out_file,'%s\n',lin);
end
fclose(in_file);
fclose(out_file);
copyfile(temp_file_string,file_string);
delete(temp_file_string);
