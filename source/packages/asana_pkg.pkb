create or replace package body asana_pkg as 

    gc_scope_prefix constant varchar2(31)  := lower($$plsql_unit) || '.'; ------------------------------- necessary for the logger implementation
    g_url_prefix    constant varchar2(50)  := 'https://app.asana.com/api/1.0';
    g_authorization constant varchar2(50)  := asana_pkg.get_env_var (p_var_name => 'authorization'); -------------- this is your API Key (very sensitive - keep to yourself)
    g_projects      constant varchar2(50)  := asana_pkg.get_env_var (p_var_name => 'projects'); -------------- this is your API Key (very sensitive - keep to yourself)
    g_workspace     constant varchar2(50)  := asana_pkg.get_env_var (p_var_name => 'workspace'); -------------- this is your API Key (very sensitive - keep to yourself)

-- create a task
function create_task (p_blog_name    in varchar2,
                      p_blog_comment in varchar2)
                     return clob
is 
l_scope       logger_logs.scope%type := gc_scope_prefix || 'create_task';
l_params      logger.tab_param;
l_response    clob;
l_parm_names  apex_application_global.vc_arr2;  
l_parm_values apex_application_global.vc_arr2; 
begin
logger.append_param(l_params, 'p_blog_name', p_blog_name);
logger.append_param(l_params, 'p_blog_comment', p_blog_comment);
logger.log('START', l_scope, null, l_params);

  l_parm_names(1)  := 'assignee';  
  l_parm_values(1) := 'me';  
  l_parm_names(2)  := 'notes';  
  l_parm_values(2) := '['||asana_pkg.get_env_var (p_var_name => 'env_name')||'] '||p_blog_comment; 
  l_parm_names(3)  := 'name';  
  l_parm_values(3) := 'New comment on : "'||p_blog_name||'"'; 
  l_parm_names(4)  := 'projects';  
  l_parm_values(4) := g_projects; 
  l_parm_names(5)  := 'workspace';  
  l_parm_values(5) := g_workspace; 
  
  apex_web_service.g_request_headers(1).name := 'Authorization';  
  apex_web_service.g_request_headers(1).value := g_authorization;  
  apex_web_service.g_request_headers(2).name := 'Content-Type';  
  apex_web_service.g_request_headers(2).value := 'application/x-www-form-urlencoded';


l_response := apex_web_service.make_rest_request(
          p_url         => g_url_prefix||'/tasks'
        , p_http_method => 'POST'
        , p_parm_name   => l_parm_names 
        , p_parm_value  => l_parm_values  
    );
    
logger.log('l_response : ', l_scope, l_response);

logger.log('END', l_scope);
return l_response;
exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
end create_task;

-- see package specs
function get_env_var (p_var_name in varchar2) return varchar2
is 
l_scope   logger_logs.scope%type := gc_scope_prefix || 'get_env_var';
l_params  logger.tab_param;
l_var_val varchar2(200);
begin 
    logger.append_param(l_params, 'p_var_name', p_var_name);
    logger.log('START', l_scope, null, l_params);

    select var_value
        into l_var_val
        from env_variables
        where upper(var_name) = upper(p_var_name);

    logger.log('END', l_scope);
    return l_var_val;
exception 
    when no_data_found then
        logger.log_info('Variable name not recognized.', l_scope, null, l_params);
        return null;
    when others then 
        logger.log_error('Unhandled Exception', l_scope, null, l_params); 
        raise;
end get_env_var;

end asana_pkg;