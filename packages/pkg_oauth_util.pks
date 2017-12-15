create or replace package pkg_oauth_util
as
  gc_hmac_sh1 constant varchar2(9) := 'HMAC-SHA1';

  function urlencode(
    p_str in varchar2
  ) return varchar2;

  function generate_timestamp
  return varchar2;

  function generate_base_string(
    p_request_method varchar2
    , p_base_url varchar2
    , p_consumer_key varchar2
    , p_nonce varchar2
    , p_signature_method varchar2 default pkg_oauth_util.gc_hmac_sh1
    , p_timestamp varchar2
    , p_access_token varchar2
    , p_params_name apex_t_varchar2
    , p_params_value apex_t_varchar2
  ) return varchar2;

  function generate_signature(
    p_base_string varchar2
    , p_consumer_secret varchar2
    , p_access_token_secret varchar2
  ) return varchar2;

  function generate_nonce
  return varchar2;

  function generate_auth_header(
    p_consumer_key varchar2
    , p_nonce varchar2
    , p_signature varchar2
    , p_signature_method varchar2 default pkg_oauth_util.gc_hmac_sh1
    , p_timestamp varchar2
    , p_access_token varchar2
  ) return varchar2;
end pkg_oauth_util;
/