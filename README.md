# PBL Export Tool (`pblexport`)

A small PowerBuilder 2019 utility that **bulk-exports every object from every PBL** in a project
to individual source files (`.srw`, `.sru`, `.srd`, `.srf`, …), so the code can be diffed and
committed as text.

Give it the project folder. It finds the `.pbt`, reads its library list and exports everything.

---

## How to use

### With the window

Double-click `pblexport.exe`. The **PBL Export** window asks for two paths:

| Field | What to pick |
|-------|--------------|
| **POS Path** | The project folder (the one with the `.pbt` and `.pbl` files). |
| **POS Export Path** | Where the source files are written. Filled in as `<POS Path>\WS_OBJECTS` when you pick the POS path; change it with **Select path** or by typing. |

Click **Export**. A message box shows the totals, and the same summary stays at the bottom of the
window. You can change the paths and export again without closing it.

### From the command line

```
pblexport.exe "<project folder>" ["<export folder>"]
```

| Argument | Meaning |
|----------|---------|
| `<project folder>` | Folder that holds the `.pbt` and `.pbl` files. A `.pbt` path also works. |
| `<export folder>` | Optional. Default is `<project folder>\WS_OBJECTS`. |

Examples:

```
pblexport.exe "E:\new-setup-pos\2012R2\VVG-POS"
pblexport.exe "E:\new-setup-pos\2012R2\VVG-POS" "E:\VVG-POS-USA19-SRC"
```

With arguments it runs silently (no dialogs) and writes the result to
`<export folder>\pblexport.log`: one line per PBL, then a total. Check the last line of the log:

```
OK       payment.pbl : 52 objects
...
353 objects exported from 17 PBLs to E:\...\WS_OBJECTS\ (0 stale files removed, 0 failed)
```

---

## What it produces

```
<export folder>\
   vvgmobile.pbl.src\
      vvgmobile.sra
      w_main.srw
      ...
   payment.pbl.src\
      d_customers.srd
      ...
   pblexport.log
```

- **One folder per PBL**, one file per object.
- **UTF-8 with BOM**, CRLF line endings. Git shows these as text diffs, and PowerBuilder imports
  them with `Entry → Import`.
- Each file starts with `$PBExportHeader$` (and `$PBExportComments$` when the object has a
  comment), the same as an export from the Library painter.
- **Stale files are removed.** If an object was deleted from a PBL, its old `.sr?` file in that
  PBL's folder is deleted, so the folder always mirrors the PBL. Other files are left alone.
- Existing files for the same object are overwritten.

Which PBLs are exported:

- Folder with a `.pbt`: the `.pbl` entries of its `LibList` (`.pbd` entries are skipped).
- Folder without a `.pbt`: every `.pbl` in the folder.
- A `;`-separated list of `.pbl` paths can be passed instead of a folder; the export folder is
  then required.

---

## Object types exported

| Type | Extension |
|------|-----------|
| Application | `.sra` |
| Window | `.srw` |
| User object | `.sru` |
| DataWindow | `.srd` |
| Menu | `.srm` |
| Function (global) | `.srf` |
| Structure | `.srs` |
| Query | `.srq` |
| Pipeline | `.srp` |
| Project | `.srj` |

Proxy objects (`.srx`) are not exported.

---

## Requirements

- **32-bit PowerBuilder 2019 R3 runtime** (19.2.0.2803). `pblexport.xml`, next to the exe, points
  at the runtime folder; edit it if the runtime is installed somewhere else.
- The PBLs must be PowerBuilder 2019 format or older.
- The PowerBuilder IDE can stay open while exporting.

---

## Files in this project

| File | Purpose |
|------|---------|
| `pblexport.exe`, `pblexport.xml` | Ready-to-run tool and its runtime path |
| `pblexport.sra` | Application object: reads the command line, or opens the window when there are no arguments |
| `w_pblexport.srw` | The window that asks for the POS path and the POS export path |
| `f_export_pbls.srf` | Global function: the export engine |
| `n_pblexport_dir.sru` | Lists files in a folder (Windows `FindFirstFile`) |
| `s_pblexport_finddata.srs` | Structure used by `n_pblexport_dir` |
| `pblexport.pbl`, `.pbt`, `.pbw` | The PowerBuilder library, target and workspace |

### Rebuilding the exe after a code change

Open `pblexport.pbw` in PowerBuilder 2019, import the changed source files into `pblexport.pbl`
in this order: `s_pblexport_finddata.srs`, `n_pblexport_dir.sru`, `f_export_pbls.srf`,
`w_pblexport.srw`, `pblexport.sra`. Then do a full build and deploy a 32-bit Pcode executable named `pblexport.exe`.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Nothing happens, no log | The PB runtime was not found. Check the path in `pblexport.xml`. |
| `ERROR Folder or target not found` in the log | The first argument is not an existing folder or `.pbt`. Quote paths that contain spaces. |
| `ERROR No .pbl found` | The folder has no `.pbt` with a `LibList` and no `.pbl` files. |
| `MISSING <path>` lines | A PBL named in the `LibList` is not on disk; the rest are still exported. |
| `FAILED <object>` lines | PowerBuilder could not export that object; the rest are still exported. |

*Author: Noaman*
