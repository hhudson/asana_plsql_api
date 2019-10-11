-- drop objects
--drop table env_variables cascade constraints;

-- create tables
create table env_variables (
    id                             number not null constraint env_variables_id_pk primary key,
    api_name                       varchar2(255),
    var_name                       varchar2(255),
    var_value                      varchar2(4000),
    created                        date not null,
    created_by                     varchar2(255) not null,
    updated                        date not null,
    updated_by                     varchar2(255) not null
)
;


-- triggers
create or replace trigger env_variables_biu
    before insert or update 
    on env_variables
    for each row
begin
    if :new.id is null then
        :new.id := to_number(sys_guid(), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    end if;
    if inserting then
        :new.created := sysdate;
        :new.created_by := nvl(sys_context('APEX$SESSION','APP_USER'),user);
    end if;
    :new.updated := sysdate;
    :new.updated_by := nvl(sys_context('APEX$SESSION','APP_USER'),user);
end env_variables_biu;
/
