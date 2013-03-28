Amazon Product API for Erlang
=============================

Small library for Erlang implementing the Amazon Product Advertising
API: http://aws.amazon.com/code/Product-Advertising-API.

Usage
-----

Include the header file:

    -include_lib("amazonproductapi/include/amazonproductapi.hrl").

Then, fill the `#amazonproductapi_config{}` record with your 

    Config = #amazonproductapi_config{
                              endpoint=webservices.amazon.com",
                              associate_tag="youraffiliate-33",
                              access_key="fixme",
                              secret="fixme"
                          }.

Now you can use the `amazonproductapi` Erlang module to search for products:

    {ok, XML} = amazonproductapi:itemSearch("shades", Config)

This returns an XMERL `xmlElement{}` record with the results. It is up
to you to interpret the XML fully.

A single item can be looked up like this:

    {ok, XML} = amazonproductapi:itemLookup("ASIN", "B007Z7UENE", Config).

