parameters tNomeLocale, tNomeAttributo
* Creare prima l'oggetto e poi chiamare il metodo main
*/
* Nella classe per SendInBlue i tipi di campo supportati sono "text", "date", "float", "boolean"
* per cui bisogna prima stabilire di che tipo è il campo da associare all'attributo che vogliamo aggiornare

* Esempio per il codice cliente
lNomeAttributo  = lNomeAttributo && il nome che vogliamo dare all'attributo
lNomeLocale     = tNomeLocale && il nome locale dell'attributo
lTipoCampo = vartype(lCodiceCliente)

do case 
  case lTipoCampo = 'C'
    oSendInBlue.UpdateAttribute(lNomeAttributo, "text")
  case lTipoCampo = 'D'
    oSendInBlue.UpdateAttribute(lNomeAttributo, "date")
  case lTipoCampo = 'N'
    oSendInBlue.UpdateAttribute(lNomeAttributo, "float")
  case lTipoCampo = 'L'    
    oSendInBlue.UpdateAttribute(lNomeAttributo, "boolean")
  otherwise
    oSendInBlue.UpdateAttribute(lNomeAttributo, "text")  
endcase

* Verifico che sia stato creato
if oSendInBlue.dataResult.Message = 'Created'
  messagebox('Attributo aggiornato con successo')
else
    messagebox("Impossibile creare l'attibuto, il servizio ha restituito l'errore:" + chr(10) + chr(13) + oSendInBle.dataResult.Message)
endif