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

event open;// Usage:  pblexport.exe "<project folder>" ["<export folder>"]
//   <project folder> = folder holding the .pbt and .pbl files (a .pbt path also works)
//   <export folder>  = optional; default is <project folder>\WS_OBJECTS
// With arguments it runs silently and writes <export folder>\pblexport.log.
// Without arguments it opens w_pblexport, which asks for the POS path and the POS export path.
string  ls_cmd, ls_args[], ls_arg, ls_target, ls_export
long    ll_p, ll_n, ll_count

// split the command line into arguments (double quotes keep spaces together)
ls_cmd = Trim(CommandParm())
do while Len(ls_cmd) > 0
	if Left(ls_cmd,1) = '"' then
		ll_p = Pos(ls_cmd,'"', 2)
		if ll_p = 0 then ll_p = Len(ls_cmd) + 1
		ls_arg = Mid(ls_cmd, 2, ll_p - 2)
	else
		ll_p = Pos(ls_cmd,' ')
		if ll_p = 0 then ll_p = Len(ls_cmd) + 1
		ls_arg = Left(ls_cmd, ll_p - 1)
	end if
	ls_cmd = Trim(Mid(ls_cmd, ll_p + 1))
	if Len(Trim(ls_arg)) > 0 then
		ll_n ++
		ls_args[ll_n] = Trim(ls_arg)
	end if
loop

if ll_n >= 1 then
	// command line: export silently and exit
	ls_target = ls_args[1]
	if ll_n >= 2 then ls_export = ls_args[2]
	ll_count = f_export_pbls(ls_target, ls_export, true)
	Halt Close
end if

// no arguments: show the window that asks for the two paths
Open(w_pblexport)
end event

