function p = convert_p_string_to_number(str)
    if (strcmp(str,'.'))
        p=NaN;
        return;
    end
    if (strcmp(str(1:4),'&lt;'))
        str=str(5:end);
    end
    p=str2num(str);
end