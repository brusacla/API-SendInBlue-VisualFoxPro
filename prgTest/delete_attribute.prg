parameters tNomeAttributoDaCancellare
* Creare prima l'oggetto e poi chiamare il metodo main
*/
oSendInBlue.DeleteAttribute(tNomeAttributoDaCancellare)

* Verifico che sia stato creato
if oSendInBlue.dataResult.Message = 'Deleted'
    messagebox('Attributo cancellato con successo')
else
    messagebox("Impossibile creare l'attibuto, il servizio ha restituito l'errore:" + chr(10) + chr(13) + oSendInBlue.dataResult.Message)
endif