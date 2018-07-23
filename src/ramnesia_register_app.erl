-module(ramnesia_register_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    error_logger:error_msg("Members ~p~n", [ra:members(ramnesia_node:node_id())]),
    ramnesia_node:trigger_election(),
    ramnesia_jepsen_api:start(),
    case string:split(atom_to_list(node()), "@") of
        ["rmns_listener" | _] ->
            Dispatch = cowboy_router:compile([
                {'_', [{"/:key", remnesia_jepsen_handler, []}]}
            ]),
            {ok, _} = cowboy:start_clear(my_http_listener,
                [{port, 8080}],
                #{env => #{dispatch => Dispatch}});
        _ -> ok
    end,
	ramnesia_register_sup:start_link().

stop(_State) ->
	ok.
