' VB Script Document
on error resume next

'------------------------------------------------------------------------------
' Param�tres du script
'------------------------------------------------------------------------------
'Chemin de 7zip
zipExe = "C:\Program Files\7-Zip\7z.exe"
'Dossier temporaire: n�cessaire au script
tmpFolder = "D:\tmpC\"
'Nom des 2 fichiers n�cessaires au script
settingsFile = "@parametres.upsti"
FTPfolderFile = "@dossierFTP.upsti"
'Param�tres FTP
FTPuser = "script@pinaultb.o2switch.net"
FTPpwd = "o2sscript"
FTPhost = "pinaultb.o2switch.net"
FTPport = 21

'------------------------------------------------------------------------------
' Script de compilation
'------------------------------------------------------------------------------

'On r�cup�re les infos du fichier cliqu�                   
Set objArgs = Wscript.Arguments
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.GetFile(objargs(i))
fileName = objFSO.GetFileName(objFile)
baseName = objFSO.GetBaseName(objFile)
pathName = objFSO.GetParentFolderName(objFile)
fullPath = objFSO.GetAbsolutePathName(objFile)
parentFolder = objFSO.GetParentFolderName(pathName)
Set objArgs = Nothing
Set objFile = Nothing

'Param�tres de la compilation
If (objFSO.FileExists(settingsFile)) Then
  Set file = objFSO.OpenTextFile(settingsFile, 1)
  parametres = file.ReadAll
Else
  parametres = InputBox("Eleve|Prof|Diaporama|Zip|isCours|copyFiles","Param�tres",100101)
End If

'On r�cup�re tout de suite les infos du dossier FTP
Set FTP=0
If (objFSO.FileExists(FTPfolderFile)) Then
  Set file = objFSO.OpenTextFile(FTPfolderFile, 1)
  ftpDir = file.ReadAll
  remoteDir = "/" & ftpDir
  FTP=1
End If

'******************************
'Compilation Tex 
'******************************
Set objShell = CreateObject("WScript.Shell")
comspec = objShell.ExpandEnvironmentStrings("%comspec%")

for i=1 To 3 Step 1

  'Version �l�ve
  If i=1 And mid(parametres,1,1)=1 Then
    If mid(parametres,5,1)=0 Then
      'Version �l�ve classique (sans corrig�)
      commande = "pdflatex -synctex=1 -interaction=nonstopmode -job-name=""" & baseName & """ ""\def\ChoixDeVersion{E} \input{" & fileName & "}"""
    Else
      'Version �l�ve pour cours (On remplace les zones � compl�ter par du texte normal)
      commande = "pdflatex -synctex=1 -interaction=nonstopmode -job-name=""" & baseName & """ ""\def\ChoixDeVersion{Pub} \input{" & fileName & "}"""
    End If
    compilation=1
    
  'Version prof
  ElseIf i=2 And mid(parametres,2,1)=1 Then
    commande = "pdflatex -synctex=1 -interaction=nonstopmode -job-name=""" & baseName & "-Prof"" ""\def\ChoixDeVersion{P} \input{" & fileName & "}"""
    compilation=1

  'Version �l�ve (cours "� trous")
  ElseIf i=3 And mid(parametres,5,1)=1 Then
    commande = "pdflatex -synctex=1 -interaction=nonstopmode -job-name=""" & baseName & "-Eleve"" ""\def\ChoixDeVersion{E} \input{" & fileName & "}"""
    compilation=1

  'Pas de compilation
  Else
    compilation=0
  End If

  If compilation=1 Then
    'On compile 2 fois par fichier
    for j=1 To 2 Step 1
      Set objExec = objShell.Exec(commande)
      Do
        WScript.StdOut.WriteLine(objExec.StdOut.ReadLine())
      Loop While Not objExec.Stdout.atEndOfStream
        WScript.StdOut.WriteLine(objExec.StdOut.ReadAll)
    Next
  End If
Next

Set objShell = Nothing

'******************************
'Cr�ation du zip (si pr�cis� dans les param�tres et si on pr�voit un transfert FTP)
'******************************
If (mid(parametres,4,1)=1) And (FTP=1) Then

  'On cr�e d'abord un nouveau dossier dans lequel on va copier les images et le fichier tex
  If not(objFSO.FolderExists(tmpFolder)) Then
    objFSO.CreateFolder(tmpFolder)
  End If
  newfolder = tmpFolder & baseName
  If not(objFSO.FolderExists(newfolder)) Then
    objFSO.CreateFolder(newfolder)
    objFSO.CopyFile fullPath, newfolder & "\" & fileName 'Copie du fichier Tex
    If objFSO.FolderExists(pathName & "\Src") Then 'Copie du dossier Ressources   
      objFSO.CreateFolder(newfolder & "\Src")
      objFSO.CopyFolder pathName & "\Src", newfolder & "\Src" 
    End If 
  End If

  'On cr�e le zip
  commande = zipExe & " a -tzip """ & pathName & "\" & baseName & "-Sources.zip"" """ & newfolder & """"
  Set objShell = CreateObject("WScript.Shell")
  comspec = objShell.ExpandEnvironmentStrings("%comspec%")

  Set objExec = objShell.Exec(commande)
  Do
    WScript.StdOut.WriteLine(objExec.StdOut.ReadLine())
  Loop While Not objExec.Stdout.atEndOfStream
    WScript.StdOut.WriteLine(objExec.StdOut.ReadAll)

  Set objShell = Nothing

  'On efface le dossier temporaire
  objFSO.DeleteFolder newfolder, True  
End If


'******************************
'Copie des PDF dans le dossier parent
'******************************
If mid(parametres,6,1)=1 Then
  If mid(parametres,1,1)=1 Then
    fichier = baseName & ".pdf" 'Fichier �l�ve 
    objFSO.CopyFile fichier, parentFolder & "\" & fichier 'Copie du fichier dans le dossier parent
  End If
  If mid(parametres,2,1)=1 Then
    fichier = baseName & "-Prof.pdf" 'Fichier prof 
    objFSO.CopyFile fichier, parentFolder & "\" & fichier 'Copie du fichier dans le dossier parent
  End If
  If mid(parametres,5,1)=1 Then
    fichier = baseName & "-Eleve.pdf" 'Fichier �l�ve "� trous" 
    objFSO.CopyFile fichier, parentFolder & "\" & fichier 'Copie du fichier dans le dossier parent
  End If
End If


'******************************
'Gestion du fichier numero de version
'******************************
If mid(parametres,6,1)=1 Then

  'Suppression des fichiers pr�c�dents s'ils existent
  objFSO.DeleteFile parentFolder & "\*.ver" 
  
  'Cr�ation du fichier
  If (objFSO.FileExists(baseName & ".version")) Then
    Set fileVersion = objFSO.OpenTextFile(baseName & ".version",1)
    versionNumber = fileVersion.ReadLine
    newVersionFileName = parentFolder & "\@_v" & versionNumber & ".ver"
    Set objFile = objFSO.CreateTextFile(newVersionFileName,True)
  End If
End If


'******************************
'Upload FTP et copie dans le dossier parent
'******************************
If (FTP=1) Then

  Set objShell = CreateObject("WScript.Shell")
  comspec = objShell.ExpandEnvironmentStrings("%comspec%")
  
  If mid(parametres,1,1)=1 Then
    fichier = baseName & ".pdf" 'Fichier �l�ve 
    FTPupload fichier, remoteDir
    If mid(parametres,6,1)=1 Then
      objFSO.CopyFile fichier, parentFolder & "\" & fichier 'Copie du fichier dans le dossier parent
    End If
  End If
  If mid(parametres,2,1)>0 Then
    fichier = baseName & "-Prof.pdf" 'Fichier prof 
    FTPupload fichier, remoteDir
    If mid(parametres,6,1)=1 Then
      objFSO.CopyFile fichier, parentFolder & "\" & fichier 'Copie du fichier dans le dossier parent
    End If
  End If
  If mid(parametres,3,1)=1 Then
    fichier = parentFolder & "\" & baseName & "-Diaporama.pptx" 'Diaporama (dans le dossier parent) 
    FTPupload fichier, remoteDir
  End If
  If mid(parametres,4,1)=1 Then
    zipFile = baseName & "-Sources.zip" 'Fichier zip 
    FTPupload zipFile, remoteDir
  End If
  If mid(parametres,1,1)=1 Or mid(parametres,2,1)=1 Then
    fichier = baseName & ".version" 'Fichier de version 
    FTPupload fichier, remoteDir
  End If
  
  'Fichier de date
  fichier = baseName & ".date" 'Fichier de date 
  dateFile = pathName & "\" & fichier
  Set objFile = objFSO.CreateTextFile(dateFile,True)
  objFile.Write Date
  objFile.Close
  FTPupload fichier, remoteDir
  
  ' On envoie tous les fichiers en ftp
  commande = "ncftpbatch"
  Set objExec = objShell.Exec(commande)
  Do
    WScript.StdOut.WriteLine(objExec.StdOut.ReadLine())
  Loop While Not objExec.Stdout.atEndOfStream
    WScript.StdOut.WriteLine(objExec.StdOut.ReadAll)
  
  Set objShell = Nothing
  
  'On efface les fichiers inutiles
  If mid(parametres,4,1)=1 Then
    objFSO.DeleteFile zipFile 
  End If
  objFSO.DeleteFile dateFile 
  
  Set objFSO = Nothing
  
  message = baseName & "|" & ftpDir & "|" & mid(parametres,1,1) & "-" & mid(parametres,2,1) & "-" & mid(parametres,3,1) & "-" & mid(parametres,4,1)
Else
  message = "compilation OK"
  Set objShell = Nothing
  Set objFSO = Nothing
End If

messageDeFin = InputBox("Tout a fonctionn� correctement","Ok !",message)

'------------------------------------------------------------------------------
'Upload FTP
'------------------------------------------------------------------------------
Sub FTPupload(localFile, remoteDir)
  commande = "ncftpput -bb -u " & FTPuser & " -p " & FTPpwd & " " & FTPhost & " """ & remoteDir & """ " & """" & localFile & """"
  
  Set objExec = objShell.Exec(commande)
  Do
    WScript.StdOut.WriteLine(objExec.StdOut.ReadLine())
  Loop While Not objExec.Stdout.atEndOfStream
    WScript.StdOut.WriteLine(objExec.StdOut.ReadAll)
End Sub
