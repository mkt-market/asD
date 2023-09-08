import {asDFactory} from "../contracts/asDFactory.sol";
import {DSTest} from "ds-test/test.sol";
import {DSToken} from "ds-token/token.sol";

contract MockERC20 is DSToken {
    constructor(string memory symbol, uint256 initialSupply) DSToken(symbol) public {
        mint(initialSupply);
    }

    function mint(uint256 amount) public {
        _balances[msg.sender] += amount;
        _supply += amount;
    }
}

contract asDFactoryTest is DSTest {
  
    asDFactory factory;
    MockERC20 cNOTE;

    function setUp() public {
      cNOTE = new MockERC20("cNOTE", 0);
      factory = new asDFactory(cNOTE);
    }

    function test_create_asD() public {
        address asD = factory.create_asD("Test", "TST", msg.sender, address(0x0));
        assertTrue(asD != address(0x0));
    }

    function testFail_create_asD_with_empty_name() public {
        factory.create_asD("", "TST", msg.sender, address(0x0));
    }

    function testFail_create_asD_with_empty_symbol() public {
        factory.create_asD("Test", "", msg.sender, address(0x0));
    }
}
