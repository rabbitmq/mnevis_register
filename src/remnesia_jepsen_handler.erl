-module(remnesia_jepsen_handler).
-behavior(cowboy_rest).

-export([init/2]).
-export([content_types_provided/2,
         resource_exists/2,
         allowed_methods/2,
         content_types_accepted/2]).
-export([to_json/2]).
-export([process_write/2]).


init(Req, State) ->
	{cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"HEAD">>, <<"GET">>, <<"OPTIONS">>, <<"PUT">>, <<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
    {[{<<"application/json">>, process_write}], Req, State}.

process_write(Req0, State) ->
    Key = cowboy_req:binding(key, Req0),
    {ok, Data, Req} = cowboy_req:read_body(Req0),
    Json = jsx:decode(Data, [return_maps]),
    case {cowboy_req:method(Req), Json} of
        {<<"PUT">>, #{<<"old_val">> := OldVal, <<"new_val">> := NewVal}} ->
            case ramnesia_jepsen_api:cas(Key, OldVal, NewVal) of
                ok ->
                    {true, Req, State};
                {error, wrong_value} ->
                    {false, Req, State}
            end;
        {<<"POST">>, #{<<"val">> := Val}} ->
            ok = ramnesia_jepsen_api:write(Key, Val),
            {true, Req, State};
        _ -> {false, Req, State}
    end.

content_types_provided(Req, State) ->
	{[
		{{<<"application">>, <<"json">>, '*'}, to_json}
	], Req, State}.

resource_exists(Req, State) ->
    Key = cowboy_req:binding(key, Req),
    case ramnesia_jepsen_api:read(Key) of
        {ok, Val} ->
            {true, Req, Val};
        {error, not_found} ->
            {false, Req, State}
    end.

to_json(Req, Val) ->
	{jsx:encode(#{val => Val}), Req, Val}.
