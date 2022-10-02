# cairo-gda

Cairo implementations of [Gradual Dutch Auctions](https://www.paradigm.xyz/2022/04/gda).

## Usage

```cairo
from src.discrete import DiscreteGDA

...

let initial_price = 1000;
let initial_price_fp = Math64x61.fromFelt(initial_price);
let scale_factor_fp = Math64x61.div(Math64x61.fromFelt(11), Math64x61.fromFelt(10)); 
let decay_constant_fp = Math64x61.div(Math64x61.fromFelt(1), Math64x61.fromFelt(2));

let (auction_start_time) = get_block_timestamp();
let auction_start_time_fp = Math64x61.fromFelt(auction_start_time);

DiscreteGDA.initializer(initial_price_fp, scale_factor_fp, decay_constant_fp, auction_start_time_fp);
let price = DiscreteGDA.purchase_price(1, 0);
```

## Development

The library uses [Protostar](https://docs.swmansion.com/protostar/) for development.

Run tests with:
```sh
protostar test
```

Based on reference implementation at https://github.com/FrankieIsLost/gradual-dutch-auction/blob/master/src/DiscreteGDA.sol