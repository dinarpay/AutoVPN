# Connessione VPN continua e automatizzata con FortiClient (solo CLI) usando bash e expect scripting.

## Problema

Come in questo caso, avevo bisogno di mantenere una connessione VPN (quasi) continua a un server (server 1) dal mio server (server 2) che stava eseguendo una web-app Tomcat (su Ubuntu Server 16.04).  
Il server 1 faceva parte di una rete che forniva un accesso VPN protetto utilizzando un gateway VPN FortiNet.

La soluzione che segue utilizza uno script bash (che crea uno script expect esterno) per automatizzare la connessione, e la riconnessione (se la connessione VPN cade), della connessione VPN al server 1.

### Soluzione
### Installazione di Forticlient e dipendenze

Impostare
Script Bash (con expect script incorporato) da eseguire (e mantenere la connessione VPN FortiClient)
Messa in sicurezza ed esecuzione
Fermare lo script (e uccidere la connessione vpn)
Installazione di Forticlient e dipendenze
Avrai bisogno di installare un appropriato pacchetto Forticlient SSLVPN.  Non so perché, ma FortiNet rende insolitamente difficile trovare il pacchetto client Linux con lo script forticlientsslvpn_cli che è richiesto.  
In ogni caso, ho trovato un pacchetto (usato la versione 4.4.23330-1) appropriato per il mio server Ubuntu (in esecuzione 16.04) qui.  Una volta scaricato si può installare con:
sudo apt-get install <DOWNLOAD_LOCATION>/forticlient-sslvpn_4.4.2333-1_amd64.deb
Avrete anche bisogno di installare i pacchetti ppp e expect.  Se stai usando Ubuntu, fai semplicemente

sudo apt-get install ppp expect

Impostare
Forticlient dovrebbe essere installato in /opt/forticlient-sslvpn/64bit/.  A quanto pare è necessario eseguire prima lo script di setup:

sudo /opt/forticlient-sslvpn/64bit/helper/setup

Scorrere il legalese e poi accettare (digitare Y).  Dovremmo avere tutto il necessario per automatizzare la connessione.

Script Bash (con script expect incorporato) da eseguire (e mantenere la connessione VPN di FortiClient)
Si prega di notare che il seguente approccio memorizza una password vpn in chiaro nel file di script, e come tale è un potenziale rischio per la sicurezza. 
Lo script dovrebbe essere bloccato per impedire agli utenti senza autorizzazione di visualizzarne il contenuto. Quindi, questo approccio può essere appropriato solo per un server/sistema che è strettamente gestito 
o non accessibile da altri utenti.

Ora creeremo uno script bash per gestire la connessione (e la riconnessione automatica).  Lo script qui sotto fa diverse cose, inclusa la creazione e l'esecuzione di uno script expect esterno.  
Questo script expect automatizza ed emula un po' di interazione umana che forticlientsslvpn_cli richiede.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Il cervello dello script expect incorporato è stato scritto da mgeeky e il suo script originale può essere trovato qui.  Molte grazie a mgeeky.
NOTA: il "EOF" sulla linea 47 DEVE essere preceduto da un singolo carattere TAB (non spazi), altrimenti lo script fallirà. Se state copiando/incollando lo script qui sopra nel vostro editor di testo Linux preferito, 
rimuovete gli spazi precedenti e sostituiteli con un carattere di tabulazione.

Messa in sicurezza ed esecuzione
Noterete che lo script qui sopra richiede l'inserimento di un nome utente e di una password.  Come minimo, blocchiamo questo script a root (permettiamo solo a root di leggere/scrivere i contenuti):

Supponiamo che il nostro script si chiami forti-vpn.sh e si trovi nella nostra cartella home

sudo chown root:root ~/forti-vpn.sh
sudo chmod 600 ~/forti-vpn.sh
sudo chmod +x ~/forti-vpn.sh

Per eseguire lo script, passate alla cartella dove risiede ed eseguite
sudo ./forti-vpn.sh &
che eseguirà lo script in background.

Fermare lo script (e uccidere la connessione vpn)
Per fermare lo script dovrete trovare i suoi pid e ucciderli.  Se avete chiamato il vostro script forti-vpn.sh, allora potete farlo facilmente con pkill.  Per esempio, eseguendo

sudo pkill forti
ucciderà tutti i processi con il nome "forti" (che includono lo script e i processi forticlient generati).

In alternativa, puoi usare htop. Dovreste averlo installato (se no, fate sudo apt-get install htop).  Con htop potete quindi localizzare il processo sudo forti-vpn.sh e selezionarlo (con la barra spaziatrice) e poi premere F9 (kill) 
e poi 9 (sigkill) e premere invio.

Riferimenti
https://hadler.me/linux/forticlient-sslvpn-deb-packages/
https://gist.github.com/mgeeky/8afc0e32b8b97fd6f96fce6098615a93
