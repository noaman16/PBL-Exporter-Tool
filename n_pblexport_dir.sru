$PBExportHeader$n_pblexport_dir.sru
$PBExportComments$Lists the files in a folder that match a wildcard pattern
forward
global type n_pblexport_dir from nonvisualobject
end type
end forward

global type n_pblexport_dir from nonvisualobject
end type
global n_pblexport_dir n_pblexport_dir

type prototypes
function long FindFirstFileW (string lpfilename, ref s_pblexport_finddata lpfinddata) library "kernel32.dll"
function boolean FindNextFileW (long hfindfile, ref s_pblexport_finddata lpfinddata) library "kernel32.dll"
function boolean FindClose (long hfindfile) library "kernel32.dll"
end prototypes

forward prototypes
public function long of_list (string as_pattern, ref string as_files[])
end prototypes

public function long of_list (string as_pattern, ref string as_files[]);// of_list: file names (no path, no sub-folders) matching as_pattern, e.g. 'C:\pos\*.pbt'.
// Returns the number of names placed in as_files.
string ls_empty[]
long   ll_handle, ll_count
s_pblexport_finddata lstr_data

as_files = ls_empty

ll_handle = FindFirstFileW(as_pattern, lstr_data)
if ll_handle = -1 then return 0

do
	// attribute bit 16 = directory
	if Mod(Int(lstr_data.fileattributes / 16), 2) = 0 then
		ll_count ++
		as_files[ll_count] = String(lstr_data.filename)
	end if
loop while FindNextFileW(ll_handle, lstr_data)

FindClose(ll_handle)
return ll_count
end function

on n_pblexport_dir.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_pblexport_dir.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

