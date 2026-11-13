$PBExportHeader$w_pblexport.srw
$PBExportComments$Asks for the POS path and the POS export path, then runs the export
forward
global type w_pblexport from window
end type
type st_status from statictext within w_pblexport
end type
type cb_close from commandbutton within w_pblexport
end type
type cb_export from commandbutton within w_pblexport
end type
type cb_export_path from commandbutton within w_pblexport
end type
type sle_export_path from singlelineedit within w_pblexport
end type
type st_export_path from statictext within w_pblexport
end type
type cb_pos_path from commandbutton within w_pblexport
end type
type sle_pos_path from singlelineedit within w_pblexport
end type
type st_pos_path from statictext within w_pblexport
end type
end forward

global type w_pblexport from window
integer width = 2798
integer height = 772
boolean titlebar = true
string title = "PBL Export"
boolean controlmenu = true
boolean minbox = true
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
st_status st_status
cb_close cb_close
cb_export cb_export
cb_export_path cb_export_path
sle_export_path sle_export_path
st_export_path st_export_path
cb_pos_path cb_pos_path
sle_pos_path sle_pos_path
st_pos_path st_pos_path
end type
global w_pblexport w_pblexport

on w_pblexport.create
this.st_status=create st_status
this.cb_close=create cb_close
this.cb_export=create cb_export
this.cb_export_path=create cb_export_path
this.sle_export_path=create sle_export_path
this.st_export_path=create st_export_path
this.cb_pos_path=create cb_pos_path
this.sle_pos_path=create sle_pos_path
this.st_pos_path=create st_pos_path
this.Control[]={this.st_status,&
this.cb_close,&
this.cb_export,&
this.cb_export_path,&
this.sle_export_path,&
this.st_export_path,&
this.cb_pos_path,&
this.sle_pos_path,&
this.st_pos_path}
end on

on w_pblexport.destroy
destroy(this.st_status)
destroy(this.cb_close)
destroy(this.cb_export)
destroy(this.cb_export_path)
destroy(this.sle_export_path)
destroy(this.st_export_path)
destroy(this.cb_pos_path)
destroy(this.sle_pos_path)
destroy(this.st_pos_path)
end on

type st_status from statictext within w_pblexport
integer x = 73
integer y = 400
integer width = 1760
integer height = 180
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Select the POS path, then click Export."
boolean focusrectangle = false
end type

type cb_close from commandbutton within w_pblexport
integer x = 2318
integer y = 400
integer width = 402
integer height = 112
integer taborder = 60
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Close"
boolean cancel = true
end type

event clicked;Close(parent)
end event

type cb_export from commandbutton within w_pblexport
integer x = 1883
integer y = 400
integer width = 402
integer height = 112
integer taborder = 50
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Export"
boolean default = true
end type

event clicked;string ls_pos, ls_export
long   ll_count

ls_pos = Trim(sle_pos_path.text)
ls_export = Trim(sle_export_path.text)

if ls_pos = '' then
	MessageBox('PBL Export', 'Select the POS path first.', Exclamation!)
	sle_pos_path.SetFocus()
	return
end if
if not DirectoryExists(ls_pos) then
	MessageBox('PBL Export', 'POS path not found:~r~n' + ls_pos, Exclamation!)
	sle_pos_path.SetFocus()
	return
end if
if ls_export = '' then
	// same default the engine uses
	ls_export = ls_pos
	if Right(ls_export,1) <> '\' then ls_export = ls_export + '\'
	ls_export = ls_export + 'WS_OBJECTS'
	sle_export_path.text = ls_export
end if

this.enabled = false
st_status.text = 'Exporting, please wait...'
SetPointer(HourGlass!)

ll_count = f_export_pbls(ls_pos, ls_export, false)

if ll_count >= 0 then
	st_status.text = String(ll_count) + ' objects exported to ' + ls_export
else
	st_status.text = 'Export failed.'
end if
this.enabled = true
end event

type cb_export_path from commandbutton within w_pblexport
integer x = 2318
integer y = 228
integer width = 402
integer height = 100
integer taborder = 40
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Select path"
end type

event clicked;string ls_dir

ls_dir = Trim(sle_export_path.text)
if ls_dir = '' then ls_dir = Trim(sle_pos_path.text)

if GetFolder('Select the POS export path (where the source files are written)', ls_dir) = 1 then
	sle_export_path.text = ls_dir
end if
end event

type sle_export_path from singlelineedit within w_pblexport
integer x = 603
integer y = 228
integer width = 1682
integer height = 100
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
boolean autohscroll = true
borderstyle borderstyle = stylelowered!
end type

type st_export_path from statictext within w_pblexport
integer x = 73
integer y = 244
integer width = 512
integer height = 72
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "POS Export Path:"
boolean focusrectangle = false
end type

type cb_pos_path from commandbutton within w_pblexport
integer x = 2318
integer y = 80
integer width = 402
integer height = 100
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Select path"
end type

event clicked;string ls_dir

ls_dir = Trim(sle_pos_path.text)

if GetFolder('Select the POS path (the folder with the .pbt and .pbl files)', ls_dir) = 1 then
	sle_pos_path.text = ls_dir
	// suggest the usual export folder if none was chosen yet
	if Trim(sle_export_path.text) = '' then
		if Right(ls_dir,1) <> '\' then ls_dir = ls_dir + '\'
		sle_export_path.text = ls_dir + 'WS_OBJECTS'
	end if
end if
end event

type sle_pos_path from singlelineedit within w_pblexport
integer x = 603
integer y = 80
integer width = 1682
integer height = 100
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
boolean autohscroll = true
borderstyle borderstyle = stylelowered!
end type

type st_pos_path from statictext within w_pblexport
integer x = 73
integer y = 96
integer width = 512
integer height = 72
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "POS Path:"
boolean focusrectangle = false
end type

