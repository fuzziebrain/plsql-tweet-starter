create or replace package body pkg_tweeter
as
  gc_twitter_domain constant varchar2(23) := 'https://api.twitter.com';
  gc_status_update_path constant varchar2(25) := '/1.1/statuses/update.json';

  procedure post_update(
    p_status in varchar2
    , p_consumer_key in varchar2
    , p_consumer_secret in varchar2
    , p_access_token in varchar2
    , p_access_token_secret in varchar2
    , p_proxy_domain in varchar2 default null
  )
  as
    l_nonce varchar2(32);
    l_timestamp varchar2(32767);
    l_signature varchar2(32767);

    l_response clob;
  begin
    l_nonce := pkg_oauth_util.generate_nonce;
    l_timestamp := pkg_oauth_util.generate_timestamp;
    l_signature :=
      pkg_oauth_util.generate_signature(
        p_base_string =>
          pkg_oauth_util.generate_base_string(
            p_request_method => 'POST'
            , p_base_url => gc_twitter_domain || gc_status_update_path
            , p_consumer_key => p_consumer_key
            , p_nonce => l_nonce
            , p_timestamp => l_timestamp
            , p_access_token => p_access_token
            , p_params_name => apex_t_varchar2('status')
            , p_params_value => apex_t_varchar2(p_status)
          )
        , p_consumer_secret => p_consumer_secret
        , p_access_token_secret => p_access_token_secret
      )
    ;

    apex_web_service.g_request_headers(1).name := 'Authorization';
    apex_web_service.g_request_headers(1).value :=
      pkg_oauth_util.generate_auth_header(
        p_consumer_key => p_consumer_key
        , p_signature => pkg_oauth_util.urlencode(l_signature)
        , p_nonce => pkg_oauth_util.urlencode(l_nonce)
        , p_timestamp => pkg_oauth_util.urlencode(l_timestamp)
        , p_access_token => p_access_token
      )
    ;

    apex_web_service.g_request_headers(2).name := 'content-type';
    apex_web_service.g_request_headers(2).value := 'application/x-www-form-urlencoded';

    l_response := apex_web_service.make_rest_request(
      p_url =>
        case
          when p_proxy_domain is not null then p_proxy_domain
          else gc_twitter_domain
        end  || gc_status_update_path
      , p_http_method => 'POST'
      , p_body => 'status=' || pkg_oauth_util.urlencode(p_status)
    );

    if apex_web_service.g_status_code != 200 then
      dbms_output.put_line(l_response);
      raise_application_error(-20001, 'Failed to send update. Error: ' || apex_web_service.g_status_code);
    end if;
  end post_update;
end pkg_tweeter;
/