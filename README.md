# guildenbug

A small self-contained project to demonstrate a bug in GuildenStern.

https://github.com/olliNiinivaara/GuildenStern

## Building

`nimble build`

## Running

`./guildenbug`

## Reproducing the bug

Go to http://localhost:8080 with your browser.

You should see the following appears:

    Guildenbug
    * foo1
    * foo2
    * foo3

This illustrates that `foo1.js`, `foo2.js` and `foo3.js` were all loaded
correctly.

Keep refreshing and sometimes you should see fewer line items, indicating
that one (or more) of the 3 javascript files was (were) not loaded
correctly.

In Chrome, the error shows up as `(failed) net::ERR_EMPTY_RESPONSE` in the Developer Tools network tab.  Alternatively, the console will also report the error as `GET http://localhost:8080/foo1.js net::ERR_EMPTY_RESPONSE`
