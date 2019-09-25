create or replace package body asana_pkg as 

    gc_scope_prefix constant varchar2(31)  := lower($$plsql_unit) || '.'; ------------------------------- necessary for the logger implementation
    g_url_prefix    constant varchar2(50)  := 'https://app.asana.com/api/1.0';
    g_password      constant varchar2(50)  := get_env_var (p_var_name => 'asana_api_key'); -------------- this is your API Key (very sensitive - keep to yourself)
    g_wallet_path   constant varchar2(100) := mailchimp_pkg.get_env_var (p_var_name => 'wallet_path'); --  the path on to your Oracle Wallet, syntax 'file:[path to your Oracle Wallet]'
    g_https_host    constant varchar2(100) := mailchimp_pkg.get_env_var (p_var_name => 'https_host'); --- necessary if you have an Oracle 12.2 database or higher (see instructions)
    g_address1      constant varchar2(500) := mailchimp_pkg.get_env_var (p_var_name => 'address1'); ----- the CAN SPAM act requires that you specify the organization's address
    g_city          constant varchar2(500) := mailchimp_pkg.get_env_var (p_var_name => 'city'); --------- the CAN SPAM act requires that you specify the organization's address
    g_state         constant varchar2(500) := mailchimp_pkg.get_env_var (p_var_name => 'state'); -------- the CAN SPAM act requires that you specify the organization's address
    g_zip           constant varchar2(500) := mailchimp_pkg.get_env_var (p_var_name => 'zip'); ---------- the CAN SPAM act requires that you specify the organization's address
    g_county        constant varchar2(500) := mailchimp_pkg.get_env_var (p_var_name => 'country'); ------ the CAN SPAM act requires that you specify the organization's address
    g_company_name  constant varchar2(100) := mailchimp_pkg.get_env_var (p_var_name => 'company'); ------ whatever your organization is called
    g_reply_to      constant varchar2(100) := mailchimp_pkg.get_env_var (p_var_name => 'email'); -------- the email that you've authenticated with Mailchimp
    g_from_name     constant varchar2(100) := mailchimp_pkg.get_env_var (p_var_name => 'from_name'); ---- the name your emails will appear to be from
    g_username      constant varchar2(50)  := 'admin'; ------------------------------------ arbitrary - can be anything

-- create a task
function create_task (p_task_name in varchar2)
                     return clob
is 
l_scope logger_logs.scope%type := gc_scope_prefix || 'create_task';
l_params logger.tab_param;
l_body         varchar2(1000);
l_response     clob;
begin
logger.append_param(l_params, 'p_task_name', p_task_name);
logger.log('START', l_scope, null, l_params);

l_body := '{"assignee":"me", "notes":"How are you today?", "name":"New comment on blog", "projects":"386313290357592", "workspace":"216995148003361" }';

l_response := apex_web_service.make_rest_request(
          p_url         => g_url_prefix||'/tasks'
        , p_http_method => 'POST'
        , p_username    => g_username
        , p_password    => g_password
        , p_body        => l_body
        , p_wallet_path => g_wallet_path
        , p_https_host  => g_https_host
    );
logger.log('l_response : ', l_scope, l_response);

logger.log('END', l_scope);
return l_response;
exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
end create_task;

end asana_pkg;