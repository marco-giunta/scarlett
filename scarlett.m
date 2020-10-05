%NOTA IMPORTANTE: i conti tornano così: se apri 8 bustine da 2000 il valore
%più probabile è 240; il tizio nella prima parte del video live di hank
%unboxing parte da 20000 gemme e arriva a 4000 dunque ne ha spese 16000
%comprando bustine da 2000--> ha fatto 8 acquisti. Si vede che così arriva 
%a 80/100 nello sblocco della quinta stella, cioè gli mancano 150+20=170
%tasselli per finire; considerando che 30 glieli hanno regalati significa
%che ha pescato 440-(170+30)=440-200=240 tasselli, esattamente il valore
%che ho predetto come più probabile!
%poi ne apre un'altra e arriva a 265 quando il programma predice come più
%probabile 290 - comunque non male, però per quantificare quanto buono sia
%il risultato devo aggiungere un calcolo della varianza e vedere se gli
%trovo una interpretazione facile in termini di spread attorno al valore
%più probabile ma per una distribuzione discreta arbitraria...
%EDIT: in realtà è partito da 65, quindi essendo che è arrivato a
%440-170=270 ha pescato complessivamente 270-65=205 tasselli. Mmm...
%poi greedos con discreta fortuna effettivamente arriva a 200 con 5 bustine
%da 2000 contro i 135 più probabili (ma expval=170 e sper. 164.537...). A
%maggior ragione mi servirebbe una misura dello spread attorno a expval

clear all
close all

plotsiono=0;
%num_tentativi=2;
bustina=input("Digita 1 per aprire le bustine da 1000 gemme, 2 per quelle da 2000 ")*1000;
num_tentativi=input("Quanti tentativi vuoi fare (bustine aprire)? ");

s=sprintf("scarlett%d.txt",bustina);
%fid=fopen("scarlett1000.txt","r");
fid=fopen(s,"r");
A=fscanf(fid,'%f',[2,inf])';
x=A(:,1);%numero di tasselli
y=A(:,2)*0.01;%con le corrispettive pobabilità (normalizzate)
fclose(fid);

t=linspace(1,x(end),x(end))';
p=zeros(x(end),1);%t sarà il vettore dei tasselli e p quello delle probabilità corrispondenti a ciascun numero di tasselli
p(x)=y;%in questo modo ai numeri di tasselli presenti in x viene associata la corrispondente prob.; p(x)=y significa che assegno gli elementi di y a quegli elemeni di p con indice pari ai vari elementi di x

if plotsiono==1
    plot(t,p)
    title("PMF per 1 tentativo")
end

%a questo punto ho la mia distribuzione di probabilità che mi escano
%1,2,3,...,200 tasselli!


N=num_tentativi-1;%ATTENZIONE: f^2 è data da 1 convoluzione di f e così via, quindi se faccio due convoluzioni ottengo f^3 (-->expval dopo 3 tentativi, non 2...)
P=nConv(p,N);%ha più senso non usare N ma va be'
T=linspace(1,(t(end)*(1+N)),(t(end)*(1+N)))';%ad ogni convoluzione bisogna aggiungere t(end) elemeni in più; in partenza ce ne sono già t(end), quindi moltiplico questa quantità per 1+N (raccogliendo)
expval=sum(T.*P);
%disp("Somma P: ")
%disp(sum(P)) %per controllare se sia preservata la normalizzazione dà effettivamente 1
%disp("expval: ")
%disp(expval)
s=sprintf("Somma P: %f",sum(P));
disp(s)
s=sprintf("expval: %f",expval);
disp(s)
s=sprintf("Gemme spese: %d",bustina*num_tentativi);

if plotsiono==1
    figure
    plot(T,P)
    s=sprintf("PMF per %d tentativi",num_tentativi);
    title(s)
end

[M,I]=max(P);
%S=sprintf("Il valore più probabile è %d con il %f percento di prob.",I,M*100);
s=sprintf("Valore più probabile: %d",I);
disp(s)
%expval supera il valore più probabile perché i primi 6 valori dei
%possibili tasselli che escono contribuiscono con lo stesso odg, quindi 20,
%25 e 30 spostano significativamente a destra il valore di aspettazione


intervalli=zeros(length(y),1);%gli intervalli di estremi F(x_j), F(x_j+1) ecc.; occhio a trattare separatamente gli intervalli di estremi 0 o 1 sotto!
for i=1:length(y)             %http://dept.stat.lsa.umich.edu/~jasoneg/Stat406/lab5.pdf
    intervalli(i)=sum(y(1:i));%in effettisi tratta della CDF per la singola estrazione
end
%n_tentativi_montecarlo=10;
n_tentativi_montecarlo=input("Quanti tentativi per il montecarlo? ");%fino a 10000 è impercettibile il delay, con 100000 tipo mezzo secondo
media=0;%OCCHIO: solo l'int. (0,p1) va trattato a parte perché 1=F finale!
for i=1:n_tentativi_montecarlo
    tot_uscito=0;%si intende a questo giro del montecarlo
    v=rand([num_tentativi,1]);%apro num_tentativi bustine
    for j=1:num_tentativi%j si riferisce al j-esimo valore estratto; k decide in quale intervallo sta
        if v(j)<intervalli(1)
            tot_uscito=tot_uscito+x(1);
        %elseif v(j)>intervalli(end)%fallisce sempre perché non può essere maggiore di somma prob.=1!
        %    tot_uscito=tot_uscito+x(end);%quindi tratto questo caso in cui aggiungo x(end) insieme con gli altri qua sotto aumentando perciò di uno le iterazioni
        else                      %non -2 qui sotto
            for k=1:(length(intervalli)-1)%devo togliere il primo e l'ultimo intervallo perché li ho già trattati
                if (v(j)>intervalli(k) && v(j)<intervalli(k+1))%è l'indice del secondo estremo a decidere quello dell'intervallo e quindi quale sia il valore corrispondente (da andare a sommare al totale)
                    tot_uscito=tot_uscito+x(k+1);%così se è fra intervalli(N-1) ed intervalli(N) gli assegna correttamente x(N)
                end
            end
        end
    end
    media=media+tot_uscito;
end
media=media/n_tentativi_montecarlo;
s=sprintf("Media dei valori estratti col montecarlo: %f",media);
disp(s);

%in alternativa provo con una logical mask e contando gli elementi non
%nulli (cioè che soddisfano l'opportuna condizione); dovrebbe risultare 
%codice vettorizzato più leggero. Provo inoltre ad unificare i 3 casi
%allungando il vettore di interesse!
media=0;
interv=[0;intervalli];%per piazzare N valori mi servono N intervalli, quindi solo lo 0 va aggiunto - il che comporta una traslazione dell'incide da mettere in x(.): non più quello del secondo estremo ma quello del primo
%interv=[0;intervalli;1];
for i=1:n_tentativi_montecarlo
    tot_uscito=0;
    v=rand([num_tentativi,1]);%apro num_tentativi bustine; non ha senso decommentare questa linea perché v va ricalcolato ogni volta (se no che esperimenti sono?)
    for j=1:length(x)%così ciclo solo sugli intervalli, che sono N essendo length(interv)=N+1 con N=length(x). Infatti ho aggiunto solo lo 0, l'1 era già presente nascosto come intervalli(end)
        tot_uscito=tot_uscito+(x(j)*nnz(v>interv(j) & v<interv(j+1)));
    end
    media=media+tot_uscito;
end
media=media/n_tentativi_montecarlo;
s=sprintf("Media dei valori estratti col montecarlo AGGIORNATO: %f",media);
disp(s);


function x=nConv(a,N)%supponendo che a sia un vettore colonna...
    x=a;%confrontando https://it.mathworks.com/help/matlab/ref/conv.html con http://www.dartmouth.edu/~chance/teaching_aids/books_articles/probability_book/amsbook.mac.pdf
    for i=1:N%pagine 296-297 noto che ho bisogno di shiftare di un posto in avanti la funzione di matlab aggiungendo uno zero in partenza
        x=[0;conv(x,a)];
    end
end