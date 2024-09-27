// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract SocialNetworkk{
    mapping(address=>string) private statuses;
    address public owner;
    event StatusUpdated(address  user, string newStatus);

    constructor() {
        owner=msg.sender;
    }


    function setStatus(string calldata NewStatus) external{

    statuses[msg.sender]=NewStatus;
    emit StatusUpdated(msg.sender, NewStatus);

    }

    function getStatus(address user) external view returns(string memory){
        return statuses[user];
    }



}