function loadb_GUI(handles, dataorInstr)
%% load data files for dippa

mnu = menu('Choose data to load:','2-Theta','1/d');

inner(handles, mnu, dataorInstr)

end

function inner(handles, mnu, dataorInstr)

haxes = handles.axes1;
    data=[];
    %find file location
    [file,  path] = uigetfile({'*.dat';'*.asc';'*.UDF';'*.udf';'*.txt';'*.xy'},'Select File to open')

    %% for udfs
    if strcmp(file(end-2:end),'udf')  || strcmp(file(end-2:end),'UDF')
        %convert udf to .dat
        if strcmp(file(end-2:end),'udf') 
            perl([cd,'/udfcon_lc.pl'],[path,file(1:end-4),'.udf']); 
        elseif strcmp(file(end-2:end),'UDF' )
            perl([cd,'/udfcon.pl'],[path,file(1:end-4),'.UDF']);
        end
        
        %and load the dat file
        filenomdat=[path,file(1:end-4),'.dat'];
        data=load(filenomdat);
    
        %get the info from the sample
        [tube, identa]=importfile([path,file]);
        
        %what type of tube
        if strcmp(tube,'Cu')==1  
            wavelen=0.5*(1.54056+1.54439);%%
        elseif strcmp(tube,'Co')==1
            wavelen= 0.5*(1.78897+ 1.79285);%%in Armstrongs
        end
        
        %update prefs
        
        setDPPApref('tube',tube)
        disp(['setting tube as',tube])
    
        %update GUI
        set(handles.alpha2_b,'value',1);
    
        %alpha 2 exists
        alpha2=0;
        setDPPApref('alpha2',alpha2)

        setDPPApref('wavelen',wavelen)
        
    elseif strcmp(file(end-2:end),'asc')  || strcmp(file(end-2:end),'ASC')
    %% if an ascii file
    
    %gets data from ascii
    fid=fopen([path, file]);
    tex = textscan(fid, '%q', 'delimiter', '\n');

    h=1;c=0;
    for n=1:size(tex{1});
        if strcmp(tex{1}{n}(1),'#')==0;
            if h==1;c=c+1;end;
            dat{c}(h,:)=str2num(char(tex{1}{n}));h=h+1;
        else h=1;
        end;
    end
    
    data=dat{1};
    
    %user input for type of tube
    wav=menu('Enter Wavelength in A:   ','Copper with alpha2','Cobalt with alpha2','(without alpha2) Enter value in Armstrongs:     ');
    switch wav
        case 1
            wavelen=0.5*(1.54056+1.54439);%%
            tube='Cu';alpha2=0;
            set(handles.alpha2_b,'value',1);
        case 2
            wavelen= 0.5*(1.78897+ 1.79285);%%in Armstrongs
            tube='Co';alpha2=0;
            set(handles.alpha2_b,'value',1);
        case 3
            wavelen= input('enter wavelength in A:  ');
            set(handles.alpha2_b,'value',0);
            alpha2=1;
            tube='None';
    end
    
    %update prefs
    setDPPApref('alpha2',alpha2)
    setDPPApref('tube',tube)
    setDPPApref('wavelen',wavelen)
        
    else
    %% not a udf or ascii
    wav=menu('Enter Wavelength in A:   ','Copper with alpha2','Cobalt with alpha2','(without alpha2) Enter value in Armstrongs:     ');
    switch wav
        case 1
            wavelen=0.5*(1.54056+1.54439);%%
            tube='Cu';alpha2=0;
            set(handles.alpha2_b,'value',1);
        case 2
            wavelen= 0.5*(1.78897+ 1.79285);%%in Armstrongs
            tube='Co';alpha2=0;
            set(handles.alpha2_b,'value',1);
        case 3
            wavelen= input('enter wavelength in A:  ');
            set(handles.alpha2_b,'value',0);
            alpha2=1;
            tube='None';
    end
    
    %update prefs
    setDPPApref('alpha2',alpha2)
    setDPPApref('tube',tube)
    setDPPApref('wavelen',wavelen)
%     
    if file(end-2:end)=='.xy'
        da=importdata([path,file]);
        data=da.data;
    else
        data=load([path,file]);
    end
    
    if size(data,2)>2
        val=input(['Select column(s) to use, of ',num2str(size(data,2)),'    ']);
        data(:,2)=sum(data(:,val),2)';data=data(:,1:2);
    else
    data=data(:,1:2);
    end
        
    identa=input('Enter Sample name:   ','s');
    end    
    

    

%% interpolate
val=mnu;

switch val
    case 2%1/d
        K = data(:,1); Kincr=.5e-04;
        rk=rem(K(1),Kincr);
        K1=K(1)-rk;K1=K1/Kincr;K1=int16(K1);K1=double(K1)*Kincr;
        rk=rem(K(end),Kincr);
        Kend=K(end)-rk; cc(:,1)=K1:Kincr:Kend;
        IK=interp1(K(:,1),data(:,2),cc(:,1),'PCHIP');
        data = [cc , IK];
    case 1%two-theta
        data=tsinterpl(data,wavelen);
end

hold(haxes,'off')
semilogy(data(:,1),data(:,2),'.','parent',haxes)
% set(handles.sampleid2_t,'string',identa)


set(handles.wav_t,'string',num2str(wavelen))
setDPPApref('identa',identa);
setDPPApref('alpha2',alpha2);       
setDPPApref('tube',tube);
setDPPApref('wavelen',wavelen);

if strcmp(dataorInstr,'Sampl')
    save([cd,'/0. variables/data.mat'],'data')

elseif strcmp(dataorInstr,'Instr')
    data_I = data;
    save([cd,'/0. variables/data_I.mat'],'data_I')

end



end
