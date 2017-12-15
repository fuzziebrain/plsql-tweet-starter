create or replace package pkg_tweeter
as
  procedure post_update(
    p_status in varchar2
    , p_consumer_key in varchar2
    , p_consumer_secret in varchar2
    , p_access_token in varchar2
    , p_access_token_secret in varchar2
    , p_proxy_domain in varchar2 default null
  );
end pkg_tweeter;
/