# SolTracker

Start a websocket client to listen for logs or programs, or use the RPC directly. 

```elixir
SolTracker.Transfers.track() # spawns a websocket in a supervised process 
SolTracker.Block.fetch(108379233) # fetch a block via RPC by its slot number

```
Query and parse a block for "transfer" types from the token program.
```elixir
iex(1)> SolTracker.Transfers.decode(program_notification)
%{
  lamports: 2039280,
  owner: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
  program: %{
    "parsed" => %{
      "info" => %{
        "isNative" => false,
        "mint" => "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
        "owner" => "HoDhphLcgw8hb6GdTicv6V9are7Yi7xXvUriwWwRWuRk",
        "state" => "initialized",
        "tokenAmount" => %{
          "amount" => "65839344362",
          "decimals" => 6,
          "uiAmount" => 65839.344362,
          "uiAmountString" => "65839.344362"
        }
      },
      "type" => "account"
    },
    "program" => "spl-token",
    "space" => 165
  },
  slot: 108520863
}

```
TODO: 
- how to identify an NFT vs other tokens? For example, the output above is USDCoin, not an NFT.
- mint vs authority? 


## Installation


```elixir
def deps do
  [
    {:soltracker, "~> 0.1.0"}
  ]
end
```