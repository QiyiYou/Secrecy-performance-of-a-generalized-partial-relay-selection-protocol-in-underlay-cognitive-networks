% This code describe the PRS_RF with SOP
function NSC_CSI_PRS_SIM(IdB,MM,NN,PP,KK,xR,xP,yP,xE,yE,PL,bit_frame)
II              = 10.^(IdB/10);
NSC             = zeros(1,length(KK));
%
for aa = 1 : length(KK)
    fprintf('Running %d per %d \n',aa,length(KK));
    LSR         = xR^PL;
    LSP         = sqrt(xP^2+yP^2)^PL;
    LSE         = sqrt(xE^2+yE^2)^PL;
    LRD         = (1-xR)^PL;
    LRP         = sqrt((xR-xP)^2+yP^2)^PL;
    LRE         = sqrt((xR-xE)^2+yE^2)^PL;
    for bitnum   =  1 : bit_frame
        %                
        SNR_SR = zeros(1,MM);
        for bb = 1 : MM
            h_SR       = sqrt(1/LSR/2)*(randn(1,1)+j*randn(1,1));
            SNR_SR(bb) = abs(h_SR)^2;
        end
        %
        SNR_SR_sort = sort(SNR_SR,'descend');
        Set_Relay   = [];
        for bb = 1 : KK(aa)
            id         = find(SNR_SR == SNR_SR_sort(bb));
            Set_Relay  = [Set_Relay id];
        end
        %
        CC2_max = 0;
        for bb = 1 : KK(aa)
            h_RD       = sqrt(1/LRD/2)*(randn(1,1)+j*randn(1,1));
            SNR_RD     = abs(h_RD)^2;
            % Transmit power of relays
            SNR_RP_max = 0;
            for cc = 1 : PP
                h_RP       = sqrt(1/LRP/2)*(randn(1,1)+j*randn(1,1));
                if (abs(h_RP)^2 > SNR_RP_max)
                    SNR_RP_max  = abs(h_RP)^2;
                end
            end
            QR         = II/SNR_RP_max;
            %
            SNR_RE_max = 0;
            for cc = 1 : NN
                h_RE       = sqrt(1/LRE/2)*(randn(1,1)+j*randn(1,1));
                if (abs(h_RE)^2 > SNR_RE_max)
                    SNR_RE_max  = abs(h_RE)^2;
                end
            end
            CC2        = max(0, 1/2*log2(1 + QR*SNR_RD) - 1/2*log2(1 + QR*SNR_RE_max) );
            if (CC2 >= CC2_max)
                CC2_max = CC2;
                bid = Set_Relay(bb);
            end            
        end
        %
        SNR_SP_max = 0;
        for bb = 1 : PP
            h_SP       = sqrt(1/LSP/2)*(randn(1,1)+j*randn(1,1));
            if (abs(h_SP)^2 > SNR_SP_max)
                SNR_SP_max  = abs(h_SP)^2;
            end
        end
        QS         = II/SNR_SP_max;
        %
        SNR_SE_max = 0;
        for bb = 1 : NN
            h_SE       = sqrt(1/LSE/2)*(randn(1,1)+j*randn(1,1));
            if (abs(h_SE)^2 > SNR_SE_max)
                SNR_SE_max  = abs(h_SE)^2;
            end
        end
        %
        CC1    = max(0, 1/2*log2(1 + QS*SNR_SR(bid)) - 1/2*log2(1 + QS*SNR_SE_max) );        
        % Secrecy Capacity
        CSEC   = min(CC1,CC2_max);
        %
        if (CSEC  > 0)
            NSC(aa) = NSC(aa) + 1;
        end
    end
end
%
NSC = NSC./bit_frame;
NSC
plot(KK,NSC,'rs'); grid on;hold on;
end









