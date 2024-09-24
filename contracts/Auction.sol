// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract Auction {
    address payable public beneficiary; //adresa user3-a
    uint public auctionEndTime;//krajnje vreme zavrsetka aukcije
    string private secretMessage; //tajna poruka, zato private modifikator pristupa
    address public highestBidder;//adresa najveceg ponudjaca ne treba pejabl jer on ne prima nista nego salje samo
    uint public highestBid; //njegova ponuda

    mapping (address=>uint) pendingReturns; //za svaku adresu apdejtujemo svotu koju je ponudjac ponudio
    bool isEnded;//true false

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amunt);

    //konstruktor za difoltne stvari uvek pravimo
    constructor(uint biddingTime,address payable beneficiaryAddress, string memory secret) {//ove odozgo samo drugacije nazovemo
        beneficiary=beneficiaryAddress;
        auctionEndTime=block.timestamp+biddingTime; // trenutno kao localdatetime(now) u javici;
        secretMessage=secret;
    }

    function bid() external payable{
        if(isEnded){
            revert("Aukcija je zavrsena!"); 
        }
        if(msg.value<=highestBid){//kada god treba da dobijemo info od nekoga ko eksterno poziva funkciju; msg.sender za adresu posiljaoca, msg.value za vrednost
            revert("Postoji trenutno veca ponuda!");
        }
        if(highestBid!=0){ //trenutna najveca ponuda
            pendingReturns[highestBidder]=highestBid;
        }
        if(msg.sender==highestBidder){ //da upamtimo ukoliko je trenutni najveci a hoce jos da ulozi nek ne ulaze 
            revert("Vec si napravio najvecu ponudu");
        }
        highestBid=msg.value;
        highestBidder=msg.sender;
        emit HighestBidIncreased(msg.sender,msg.value);

    }

    function withdraw() external returns(bool) { //transakcija je/nije uspesno izvrsena
        uint amount=pendingReturns[msg.sender]; //sta treba njemu da se vrati
        if(amount>0){
            pendingReturns[msg.sender]=0;
           bool isTransactionSuccessful= payable(msg.sender).send(amount); //da bi mogli na nji da posaljemo izvesnu sumu novca
           if(!isTransactionSuccessful){ //proverava da li je transakcija uspesna
            pendingReturns[msg.sender]=amount;
            return false;
           }
        }
        return true;
    }

    function getSecretMessage() external view returns (string memory) {
        require(isEnded,"Aukcija jos uvek traje");
        require(msg.sender==highestBidder,"Samo pobednik moze dobiti tajnu poruku");
        return secretMessage;
    }

    function auctionEnd() external{
        if(block.timestamp<auctionEndTime){
            revert("Aukcija jos uvek traje");
        }
        if(isEnded){
            revert("Aukcija se vec zavrsila");
        }
        isEnded=true;
        emit AuctionEnded(highestBidder,highestBid);
        beneficiary.transfer(highestBid);
    }

    

    
}