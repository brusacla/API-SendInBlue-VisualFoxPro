Parameters tEmailcontact, tArrayAttribute
* Creare prima l'oggetto e poi chiamare il metodo main
*/

* per ogni email che trovi devi creare un array con 2 colonne
* nella prima colonna ci va il nome dell'attributo 
* nella seconda colonna ci va il contenuto del campo 
oSendInBlue.CreateContact(tEmailcontact, tArrayAttribute)


if oSendInBlue.dataResult.Message = 'Created' && se il contatto è già presente viene aggiornato 
  messagebox('Contatto creato o aggiornato')
else
  messagebox('Contatto non creato')
endif