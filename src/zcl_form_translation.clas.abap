class ZCL_FORM_TRANSLATION definition
  public
  final
  create public .

public section.

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
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FORM_TRANSLATION IMPLEMENTATION.


  METHOD translate_form.

    IF iv_formname IS INITIAL.
      RETURN.
    ENDIF.

    TYPES r_fieldname TYPE RANGE OF zabap_form_trans-fieldname.
    DATA(lr_fieldname) = VALUE r_fieldname( FOR <fs> IN CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( cs_form_elements ) )->components
                                          ( low    = <fs>-name
                                            high   = <fs>-name
                                            sign   = 'I'
                                            option = 'EQ' ) ).

    TRY.
        SELECT FROM zabap_form_trans
          FIELDS *
          WHERE fieldname IN @lr_fieldname
            AND form  EQ @iv_formname
            AND langu EQ @( COND #( WHEN iv_langu IS NOT INITIAL THEN iv_langu
                                    ELSE cl_abap_context_info=>get_user_language_abap_format( ) ) )
           INTO TABLE @DATA(lt_translations).
      CATCH cx_abap_context_info_error.
    ENDTRY.

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
ENDCLASS.
