# abap-smartform-translator

# ABAP Smartform Translator

![ABAP Version](https://img.shields.io/badge/ABAP-7.40%2B-blue)
![License](https://img.shields.io/badge/License-MIT-green)

A lightweight, dynamic **runtime translation tool** for SAP Smartforms and Adobe Forms.
It decouples text management from form development, allowing functional consultants or users to maintain labels via a simple database table (`SM30`), bypassing the complex standard SE63 workflow.

## 🚀 Why use this?

* **No more SE63:** Forget about the painful standard translation process for Smartforms.
* **Zero Hardcoding:** Keep your form logic clean. No more `IF sy-langu = 'D'. text = 'Kunde'. ENDIF`.
* **Hot-Swap Texts:** Change a label description in Production without a Transport Request.
* **Generic:** Works with **any** ABAP structure or Form interface using RTTI.
* **Performance:** Optimized with table buffering to ensure zero impact on print times.
* **Unit Tested:** Includes built-in ABAP Unit tests.

## 🛠️ Installation & Setup

### 1. Create the Database Table
Create a Transparent Table named **`ZDB_FORM_TRANS`** in `SE11`.

| Field | Key | Data Element | Description |
| :--- | :---: | :--- | :--- |
| `MANDT` | ✅ | `MANDT` | Client |
| `FORM` | ✅ | `TDSFNAME` | Smartform Name |
| `FIELDNAME` | ✅ | `FIELDNAME` | Field Name in Structure |
| `LANGU` | ✅ | `SPRAS` | Language Key |
| `DESCR` | | `TEXT50` | Translated Text / Label |

> **⚠️ Important Performance Setting:**
> In `SE11` -> Technical Settings:
> * **Buffering:** "Buffering Activated"
> * **Buffering Type:** "Fully Buffered"
> * **Translation:** "Table is language-dependent but not translation-relevant"

### 2. Install the Class
Create the class `ZCL_FORM_TRANSLATION`. You can copy the source code from the `src/` folder of this repository.

## 💻 Usage

### In your Smartform Driver Program / Print Program

1.  Define a structure for your labels/texts in the Smartform Global Definitions or the Driver Program.
2.  Populate it with default values (optional).
3.  Call the translator **before** calling the Smartform Function Module.

```abap
DATA: BEGIN OF gs_labels,
        title        TYPE string,
        footer_note  TYPE string,
        customer_lbl TYPE string,
      END OF gs_labels.

" 1. Initialize (Optional defaults)
gs_labels-title = 'Invoice'.

" 2. Translate dynamically based on Language and DB Configuration
NEW zcl_form_translation( )->translate_form(
  EXPORTING
    iv_formname      = 'ZINVOICE_FORM'   " Key in ZDB_FORM_TRANS
    iv_langu         = p_langu           " e.g., NAST-SPRAS
  CHANGING
    cs_form_elements = gs_labels         " The structure to be translated
).

" 3. The gs_labels structure now contains the translated texts from ZDB_FORM_TRANS
"    Pass this structure to your Smartform / Adobe Form interface.
