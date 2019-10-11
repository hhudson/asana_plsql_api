create or replace package asana_pkg 
authid definer as 

-- create a task
function create_task (p_blog_name    in varchar2,
                      p_blog_comment in varchar2)
                     return clob;

--retrieve environment variables written to the database
function get_env_var (p_var_name in varchar2) return varchar2;

end asana_pkg;