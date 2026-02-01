*&---------------------------------------------------------------------*
*& Report ZABAP_TRANSLATION_SAMPLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_translation_sample.

TYPES: BEGIN OF t_form_data,
         header_label  TYPE string,
         footer_note   TYPE string,
         customer_addr TYPE string,
       END OF t_form_data.

DATA: gs_form_data TYPE t_form_data.

gs_form_data-header_label  = 'Default Header'.
gs_form_data-footer_note   = 'Default Footer'.
gs_form_data-customer_addr = 'Default Customer Address'.

WRITE: / 'Before Translation:', gs_form_data-header_label,gs_form_data-footer_note,gs_form_data-customer_addr.

NEW zcl_form_translation( )->translate_form(
  EXPORTING
    iv_formname      = 'ZTEST'
    iv_langu         = cl_abap_context_info=>get_user_language_abap_format( )
  CHANGING
    cs_form_elements = gs_form_data ).

WRITE: / 'After Translation: ', gs_form_data-header_label,gs_form_data-footer_note,gs_form_data-customer_addr.
