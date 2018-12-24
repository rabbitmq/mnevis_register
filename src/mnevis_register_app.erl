-module(mnevis_register_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    mnevis_node:start(),
    error_logger:error_msg("Members ~p~n", [ra:members(mnevis_node:node_id())]),
    % mnevis_node:trigger_election(),
    mnevis_jepsen_api:start(),
    case string:split(atom_to_list(node()), "@") of
        ["mnevis_listener" | _] ->
            Dispatch = cowboy_router:compile([
                {'_', [{"/:key", mnevis_jepsen_handler, []}]}
            ]),
            {ok, _} = cowboy:start_clear(my_http_listener,
                [{port, 8080}],
                #{env => #{dispatch => Dispatch}});
        _ -> ok
    end,
	mnevis_register_sup:start_link().

stop(_State) ->
	ok.
