// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract ODON is
    Initializable,
    ContextUpgradeable,
    IERC20Upgradeable,
    IERC20MetadataUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable
{
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;

    uint256 private _currentSupply;
    uint256 private _decimals;

    uint256 public maximumCappedSupply;

    uint256 public liquidityFee;
    uint256 public charityFee;
    uint256 public developerFee;
    uint256 public marketingFee;
    uint256 public burnFee;

    uint256 public maximumSwapableLiquidityAmount;

    bool public enableFee;
    bool public swapLiquidity;
    bool private taxDisableInLiquidity;

    address public UNISWAPV2ROUTER;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    address public charityWallet;
    address public developerWallet;
    address public marketingWallet;
    address private deadAddress;

    uint256 private previousCharityFee;
    uint256 private previousBurnFee;
    uint256 private previousLiquidityFee;
    uint256 private previousDeveloperFee;
    uint256 private previousMarketingFee;

    uint256 public totalLiquidityFeeAmount;
    uint256 public totalCharityFeeAmount;
    uint256 public totalDeveloperFeeAmount;
    uint256 public totalMarketingFeeAmount;
    uint256 public totalBurnFeeAmount;
    uint256 public burnableFeeAmount;
    uint256 public swapableLiquidityFeeAmount;

    event SetDeveloperFeePercent(uint256 developerFeePercent);
    event SetLiquidityFeePercent(uint256 liquidityFeePercent);
    event SetBurnFeePercent(uint256 burnFeePercent);
    event SetCharityFeePercent(uint256 CharityFeePercent);
    event SetMarketingFeePercent(uint256 marketingFeePercent);
    event FeeEnabled(bool enableTax);
    event MaximumSwapableAmount(uint256 _maximumSwapableLiquidityAmount);
    event SetMarketingFeePercent(
        uint256 marketingFee,
        uint256 developerFee,
        uint256 burnFee,
        uint256 liquidityFee,
        uint256 charityFee
    );
    event updateCharityWallet(address _chrarityWalletAddress);
    event updateDeveloperWallet(address _developerWalletAddress);
    event updateMarketingWallet(address _marketingWalletAddress);

    function initialize() public initializer {
        _name = "ODON";
        _symbol = "ODON";
        _currentSupply = 2000000 * 10**18;
        _decimals = 18;

        maximumCappedSupply = 17000000 * 10**18;

        liquidityFee = 5;
        charityFee = 3;
        developerFee = 3;
        marketingFee = 3;
        burnFee = 2;

        maximumSwapableLiquidityAmount = 100000 * 10**18;

        UNISWAPV2ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        charityWallet = 0x0bCcF8ef0e2CcD889d634b542823Dd57840ad238;
        developerWallet = 0x0bCcF8ef0e2CcD889d634b542823Dd57840ad238;
        marketingWallet = 0x0bCcF8ef0e2CcD889d634b542823Dd57840ad238;
        deadAddress = 0x0000000000000000000000000000000000000000;

        enableFee = false;
        swapLiquidity = false;

        _balances[_msgSender()] = _currentSupply;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            UNISWAPV2ROUTER
        );
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        __Pausable_init_unchained();
        __Ownable_init_unchained();
        __Context_init_unchained();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _currentSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        whenNotPaused
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        whenNotPaused
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override whenNotPaused returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        whenNotPaused
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        whenNotPaused
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual whenNotPaused {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //indicates if fee should be deducted from transfer
        bool takeFee = false;

        bool overMaxTokenBalance = swapableLiquidityFeeAmount >=
            maximumSwapableLiquidityAmount;
        if (!swapLiquidity && from != uniswapV2Pair) {
            swapLiquidity = true;

            if (overMaxTokenBalance) {
                if (enableFee) {
                    enableFee = false;
                    taxDisableInLiquidity = true;
                }
                uint256 contractSwapTokenBalance = _balances[address(this)];
                uint256 swapToken = contractSwapTokenBalance -
                    burnableFeeAmount;
                swapAndLiquify(swapToken);
                if (taxDisableInLiquidity) {
                    enableFee = true;
                    taxDisableInLiquidity = false;
                }
            }
            swapLiquidity = false;
        }

        if (enableFee && (from == uniswapV2Pair || to == uniswapV2Pair))
            takeFee = true;

        // it will take tax, burn and charity amount and distribute to the respective accounts
        calculateAndDistributeTotalFeeAmount(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance)
        private
        whenNotPaused
    {
        // split the contract balance into half
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;
        uint256 previousToken = contractTokenBalance;
        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        swapableLiquidityFeeAmount -= previousToken;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    // calculate and distribute Fee to the respective wallets
    function calculateAndDistributeTotalFeeAmount(
        address from,
        address to,
        uint256 amount,
        bool takeFee
    ) internal {
        if (takeFee != true) removeAllFee();
        _balances[from] -= amount;
        uint256 currentBurnFee = (amount * burnFee) / 1000;
        uint256 currentcharityFee = (amount * charityFee) / 1000;
        uint256 currentLiquidityFee = (amount * liquidityFee) / 1000;
        uint256 currentMarketingFee = (amount * marketingFee) / 1000;
        uint256 currentDeveloperFee = (amount * developerFee) / 1000;
        uint256 totalFee = currentBurnFee +
            currentcharityFee +
            currentLiquidityFee +
            currentMarketingFee +
            currentDeveloperFee;

        // fee update for each transaction
        totalBurnFeeAmount += currentBurnFee;
        totalLiquidityFeeAmount += currentLiquidityFee;
        swapableLiquidityFeeAmount += currentLiquidityFee;
        totalCharityFeeAmount += currentcharityFee;
        totalMarketingFeeAmount += currentMarketingFee;
        totalDeveloperFeeAmount += currentDeveloperFee;
        burnableFeeAmount += currentBurnFee;

        //update fee on wallets
        _balances[charityWallet] += currentcharityFee;
        _balances[marketingWallet] += currentMarketingFee;
        _balances[developerWallet] += currentDeveloperFee;
        _balances[address(this)] += currentBurnFee;
        _balances[address(this)] += currentLiquidityFee;

        _balances[to] += amount - totalFee;

        if (takeFee != true) restoreAllFee();
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */

    function mint(address account, uint256 amount)
        external
        onlyOwner
        whenNotPaused
    {
        require(account != address(0), "ERC20: mint to the zero address");
        require(
            (amount + _currentSupply) <= maximumCappedSupply,
            "Current Supply must be less than maximum capped supply"
        );

        _beforeTokenTransfer(address(0), account, amount);

        _currentSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */

    function burn(uint256 amount) public onlyOwner whenNotPaused {
        address account = address(this);
        require(account != address(0), "ERC20: burn from the zero address");
        require(
            amount <= burnableFeeAmount,
            "Amount must be less the burnable amount"
        );

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _currentSupply -= amount;

        burnableFeeAmount -= amount;

        _balances[deadAddress] += amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual whenNotPaused {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     *@dev remove all fee (i.e charity fee,burn fee,liquidity fee,developer fee,marketing fee)
     *remove all the fee and set it as previous fee
     */
    function removeAllFee() internal {
        if (
            charityFee == 0 &&
            burnFee == 0 &&
            liquidityFee == 0 &&
            developerFee == 0 &&
            marketingFee == 0
        ) return;

        previousCharityFee = charityFee;
        charityFee = 0;

        previousBurnFee = burnFee;
        burnFee = 0;

        previousLiquidityFee = liquidityFee;
        liquidityFee = 0;

        previousDeveloperFee = developerFee;
        developerFee = 0;

        previousMarketingFee = marketingFee;
        marketingFee = 0;
    }

    /**
     *@dev restore all fee (i.e charity fee,burn fee,liquidity fee,developer fee,marketing fee)
     *restore all fee from the previous fee
     */
    function restoreAllFee() internal {
        charityFee = previousCharityFee;
        burnFee = previousBurnFee;
        liquidityFee = previousLiquidityFee;
        marketingFee = previousMarketingFee;
        developerFee = previousDeveloperFee;
    }

    /**
    @dev set all the 'fee' in the same function
    *@param '_marketingFee'updates the marketingFee value,
            '_developerFee' updates the developerFee value,
            '_burnFee' updates the burnFee value,
            '_liquidityFee' updates the liquidityFee value,
            '_charityFee' updates the charityFee value
     */
    function setTaxFeePercent(
        uint256 _marketingFee,
        uint256 _developerFee,
        uint256 _burnFee,
        uint256 _liquidityFee,
        uint256 _charityFee
    ) external onlyOwner {
        marketingFee = _marketingFee;
        developerFee = _developerFee;
        burnFee = _burnFee;
        liquidityFee = _liquidityFee;
        charityFee = _charityFee;
        emit SetMarketingFeePercent(
            marketingFee,
            developerFee,
            burnFee,
            liquidityFee,
            charityFee
        );
    }

    /**
     *@dev update marketing fee percentage
     *@param '_marketingFee'updates the marketingFee value
     */
    function setMarketingFee(uint256 _marketingFee) external onlyOwner {
        marketingFee = _marketingFee;
        emit SetMarketingFeePercent(marketingFee);
    }

    /**
     *@dev update developer fee percent
     *@param '_developerFee' updates the developerFee value
     */
    function setDeveloperFee(uint256 _developerFee) external onlyOwner {
        developerFee = _developerFee;
        emit SetDeveloperFeePercent(developerFee);
    }

    /**
     *@dev update burn fee percent
     *@param '_burnFee' updates the burnFee value
     */
    function setBurnFee(uint256 _burnFee) external onlyOwner {
        burnFee = _burnFee;
        emit SetBurnFeePercent(burnFee);
    }

    /**
     *@dev update liquidity fee percent
     *@param '_liquidityFee' updates the liquidityFee value
     */
    function setLiquidityFee(uint256 _liquidityFee) external onlyOwner {
        liquidityFee = _liquidityFee;
        emit SetLiquidityFeePercent(liquidityFee);
    }

    /**
     *@dev update charity fee percent
     *@param '_charityFee' updates the charityFee value
     */
    function setCharityFee(uint256 _charityFee) external onlyOwner {
        charityFee = _charityFee;
        emit SetCharityFeePercent(charityFee);
    }

    /**
     *@dev set tax fee enable or disable
     *@param 'bool value=true or false' ,whether the enableFee is true or false
     */
    function setEnableFee(bool enableTax) external onlyOwner {
        enableFee = enableTax;
        emit FeeEnabled(enableTax);
    }

    /**
     *@dev set maximum swapable fee amount.
     *@param '_maximumSwapableLiquidityAmount' updates the maximum swapable amount
     *once the fee amount reached this limit it will call swapAndLiquify function
     */
    function setMaximumSwapableAmount(uint256 _maximumSwapableLiquidityAmount)
        external
        onlyOwner
    {
        maximumSwapableLiquidityAmount = _maximumSwapableLiquidityAmount;
        emit MaximumSwapableAmount(_maximumSwapableLiquidityAmount);
    }

    /**
     *@dev update Charity Wallet Address
     *@param '_charityWalletAddress' updates charityWallet address
     */
    function updateCharityWalletAddress(address _chrarityWalletAddress)
        external
        onlyOwner
    {
        charityWallet = _chrarityWalletAddress;
        emit updateCharityWallet(_chrarityWalletAddress);
    }

    /**
     *@dev update Developer Wallet Address
     *@param '_developerWalletAddress' updates developerWallet address
     */
    function updateDeveloperWalletAddress(address _developerWalletAddress)
        external
        onlyOwner
    {
        developerWallet = _developerWalletAddress;
        emit updateDeveloperWallet(_developerWalletAddress);
    }

    /**
     *@dev update Marketing Wallet Address
     *@param '_marketinfWalletAddress' updates marketingWallet address
     */
    function updateMarketingWalletAddress(address _marketingWalletAddress)
        external
        onlyOwner
    {
        marketingWallet = _marketingWalletAddress;
        emit updateMarketingWallet(_marketingWalletAddress);
    }

    /**

     *@dev update all Wallets Address in the same function
     *@param '_charityWalletAddress' updates charityWallet address
     *@param '_developerWalletAddress' updates developerWallet address
     *@param '_marketinfWalletAddress' updates marketingWallet address

     */
    function updateWalletsAddress(
        address _chrarityWalletAddress,
        address _developerWalletAddress,
        address _marketingWalletAddress
    ) external onlyOwner {
        charityWallet = _chrarityWalletAddress;
        developerWallet = _developerWalletAddress;
        marketingWallet = _marketingWalletAddress;
    }

    //to recieve BNB from uniswapV2Router when swaping
    receive() external payable {}

    /**
       @dev withdraw native currency from the contract address
        */
    function withdrawBNBFromContract() external onlyOwner whenNotPaused {
        uint256 nativeCrrency = address(this).balance;
        // require(amount <= address(this).balance);
        address payable _owner = payable(msg.sender);
        _owner.transfer(nativeCrrency);
    }

    /**
        @dev withdraw token from the contract address
     */
    function withdrawTokenFromContract() external onlyOwner whenNotPaused {
        uint256 contractAddressToken = _balances[address(this)];
        uint256 withdrawlAmount = contractAddressToken -
            swapableLiquidityFeeAmount -
            burnableFeeAmount;
        _balances[address(this)] -= withdrawlAmount;
        _balances[developerWallet] += withdrawlAmount;
    }

    /**
     * @dev Pause `contract` - pause events.
     *
     * See {BEP20Pausable-_pause}.
     */
    function pauseContract() external virtual onlyOwner {
        _pause();
    }

    /**
     * @dev unPause `contract` - unpause events.
     *
     * See {BEP20Pausable-_unpause}.
     */
    function unPauseContract() external virtual onlyOwner {
        _unpause();
    }
}
