create or replace package body pkg_oauth_util
as
  gc_base_string_template constant varchar2(37) := '#REQUEST_METHOD#&#BASE_URL#&#PAYLOAD#';
  gc_payload_template constant varchar2(168) :=
    'oauth_consumer_key=#CONSUMER_KEY#'
    || '&oauth_nonce=#NONCE#'
    || '&oauth_signature_method=#SIGNATURE_METHOD#'
    || '&oauth_timestamp=#TIMESTAMP#'
    || '&oauth_token=#ACCESS_TOKEN#'
    || '&oauth_version=1.0'
  ;
  gc_auth_header_template constant varchar2(250) :=
    'OAuth oauth_consumer_key=#CONSUMER_KEY#'
    || ', oauth_nonce=#NONCE#'
    || ', oauth_signature=#SIGNATURE#'
    || ', oauth_signature_method=#SIGNATURE_METHOD#'
    || ', oauth_timestamp=#TIMESTAMP#'
    || ', oauth_token=#ACCESS_TOKEN#'
    || ', oauth_version=1.0'
  ;

  function urlencode(
    p_str in varchar2
  ) return varchar2
  as
    l_return varchar2(32767);
  begin
    l_return := replace(utl_url.escape(p_str, true), '!', '%21');
    return l_return;
  end urlencode;

  function generate_timestamp
  return varchar2
  as
    l_return varchar2(32767);
  begin
    l_return :=
      to_char(
        round(
          (sysdate - to_date('1970-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) * 86400
        )
      )
    ;
    return l_return;
  end generate_timestamp;

  -- Validate base string with http://quonos.nl/oauthTester/
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
  ) return varchar2
  as
    l_return varchar2(32767) := gc_base_string_template;
    l_payload varchar2(32767) := gc_payload_template;

    unsupported_request_method exception;
    parameter_mismatched exception;
  begin
    if upper(p_request_method) not in ('POST', 'GET') then
      raise unsupported_request_method;
    end if;

    if p_params_name.count != p_params_value.count then
      raise parameter_mismatched;
    end if;

    l_payload := replace(l_payload, '#CONSUMER_KEY#', p_consumer_key);
    l_payload := replace(l_payload, '#NONCE#', p_nonce);
    l_payload := replace(l_payload, '#SIGNATURE_METHOD#', p_signature_method);
    l_payload := replace(l_payload, '#TIMESTAMP#', p_timestamp);
    l_payload := replace(l_payload, '#ACCESS_TOKEN#', p_access_token);

    for i in 1..p_params_name.count loop
      l_payload := l_payload || '&' || p_params_name(i) || '=' || urlencode(p_params_value(i));
    end loop;

    l_return := replace(l_return, '#REQUEST_METHOD#', upper(p_request_method));
    l_return := replace(l_return, '#BASE_URL#', urlencode(p_base_url));
    l_return := replace(l_return, '#PAYLOAD#', urlencode(l_payload));

    return l_return;
  end generate_base_string;

  function generate_signature(
    p_base_string varchar2
    , p_consumer_secret varchar2
    , p_access_token_secret varchar2
  ) return varchar2
  as
    l_return varchar2(32767);
  begin
    l_return :=
      utl_raw.cast_to_varchar2(
        utl_encode.base64_encode(
          dbms_crypto.mac(
            src => utl_i18n.string_to_raw(data => p_base_string, dst_charset => 'AL32UTF8')
            , typ => dbms_crypto.hmac_sh1
            , key =>
                utl_i18n.string_to_raw(
                  data => p_consumer_secret || '&' || p_access_token_secret,
                  dst_charset => 'AL32UTF8'
                )
          )
        )
      )
    ;

    return l_return;
  end generate_signature;

  function generate_nonce
  return varchar2
  as
    l_return varchar2(32);
  begin
    l_return :=
      utl_encode.base64_encode(
        utl_i18n.string_to_raw(
          dbms_random.string('A', 12)
          , 'AL32UTF8'
        )
      )
    ;
    return l_return;
  end generate_nonce;

  function generate_auth_header(
    p_consumer_key varchar2
    , p_nonce varchar2
    , p_signature varchar2
    , p_signature_method varchar2 default pkg_oauth_util.gc_hmac_sh1
    , p_timestamp varchar2
    , p_access_token varchar2
  ) return varchar2
  as
    l_return varchar2(32767) := gc_auth_header_template;
  begin
    l_return := replace(l_return, '#CONSUMER_KEY#', p_consumer_key);
    l_return := replace(l_return, '#NONCE#', p_nonce);
    l_return := replace(l_return, '#SIGNATURE#', p_signature);
    l_return := replace(l_return, '#SIGNATURE_METHOD#', p_signature_method);
    l_return := replace(l_return, '#TIMESTAMP#', p_timestamp);
    l_return := replace(l_return, '#ACCESS_TOKEN#', p_access_token);

    return l_return;
  end generate_auth_header;
end pkg_oauth_util;
/