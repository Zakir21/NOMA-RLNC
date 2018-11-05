%Before any simulation, please use
clear all; close all;clc

%set used SNR values (SNR =Eb/No) values in decibels
SNR=[0:1:14]'; %column vector
%SNR in linear scale
snr=10.^(SNR/10); 
%we create initial zero vectors for BER
BER1=zeros(length(SNR),1);
BER2=BER1;
BER3=BER1;
%Monte Carlo loop starts here
%some initial values
%totally Nmax symbols
Nmax=1000; %maximum number of iterations
Nerr=100; %minimum number of errors
for k=1:length(SNR), %we do MC trials for each SNR
for l=1:Nmax, %MC loop 
%DATA
%we create data as vectors of length Ns symbols and thus use MATLAB's %vector processing capabilities in addition to for loops (since too long vectors %are problems to some versions of MATLAB)
Ns=100;
data=2*round(rand(Ns,1))-1;
%data is random and generated again and again for each MC trial
%totally Ns * Nmax symbols, if 100*1000 = 100 000
%results rather reliable down to 1e-4  
%plot data
if l==1 & k==1 %we plot/see things only once, at the first round
plot(data);title('donnes');axis([0 Ns -1.1 1.1]);
pause
end 
%MODULATION
%BPSK signal
bpsk=data;

%-------------------------------------------------
%CHANNELS
%This is the place to set SNR.
%Since symbol energy is 1 and noise variance is 1,
%SNR of symbol/noise sample is 0 dB.
%Thus, we have to multiply symbol or divide noise to obtain desired SNR.
%Since snr is power variable we have to multiply/divide by
%sqrt(snr) to have amplitude coefficient.
%------------------------------------------------
%noise gereration for BPSK
n=1/sqrt(2)*(randn(Ns,1)+j*randn(Ns,1));
%Since complex noise is generated by two real noise sequences the
%total variance is 2 x variance of one sequence (now 1). If we multiply
%by 1/sqrt(2) the total variance of noise becomes 1.
%This is two sided noise spectral density No in BER equations. 

%we check this
if l==1 & k==1
var_n=norm(n)^2;
end
%This should be Ns since we sum Ns variables. Since n is a realization of a random process, the result is not exact. Average of repeated trials gives more exact result. 

%AWGN BPSK
Bpsk=sqrt(snr(k))*data+n; %snr is Eb/N0 in BER equations
if l==1 & k==1
plot([real(Bpsk) data]);
legend('partie r�el du signal','donn�es');
title('signal BPSK avec bruit');
pause
end

%Rayleigh fading BPSK signal
%first we create h for each symbol
h=1/sqrt(2)*(randn(Ns,1)+j*randn(Ns,1));
%these are zero mean unit variance complex Gaussian variables
Bpsk_r=sqrt(snr(k))*abs(h).*data+n; %SIGNAL
%notice usage of elementwise vector or matrix product .*
if l==1 & k==1,
plot([real(Bpsk_r) data])
legend('partie r�el avec bruit','donn�es'),
title('signal BPSK avec bruit et canal devanuissement');
pause
end

%difference between AWGN and Rayleigh channel
if l==1 & k==1,
plot(abs([Bpsk Bpsk_r]))
legend('AWGN','RAYLEIGH');
title('BPSK dasn AWGN et canal d �vanuissement Rayleigh');
pause
end 
%---------------------------------------------------
%DEMODULATION
%you have to know how these signals are demodulated
%coherent + synchronized reception
%---------------------------------------------------
 
%BPSK
r1=real(Bpsk); %demodulated signal, soft decision
%because phase is 0, if phase is h, r1=real(Bpsk*exp(-j*2*pi*h)); i.e., phase is cancelled 
 
%BPSK in fading channel
r2=real(Bpsk_r); 
 
%different demodulated symbols
if l==1 & k==1
plot([r1 r2])
legend('AWGN','Rayleigh');
title('symboles d�modul�s');pause;
end
%hard decisions, converts soft demodulated symbols to sequence of +-1
%AWGN
d1=find(r1>=0);d2=find(r1<0);
r1(d1)=1;r1(d2)=-1;
%Rayl
d1=find(r2>=0);d2=find(r2<0);
r2(d1)=1;r2(d2)=-1; 
 
%plot example
if l==1 & k==1
plot([r1 r2])
legend('AWGN','Rayleigh');
axis([0 Ns -1.1 1.1]);
title('signal demodul� apres les decisions')
pause
end
%BER analysis
%errors in the current MC run
Ber1=length(find((data-r1)~=0)); %number of errors in AWGN
Ber2=length(find((data-r2)~=0)); %number of errors in Rayleigh 
if k==1 & l==1,
errors=[Ber1 Ber2];
end 
%we add errors to previous error counts, initially zero
%index k is for SNRs
BER1(k)=BER1(k)+Ber1; %AWGN
BER2(k)=BER2(k)+Ber2; %Rayleigh 
 
%we stop MC trials if minimum number of errors is
%obtained in all systems
if BER1(k)>Nerr & BER2(k)>Nerr 
    break %terminates the innermost loop
end

end % end of MC
%we calculate BER by dividing number of successful trials by their total number
BER1(k)=BER1(k)/Ns/l;
BER2(k)=BER2(k)/Ns/l; 
end % end SNR loop
%all simulated BERs and corresponding SNR in a matrix
BER=[SNR BER1 BER2];
%finally we compute theoretical values and compare them to simulation results
%AWGN BER is function of sqrt(2*SNR)
The_awgn=.5*erfc(sqrt(2*snr)/sqrt(2));
%Rayleigh BER is different function of SNR
The_rayl=.5*(1-sqrt(snr./(1+snr))); 
%logarithmic plot (y-axis)
semilogy(SNR,[The_awgn The_rayl BER1 BER2])
xlabel('SNR [dB]')
ylabel('BER')
axis([0 SNR(length(SNR)) 1e-4 .5])
grid on
legend('AWGN theorique','Rayl. theorique','AWGN','Rayl.')