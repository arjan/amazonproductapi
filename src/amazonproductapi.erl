-module(amazonproductapi).

-include_lib("amazonproductapi/include/amazonproductapi.hrl").
-include_lib("xmerl/include/xmerl.hrl").

-export([
         itemSearch/2,
         itemLookup/3
        ]).

-define(PROTOCOL, "http").
-define(REQUEST_URI, "/onca/xml").


-spec itemSearch(string(), #amazonproductapi_config{}) -> {ok, #xmlElement{}}.
itemSearch(Keywords, Config) ->
    do_rest_call(get, "ItemSearch", [{"Keywords", Keywords}], Config).

-spec itemLookup(string(), string(), #amazonproductapi_config{}) -> {ok, #xmlElement{}}.
itemLookup(IdType, ItemId, Config) ->
    do_rest_call(get, "ItemLookup", [{"IdType", IdType}, {"ItemId", ItemId}], Config).



do_rest_call(RequestMethod, Operation, Params, Config) ->

    %% See: http://associates-amazon.s3.amazonaws.com/scratchpad/index.html
    
    AllParams = [{"Operation", Operation},
                   {"Service", "AWSECommerceService"},
                   {"AWSAccessKeyId", Config#amazonproductapi_config.access_key},
                   {"AssociateTag", Config#amazonproductapi_config.associate_tag},
                   {"Version", "2011-08-01"},
                   {"SearchIndex", "All"},
                   {"Condition", "All"},
                   {"ResponseGroup", "Images,ItemAttributes,Offers"},
                   {"Timestamp", make_date()}
                 | Params],
    EncodedAndSortedParams = lists:sort([{K, z_url:percent_encode(V)} || {K, V} <- AllParams]),

    StringedParams = string:join([K ++ "=" ++ V || {K, V} <- EncodedAndSortedParams], "&"),
    
    SignString = map_request_method(RequestMethod) ++ "\n"
        ++  Config#amazonproductapi_config.endpoint ++ "\n"
        ++ ?REQUEST_URI ++ "\n"
        ++ StringedParams,

    Signature = z_url:percent_encode(z_convert:to_list(base64:encode(hmac:hmac256(Config#amazonproductapi_config.secret, SignString)))),

    Url = ?PROTOCOL ++ "://" ++ Config#amazonproductapi_config.endpoint ++ ?REQUEST_URI ++ "?"
        ++ StringedParams ++ "&Signature=" ++ Signature,

    case httpc:request(RequestMethod, {Url, []}, [], []) of
        {ok, {{_, 200, _}, ResponseHeaders, Body}} ->
            {ok, interpret_body(ResponseHeaders, Body)};
        {ok, {{_, OtherCode, _}, ResponseHeaders, Body}} ->
            {error,
             {http, OtherCode, interpret_body(ResponseHeaders, Body)}};
        {error, R} ->
            {error, R}
    end.

map_request_method(get) -> "GET";
map_request_method(post) -> "POST".

interpret_body(_Headers, Body) ->
    {XML, _} = xmerl_scan:string(Body),
    XML.

make_date() ->
    z_convert:to_list(z_dateformat:format(calendar:local_time(), "c", [])).
                    
