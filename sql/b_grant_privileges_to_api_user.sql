GRANT connect ON database postgres TO api;
GRANT select, insert, update, delete ON all tables IN schema public, norma, apiview, adapt TO api;
GRANT usage on schema public, norma, apiview, adapt to api;
GRANT execute ON all functions IN schema public, norma, apiview, adapt TO api;
