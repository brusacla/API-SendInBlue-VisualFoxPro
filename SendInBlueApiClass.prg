* Classe Visual FoxPro per integrare NextLogic a SendInBlue
* @author Claudio Brusaferri < brusacla@gmail.com
* @version 1.0
* @package NextLogic


* Documentazione API SendInBlue
* @link https://developers.sendinblue.com/reference


* Dati di esempio da configurare in NextLogic del cliente
* apiKey = "xkeysib-[API_KEY]"
* apiUrl = "https://api.sendinblue.com/v3/"

Define Class SendInBlueApi As Custom
	** CHR per andare a capo
	NewLine = Chr(10) + Chr(13)
	
	** Variabile per success
	Success		= .F.

	** Oggetto per il collegamento Http
	Http		= Null

	** Oggetto regex per la validazione dei campi
	oRegex		= Null

	** Pattern per la validazione delle email
	patternValidateEmail = '^[A-Za-z0-9](([_\.\-]?[a-zA-Z0-9]+)*)@([A-Za-z0-9]+)(([\.\-]?[a-zA-Z0-9]+)*)\.([A-Za-z]{2,})$'

	** Pattern per la validazione delle url
	patternValidateUrl = '(http[s]?:\/\/)?([^\/\s]+\/)(.*)'



	** Array dei codici http
	dimension aStatusHttp(12)
	aStatusHttp(1) = 200
	aStatusHttp(2) = 201
	aStatusHttp(3) = 202
	aStatusHttp(4) = 204
	aStatusHttp(5) = 400
	aStatusHttp(6) = 401
	aStatusHttp(7) = 402
	aStatusHttp(8) = 403
	aStatusHttp(9) = 404
	aStatusHttp(10) = 405
	aStatusHttp(11) = 406
	aStatusHttp(12) = 429

	** Dati di autenticazione
	apiKey		= '' 

	** Url Base Address
	apiUrl	= '' 

	** apiKey attiva
	apiKeyActive	= .F.

	** Json Result Object
	dataResult	= Null

	&& Creazione oggetto richieste HTTP
	Function Init()
		This.Http = Createobject("MSXML2.XMLHTTP.6.0")
		this.oRegex = CreateObject("VBScript.RegExp")
	Endfunc

	&& Funzione per attivare le API
	Function Main()
		* Se ho gi� impostato l'apiKey e l'apiUrl
		If Len(Alltrim(This.apiUrl)) > 0 And Len(Alltrim(This.apiKey)) > 0
			Local lError
			lError = .F.

			* Verifico che l'url sia valido
			if this.oRegex.test(This.apiUrl, this.patternValidateUrl)

				* Recupero i dati dell'account
				This.GetAccountInfo()

				* Se la richiesta � andata a buon fine
				If This.Http.Status = 200
					* Tento di leggere il nome dell'azienda
					Try
						If Len(Alltrim(This.dataResult.companyname)) > 0
							* Attivo le API e il servizio
							This.apiKeyActive = .T.
						Endif
					Catch
						lError = .T.
					Endtry
				Else
					* In tutti gli altri casi setto l'errore
					lError = .T.
				Endif
			else
				* Errore
				lError = .T.
				This.dataResult = "Url non valido"
			endif

			* Se ci sono stati errori
			If lError
				if ascan(this.aStatusHttp, This.Http.Status) > 0
					This.dataResult = this.ApiError()
				Else
					This.dataResult = this.ApiMessage("Errore di connessione")
				endif	
			Endif

		Else
			This.dataResult = this.ApiMessage("Devi prima impostare la chiave API e l'url base")
		Endif
	Endfunc

	&& JSonParser � utilizzata dall'interno della classe SendInBlueApi
	Function JSonParser(cJsonData)
		Local oRet
		With Createobject('NFJSon_Class')
			oRet = .NFJSonRead(cJsonData)
		Endwith
		Return oRet
	Endfunc

	&& Funzione per la gestione dei messaggi
	Function ApiMessage(cMessage)
		local lApiMessage
		text to lApiMessage Noshow TextMerge Pretext 15
		{"Messaggio":"<<cMessage>>"}
		endtext

		Return this.JSonParser(lApiMessage)
	Endfunc	

	&& Funzione per la gestione degli errori HTTP
	Function ApiError()
		* Se l'errore � stato impostato
		local lErrorJson, lErrorStatus, lErrorCode, lErrorMessage
		lErrorStatus 	= transform(This.Http.Status)
		lErrorCode 		= this.dataResult.Code
		lErrorMessage 	= this.dataResult.Message
		
		text to lErrorJson Noshow TextMerge Pretext 15
		{"Codice":"<<pErrorStatus>>","Errore":"<<pErrorCode>>","Messaggio":"<<pErrorMessage>>"}
		endtext

		Return this.JSonParser(lErrorJson)
	Endfunc

	&& Ogetto Http tipo POST
	Function HttpOpenPost(cApi)
		This.Http.Open("POST", This.apiUrl + cApi ,.F.)
	Endfunc

	&& Ogetto Http tipo PUT
	Function HttpOpenPut(cApi)
		This.Http.Open("PUT", This.apiUrl + cApi ,.F.)
	Endfunc

	&& Ogetto Http tipo GET
	Function HttpOpenGet(cApi)
		This.Http.Open("GET", This.apiUrl + cApi ,.F.)
	Endfunc

	&& Ogetto Http tipo DELETE
	Function HttpOpenDelete(cApi)
		This.Http.Open("DELETE", This.apiUrl + cApi ,.F.)
	Endfunc

	&& Chiamata all'EndPoint "account" per verificare la validit� dell'apiKey
	Function GetAccountInfo()
		This.HttpOpenGet("account")
		This.Http.setRequestHeader("api-key", This.apiKey)
		try 
			This.Http.Send()
			This.dataResult = This.JSonParser(This.Http.responseText)
		Catch
		endtry 	
	Endfunc

	*********************************************************************************************************
	**************** FUNZIONI PER ENDPOINTs ******************************************************************
	*********************************************************************************************************

	&& Chiamata API di tipo GET per ottenere la lista dei contatti
	Function GetContacts(limit, offset)
		* limit = Numero massimo di contatti da restituire
		* offset = Numero di contatti da saltare

		If limit = .F.
			limit = 50
		Endif

		If offset = .F.
			offset = 0
		Endif

		limit = Transform(limit)
		offset = Transform(offset)

		With This
			.HttpOpenGet("contacts?limit=" + limit + "&offset=" + offset)
			.Http.setRequestHeader("Content-Type","application/json")
			.Http.setRequestHeader("api-key", This.apiKey)
			.Http.Send()
			This.dataResult = .Http.responseText
		Endwith

	Endfunc

	* Chiamata API di tipo GET per ottenere la lista degli attributi
	* List all attributes
	* GET
	* https://api.sendinblue.com/v3/contacts/attributes
	Function ListAttributes()
		With This
			.HttpOpenGet("contacts/attributes")
			.Http.setRequestHeader("Content-Type","application/json")
			.Http.setRequestHeader("api-key", This.apiKey)
			.Http.Send()
			This.dataResult = this.JSonParser(.Http.responseText)
		Endwith
	Endfunc

	* Chiamata API di tipo POST per creare un nuovo attributo
	* Create contact attribute
	* POST
	* https://api.sendinblue.com/v3/contacts/attributes/normal/[nome_attributo]
	* In questa  classe vengono gestiti solo gli attributi della categoria "normal"
		* Tipi di attributo consetiti:
		* text
		* date
		* float
		* boolean
	* Nella pagina https://developers.sendinblue.com/reference/createattribute-1/ si trovano tutti gli altri casi implementabili	
	Function CreateAttribute(cName, cType) && cName [nome dell'attributo], cType [tipo di attributo "text", "date", "float", "boolean"]
		local lError
		lError = .F.

		* Controllo che il nome dell'attributo sia valido
		if len(alltrim(cName)) > 0
			* Trasformo il nome dell'attributo in maiuscolo e senza spazi
			cName = alltrim(cName)
			cName = upper(cName)
			cName = strtran(cName, " ", "_")
		Else
			lError = .T.					
		endif 

		* Controllo che il tipo di attributo sia valido
		if len(alltrim(cType)) > 0
			* Trasformo il tipo dell'attributo in minuscolo e senza spazi
			cType = alltrim(cType)
			cType = lower(cType)
			cType = strtran(cType, " ", "_")

			* Se il tipo di attributo non � tra quelli consentiti
			if cType <> "text" and cType <> "date" and cType <> "float" and cType <> "boolean"
				* In tutti gli altri casi setto l'errore
				lError = .T.
			endif 	
		Else
			lError = .T.	
		endif 

		* Se non ci sono errori
		if lError = .F.
			* Eseguo la POST per creare un nuovo attributo
			With This
				.HttpOpenPost("contacts/attributes/normal/" + cName)
				.Http.setRequestHeader("Content-Type","application/json")
				.Http.setRequestHeader("api-key", This.apiKey)
				.Http.Send('{"type":"' + cType + '"}')
			Endwith

			* Verifico se l'attributo � stato creato
			If This.http.status = 201
				This.dataResult = This.Http.statusText
			Else
				* Restituisco l'errore HTTP
				This.dataResult = this.JSonParser(This.Http.responseText)
			endif	

		Else
			* Se non � stato impostato il nome dell'attributo
			This.dataResult = this.ApiMessage("Nome o tipo di attributo non valido")
		endif	
	Endfunc

	* Chiamata API di tipo DELETE per eliminare un attributo
	* Delete an attribute
	* DELETE
	* https://api.sendinblue.com/v3/contacts/attributes/[attributeCategory]/[attributeName]
	Function DeleteAttribute(cName) && cName [nome dell'attributo]
		local lError
		lError = .F.

		* Controllo che il nome dell'attributo sia valido
		if len(alltrim(cName)) > 0
			* Trasformo il nome dell'attributo in maiuscolo e senza spazi
			cName = alltrim(cName)
			cName = upper(cName)
			cName = strtran(cName, " ", "_")
		Else
			lError = .T.
		endif

		* Se non ci sono errori
		if lError = .F.
			* Eseguo la DELETE per eliminare l'attributo
			With This
				.HttpOpenDelete("contacts/attributes/normal/" + cName)
				.Http.setRequestHeader("Content-Type","application/json")
				.Http.setRequestHeader("api-key", This.apiKey)
				.Http.Send()
			Endwith

			* Verifico se l'attributo � stato eliminato
			If This.http.status = 204
				This.dataResult = "Deleted"
			Else
				* Restituisco l'errore HTTP
				This.dataResult = this.JSonParser(This.Http.responseText)
			endif	

		Else
			* Se non � stato impostato il nome dell'attributo
			This.dataResult = this.ApiMessage("Nome attributo non valido")
		endif
	Endfunc

	* Chiamata API di tipo PUT per aggiornare un attributo
	* Update contact attribute
	* PUT
	* https://api.sendinblue.com/v3/contacts/attributes/[attributeCategory]/[attributeName]
	* In questa  classe vengono gestiti solo gli attributi della categoria "normal"
		* Tipi di attributo consetiti:
		* text
		* date
		* float
		* boolean
	* Nella pagina https://developers.sendinblue.com/reference/updateattribute si trovano tutti gli altri casi implementabili	
	Function UpdateAttribute(cName, cType) && cName [nome dell'attributo], cType [tipo di attributo "text", "date", "float", "boolean"]
		local lError
		lError = .F.

		* Controllo che il nome dell'attributo sia valido
		if len(alltrim(cName)) > 0
			* Trasformo il nome dell'attributo in maiuscolo e senza spazi
			cName = alltrim(cName)
			cName = upper(cName)
			cName = strtran(cName, " ", "_")
		Else
			lError = .T.					
		endif 

		* Controllo che il tipo di attributo sia valido
		if len(alltrim(cType)) > 0
			* Trasformo il tipo dell'attributo in minuscolo e senza spazi
			cType = alltrim(cType)
			cType = lower(cType)
			cType = strtran(cType, " ", "_")

			* Se il tipo di attributo non � tra quelli consentiti
			if cType <> "text" and cType <> "date" and cType <> "float" and cType <> "boolean"
				* In tutti gli altri casi setto l'errore
				lError = .T.
			endif 	
		Else
			lError = .T.	
		endif 

		* Se non ci sono errori
		if lError = .F.
			* Eseguo la PUT per aggiornare l'attributo
			With This
				.HttpOpenPut("contacts/attributes/normal/" + cName)
				.Http.setRequestHeader("Content-Type","application/json")
				.Http.setRequestHeader("api-key", This.apiKey)
				.Http.Send('{"type":"' + cType + '"}')
			Endwith

			* Verifico se l'attributo � stato aggiornato
			If This.http.status = 204
				This.dataResult = "Updated"
			Else
				* Restituisco l'errore HTTP
				This.dataResult = this.JSonParser(This.Http.responseText)
			endif

		Else
			* Se non � stato impostato il nome dell'attributo
			This.dataResult = this.ApiMessage("Nome o tipo di attributo non valido")
		endif
	Endfunc

	* Chiamata API di tipo POST per aggiungere un contatto
	* Create contact
	* POST
	* https://api.sendinblue.com/v3/contacts
	* Viene passato il parametro updateEnabled in questo modo se il contatto esiste viene aggiornato
	* In questa classe non viene scritta una fuznione per aggiornare un contatto o una serie di contatti
	* Per vedere tutti i casi implementabili in questa classe vedere la pagina https://developers.sendinblue.com/reference/createcontact
	function CreateContact(cEmail, arrAttributes) && cEmail [email del contatto], arrAttributes [array di attributi]
		local lError
		lError = .F.
		
		* Controllo che l'email del contatto sia valida
		if len(alltrim(cEmail)) > 0
			* Verifico che l'email sia valida
			cEmail = alltrim(cEmail)
			cEmail = lower(cEmail)
			if not this.oRegex.test(cEmail, this.patternValidateEmail)	
				lError = .T.
			endif
		Else
			lError = .T.					
		endif 

		* Controllo che gli attributi del contatto siano validi
		if len(arrAttributes) > 0
			* Devo scorrere l'array e costruire un json che contiene tutti gli attributi
			local jsonAttributes, lCount, lArrCount
			jsonAttributes = ''
			lCount = 0
			lArrCount = aLen(arrAttributes)

			* Scorro l'array
			do while lCount < lArrCount
				'{"' + arrAttributes[i][0] + '":"' + arrAttributes[i][1] + '"},'
				lCount = lCount + 1
			enddo

		endif 

		* Se non ci sono errori
		if lError = .F.
			local cData
			cData = '{'

			* Se sono presenti attributi
			if aLen(arrAttributes) > 0
				cData = cData + jsonAttributes
			endif 

			cData = cData + '"updateEnabled": true, "email": "' + cEmail + '"}'

			* Eseguo la POST per aggiungere il contatto
			With This
				.HttpOpenPost("contacts")
				.Http.setRequestHeader("Content-Type","application/json")
				.Http.setRequestHeader("api-key", This.apiKey)
				.Http.Send(cData)
			Endwith

			* Verifico se il contatto � stato aggiunto
			If This.http.status = 204
				This.dataResult = "Created"
			Else
				* Restituisco l'errore HTTP
				This.dataResult = this.JSonParser(This.Http.responseText)
			endif

		Else
			* Se non � stato impostato l'email del contatto
			This.dataResult = this.ApiMessage("Email non valida")
		endif
	Endfunc

Enddefine && fine Define Class SendInBlueApi As Custom

******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
******************************************************************************************************************************************************
&& Definizione classe per il parsing JSON da qui in poi non toccare nulla
Define Class NFJSon_Class As Session
	DataSession = 2
	*-------------------------------------------------------------------
	* Created by Marco Plaza , 2013-2017 @nfTools
	*-------------------------------------------------------------------
	** lparameters cjsonstr,revivecollection
	Function NFJSonRead(cjsonstr,revivecollection)

		#Define crlf Chr(13)+Chr(10)

		Private All

		stacklevels=Astackinfo(aerrs)

		If m.stacklevels > 1
			calledfrom = ' ( called From '+aerrs(m.stacklevels-1,4)+' line '+Transform(aerrs(m.stacklevels-1,5))+')'
		Else
			calledfrom = ''
		Endif


		Try

			cerror = ''
			If Not Left(Ltrim(cjsonstr),1)  $ '{['  And File(m.cjsonstr)
				cjsonstr = Filetostr(m.cjsonstr)
			Endif

			ost = Set('strictdate')
			Set StrictDate To 0
			ojson = This.nfjsonread2(m.cjsonstr, m.revivecollection)
			Set StrictDate To (m.ost)

		Catch To oerr1
			cerror = 'nfJson '+m.calledfrom+crlf+m.oerr1.Message

		Endtry

		If !Empty(m.cerror)
			Error m.cerror
			Return .Null.
		Endif

		Return Iif(Vartype(m.ojson)='O',m.ojson,.Null.)
	Endfunc


	*-------------------------------------------------------------------------
	Function nfjsonread2(cjsonstr,revivecollection)
		*-------------------------------------------------------------------------


		Try

			x = 1
			cerror = ''

			* process json:

			cjson = Rtrim(Chrtran(m.cjsonstr,Chr(13)+Chr(9)+Chr(10),''))
			pchar = Left(Ltrim(m.cjson),1)


			nl = Alines(aj,m.cjson,20,'{','}','"',',',':','[',']','\\')

			For xx = 1 To Alen(aj)
				If Left(Ltrim(aj(m.xx)),1) $ '{}",:[]'  Or Lower(Left(Ltrim(m.aj(m.xx)),4)) $ 'true/false/null'
					aj(m.xx) = Ltrim(aj(m.xx))
				Endif
			Endfor

			ostack = Createobject('stack')

			ojson = Createobject('empty')

			Do Case
				Case  aj(1)='{'
					x = 1
					ostack.pushobject()
					This.procstring(m.ojson)

				Case aj(1) = '['
					x = 0
					This.procstring(m.ojson,.T.)

				Otherwise
					Error ' expecting [{  got '+m.pchar

			Endcase


			If m.revivecollection
				ojson = This.revivecollection(m.ojson)
			Endif


		Catch To oerr

			strp = ''

			For Y = 1 To m.x
				strp = m.strp+aj(m.y)
			Endfor

			Do Case
				Case oerr.ErrorNo = 1098

					cerror = ' Invalid Json: '+ m.oerr.Message+crlf+' Parsing: '+Right(m.strp,80)

				Otherwise

					cerror = ' program error # '+Transform(m.oerr.ErrorNo)+crlf+m.oerr.Message+' at line: '+Transform(oerr.Lineno)+crlf+' Parsing: '+Right(m.strp,80)

			Endcase

		Endtry

		If !Empty(m.cerror)
			Error m.cerror
		Endif

		Return m.ojson
	Endfunc

	*--------------------------------------------------------------------------------
	Function procstring(obj,evalue)
		*--------------------------------------------------------------------------------
		#Define cvalid 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890_'
		#Define creem  '_______________________________________________________________'

		Private rowpos,colpos,bidim,ncols,arrayname,expecting,arraylevel,vari
		Private expectingpropertyname,expectingvalue,objectopen

		expectingpropertyname = !m.evalue
		expectingvalue = m.evalue
		expecting = Iif(expectingpropertyname,'"}','')
		objectopen = .T.
		bidim = .F.
		colpos = 0
		rowpos = 0
		arraylevel = 0
		arrayname = ''
		vari = ''
		ncols = 0

		Do While m.objectopen

			x = m.x+1

			Do Case

				Case m.x > m.nl

					m.x = m.nl

					If ostack.Count > 0
						Error 'expecting '+m.expecting
					Endif

					Return

				Case aj(m.x) = '}' And '}' $ m.expecting
					This.closeobject()

				Case aj(x) = ']' And ']' $ m.expecting
					This.closearray()

				Case  m.expecting = ':'
					If aj(m.x) = ':'
						expecting = ''
						Loop
					Else
						Error 'expecting : got '+aj(m.x)
					Endif

				Case ',' $ m.expecting

					Do Case
						Case aj(x) = ','
							expecting = Iif( '[' $ m.expecting , '[' , '' )
						Case Not aj(m.x) $ m.expecting
							Error 'expecting '+m.expecting+' got '+aj(m.x)
						Otherwise
							expecting = Strtran(m.expecting,',','')
					Endcase


				Case m.expectingpropertyname

					If aj(m.x) = '"'
						This.propertyname(m.obj)
					Else
						Error 'expecting "'+m.expecting+' got '+aj(m.x)
					Endif


				Case m.expectingvalue

					If m.expecting == '[' And m.aj(m.x) # '['
						Error 'expecting [ got '+aj(m.x)
					Else
						This.procvalue(m.obj)
					Endif


			Endcase


		Enddo
	Endfunc



	*-----------------------------------------------------------------------------
	Function anuevoel(obj,arrayname,valasig,bidim,colpos,rowpos)
		*-----------------------------------------------------------------------------


		If m.bidim

			colpos = m.colpos+1

			If colpos > m.ncols
				ncols = m.colpos
			Endif

			Dimension obj.&arrayname(m.rowpos,m.ncols)

			obj.&arrayname(m.rowpos,m.colpos) = m.valasig

			If Vartype(m.valasig) = 'O'
				This.procstring(obj.&arrayname(m.rowpos,m.colpos))
			Endif

		Else

			rowpos = m.rowpos+1
			Dimension obj.&arrayname(m.rowpos)

			obj.&arrayname(m.rowpos) = m.valasig

			If Vartype(m.valasig) = 'O'
				This.procstring(obj.&arrayname(m.rowpos))
			Endif

		Endif
	Endfunc

	*-----------------------------------------
	Function unescunicode( cstr )
		*-----------------------------------------

		Private All

		ust = ''

		For x = 1 To Alines(xstr,m.cstr,18,'\u','\\u')

			If Right(xstr(m.x),3) # '\\u' And Right(xstr(m.x),2) = '\u'

				ust = m.ust + Rtrim(xstr(M.x),0,'\u')

				dec = Val( "0x"+Left(xstr(m.x+1),4))
				Ansi = Strconv( BinToC( m.dec  , "2RS" ) ,6 )

				If m.ansi = '?'
					ust = m.ust + '&#'+Transform(m.dec)
				Else
					ust = m.ust + m.ansi
				Endif

				xstr(m.x+1) = Substr(xstr(m.x+1),5)

			Else

				ust = m.ust + xstr(m.x)

			Endif

		Endfor

		cstr = m.ust
	Endfunc

	*-----------------------------------
	Function unescapecontrolc( Value )
		*-----------------------------------

		If At('\', m.value) = 0
			Return
		Endif

		* unescape special characters:

		Private aa,elem,unesc


		Declare aa(1)
		=Alines(m.aa,m.value,18,'\\','\b','\f','\n','\r','\t','\"','\/')

		unesc =''

		#Define sustb 'bnrt/"'
		#Define sustr Chr(127)+Chr(10)+Chr(13)+Chr(9)+Chr(47)+Chr(34)

		For Each elem In m.aa

			If ! m.elem == '\\' And Left(Right(m.elem,2),1) = '\'
				elem = Left(m.elem,Len(m.elem)-2)+Chrtran(Right(m.elem,1),sustb,sustr)
			Endif

			unesc = m.unesc+m.elem

		Endfor

		Value = m.unesc
	Endfunc
	*--------------------------------------------
	Procedure propertyname(obj)
		*--------------------------------------------

		x = m.x+1
		vari = aj(m.x)

		Do While Right(aj(m.x),1) # '"' And m.x < Alen(m.aj)
			x=m.x+1
			vari = m.vari + aj(m.x)
		Enddo

		If Right(m.aj(m.x),1) # '"'
			Error ' expecting "  got  '+ m.aj(m.x)
		Endif

		vari = Rtrim(m.vari,1,'"')
		vari = Iif(Isalpha(m.vari),'','_')+m.vari
		vari = Chrtran( vari, Chrtran( vari, cvalid,'' ) , creem )

		If vari == 'tabindex'
			vari = '_tabindex'
		Endif

		expecting = ':'
		expectingvalue = .T.
		expectingpropertyname = .F.
	Endfunc

	*-------------------------------------------------------------
	Function procvalue(obj)
		*-------------------------------------------------------------

		Do Case
			Case aj(m.x) = '{'

				ostack.pushobject()

				If m.arraylevel = 0

					AddProperty(obj,m.vari,Createobject('empty'))

					This.procstring(obj.&vari)
					expectingpropertyname = .T.
					expecting = ',}'
					expectingvalue = .F.

				Else

					This.anuevoel(m.obj,m.arrayname,Createobject('empty'),m.bidim,@m.colpos,@m.rowpos)
					expectingpropertyname = .F.
					expecting = ',]'
					expectingvalue = .T.

				Endif


			Case  aj(x) = '['

				ostack.pusharray()

				Do Case

					Case m.arraylevel = 0

						arrayname = Evl(m.vari,'array')
						rowpos = 0
						colpos = 0
						bidim = .F.


						Try
							AddProperty(obj,(m.arrayname+'(1)'),.Null.)
						Catch
							m.arrayname = m.arrayname+'_vfpSafe_'
							AddProperty(obj,(m.arrayname+'(1)'),.Null.)
						Endtry


					Case m.arraylevel = 1 And !m.bidim

						rowpos = 1
						colpos = 0
						ncols = 1

						Dime obj.&arrayname(1,2)
						bidim = .T.

				Endcase

				arraylevel = m.arraylevel+1

				vari=''

				expecting = Iif(!m.bidim,'[]{',']')
				expectingvalue = .T.
				expectingpropertyname = .F.

			Otherwise

				isstring = aj(m.x)='"'
				x = m.x + Iif(m.isstring,1,0)

				Value = ''

				Do While m.x <= Alen(m.aj)
					Value = m.value + aj(m.x)
					If  ( ( m.isstring And Right(aj(m.x),1) = '"' ) Or (!m.isstring And Right(aj(m.x),1) $ '}],') ) And Left(Right(aj(m.x),2),1) # '\'
						Exit
					Endif
					x = m.x+1
				Enddo

				closechar = Right(aj(m.x),1)

				Value = Left(m.value,Len(m.value)-1)

				Do Case

					Case Empty(m.value) And  Not ( m.isstring And m.closechar = '"'  )
						Error 'Expecting value got '+m.closechar

					Case  m.isstring
						If m.closechar # '"'
							Error 'expecting " got '+m.closechar
						Endif

					Case ostack.isobject() And Not m.closechar $ ',}'
						Error 'expecting ,} got '+m.closechar

					Case ostack.isarray() And  Not m.closechar $ ',]'
						Error 'expecting ,] got '+m.closechar

				Endcase



				If m.isstring

					* don't change this lines sequence!:
					This.unescunicode(@m.value)  && 1
					This.unescapecontrolc(@m.value)  && 2
					Value = Strtran(m.value,'\\','\')  && 3

					** check for Json DateTime: && 2017-03-10T17:43:55
					* proper formatted dates with invalid values will parse as character - eg: {"today":"2017-99-01T15:99:00"}

					If This.isjsondt( m.value )
						Value = This.jsondatetodt( m.value )
					Endif

				Else

					Value = Alltrim(m.value)

					Do Case
						Case Lower(m.value) == 'null'
							Value = .Null.
						Case Lower(m.value) == 'true' Or Lower(m.value) == 'false'
							Value = m.value='true'

						Case Empty(Chrtran(m.value,'-1234567890.Ee',''))

							Try
								Local tvaln,im
								im = 'tvaln = '+m.value
								&im
								Value = m.tvaln
								badnumber = .F.
							Catch
								badnumber = .T.
							Endtry

							If badnumber
								Error 'bad number format:  got '+aj(m.x)
							Endif

						Otherwise
							Error 'expecting "|number|null|true|false|  got '+aj(m.x)
					Endcase


				Endif


				If m.arraylevel = 0


					AddProperty(obj,m.vari,m.value)

					expecting = '}'
					expectingvalue = .F.
					expectingpropertyname = .T.

				Else

					This.anuevoel(obj,m.arrayname,m.value,m.bidim,@m.colpos,@m.rowpos)
					expecting = ']'
					expectingvalue = .T.
					expectingpropertyname = .F.

				Endif

				expecting = Iif(m.isstring,',','')+m.expecting


				Do Case
					Case m.closechar = ']'
						This.closearray()
					Case m.closechar = '}'
						This.closeobject()
				Endcase

		Endcase
	Endfunc

	*------------------------------
	Function closearray()
		*------------------------------

		If ostack.Pop() # 'A'
			Error 'unexpected ] '
		Endif

		If m.arraylevel = 0
			Error 'unexpected ] '
		Endif

		arraylevel = m.arraylevel-1

		If m.arraylevel = 0

			arrayname = ''
			rowpos = 0
			colpos = 0

			expecting = Iif(ostack.isobject(),',}','')
			expectingpropertyname = .T.
			expectingvalue = .F.

		Else

			If  m.bidim
				rowpos = m.rowpos+1
				colpos = 0
				expecting = ',]['
			Else
				expecting = ',]'
			Endif

			expectingvalue = .T.
			expectingpropertyname = .F.

		Endif
	Endfunc


	*-------------------------------------
	Function closeobject
		*-------------------------------------

		If ostack.Pop() # 'O'
			Error 'unexpected }'
		Endif

		If m.arraylevel = 0
			expecting = ',}'
			expectingvalue = .F.
			expectingpropertyname = .T.
			objectopen = .F.
		Else
			expecting = ',]'
			expectingvalue = .T.
			expectingpropertyname = .F.
		Endif
	Endfunc

	*----------------------------------------------
	Function revivecollection( o )
		*----------------------------------------------

		Private All

		oconv = Createobject('empty')

		nprop = Amembers(elem,m.o,0,'U')

		For x = 1 To m.nprop

			estavar = m.elem(x)

			esarray = .F.
			escoleccion = Type('m.o.'+m.estavar) = 'O' And Right( m.estavar , 14 ) $ '_KV_COLLECTION,_KL_COLLECTION' And Type( 'm.o.'+m.estavar+'.collectionitems',1) = 'A'

			Do Case
				Case m.escoleccion

					estaprop = Createobject('collection')

					tv = m.o.&estavar

					m.keyvalcoll = Right( m.estavar , 14 ) = '_KV_COLLECTION'

					If Not ( Alen(m.tv.collectionItems) = 1 And Isnull( m.tv.collectionItems ) )


						For T = 1 To Alen(m.tv.collectionItems)

							If m.keyvalcoll
								esteval = m.tv.collectionItems(m.t).Value
							Else
								esteval = m.tv.collectionItems(m.t)
							Endif


							If Vartype(m.esteval) = 'O' Or Type('esteVal',1) = 'A'
								esteval = This.revivecollection(m.esteval)
							Endif

							If m.keyvalcoll
								estaprop.Add(esteval,m.tv.collectionItems(m.t).Key)
							Else
								estaprop.Add(m.esteval)
							Endif

						Endfor

					Endif

				Case Type('m.o.'+m.estavar,1) = 'A'

					esarray = .T.

					For T = 1 To Alen(m.o.&estavar)

						Dimension &estavar(m.t)

						If Type('m.o.&estaVar(m.T)') = 'O'
							&estavar(m.t) = This.revivecollection(m.o.&estavar(m.t))
						Else
							&estavar(m.t) = m.o.&estavar(m.t)
						Endif

					Endfor

				Case Type('m.o.'+estavar) = 'O'
					estaprop = This.revivecollection(m.o.&estavar)

				Otherwise
					estaprop = m.o.&estavar

			Endcase


			estavar = Strtran( m.estavar,'_KV_COLLECTION', '' )
			estavar = Strtran( m.estavar, '_KL_COLLECTION', '' )

			Do Case
				Case m.escoleccion
					AddProperty(m.oconv,m.estavar,m.estaprop)
				Case  m.esarray
					AddProperty(m.oconv,m.estavar+'(1)')
					Acopy(&estavar,m.oconv.&estavar)
				Otherwise
					AddProperty(m.oconv,m.estavar,m.estaprop)
			Endcase

		Endfor

		Try
			retcollection = m.oconv.Collection.BaseClass = 'Collection'
		Catch
			retcollection = .F.
		Endtry

		If m.retcollection
			Return m.oconv.Collection
		Else
			Return m.oconv
		Endif
	Endfunc

	*----------------------------------
	Function isjsondt( cstr )
		*----------------------------------

		cstr = Rtrim(m.cstr,1,'Z')

		Return Iif( Len(m.cstr) = 19 ;
			and Len(Chrtran(m.cstr,'01234567890:T-','')) = 0 ;
			and Substr(m.cstr,5,1) = '-' ;
			and Substr(m.cstr,8,1) = '-' ;
			and Substr(m.cstr,11,1) = 'T' ;
			and Substr(m.cstr,14,1) = ':' ;
			and Substr(m.cstr,17,1) = ':' ;
			and Occurs('T',m.cstr) = 1 ;
			and Occurs('-',m.cstr) = 2 ;
			and Occurs(':',m.cstr) = 2 ,.T.,.F. )
	Endfunc

	*-----------------------------------------------------
	Function jsondatetodt( cjsondate )
		*-----------------------------------------------------

		cjsondate = Rtrim(m.cjsondate,1,'Z')

		If m.cjsondate = '0000-00-00T00:00:00'

			Return {}

		Else

			cret = Eval('{^'+Rtrim(m.cjsondate,1,"T00:00:00")+'}')

			If !Empty(m.cret)
				Return m.cret
			Else
				Error 'Invalid date '+cjsondate
			Endif

		Endif
	Endfunc


Enddef


******************************************
Define Class Stack As Collection
	******************************************

	*---------------------------
	Function pushobject()
		*---------------------------
		This.Add('O')

		*---------------------------
	Function pusharray()
		*---------------------------
		This.Add('A')

		*--------------------------------------
	Function isobject()
		*--------------------------------------
		Return This.Count > 0 And This.Item( This.Count ) = 'O'

		*--------------------------------------
	Function isarray()
		*--------------------------------------
		Return This.Count > 0 And This.Item( This.Count ) = 'A'

		*----------------------------
	Function Pop()
		*----------------------------
		cret = This.Item( This.Count )
		This.Remove( This.Count )
		Return m.cret

		******************************************
Enddefine
******************************************
