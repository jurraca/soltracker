# SolTracker

Start a websocket client to listen for logs or programs, or use the RPC directly. 
Parse Blocks by slot ID, Transactions, and filter for NFT transfers.  

Decoding token metadata encoded under the Metaplex [standard](https://docs.metaplex.com/nft-standard) is done via a Rust [metaplex-decoder](https://github.com/samuelvanderwaal/metaplex_decoder), which we call via [Rustler](https://github.com/rusterlium/rustler). Therefore you will need Rust installed to compile the project. 

```elixir
SolTracker.Transfers.track() # spawns a websocket in a supervised process 
SolTracker.Block.fetch(108379233) # fetch a block via RPC by its slot number
```

Query and parse a block for "transfer" types from the token program.
```elixir
iex(1)> SolTracker.Transfers.parse_transfers_from_slot(109742643)
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

## Installation


```elixir
def deps do
  [
    {:soltracker, "~> 0.1.0"}
  ]
end
```