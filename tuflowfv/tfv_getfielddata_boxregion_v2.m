function [fielddata,fielddist,fielddata_all,fielddist_all] = tfv_getfielddata_boxregion(fdata,shp,shp2,def,isSurf,varname,mtime,isSpherical)

%Convert from km to m
binRad = def.binradius * 1000;

distRad = binRad;



% Convert Radius for spherical

if isSpherical
    binRad = binRad/111111;
end

% dusplicated processing in model data bit. Should be replaced.
for i = 1:length(shp)
    sdata(i,1) = shp(i).X;
    sdata(i,2) = shp(i).Y;
end

for i = 1:length(shp2)
    sdata2(i,1) = shp2(i).X;
    sdata2(i,2) = shp2(i).Y;
end

dtri = DelaunayTri(double(sdata2(:,1)),double(sdata2(:,2)));






dist(1,1) = 0;

for i = 2:length(shp)
    
    dist(i,1) = sqrt(power((sdata(i,1) - sdata(i-1,1)),2) + power((sdata(i,2)- sdata(i-1,2)),2)) + dist(i-1,1);

    
    
end

dist2(1,1) = 0;

for i = 2:length(shp2)
    
    dist2(i,1) = sqrt(power((sdata2(i,1) - sdata2(i-1,1)),2) + power((sdata2(i,2)- sdata2(i-1,2)),2)) + dist2(i-1,1);

end
dist2 = dist2 / 1000; % convert to km


if isSpherical
   dist = dist * 111111;
end

dist = dist / 1000; % convert to km


maxdist = max(dist2);
mindist = 0;

thePolygons = [mindist:(def.binradius)*2:maxdist];


for i = 1:length(thePolygons)
    
    [~,ind] = min(abs(dist2 - thePolygons(i)));
    
    T = nsidedpoly(360,'Center',[shp2(ind).X shp2(ind).Y],'Radius',binRad);
    
    pol(i).X = T.Vertices(:,1);
    pol(i).Y = T.Vertices(:,2);
    pol(i).Dist = dist2(ind);
    pol(i).Geometry = 'Polygon';
end



sites = fieldnames(fdata);




fielddata = [];
fielddist = [];
fielddata_all = [];
fielddist_all = [];

for j = 1:length(pol)
    
    for i = 1:length(sites)
        
        if isfield(fdata.(sites{i}),varname)
            
            fX = fdata.(sites{i}).(varname).X;
            fY = fdata.(sites{i}).(varname).Y;
            
            fDat = fdata.(sites{i}).(varname).Data;
            fDate = fdata.(sites{i}).(varname).Date;
            fDepth = fdata.(sites{i}).(varname).Depth;
            
            
            
            if inpolygon(fX,fY,pol(j).X,pol(j).Y)
                
                query_points(:,1) = fX;
                query_points(:,2) = fY;
                
                pt_id = nearestNeighbor(dtri,query_points);

                
                cdata = [];
                cdist = [];
                
                sss = find(fDate >= mtime(1) & fDate <= mtime(2));
                
                if ~isempty(sss)
                    

                    
                    if isSurf
                        ttt = find(fDepth(sss) >= -2);
                    else
                        ttt = find(fDepth(sss) < -2);
                    end
                    
                    if isSurf
                        ggg = find(fDepth >= -2);
                    else
                        ggg = find(fDepth < -2);
                    end                    
                    disp(['Adding: ',num2str(length(ttt)),' from: ',sites{i}]);
                    
                    cdata = tfv_Unit_Conversion(fDat(sss(ttt)),varname);
                    cdata_all = tfv_Unit_Conversion(fDat(ggg),varname);
                    
                    
                    cdist(1:length(ttt),1) = dist2(pt_id);%(pol(j).Dist;
                    cdist_all(1:length(ggg),1) = dist2(pt_id);%pol(j).Dist;
                    
                    
                    fielddata = [fielddata;cdata];
                    fielddist = [fielddist;cdist];clear cdist
                    
                    fielddata_all = [fielddata_all;cdata_all];
                    fielddist_all = [fielddist_all;cdist_all];clear cdist_all
                    
                end
            end
        end
    end
end   
    
if def.export_shapefile
    sites = fieldnames(fdata);
    for i = 1:length(sites)
        vars = fieldnames(fdata.(sites{i}));
        S(i).X = fdata.(sites{i}).(vars{1}).X; 
        S(i).Y = fdata.(sites{i}).(vars{1}).Y;
        S(i).Name = sites{i};
        S(i).Geometry = 'Point';
    end
    
    shapewrite(pol,'fieldpolygons.shp');
    shapewrite(S,'fieldsites.shp');
end    
