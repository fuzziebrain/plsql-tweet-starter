# Starter Code for Tweeting with PL/SQL
The provided code and instruction assumes that the developer is performing operations using the single-user OAuth method.

## Requirements
* [Oracle Application Express](https://apex.oracle.com/) version 5.1 or later

## Instructions
1. Compile the code in the following order:
```bash
SQL> @packages/pkg_oauth_util.pks
SQL> @packages/pkg_oauth_util.pkb
SQL> @packages/pkg_tweeter.pks
SQL> @packages/pkg_tweeter.pkb
```
2. Go to [Twitter Apps](https://apps.twitter.com/).
3. Create a new App and provide the required information.
4. When the application has been created successfully, click on the `Keys and Access Tokens` tab.
5. Under `Your Access Token`, click `Create my access token`.
6. Note the following to be used in the procedure call:
    - Consumer Key
    - Consumer Secret
    - Access Token
    - Access Token Secret
7. Ensure that the application has read and write permissions.


#### Example:
```sql
begin
  pkg_tweeter.post_update(
    p_status => 'Hello world!'
    , p_consumer_key => 'aaaaaaaaaaaaaaaaaaaaaaaaa'
    , p_consumer_secret => 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
    , p_access_token => 'nnnnnnnn-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    , p_access_token_secret => 'yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy'
  );
end;
/
```