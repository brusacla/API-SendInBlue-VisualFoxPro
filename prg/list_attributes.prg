* Creare prima l'oggetto e poi chiamare il metodo main
*/
* Ottieni la lista degli attributi
oSendInBlue.Listattributes()

* Creo un cursore per inserire gli attributi
CREATE CURSOR cAttributes (Calculatedvalue c(100), cname c(100), category c(100), ctype c(100))
LOCAL lnArray, lCount
lCount = 0
lnArray = ALEN(oSendInBlue.dataResult.attributes)

* Scorro l'array e inserisco tutto nel cursore, ho messo i try catch per evitare problemi con campi a volte non presenti
DO WHILE lCount < lnArray
	lCount = lCount + 1
		
	PRIVATE pCalculatedvalue, pCname, pCategory, pCtype
	
	TRY 
		pCalculatedvalue = oSendInBlue.daTARESULT.attributes(lCount).Calculatedvalue
	CATCH
		pCalculatedvalue = ''	
	ENDTRY 	
	
	TRY 
		pName = oSendInBlue.daTARESULT.attributes(lCount).name
	CATCH
		pName = ''
	ENDTRY 
		
	TRY 	
		pCategory = oSendInBlue.daTARESULT.attributes(lCount).category		
	CATCH
		pCategory = ''
	ENDTRY 					
	
	TRY 		
		pType = oSendInBlue.daTARESULT.attributes(lCount).type			
	CATCH
		pType = ''
	ENDTRY 	
		
	SELECT cAttributes 
	INSERT INTO cAttributes (Calculatedvalue, Cname, Category, cType) VALUES (pCalculatedvalue, pName, pCategory, pType)
ENDDO 

* Questo cursore può essere usato per popolare i combo da usare per l'associazione
SELECT cAttributes 
browse