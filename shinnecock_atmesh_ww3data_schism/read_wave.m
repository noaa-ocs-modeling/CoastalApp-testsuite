
close all; clear all;
nodeout=101;

  ncid0 = netcdf.open('ww3.Constant.20151214_sxy_ike_date.nc','NC_NOWRITE');
  vid=netcdf.inqVarID(ncid0,'time'); %input var./array name
  time2= double(netcdf.getVar(ncid0, vid));
  timeout=time2+datenum(1982,9,11)-datenum(2008,8,23);

  vid=netcdf.inqVarID(ncid0,'longitude'); %(np)
  lon= double(netcdf.getVar(ncid0, vid));
  vid=netcdf.inqVarID(ncid0,'latitude');
  lat= double(netcdf.getVar(ncid0, vid));

  vid=netcdf.inqVarID(ncid0,'sxx'); %(np,ntime)
  sxx= double(netcdf.getVar(ncid0, vid));
  vid=netcdf.inqVarID(ncid0,'syy'); %(np,ntime)
  syy= double(netcdf.getVar(ncid0, vid));
  vid=netcdf.inqVarID(ncid0,'sxy'); %(np,ntime)
  sxy= double(netcdf.getVar(ncid0, vid));

  plot(timeout,sxx(nodeout,:),'k',timeout,syy(nodeout,:),'r',timeout,sxy(nodeout,:),'g');
  legend('SXX','SYY','SXY');

  format long;
  [lon(nodeout) lat(nodeout)]
  fid=fopen('SXXYY_from_input.dat','w');
  fprintf(fid,'%f %f %f %f\n',[timeout sxx(nodeout,:)' syy(nodeout,:)' sxy(nodeout,:)']');
  fclose(fid);
