# PBL Export Tool (`pblexport`)

A small PowerBuilder 2019 utility that **bulk-exports every object from every PBL** in a project
to individual source files (`.srw`, `.sru`, `.srd`, `.srf`, …) — the same layout the IDE's manual
"Export" produces, but for the whole project at once instead of one object at a time.

Built because exporting objects one-by-one from the Library painter is slow. Point it at a project
target and an output folder, and it exports everything.

---

## What it produces

For a target whose `LibList` contains, say, `app.pbl;module1.pbl;module2.pbl;…`, running
the tool with output folder `C:\export` creates:

```
C:\export\
   app.pbl.src\
      f_myfunction.srf
      n_myobject.sru
      w_main.srw
      ...
   module1.pbl.src\
      w_orders.srw
      ...
   module2.pbl.src\
      d_customers.srd
      ...
```

Each file is written in **UTF-16LE** (the same encoding PowerBuilder uses for native exports), so
the files re-import cleanly with `Entry → Import`.

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

> Proxy objects (`.srx`) are intentionally **not** exported — the PB 2019 enum for them differs and
> they are not used in the target applications. Add them back only if a project actually contains
> proxy objects.

---

## How it works

The tool is a tiny standalone PowerBuilder application made of just two objects:

1. **`pblexport` (application object, `.sra`)** — its `open` event:
   - Prompts for a project **`.pbt`** file via `GetFileOpenName()`.
   - Prompts for an **export folder** via `GetFolder()`.
   - Calls `f_export_pbls(...)`, then exits (`Halt Close`).

2. **`f_export_pbls` (global function, `.srf`)** — the engine:
   - `as_target`  = full path to the `.pbt`/`.pbw` **or** a `;`-separated list of `.pbl` paths.
   - `as_exportdir` = output root folder.
   - Reads the `LibList "..."` line from the target file to get every `.pbl`.
   - For each `.pbl`, for each object type, it calls the built-in
     **`LibraryDirectory()`** (to list objects of that type) and
     **`LibraryExport()`** (to get each object's source), and writes the source file.
   - Returns the number of objects exported.

Because it uses the built-in `LibraryDirectory` / `LibraryExport` functions, it works on **any**
`.pbl` by path and needs no ORCA DLL, no source control, and no special setup.

---

## One-time setup (import into PowerBuilder 2019)

The two source files live in `E:\pblexport_import\`:
`pblexport.sra` and `f_export_pbls.srf`.

1. **File → New → Workspace** → create a workspace (e.g. `pbltools`).
2. **File → New → Target → Application** → name it `pblexport`, library `pblexport.pbl`, Finish.
3. **Tools → Library** → select `pblexport.pbl` → **Entry → Import…** → select **both**
   `pblexport.sra` and `f_export_pbls.srf` → **Open** → **Yes/Replace** for the app object.
4. Right-click `pblexport.pbl` → **Regenerate**. The Errors tab should be clean.

> If replacing the app object during import is awkward, import only `f_export_pbls.srf`, then open
> the generated `pblexport` app object and paste the `open`-event code from `pblexport.sra` into it.

---

## How to use

### Run from the IDE (quickest)
1. Make sure `pblexport` is the active target (bold in the System Tree).
2. Press **Ctrl+R** (Run).
3. **Select Project Target (.pbt)** → choose the project you want to export
   (e.g. `C:\projects\myapp\myapp.pbt`).
4. **Select Export Folder** → choose the output folder (e.g. `E:\export`).
5. It exports and shows **"Export complete — N objects exported."**

### Run as a standalone `.exe` (reuse without the IDE)
1. **File → New → Project → Application** wizard.
2. Set **Executable File Name** = `pblexport.exe`, **Pcode**, **Platform: 32-bit**.
3. Save the project, right-click it → **Deploy** to build `pblexport.exe`.
4. Ship the exe with the matching **32-bit PB Runtime** (the same runtime version your application uses).
5. Double-click `pblexport.exe` → pick a `.pbt` → pick a folder → done.

---

## Notes & limitations

- **Output encoding:** UTF-16LE (matches native PB export) — files re-import cleanly.
- **Bitness:** run it under the same PB runtime bitness as the objects you're exporting
  (typically **32-bit**, matching the IDE and the deployed application).
- **Overwrites:** existing files in the target folder for the same object are replaced.
- **No proxy objects** (`.srx`) — see the note above.
- The tool reads the PBL list from the target's `LibList`; if you pass a `;`-separated list of
  `.pbl` paths as the first argument instead of a `.pbt`, it will use that list directly.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `C0060 Illegal enumerated constant` on compile | An object-type enum name is wrong for this PB build — remove/adjust that row in `f_export_pbls`. (Proxy was already removed for this reason.) |
| "No .pbl found in target/list" | The `.pbt` had no readable `LibList`, or the path passed wasn't a `.pbt`/`.pbw`/`.pbl` list. Check the target path. |
| Some objects missing | They may be a type not in the 10 handled (e.g. proxy). Add the type's `DirXxx!`/`ExportXxx!`/extension row. |
| Exported files won't re-import | Confirm they are UTF-16LE and start with `$PBExportHeader$` — the tool writes this automatically. |

---

## Files in this project

| File | Purpose |
|------|---------|
| `pblexport.sra` | Application object — prompts for paths, calls the engine |
| `f_export_pbls.srf` | Global function — the export engine |
| `README.md` | This document |

*Author: Noaman*
