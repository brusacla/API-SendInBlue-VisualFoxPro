* Test classe SendinBlueApiClass

* Variabili che recupero dalla mia configurazione
* @var string ApiKey
* @var string ApiUrl

Public ApiKey, ApiUrl
ApiKey = "" && xkeysib-[YOURSENDINBLUEAPIKEY]
ApiUrl = "" && https://api.sendinblue.com/v3/

* Importo la procedura dal file SendInBlueApiClass.prg
Set procedure to "SendInBlueApiClass.prg"



* Creo l'oggetto basato sulla classe importata
Public oSendInBlue 
oSendInBlue = CreateObject("SendInBlueApi")

* Imposto le variabili di configurazione
oSendInBlue.ApiKey = ApiKey
oSendInBlue.ApiUrl = ApiUrl

* Avvio le api prima di procedere con le altre chiamate
oSendInBlue.Main()

* Esempi per il test delle chiamate

** CREAZIONE DI UN ATTRIBUTO
* create_attribute('nome_campo_locale', 'nome_nuovo_attributo')

** CANCELLAZIONE DI UN ATTRIBUTO
* delete_attribute('nome_campo_locale')

** AGGIORNAMENTO DI UN ATTRIBUTO
* update_attribute('nome_campo_locale', 'nome_nuovo_attributo')

** LISTA DEGLI ATTRIBUTI
* list_attributes()

** CREAZIONE DI UN CONTATTO
* lMail = 'mail@mail.com'
* lName = 'nome'
*create_contact(lMail, lName)




