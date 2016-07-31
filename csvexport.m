function csvexport(name,data_struc, points)

    if exist('points','var')
        csvwrite(name,[data_struc.ideal,data_struc.actual, [1:length(data_struc.ideal)]',points]);
    else
        csvwrite(name,[data_struc.ideal,data_struc.actual, [1:length(data_struc.ideal)]']);
    end

end