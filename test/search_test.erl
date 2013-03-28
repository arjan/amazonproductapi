-module(search_test).

-compile(export_all).

-include_lib("eunit/include/eunit.hrl").
-include_lib("amazonproductapi/include/amazonproductapi.hrl").

setup() ->
    application:start(amazonproductapi),
    application:start(lager),
    application:start(inets),
    application:start(public_key),
    application:start(ssl).


get_config() ->
    {ok, Cfg} = file:consult("../secrets.config"),
    #amazonproductapi_config{
                              endpoint=proplists:get_value(endpoint, Cfg),
                              associate_tag=proplists:get_value(associate_tag, Cfg),
                              access_key=proplists:get_value(access_key, Cfg),
                              secret=proplists:get_value(secret, Cfg)
           }.

itemSearch_test() ->
    setup(),
    C = get_config(),
    {ok, XML} = amazonproductapi:itemSearch("shades", C),
    xmlElement = element(1, XML),
    ok.


itemLookup_test() ->
    setup(),
    C = get_config(),
    {ok, XML} = amazonproductapi:itemLookup("ASIN", "B007Z7UENE", C),
    xmlElement = element(1, XML),
    ok.
