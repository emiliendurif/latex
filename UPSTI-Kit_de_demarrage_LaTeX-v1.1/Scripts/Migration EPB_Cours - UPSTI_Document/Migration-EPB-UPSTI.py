'''
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script de migration EPB_Cours -> UPSTI_Document                                  
% -----------                                                                        
% Auteur: Emmanuel Pinault-Bigeard                                                   
% email: s2i@pinault-bigeard.com
% -----------
% Version: 1.0 - 2017/11/23                                                                       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://s2i.pinault-bigeard.com
% CC BY-NC-SA 2.0 FR - http://creativecommons.org/licenses/by-nc-sa/2.0/fr/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

'''
import sys
from tkinter import *
from tkinter.filedialog import askopenfilename
import os, os.path   
from shutil import copyfile

fname = "unassigned"

def openFile():
    global fname
    fname = askopenfilename()
    root.destroy()

if __name__ == '__main__':

    root = Tk()
    Button(root, text='Choisir le fichier à traiter', command = openFile).pack(fill=X)
    mainloop()

    
#    print (fname)
    
    if len(fname) > 0:
        rep=os.path.dirname(fname)
        fic=os.path.basename(fname)
        (nomfic, extension) = os.path.splitext(fic)

        # Renommage des fichiers .epb en .upsti
        fichierParametres = rep + os.path.sep + "@parametres."
        fichierDossierFTP = rep + os.path.sep + "@dossierFTP." 
        if  os.path.exists(fichierParametres + "epb")==True:
            os.rename(fichierParametres + "epb",fichierParametres + "upsti")
        if  os.path.exists(fichierDossierFTP + "epb")==True:
            os.rename(fichierDossierFTP + "epb",fichierDossierFTP + "upsti")
     
        # Backup
        newName = rep + os.path.sep + nomfic + "_ini" + extension 
        copyfile(fname, newName)    
    
        Src = open(fname,"r" ) # on ouvre le fichier texte source
        i=Src.read() # on stocke le contenu du fichier source dans la variable i (chaine de caractères) 
        Src.close()

        remplacements=[]
        remplacements+=[
            [" Package EPB_Cours"," Package UPSTI_Document"],
            ["\\usepackage{EPB_Cours}","\\RequirePackage{UPSTI_Document}"],
            [" Version du document"," Versioning"],
            [" Destination du document"," Version du document (pour la compilation)"],
            ["\\newcommand{\\EPBVariante}{0}","\\newcommand{\\EPBVariante}{3}"],
            ["EPBapplication","UPSTIappli"],
            ["EPBappli","UPSTIapplication"],
            ["EPBCorrectionTab","UPSTIcorrection[1]"],
            ["EPBCorrection","UPSTIcorrection"],
            ["EPBCorrect","UPSTIcorrectionEnv"],
            ["EPBActionTP","UPSTIactionTP"],
            ["EPBAct","UPSTIactivite"],
            ["\\legend{","\\captionof{figure}{"],
            ["EPBitemize","itemize"]
        ]

        majuscules=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        for lettre in majuscules:
            remplacements += [["EPB"+lettre,"UPSTI"+lettre.lower()]]
        
        remplacements+=[
            ["EPB","UPSTI"],
            ["UPSTIdR","UPSTIDR"],
            ["UPSTIdRes","UPSTIDRes"],
            ["UPSTIdT","UPSTIDT"],
            ["UPSTIidDocumentDestination","UPSTIidVersionDocument"],
            ["UPSTItype","UPSTItypeDocument"],
            ["UPSTIcouleurProf","UPSTIcouleurCorrige"],
            ["UPSTIcouleurACompleter","UPSTIcouleurZoneACompleter"],
            ["UPSTIzoneACompleter","UPSTIaCompleterEnv"],
            ["UPSTIthemeColle","UPSTItitreEnTete"],
            ["UPSTIcompetenceRef","UPSTIcompetenceCode"],
            ["UPSTIquadReponse","UPSTIquadrillage"],
            ["UPSTIlinespaceMinipage","UPSTIparskipMinipage"],
            ["boxedCorText","UPSTIcadreTextCor"],
            ["boxedCor","UPSTIcadreMathCor"],
            ["boxed","UPSTIcadreMath"],
            ["UPSTIBlackGrid","grillePourBlack"],
            ["UPSTIremarqueCond[","UPSTIremarqueCond[0]["],
            ["UPSTIenTeteColor","UPSTIcustomColor1"],
            ["PoutreDiagAxesCfg","PoutreDiagCfg"],
            ["{pes}","{\\pes}"],
            ["{ext}","{\\ext}"],
            ["parametrageAngulaireInTikz","parametrageAngulaireFig"],
            ["figurePlaneMultipleInTikz","figurePlaneMultipleFig"]
        ]

        # Pour les colles seulement
        # remplacements+=[["\\RequirePackage{UPSTI_Document}","\\RequirePackage[kholle]{UPSTI_Document}"]]

        remplacements+=[
            ["newcommand{\\UPSTIidClasse}{1}","newcommand{\\UPSTIidClasse}{101}"],
            ["newcommand{\\UPSTIidClasse}{2}","newcommand{\\UPSTIidClasse}{102}"],
            ["newcommand{\\UPSTIidClasse}{3}","newcommand{\\UPSTIidClasse}{103}"],
            ["newcommand{\\UPSTIidClasse}{4}","newcommand{\\UPSTIidClasse}{104}"],
            ["newcommand{\\UPSTIidClasse}{5}","newcommand{\\UPSTIidClasse}{105}"],
            ["newcommand{\\UPSTIidClasse}{6}","newcommand{\\UPSTIidClasse}{106}"],
            ["newcommand{\\UPSTIidClasse}{7}","newcommand{\\UPSTIidClasse}{107}"],
            ["newcommand{\\UPSTIidClasse}{8}","newcommand{\\UPSTIidClasse}{108}"],
            ["newcommand{\\UPSTIidClasse}{105}","newcommand{\\UPSTIidClasse}{1}"],
            ["newcommand{\\UPSTIidClasse}{9}","newcommand{\\UPSTIidClasse}{2}"],
            ["newcommand{\\UPSTIidClasse}{104}","newcommand{\\UPSTIidClasse}{4}"],
            ["newcommand{\\UPSTIidClasse}{108}","newcommand{\\UPSTIidClasse}{5}"],
            ["newcommand{\\UPSTIidClasse}{103}","newcommand{\\UPSTIidClasse}{7}"],
            ["newcommand{\\UPSTIidClasse}{106}","newcommand{\\UPSTIidClasse}{8}"],
            ["newcommand{\\UPSTIidClasse}{101}","newcommand{\\UPSTIidClasse}{10}"],
            ["newcommand{\\UPSTIidClasse}{102}","newcommand{\\UPSTIidClasse}{11}"],
            ["newcommand{\\UPSTIidClasse}{107}","newcommand{\\UPSTIidClasse}{13}"]
        ]
 
        remplacements+=[
            ["newcommand{\\UPSTIidFiliere}{1}","newcommand{\\UPSTIidFiliere}{101}"],
            ["newcommand{\\UPSTIidFiliere}{2}","newcommand{\\UPSTIidFiliere}{1}"],
            ["newcommand{\\UPSTIidFiliere}{3}","newcommand{\\UPSTIidFiliere}{2}"],
            ["newcommand{\\UPSTIidFiliere}{4}","newcommand{\\UPSTIidFiliere}{3}"],
            ["newcommand{\\UPSTIidFiliere}{101}","newcommand{\\UPSTIidFiliere}{4}"]
        ]

        for k in range(len(remplacements)):
            i=i.replace(remplacements[k][0],remplacements[k][1]) # on remplace 
    
        Src = open(fname,"w" ) # on ouvre le fichier texte source
        Src.write(i) # on écrit dans le fichier
        Src.close() # et on ferme les fichiers
    
