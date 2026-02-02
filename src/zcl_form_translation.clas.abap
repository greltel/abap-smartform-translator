class ZCL_FORM_TRANSLATION definition
  public
  create public .

public section.

  types:
    r_fieldname TYPE RANGE OF zabap_form_trans-fieldname .

    "! <p class="shorttext synchronized">Translates fields of a structure based on DB configuration</p>
    "! @parameter iv_formname | <p class="shorttext synchronized">Smartform/Form Name (Key in DB)</p>
    "! @parameter iv_langu | <p class="shorttext synchronized">Target Language (Default: SY-LANGU)</p>
    "! @parameter cs_form_elements | <p class="shorttext synchronized">Structure containing fields to be translated</p>
  methods TRANSLATE_FORM
    importing
      !IV_FORMNAME type TDSFNAME
      !IV_LANGU type SYST_LANGU default SYST-LANGU
    changing
      !CS_FORM_ELEMENTS type ANY .
  PROTECTED SECTION.

    types tt_zabap_form_transv type STANDARD TABLE OF zabap_form_trans with empty key.

    METHODS get_translations
      IMPORTING
                !iv_formname           TYPE tdsfname
                !iv_langu              TYPE syst_langu
                !iv_fieldnames         TYPE r_fieldname
      RETURNING VALUE(re_translations) TYPE zcl_form_translation=>tt_zabap_form_transv.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FORM_TRANSLATION IMPLEMENTATION.


  METHOD translate_form.

    IF iv_formname IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_translations) = me->get_translations( iv_fieldnames = VALUE r_fieldname( FOR <fs> IN CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( cs_form_elements ) )->components
                                                                                   ( low    = <fs>-name
                                                                                     high   = <fs>-name
                                                                                     sign   = 'I'
                                                                                     option = 'EQ' )  )
                                                  iv_formname   = iv_formname
                                                  iv_langu      = iv_langu ).
    IF lt_translations IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_translations REFERENCE INTO DATA(lr_translation).

      ASSIGN COMPONENT lr_translation->*-fieldname OF STRUCTURE cs_form_elements TO FIELD-SYMBOL(<lv_field_value>) ELSE UNASSIGN.

      IF syst-subrc IS INITIAL AND <lv_field_value> IS ASSIGNED.

        TRY.
            <lv_field_value> = lr_translation->*-descr.
          CATCH cx_root.
            CONTINUE.
        ENDTRY.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_translations.

    TRY.
        SELECT FROM zabap_form_trans
          FIELDS *
          WHERE fieldname IN @iv_fieldnames
            AND form  EQ @iv_formname
            AND langu EQ @( COND #( WHEN iv_langu IS NOT INITIAL THEN iv_langu
                                    ELSE cl_abap_context_info=>get_user_language_abap_format( ) ) )
           INTO TABLE @re_translations.
      CATCH cx_abap_context_info_error.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
