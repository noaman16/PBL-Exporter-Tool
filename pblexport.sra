$PBExportHeader$pblexport.sra
$PBExportComments$PBL bulk-export utility
forward
global type pblexport from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global variables
end variables

global type pblexport from application
string appname = "pblexport"
end type
global pblexport pblexport

on pblexport.create
appname="pblexport"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on pblexport.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;string ls_target, ls_export, ls_name
long ll_count

// pick the project target
if GetFileOpenName("Select Project Target (.pbt)", ls_target, ls_name, "pbt", &
     "Target (*.pbt),*.pbt,Workspace (*.pbw),*.pbw,All Files (*.*),*.*") <> 1 then
	Halt Close
end if

// pick the export destination folder
if GetFolder("Select Export Folder", ls_export) <> 1 then
	Halt Close
end if

ll_count = f_export_pbls(ls_target, ls_export)

Halt Close
end event

