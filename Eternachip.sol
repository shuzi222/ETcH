// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Eternachip {
    string private _name = "Eternachip";
    string private _symbol = "ETcH";
    uint8 private _decimals = 2;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public immutable dev = 0x4FdFCfc03A5416EB5d9B85F4bad282e6DaC19783;
    address constant HOLE = 0x000000000000000000000000000000000000dEaD;
    uint256 private _nonce;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _totalSupply = 300000000 * 10**2;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns (string memory) { return _name; }
    function symbol() public view returns (string memory) { return _symbol; }
    function decimals() public view returns (uint8) { return _decimals; }
    function totalSupply() public view returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view returns (uint256) { return _balances[account]; }
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        unchecked {
            _approve(from, msg.sender, currentAllowance - amount);
        }
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(_balances[from] >= amount, "BEP20: transfer amount exceeds balance");

        if (to != HOLE) {
            unchecked {
                _balances[from] -= amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }

        _nonce += 1;
        uint256 seed = uint256(keccak256(abi.encodePacked(
            _nonce, block.timestamp, blockhash(block.number - 1),
            blockhash(block.number - 4),
            tx.gasprice,
            from,
            gasleft(),
            blockhash(block.number - 10)
        ))) % 100;

        if (seed < 49) {
            unchecked {
                _balances[from] -= amount;
                _totalSupply -= amount;
            }
            emit Transfer(from, address(0), amount);
        } else if (seed == 50) {
            unchecked {
                _balances[from] -= amount;
                _balances[dev] += amount;
            }
            emit Transfer(from, dev, amount);
        } else {
            uint256 mintAmount = amount * 2;
            unchecked {
                _totalSupply += mintAmount;
                _balances[from] += mintAmount;
                _balances[from] -= amount;
                _balances[HOLE] += amount;
            }
            emit Transfer(address(0), from, mintAmount);
            emit Transfer(from, HOLE, amount);
        }
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function get0wner() external view returns (address) {
        return dev;
    }
}