%lex
%%

\s+                   { /* ignore */ }
'namespace'           { return 'NAMESPACE' }
'include'             { return 'INCLUDE' }
'enum'                { return 'ENUM' }
'struct'              { return 'STRUCT'}
'required'            { return 'REQUIRED' }
'optional'            { return 'OPTIONAL' }

'byte'                { return 'BYTE' }
'i16'                 { return 'I16' }
'i32'                 { return 'I32' }
'i64'                 { return 'I64' }
'double'              { return 'DOUBLE' }
'string'              { return 'STRING' }

'list'                { return 'LIST' }
'set'                 { return 'SET' }
'map'                 { return 'MAP' }

\"                    { return 'STR_BOUNDARY'}
\{                    { return 'OP' }
\}                    { return 'CP' }
\=                    { return 'EQ' }
\,                    { return 'COMMA' }
\;                    { return 'SEMI' }
\:                    { return 'COLON' }
\<                    { return 'LT' }
\>                    { return 'GT' }

\/\/.*?\n             { /* ignore */ }
\/\*\*(.|\n)*?\*\*\/  { /* ignore */ }
[0-9]+                { return 'NUMBER' }
<<EOF>>               { return 'EOF' }
[a-zA-Z0-9._]+\b      { return 'VALUE' }

/lex
%%

file
  : e EOF
    { return $e; }
  ;

e
  : _namespace
    { $$ = { 'header': $1, 'includeList': [], 'enumList': [], 'structList': []  }; }
  | e _include
    %{
      $1.includeList.push($2); 
      $$ = $1;
    %}
  | e _enum
     %{
      $1.enumList.push($2); 
      $$ = $1;
    %}
  | e _struct
     %{
      $1.structList.push($2); 
      $$ = $1;
    %}
  ;

_namespace
  : NAMESPACE _language _namespace_string
    %{
      $$ = {
        'language': $2,
        'namespace': $3
      };
    %}
  ;

_include
  : INCLUDE STR_BOUNDARY _file STR_BOUNDARY
    %{
      $$ = $3;
    %}
  ;

_enum
  : ENUM _enum_name OP _enum_fields CP
    %{
      $$ = {
        'enumName': $2,
        'enumValue': $4
      };
    %}
  ;

_enum_fields
  : _enum_field 
    %{
      $$ = [$1];
    %}
  | _enum_fields _enum_field
    %{
      $1.push($2);
      $$ = $1;
    %}
  ;

_enum_field
  : _enum_field_name EQ _enum_field_value _enum_field_comma
    { $$ = { 'identifier': $1, 'value': $3 }; }
  | _enum_field_name _enum_field_comma
    { $$ = { 'identifier': $1, 'value': null }; }
  ;

_struct
  : STRUCT _struct_name OP _struct_fields CP
    %{
      $$ = {
        'structName': $2,
        'structValue': $4
      };
    %}
  ;

_struct_fields
  : _struct_field SEMI
    %{
      $$ = [$1];
    %}
  | _struct_fields _struct_field SEMI
    %{
      $1.push($2);
      $$ = $1;
    %}
  ;

_struct_field
  : NUMBER COLON _option _field_type _identifier
    { $$ = { 'id': $1, 'option': $3, 'fieldType': $4, 'identifier': $5 }; }
  ;

_option
  : OPTIONAL
    { $$ = 'optional'; }
  | REQUIRED
    { $$ = 'required'; }
  |
    { $$ = null; }
  ;

_field_type
  : BYTE { $$ = { 'type': $1 }; }
  | I16 { $$ = { 'type': $1 }; }
  | I32 { $$ = { 'type': $1 }; }
  | I64 { $$ = { 'type': $1 }; }
  | DOUBLE { $$ = { 'type': $1 }; }
  | STRING { $$ = { 'type': $1 }; }
  | LIST LT _field_type_value GT { $$ = { 'type': 'list', 'typeNode': $3 }; }
  | SET LT VALUE GT { $$ = { 'type': 'set', 'typeNode': $3 }; }
  | MAP LT VALUE COMMA VALUE GT { $$ = { 'type': 'map', 'typeNode': { 'key': $3, 'value': $5 } }; }
  ;

_identifier : VALUE;

_enum_field_comma: COMMA | ;

_enum_field_name: VALUE;

_enum_field_value: NUMBER | VALUE;

_field_type_value: BYTE | I16 | I32 | I64 | DOUBLE | STRING | VALUE ;

_file: VALUE;

_language: VALUE;

_namespace_string: VALUE;

_enum_name: VALUE;

_struct_name: VALUE;
