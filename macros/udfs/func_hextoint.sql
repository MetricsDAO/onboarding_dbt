{% macro create_js_hextoint() -%}
create or replace function {{ target.database }}.{{ target.schema }}.js_hextoint (s string)
returns string
language java
handler='MyClass.x'
as $$
import java.math.*;
class MyClass {
  public static String x(String s)
  {
    return new BigInteger(s,16).toString();
  }
}
$$;
{%- endmacro %}