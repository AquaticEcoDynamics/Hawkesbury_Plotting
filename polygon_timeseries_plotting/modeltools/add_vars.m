clear all; close all;

load hawkesbury_all.mat;

[snum,sstr] = xlsread('WQ Module Variable Names.xlsx','A2:C16');

aedname = sstr(:,1);
newname = sstr(:,2);
conv = snum(:,1);

sites = fieldnames(hawkesbury_all);

for i = 1:length(newname)
    for j = 1:length(sites)
        vars = fieldnames(hawkesbury_all.(sites{j}));
        
        for k = 1:length(vars)
           sss = find(strcmpi(aedname,vars{k}) == 1);
           if ~isempty(sss)
               disp(newname{sss});
               hawkesbury_all.(sites{j}).(newname{sss}) = hawkesbury_all.(sites{j}).(aedname{sss});
               hawkesbury_all.(sites{j}).(newname{sss}).Data = hawkesbury_all.(sites{j}).(newname{sss}).Data * conv(sss);
           end
        end
    end
end

[snum,sstr] = xlsread('WQ Module Variable Names.xlsx','D2:F16');

aedname = sstr(:,1);
newname = sstr(:,2);
conv = snum(:,1);

sites = fieldnames(hawkesbury_all);

for i = 1:length(newname)
    for j = 1:length(sites)
        vars = fieldnames(hawkesbury_all.(sites{j}));
        
        for k = 1:length(vars)
           sss = find(strcmpi(aedname,vars{k}) == 1);
           if ~isempty(sss)
               disp(newname{sss});
               hawkesbury_all.(sites{j}).(newname{sss}) = hawkesbury_all.(sites{j}).(aedname{sss});
               hawkesbury_all.(sites{j}).(newname{sss}).Data = hawkesbury_all.(sites{j}).(newname{sss}).Data * conv(sss);
           end
        end
    end
end

save('hawkesbury_all.mat','hawkesbury_all','-mat');
        