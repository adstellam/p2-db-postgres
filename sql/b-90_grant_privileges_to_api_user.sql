GRANT connect ON database postgres TO api;
GRANT select, insert, update, delete ON all tables IN schema public, norma, stout, adapt TO api;
GRANT usage on schema public, norma, stout, adapt to api;
GRANT execute ON all functions IN schema public, norma, stout, adapt TO api;
