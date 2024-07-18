// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



contract StartPay {

    uint256 public giftLen;

    struct Gift {
        address owner;
        address payable gifter;
        string link;
        string content;
        // address claimer;
    }
    // GDAv1Forwarder.sol

    mapping (address => mapping( uint256 => Gift)) public _gifts;

    function giftUser(address _gifter, string memory _link, string memory _content) external {
        Gift storage gift = _gifts[msg.sender][giftLen];

        gift.owner = msg.sender;
        gift.gifter = payable(_gifter);
        gift.content = _content;
        gift.link = _link;
    }
    


}