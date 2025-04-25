pragma solidity ^0.8.0;

import "../../PriceSource.sol";
import "./interfaces/IPoolFactory.sol";
import "./interfaces/IPool.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ReactorV2PriceSource is PriceSource {
    IPoolFactory public immutable factory;

    constructor(
        IPoolFactory _factory,
        address _usdt,
        address _usdc,
        address _weth
    ) PriceSource("Reactor Finance V2", _usdt, _usdc, _weth) {
        factory = _factory;
    }

    function _deriveAmountOut(
        address token0,
        address token1,
        uint256 _amountIn
    ) internal view returns (uint256 amountOut) {
        if (_amountIn == 0) return 0;
        if (token0 == token1) return _amountIn;

        address pair = factory.getPool(token0, token1, false); // Search volatile first

        if (pair == address(0)) pair = factory.getPool(token0, token1, true); // Search stable next
        if (pair == address(0)) return 0; // Return 0 if pair is still zero

        IPool pool = IPool(pair);
        amountOut = pool.getAmountOut(_amountIn, token0);
    }

    function _getUnitValueInETH(address token) internal view override returns (uint256 amountOut) {
        uint8 _decimals = ERC20(token).decimals();
        uint256 _amountIn = 1 * 10 ** _decimals;
        amountOut = _deriveAmountOut(token, weth, _amountIn);
    }

    function _getUnitValueInUSDC(address token) internal view override returns (uint256) {
        uint256 _valueInETH = _getUnitValueInETH(token);
        uint256 _ethUSDCAmountOut = _deriveAmountOut(weth, usdc, _valueInETH);

        if (_ethUSDCAmountOut > 0) {
            return _ethUSDCAmountOut;
        } else {
            uint8 _tokenDecimals = ERC20(token).decimals();
            uint256 _amountIn = 1 * 10 ** _tokenDecimals;
            uint256 amountOut = _deriveAmountOut(token, usdc, _amountIn);
            return amountOut;
        }
    }

    function _getUnitValueInUSDT(address token) internal view override returns (uint256) {
        uint256 _valueInETH = _getUnitValueInETH(token);
        uint256 _ethUSDTAmountOut = _deriveAmountOut(weth, usdt, _valueInETH);

        if (_ethUSDTAmountOut > 0) {
            return _ethUSDTAmountOut;
        } else {
            uint8 _tokenDecimals = ERC20(token).decimals();
            uint256 _amountIn = 1 * 10 ** _tokenDecimals;
            uint256 amountOut = _deriveAmountOut(token, usdt, _amountIn);
            return amountOut;
        }
    }
}