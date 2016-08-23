function [aaC, aabcgC, dataC]=plotfit_GUI(haxes, val, peakno, logplot)
%% plotting of indiv peaks
%% THS 2016 dppa

%% select peak index in fitting

hold(haxes, 'off')
load([cd,'/0. variables/phases.mat'],'dsettings')
datorI=getDPPApref('datainstr');
bcg2peak = getDPPApref('bcg2peak');

if val==2 && strcmp(datorI,'Sampl')
    peakno=length(dsettings(1,1).d)+peakno;
end

if strcmp(datorI,'Sampl')%%data
    load([cd,'/0. variables/fit.mat'],'aa','aabcg')
    load([cd,'/0. variables/data.mat'],'data')
    
   
    if logplot==1
        semilogy(data(:,1),data(:,2),'.','color','b','parent',haxes),
        
    else
        plot(data(:,1),data(:,2),'.','color','b','parent',haxes),
           
    end
       
    hold(haxes, 'on')
    
    IIfit=pv_tv_aa(aa(:,:),data(:, 1)) + pv_tv_aa([aabcg(:,peakno);0;0],data(:, 1)) ;
    plot(data(:,1),IIfit,'m','linewidth',4,'linestyle','-',...
    'parent',haxes)

    pp=1:1:size(aa,2)-1;np=pp(pp~=peakno);
    lam0=aa;lam0(:,np)=zeros(size(aa,1),length(np));
    IIfit=pv_tv_aa(lam0(:,:),data(:, 1)) + pv_tv_aa([aabcg(:,peakno);0;0],data(:, 1)) ;
    plot(data(:,1),IIfit,'c','linewidth',2,'linestyle','-',...
    'parent',haxes)

    lam0=aa;lam0(:,peakno)=zeros(size(aa(:,1)));
    IIfit=+ pv_tv_aa(lam0,data(:, 1))+ pv_tv_aa([aabcg(:,peakno);0;0],data(:, 1)) ;
    plot(data(:,1),IIfit,'g','parent',haxes)
    
    
    plot(data(:,1),data(:,2),'.','color','b','parent',haxes),
           
   


%     IIfit= data(:,2) - pv_tv_aa(lam0,data(:, 1));%- pv_tv_aa([aabcg(:,peakno);0;0],data(:, 1)) ;
%     plot(data(:,1),IIfit,'k','parent',haxes)

    if logplot~=1
        IIfit=pv_tv_aa(aa(:,:),data(:, 1))+pv_tv_aa([aabcg(:,peakno);0;0],data(:, 1)) ;
        plot(data(:,1),data(:,2)-IIfit,'-r.','parent',haxes)
        plot(data(:,1),data(:,2)*0,'k:','parent',haxes)
    end
    
    
elseif strcmp(datorI,'Instr')
%%  instrumental
    load([cd,'/0. variables/fit_I.mat'],'aa_I','aabcg_I')
    load([cd,'/0. variables/data_I.mat'],'data_I')
    hold(haxes, 'off')
    
   
    if logplot==1
        semilogy(data_I(:,1),data_I(:,2),'.',...
            'parent',haxes),
        hold(haxes, 'on')
    else
        plot(data_I(:,1),data_I(:,2),'.',...
            'parent',haxes),
        hold(haxes, 'on')   
    end
        
            IIfit=pv_tv_aa(aa_I(:,:),data_I(:, 1))+pv_tv_aa([aabcg_I(:,peakno);0;0],data_I(:, 1)) ;
            
            plot(data_I(:,1),IIfit,'m',...
                'parent',haxes)
            lam0=aa_I;lam0(:,peakno)=zeros(size(aa_I(:,1)));
            IIfit=+ pv_tv_aa(lam0,data_I(:, 1))+ pv_tv_aa([aabcg_I(:,peakno);0;0],data_I(:, 1)) ;
            
            plot(data_I(:,1),IIfit,'g',...
                'parent',haxes)
%             IIfit=pv_tv_aa(aa(:,:),data(:, 1))+pv_tv_aa([aabcg(:,peakno);0;0],data(:, 1)) ;
%             plot(data(:,1),IIfit,'m')
            IIfit= data_I(:,2) - pv_tv_aa(lam0,data_I(:, 1));%- pv_tv_aa([aabcg(:,peakno);0;0],data(:, 1)) ;
%             plot(data_I(:,1),IIfit,'k')
            if logplot~=1
            IIfit=pv_tv_aa(aa_I(:,:),data_I(:, 1))+pv_tv_aa([aabcg_I(:,peakno);0;0],data_I(:, 1)) ;
            
            plot(data_I(:,1),data_I(:,2)-IIfit,'-r.',...
                'parent',haxes)
            end
            

end

%% update GUI and focus on the one peak
if strcmp(datorI,'Sampl')
    aaC=aa;
    aabcgC=aabcg;
    dataC=data;
elseif strcmp(datorI,'Instr')
    aaC=aa_I;
    aabcgC=aabcg_I;
    dataC=data_I;
end


if aaC(1,peakno)~=0
%         axes(handles.axes1)
    adjtth=abs( dataC(:,1)-aaC(1,peakno) +bcg2peak);
    peak_posmin=find(adjtth==min(adjtth));
    adjtth=abs( dataC(:,1)-aaC(1,peakno) -bcg2peak);
    peak_posmax=find(adjtth==min(adjtth));
    if logplot==1
        xlim(haxes,[aaC(1,peakno)-bcg2peak aaC(1,peakno)+bcg2peak])
        ylim(haxes,[min(dataC(peak_posmin:peak_posmax,2))*0.9 max(dataC(peak_posmin:peak_posmax,2))*1.1])

    else
        
        xlim(haxes,[aaC(1,peakno)-bcg2peak aaC(1,peakno)+bcg2peak])
    end
%         ylim([min(data(peak_posmin:peak_posmax,2))*0.9 max(data(peak_posmin:peak_posmax,2))*1.1])

end
grid(haxes,'on')
legend(haxes,'Raw data','Fit of all','Fit of peak','Fit of rest')%,'Data to use')
xlabel(haxes,'1/d (10^-^1^0 m^-^1)','fontsize',18)
ylabel(haxes,'Intensity','fontsize',18)
set(haxes,'fontsize',16)
end