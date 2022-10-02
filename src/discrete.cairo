%lang starknet
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_block_timestamp

from cairo_math_64x61.math64x61 import Math64x61

// @notice parameter that controls initial price, stored as a 64x61 fixed precision number
@storage_var
func DiscreteGDA_initial_price_fp() -> (price: felt) {
}

// @notice parameter that controls how much the starting price of each successive auction increases by,
// stored as a 64x61 fixed precision number
@storage_var
func DiscreteGDA_scale_factor_fp() -> (factor: felt) {
}

// @notice parameter that controls price decay, stored as a 59x18 fixed precision number
@storage_var
func DiscreteGDA_decay_constant_fp() -> (constant: felt) {
}

// @notice start time for all auctions, stored as a 59x18 fixed precision number
@storage_var
func DiscreteGDA_auction_start_time_fp() -> (time: felt) {
}

namespace DiscreteGDA {
    func initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        initial_price_fp: felt, scale_factor_fp: felt, decay_constant_fp: felt, auction_start_time_fp: felt,
    ) {
        Math64x61.assert64x61(initial_price_fp);
        Math64x61.assert64x61(scale_factor_fp);
        Math64x61.assert64x61(decay_constant_fp);
        Math64x61.assert64x61(auction_start_time_fp);

        DiscreteGDA_initial_price_fp.write(initial_price_fp);
        DiscreteGDA_scale_factor_fp.write(scale_factor_fp);
        DiscreteGDA_decay_constant_fp.write(decay_constant_fp);
        DiscreteGDA_auction_start_time_fp.write(auction_start_time_fp);

        return ();
    }

    // @notice calculate purchase price using exponential discrete GDA formula
    func purchase_price{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(quantity: felt, existing: felt) -> felt {
        alloc_locals;

        let (auction_start_time_fp) = DiscreteGDA_auction_start_time_fp.read();
        let (initial_price_fp) = DiscreteGDA_initial_price_fp.read();
        let (decay_constant_fp) = DiscreteGDA_decay_constant_fp.read();
        let (scale_factor_fp) = DiscreteGDA_scale_factor_fp.read();

        let quantity_fp = Math64x61.fromFelt(quantity);
        let existing_fp = Math64x61.fromFelt(existing);

        let (block_timestamp) = get_block_timestamp();
        let block_timestamp_fp = Math64x61.fromFelt(block_timestamp);

        let time_since_start_fp = Math64x61.sub(block_timestamp_fp, auction_start_time_fp);

        let num1_pow_fp = Math64x61.pow(scale_factor_fp, existing_fp);
        let num1_fp = Math64x61.mul(initial_price_fp, num1_pow_fp);

        let num2_pow_fp = Math64x61.pow(scale_factor_fp, quantity_fp);
        let num2_fp = Math64x61.sub(num2_pow_fp, Math64x61.ONE);

        let den1_mul_fp = Math64x61.mul(decay_constant_fp, time_since_start_fp);
        let den1_fp = Math64x61.exp(den1_mul_fp);
        let den2_fp = Math64x61.sub(scale_factor_fp, Math64x61.ONE);

        let mul_num2_fp = Math64x61.mul(num1_fp, num2_fp);
        let mul_num3_fp = Math64x61.mul(den1_fp, den2_fp);

        let total_cost_fp = Math64x61.div(mul_num2_fp, mul_num3_fp);
        let total_cost = Math64x61.toFelt(total_cost_fp);
        return total_cost;
    }
}
