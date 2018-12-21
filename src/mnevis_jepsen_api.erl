-module(mnevis_jepsen_api).

-export([start/0, write/2, read/1, cas/3]).


start() ->
    mnevis:create_table(foo, []).

-spec write(term(), term()) -> ok | {error, term()}.
write(K, V) ->
    Res = mnevis:transaction(fun() ->
        mnesia:write({foo, K, V})
    end),
    case Res of
        {atomic, ok} -> ok;
        {aborted, Reason} -> {error, Reason}
    end.

-spec read(term()) -> {ok, term()} | {error, term()}.
read(K) ->
    Res = mnevis:transaction(fun() ->
        mnesia:read(foo, K)
    end),
    case Res of
        {atomic, []}                -> {error, not_found};
        {atomic, [{foo, K, Val}]}   -> {ok, Val};
        {aborted, Reason}           -> {error, Reason}
    end.

-spec cas(term(), term(), term()) -> ok | {error, term()}.
cas(K, OldV, NewV) ->
    Res = mnevis:transaction(fun() ->
        case mnesia:read(foo, K) of
            [{foo, K, OldV}] -> mnesia:write({foo, K, NewV});
            _                -> wrong_value
        end
    end),
    case Res of
        {atomic, ok}          -> ok;
        {atomic, wrong_value} -> {error, wrong_value};
        {aborted, Reason}     -> {error, Reason}
    end.
